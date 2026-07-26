#!/usr/bin/env zsh
# Exercise automatic .venv discovery, switching, restoration, and ownership.
emulate -L zsh
setopt err_return nounset pipe_fail

local original=$PWD
local sandbox
sandbox=$(mktemp -d "${TMPDIR:-/tmp}/kronuz-auto-venv.XXXXXX")

function _kz_test_cleanup {
  builtin cd "$original"
  command rm -rf -- "$sandbox"
}
trap _kz_test_cleanup EXIT HUP INT TERM

function _kz_test_fail {
  print -u2 -r -- "$1"
  return 1
}

function _kz_test_make_venv {
  local root=$1
  command mkdir -p "$root/.venv/bin"
  print -r -- '
typeset -g _KZ_TEST_OLD_PATH=$PATH
export VIRTUAL_ENV=${${(%):-%x}:A:h:h}
export PATH="$VIRTUAL_ENV/bin:$PATH"
export VIRTUAL_ENV_PROMPT=.venv
if [[ -z "${VIRTUAL_ENV_DISABLE_PROMPT-}" ]]; then
  typeset -g _KZ_TEST_OLD_PROMPT=${PROMPT-}
  PROMPT="(.venv) ${PROMPT-}"
fi
function deactivate {
  export PATH=$_KZ_TEST_OLD_PATH
  if (( ${+_KZ_TEST_OLD_PROMPT} )); then
    PROMPT=$_KZ_TEST_OLD_PROMPT
    unset _KZ_TEST_OLD_PROMPT
  fi
  unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT _KZ_TEST_OLD_PATH
  unfunction deactivate
}
' > "$root/.venv/bin/activate"
}

local project="$sandbox/project"
local nested="$project/nested"
local outside="$sandbox/outside"
command mkdir -p "$project/sub" "$project/sibling" "$nested/deep" "$outside"
_kz_test_make_venv "$project"
_kz_test_make_venv "$nested"

# Start outside the checkout so a .venv in $HOME or another parent cannot become
# part of the test baseline.
builtin cd "$outside"
unset VIRTUAL_ENV_DISABLE_PROMPT
source "$original/lib/python.zsh"
_kz_python_venv_setup

local baseline_path=$PATH
local baseline_prompt=${PROMPT-}
local parent_venv="${project:A}/.venv"
local nested_venv="${nested:A}/.venv"

builtin cd "$project/sub"
[[ "${VIRTUAL_ENV:-}" == "$parent_venv" \
  && "$_kz_managed_venv" == "$parent_venv" \
  && "$PATH" == "$parent_venv/bin:"* \
  && "${PROMPT-}" == "$baseline_prompt" \
  && "${VIRTUAL_ENV_PROMPT:-}" == .venv ]] \
  || _kz_test_fail "nearest parent .venv was not activated"

# Re-sourcing KronuZSH must preserve ownership and not duplicate the chpwd hook.
source "$original/lib/python.zsh"
_kz_python_venv_setup
local -a managed_hooks=(${(M)chpwd_functions:#_kz_python_venv_update})
[[ "$_kz_managed_venv" == "$parent_venv" && $#managed_hooks -eq 1 ]] \
  || _kz_test_fail "re-sourcing lost ownership or duplicated the chpwd hook"

# Disabling the integration live removes its hook and restores its environment.
KZ_AUTO_VENV=off
_kz_python_venv_setup
managed_hooks=()
(( ${+chpwd_functions} )) \
  && managed_hooks=(${(M)chpwd_functions:#_kz_python_venv_update})
[[ -z "${VIRTUAL_ENV:-}" && -z "$_kz_managed_venv" \
  && $#managed_hooks -eq 0 && "$PATH" == "$baseline_path" ]] \
  || _kz_test_fail "disabling did not remove the hook and restore its environment"
unset KZ_AUTO_VENV
_kz_python_venv_setup
[[ "${VIRTUAL_ENV:-}" == "$parent_venv" && "$_kz_managed_venv" == "$parent_venv" ]] \
  || _kz_test_fail "re-enabling did not scan the current directory"

builtin cd "$project/sibling"
[[ "${VIRTUAL_ENV:-}" == "$parent_venv" && "$_kz_managed_venv" == "$parent_venv" ]] \
  || _kz_test_fail "the project .venv did not survive a sibling directory change"

builtin cd "$nested/deep"
[[ "${VIRTUAL_ENV:-}" == "$nested_venv" \
  && "$_kz_managed_venv" == "$nested_venv" \
  && "$PATH" == "$nested_venv/bin:"* \
  && "$PATH" != *"$parent_venv/bin"* ]] \
  || _kz_test_fail "a nearer nested .venv did not replace the parent environment"

builtin cd "$project/sub"
[[ "${VIRTUAL_ENV:-}" == "$parent_venv" && "$PATH" != *"$nested_venv/bin"* ]] \
  || _kz_test_fail "leaving a nested project did not restore its parent .venv"

builtin cd "$outside"
[[ -z "${VIRTUAL_ENV:-}" && -z "$_kz_managed_venv" && "$PATH" == "$baseline_path" ]] \
  || _kz_test_fail "leaving the project did not restore the original shell state"

# An explicitly empty override restores virtualenv's stock prompt prefix.
VIRTUAL_ENV_DISABLE_PROMPT=''
builtin cd "$project/sub"
[[ "${PROMPT-}" == "(.venv) $baseline_prompt" \
  && "${VIRTUAL_ENV_PROMPT:-}" == .venv ]] \
  || _kz_test_fail "empty prompt override did not restore virtualenv's prefix"
builtin cd "$outside"
[[ "${PROMPT-}" == "$baseline_prompt" && -z "${VIRTUAL_ENV_PROMPT:-}" ]] \
  || _kz_test_fail "deactivation did not restore the prompt"
VIRTUAL_ENV_DISABLE_PROMPT=1

# An environment that existed before the hook took ownership always wins.
typeset -gi _kz_test_manual_deactivations=0
export VIRTUAL_ENV="$sandbox/manual"
function deactivate {
  (( ++_kz_test_manual_deactivations ))
  unset VIRTUAL_ENV
}
builtin cd "$project/sub"
builtin cd "$outside"
[[ "$VIRTUAL_ENV" == "$sandbox/manual" \
  && -z "$_kz_managed_venv" \
  && $_kz_test_manual_deactivations -eq 0 ]] \
  || _kz_test_fail "a manually activated environment was modified"
unfunction deactivate
unset VIRTUAL_ENV

# If the user replaces an environment that the hook activated, relinquish ownership
# without invoking the old deactivate function against the new environment.
builtin cd "$project/sub"
[[ "$_kz_managed_venv" == "$parent_venv" ]] \
  || _kz_test_fail "managed environment was not reactivated"
deactivate
export VIRTUAL_ENV="$sandbox/replacement"
function deactivate {
  (( ++_kz_test_manual_deactivations ))
  unset VIRTUAL_ENV
}
builtin cd "$project/sibling"
builtin cd "$outside"
[[ "$VIRTUAL_ENV" == "$sandbox/replacement" \
  && -z "$_kz_managed_venv" \
  && $_kz_test_manual_deactivations -eq 0 ]] \
  || _kz_test_fail "ownership was not relinquished after manual replacement"
unfunction deactivate
unset VIRTUAL_ENV

# If another tool removes deactivate without replacing VIRTUAL_ENV, fail safe: leave
# that environment alone, relinquish ownership, and keep chpwd successful.
builtin cd "$project/sub"
unfunction deactivate
builtin cd "$outside" \
  || _kz_test_fail "a missing deactivate function made directory changes fail"
[[ "$VIRTUAL_ENV" == "$parent_venv" && -z "$_kz_managed_venv" ]] \
  || _kz_test_fail "missing deactivate did not relinquish ownership safely"
export PATH=$baseline_path
unset VIRTUAL_ENV _KZ_TEST_OLD_PATH

# The machine-local opt-out prevents both the initial scan and hook registration.
(
  chpwd_functions=()
  _kz_managed_venv=''
  builtin cd "$project/sub"
  KZ_AUTO_VENV=off
  _kz_python_venv_setup
  local -a disabled_hooks=()
  (( ${+chpwd_functions} )) \
    && disabled_hooks=(${(M)chpwd_functions:#_kz_python_venv_update})
  [[ -z "${VIRTUAL_ENV:-}" && $#disabled_hooks -eq 0 ]]
) || _kz_test_fail "KZ_AUTO_VENV=off did not disable automatic activation"

print "automatic Python .venv checks passed"
