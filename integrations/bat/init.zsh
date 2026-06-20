# bat: a `cat`/pager with syntax highlighting (Debian/Ubuntu ship it as `batcat`, a
# name clash). We don't shadow `cat` (too surprising); we use bat where it clearly
# helps: as the man pager, and as fzf's file preview (see ../fzf/init.zsh).
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
fi
unset _kronuz_bat
