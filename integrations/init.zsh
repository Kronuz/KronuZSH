# integrations/init.zsh — wire up optional external CLI tools. Each tool's runtime
# config is its own integrations/<tool>/init.zsh, guarded internally on the command
# existing, and sourced explicitly below — like lib/ and the plugins — so the load
# order is right there to read. Most tools are independent; the one that isn't: atuin
# must bind Ctrl-R *after* fzf. To add a tool, drop in its dir and add a line here; to
# remove one, delete both. (The install-time half, setup.sh, globs instead, since
# install order is independent.)
#
# Sourced by runcoms/zshrc after lib/keybindings + lib/plugins, so fzf's Ctrl-R wins
# and the widgets layer over the plugins. PATH timing: a tool's bin dir must be on
# PATH before .zshrc runs — put that in ~/.profile, not ~/.zshrc.local (Integrations.md).
#
# Tools that need no shell wiring (lazygit, hyperfine, jq/yq, dust, duf, btop, procs,
# tokei, sd, tldr, xh) aren't here — see Integrations.md for the full catalog.
source "$KRONUZSH/integrations/fd/init.zsh"
source "$KRONUZSH/integrations/bat/init.zsh"
source "$KRONUZSH/integrations/fzf/init.zsh"
source "$KRONUZSH/integrations/zoxide/init.zsh"
source "$KRONUZSH/integrations/atuin/init.zsh"   # after fzf, so atuin owns Ctrl-R
source "$KRONUZSH/integrations/eza/init.zsh"
source "$KRONUZSH/integrations/yazi/init.zsh"
source "$KRONUZSH/integrations/ripgrep/init.zsh"
source "$KRONUZSH/integrations/glow/init.zsh"
