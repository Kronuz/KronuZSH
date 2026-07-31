# fzf: the fuzzy finder. The modern one-shot integration (`fzf --zsh`, fzf >= 0.48)
# adds Ctrl-T (paste a file path), Ctrl-R (search history), and Alt-C (cd into a
# chosen dir). It uses fd for its file/dir lists (see ../fd/init.zsh) and bat for the
# file preview (detected below). The --color flags are the Kronuz palette.
# install: brew install fzf · apt/dnf install fzf · else the prebuilt binary from
# https://github.com/junegunn/fzf/releases into ~/.local/bin (it's Go, not Rust).
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=fg:-1,bg:-1,hl:#cc7833,fg+:#e8e6e5,bg+:#454545,hl+:#fd971f,info:#95815e,border:#676867,prompt:#a5c261,pointer:#da4939,marker:#219186,spinner:#caa473,header:#6089b4'
  # bat (or batcat) makes the Ctrl-T file preview colourful; skip it if absent.
  _kz_bat=''
  (( $+commands[bat] ))    && _kz_bat=bat
  (( $+commands[batcat] )) && [[ -z $_kz_bat ]] && _kz_bat=batcat
  [[ -n $_kz_bat ]] && \
    export FZF_CTRL_T_OPTS="--preview '$_kz_bat -n --color=always --line-range :200 {}'"
  unset _kz_bat
  _kz_fzf_init="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/generated/fzf.zsh"
  if [[ -r $_kz_fzf_init ]]; then
    source "$_kz_fzf_init"
  else
    source <(fzf --zsh)
  fi
  unset _kz_fzf_init
fi
