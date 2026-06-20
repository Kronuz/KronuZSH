# glow: render Markdown in the terminal. Point $GLAMOUR_STYLE at the bundled Kronuz
# style (./kronuz.json) — only if you haven't set your own. Set GLAMOUR_STYLE in
# ~/.zshrc.local (a built-in name like "dark", or your own JSON) to override.
# install: brew install glow · or the prebuilt binary from
# https://github.com/charmbracelet/glow/releases into ~/.local/bin (it's Go).
if (( $+commands[glow] )); then
  export GLAMOUR_STYLE="${GLAMOUR_STYLE:-${0:h}/kronuz.json}"
fi
