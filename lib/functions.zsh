# Small, generally useful shell functions. Machine- or tool-specific helpers
# belong in ~/.zshrc.local or the matching integration instead.

# Creates one directory (including missing parents), then enters it.
function mkdcd {
  (( $# == 1 )) || {
    print -u2 'usage: mkdcd directory'
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

# Show local function source directly; let native run-help resolve everything
# else (builtins, aliases, reserved words, and external commands).
function help {
  emulate -L zsh

  if (( $# == 1 && $+functions[$1] )); then
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
