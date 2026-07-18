# bat: a `cat`/pager with syntax highlighting (Debian/Ubuntu ship it as `batcat`, a
# name clash). When either name exists, it highlights simple interactive `cat file`
# viewing, powers the man pager, and backs fzf's file preview (see ../fzf/init.zsh).
# Options, stdin, and non-terminal output stay with native cat for compatibility.
# `MANROFFOPT=-c` avoids the groff/col spacing glitch. The Kronuz theme cache build
# lives in ./setup.sh; the theme files live in ../themes/ (shared with delta + yazi).
# install: brew install bat · cargo install bat · apt/dnf install bat
_kronuz_bat=''
(( $+commands[bat] ))    && _kronuz_bat=bat
(( $+commands[batcat] )) && [[ -z $_kronuz_bat ]] && _kronuz_bat=batcat
if [[ -n $_kronuz_bat ]]; then
  # Use the bundled Kronuz theme, but only once setup.sh has built bat's cache
  # (themes are read at cache-build time, not live). Guard on the cache file so we
  # never trip bat's "unknown theme" warning on a box where it wasn't built.
  [[ -f ${BAT_CACHE_PATH:-$HOME/.cache/bat}/themes.bin ]] && \
    export BAT_THEME="${BAT_THEME:-Kronuz}"
  export MANPAGER="sh -c 'col -bx | $_kronuz_bat -l man -p --paging=always'"
  export MANROFFOPT='-c'

  # Keep cat's byte-stream behavior everywhere it matters. Bat is the pretty path
  # only for option-free files written directly to a terminal; native cat handles
  # every flag (including platform-specific ones), stdin, pipes, and redirections.
  typeset -g _kronuz_bat_command="$_kronuz_bat"
  _kronuz_help_native[cat]=cat
  unalias cat 2>/dev/null
  function cat {
    local arg after_options=0
    [[ -t 1 && $# -gt 0 ]] || { command cat "$@"; return }

    for arg in "$@"; do
      if (( after_options )); then
        [[ "$arg" == - ]] && { command cat "$@"; return }
      elif [[ "$arg" == -- ]]; then
        after_options=1
      elif [[ "$arg" == -* ]]; then
        command cat "$@"
        return
      fi
    done
    for arg in "${(@)@:#--}"; do
      [[ -f "$arg" ]] || { command cat "$@"; return }
    done
    command "$_kronuz_bat_command" --style=plain --paging=never "$@"
  }
fi
unset _kronuz_bat
