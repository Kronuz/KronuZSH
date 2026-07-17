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

# One front door for help: zsh constructs need run-help's shell awareness;
# external commands get tealdeer's concise examples first when it is installed.
# A missing tldr page quietly falls through to the authoritative manual.
function help {
  emulate -L zsh

  local usage='usage: help [-m|--man|-t|--tldr] command [subcommand ...]'
  local mode=auto page word
  local -a words
  integer i

  case ${1:-} in
    (-h|--help) print -r -- "$usage"; return 0 ;;
    (-m|--man)  mode=man;  shift ;;
    (-t|--tldr) mode=tldr; shift ;;
    (--) shift ;;
    (-*) print -u2 -r -- "$usage"; return 64 ;;
  esac

  (( $# )) || { print -u2 -r -- "$usage"; return 64; }

  if [[ $mode == man ]]; then
    run-help "$@"
    return
  fi

  # tldr subcommand pages use hyphens (for example, git-commit). Options are
  # not part of a page name, so stop collecting words at the first one.
  for word in "$@"; do
    [[ $word == -* ]] && break
    words+=("$word")
  done
  page=${(j:-:)words}

  if [[ $mode == tldr ]]; then
    if (( $+commands[tldr] || $+functions[tldr] )); then
      tldr "$page"
    else
      print -u2 'help: tldr is not installed'
      return 127
    fi
    return
  fi

  # Builtins, reserved words, and shell functions have zsh-specific semantics.
  if (( $+builtins[$1] || $+reswords[$1] || $+functions[$1] )); then
    run-help "$@"
    return
  fi

  if (( $+commands[tldr] || $+functions[tldr] )); then
    # Try the most specific subcommand page, then successively broader pages.
    # Suppress lookup errors only in automatic mode; `help -t` shows them.
    for (( i = $#words; i >= 1; --i )); do
      page=${(j:-:)words[1,i]}
      tldr "$page" 2>/dev/null && return 0
    done
  fi

  run-help "$@"
}
