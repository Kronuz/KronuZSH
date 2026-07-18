# Small, generally useful shell functions. Machine- or tool-specific helpers
# belong in ~/.zshrc.local or the matching integration instead.

# Creates one directory (including missing parents), then enters it.
function mkdcd {
  if [[ ${1:-} == (-h|--help) ]]; then
    print 'usage: mkdcd [--] directory'
    return 0
  elif [[ ${1:-} == -- ]]; then
    shift
  fi

  (( $# == 1 )) || {
    print -u2 'usage: mkdcd [--] directory'
    return 64
  }

  command mkdir -p -- "$1" && builtin cd -- "$1"
}

# Replace zsh's default `run-help=man` alias with its context-aware function.
# Minimal zsh packages sometimes omit these files, so only autoload what exists
# and keep the plain man fallback when the main function is unavailable.
typeset -a _kronuz_run_help_files
_kronuz_run_help_files=(${^fpath}/run-help(N[1]))
unalias run-help 2>/dev/null
if (( $#_kronuz_run_help_files )); then
  autoload -Uz run-help

  for _kronuz_run_help in run-help-{git,ip,openssl,sudo}; do
    _kronuz_run_help_files=(${^fpath}/$_kronuz_run_help(N[1]))
    (( $#_kronuz_run_help_files )) && autoload -Uz "$_kronuz_run_help"
  done
  unset _kronuz_run_help
else
  function run-help { command man "$@" }
fi
unset _kronuz_run_help_files

# Integrations may register a transparent wrapper whose help should resolve to the
# wrapped external command rather than display the wrapper's implementation.
typeset -gA _kronuz_help_native

# Show local function source directly; let native run-help resolve everything else
# (builtins, aliases, reserved words, external commands, and registered wrappers).
function help {
  emulate -L zsh

  if (( $# == 1 && $+_kronuz_help_native[$1] )); then
    # A subshell makes unfunction temporary. Native run-help can then classify the
    # executable normally, including any command-specific run-help helper.
    ( unfunction "$1" 2>/dev/null; run-help "${_kronuz_help_native[$1]}" )
  elif (( $# == 1 && $+functions[$1] )); then
    local bat_command=${commands[bat]:-${commands[batcat]:-}}
    if [[ -n $bat_command ]]; then
      builtin functions "$1" |
        "$bat_command" --language=zsh --style=plain --paging=auto
    else
      local -a pager=(${(z)${PAGER:-cat}})
      builtin functions "$1" | "${pager[@]}"
    fi
  else
    run-help "$@"
  fi
}
