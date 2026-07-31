# zoxide: a smarter `cd` that learns your most-visited directories. Adds `z` (jump)
# and `zi` (interactive pick). We leave the real `cd` untouched, so AUTO_CD and plain
# `cd` keep working exactly as before.
# install: brew install zoxide · cargo install zoxide
if (( $+commands[zoxide] )); then
  _kz_zoxide_init="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/generated/zoxide.zsh"
  if [[ -r $_kz_zoxide_init ]]; then
    source "$_kz_zoxide_init"
  else
    eval "$(zoxide init zsh)"
  fi
  unset _kz_zoxide_init
fi
