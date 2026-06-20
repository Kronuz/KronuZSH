# zoxide: a smarter `cd` that learns your most-visited directories. Adds `z` (jump)
# and `zi` (interactive pick). We leave the real `cd` untouched, so AUTO_CD and plain
# `cd` keep working exactly as before.
# install: brew install zoxide · cargo install zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
