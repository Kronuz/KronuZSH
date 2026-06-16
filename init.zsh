# kronuzsh: a lean, prezto-free zsh setup.
# Entry point. Point your ~/.zshrc at this file:
#   source ~/Development/kronuzsh/init.zsh
#
# Author: Germán Méndez Bravo (Kronuz) <german.mb@gmail.com>

# Resolve this repo's directory regardless of how we were sourced.
KRONUZSH="${KRONUZSH:-${${(%):-%x}:A:h}}"
export KRONUZSH

source "$KRONUZSH/env.zsh"
source "$KRONUZSH/options.zsh"
source "$KRONUZSH/history.zsh"
source "$KRONUZSH/completion.zsh"
source "$KRONUZSH/keybindings.zsh"
source "$KRONUZSH/aliases.zsh"
source "$KRONUZSH/terminal.zsh"
source "$KRONUZSH/plugins.zsh"
source "$KRONUZSH/prompt.zsh"
prompt_kronuz_setup

# Machine-local, non-public config (tool hooks, corp URLs, PATH tweaks).
# Tracked example: local.zsh.example. Real file is git-ignored.
[[ -r "$KRONUZSH/local.zsh" ]] && source "$KRONUZSH/local.zsh"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
