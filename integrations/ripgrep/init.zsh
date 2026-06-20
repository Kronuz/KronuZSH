# ripgrep (rg): a faster `grep` for code. Nothing to wire into the shell, but we point
# $RIPGREP_CONFIG_PATH at the bundled Kronuz colours (./config) — only if you haven't
# set your own. To use your own flags/colours, set RIPGREP_CONFIG_PATH in ~/.zshrc.local
# (it wins over this default).
# install: brew install ripgrep · cargo install ripgrep · apt/dnf install ripgrep
if (( $+commands[rg] )); then
  export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-${0:h}/config}"
fi
