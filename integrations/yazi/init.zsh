# yazi: a fast terminal file manager. `y` opens it and cd's to wherever you quit
# (yazi's official shell wrapper); plain `yazi` still works without the cd.
# install: brew install yazi · cargo install --locked yazi-fm yazi-cli · or the
# prebuilt binary from https://github.com/sxyazi/yazi/releases into ~/.local/bin.
if (( $+commands[yazi] )); then
  function y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi
