# atuin: a SQLite-backed shell history with a great fuzzy search. It is the one tool
# here that *competes* with fzf for Ctrl-R: installing it means you want it, so we let
# it own Ctrl-R (the loader sources atuin after fzf, so it wins), and pass
# --disable-up-arrow to keep our Up/Down history-substring-search intact.
# install: brew install atuin · cargo install atuin
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
