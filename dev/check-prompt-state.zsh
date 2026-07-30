#!/usr/bin/env zsh
# Guard the normalized state exposed to declarative skins.
emulate -L zsh
setopt err_return

typeset -g KRONUZSH=$PWD
typeset -g KZ_PROMPT_TERMINAL_INTEGRATION=0
source runcoms/zshenv 2>/dev/null
source dev/fake-gitstatus.zsh
source lib/prompt.zsh
kz_prompt_setup
# This is a state/rendering test, not a lifecycle test. A real preexec between the
# synthetic timestamp below and _kz_duration_segment would replace that timestamp.
preexec_functions=(${preexec_functions:#_kz_duration_preexec})

[[ "${kz[context.ssh]}" == "$_kz_is_ssh" \
  && "${kz[context.container]}" == "$_kz_is_container" ]] || {
  print -u2 -r -- "session context was not exposed"
  return 1
}

function _kz_test_context_colors {
  local ssh=$1 container=$2 host_name=$3 pwd_name=$4
  local host_key="FG.$host_name" pwd_key="FG.$pwd_name"
  kz[context.ssh]=$ssh
  kz[context.container]=$container
  _kz_colors_sig=''
  kz_prompt_colors
  [[ "${_kz_sem[host]}" == "${kz[$host_key]}" \
    && "${_kz_sem[pwd]}" == "%(!.${kz[FG.tomato]}.${kz[$pwd_key]})" ]] || {
    print -u2 -r -- "wrong context colors for ssh=${ssh:-0}, container=${container:-0}"
    return 1
  }
}
_kz_test_context_colors '' '' blue aqua
_kz_test_context_colors 1 '' green mediumspringgreen
_kz_test_context_colors '' 1 purple violet
_kz_test_context_colors 1 1 purple violet

# The copyable kronuz skin must remain identical to the built-in configuration.
source skins/kronuz.zsh
[[ "$KZ_PROMPT_PROMPT" == "$DEFAULT_KZ_PROMPT_PROMPT" \
  && "$KZ_PROMPT_RPROMPT" == "$DEFAULT_KZ_PROMPT_RPROMPT" \
  && "$KZ_PROMPT_TRANSIENT_PROMPT" == "$DEFAULT_KZ_PROMPT_TRANSIENT_PROMPT" ]] || {
  print -u2 -r -- "kronuz skin layout drifted from the built-in prompt"
  return 1
}
_kz_test_context_colors '' '' blue aqua
_kz_test_context_colors 1 '' green mediumspringgreen
_kz_test_context_colors '' 1 purple violet
_kz_test_context_colors 1 1 purple violet

kz_prompt_colors
_kz_git_render

local key
for key in git.repo git.branch git.commit git.dirty git.staged git.unstaged \
  git.untracked git.stashed git.ahead; do
  [[ -n "${kz[$key]}" ]] || {
    print -u2 -r -- "$key: expected normalized fake-repository state"
    return 1
  }
done
[[ -z "${kz[git.clean]}" ]] || {
  print -u2 -r -- "git.clean: dirty repository reported clean"
  return 1
}

VCS_STATUS_NUM_STAGED=0
VCS_STATUS_NUM_UNSTAGED=0
VCS_STATUS_NUM_UNTRACKED=0
VCS_STATUS_NUM_CONFLICTED=0
VCS_STATUS_STASHES=0
VCS_STATUS_COMMITS_AHEAD=0
_kz_git_render
[[ -n "${kz[git.clean]}" && -z "${kz[git.dirty]}" ]] || {
  print -u2 -r -- "clean/dirty flags did not invert for a clean repository"
  return 1
}

VCS_STATUS_LOCAL_BRANCH=''
VCS_STATUS_TAG=''
VCS_STATUS_ACTION='rebase'
_kz_git_render
[[ -n "${kz[git.detached]}" && "${kz[git.action]}" == rebase ]] || {
  print -u2 -r -- "detached/action state was not exposed"
  return 1
}

VIRTUAL_ENV=/tmp/example-venv
_kz_venv_segment
[[ "${kz[venv.name]}" == example-venv ]] || {
  print -u2 -r -- "venv.name was not exposed"
  return 1
}

_kz_cmd_start=$(( EPOCHREALTIME - 4 ))
_kz_duration_segment
[[ -n "${kz[status.duration]}" ]] || {
  print -u2 -r -- "duration was not exposed"
  return 1
}
_kz_cmd_ran=1
_kz_prompt_last_exit=7
_kz_status_segment
[[ "${kz[status.exit]}" == 7 ]] || {
  print -u2 -r -- "status.exit was not exposed"
  return 1
}
_kz_status_segment || true
[[ -z "${kz[status.exit]}" ]] || {
  print -u2 -r -- "status.exit survived a prompt with no command"
  return 1
}

_kz_git_reset_state
for key in ${(k)kz[(I)git.*]}; do
  [[ -z "${kz[$key]}" ]] || {
    print -u2 -r -- "$key: state leaked outside a repository"
    return 1
  }
done
