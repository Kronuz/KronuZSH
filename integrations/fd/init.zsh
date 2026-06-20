# fd: a faster, friendlier `find`, and the engine behind fzf's file/dir pickers.
# Debian/Ubuntu ship the binary as `fdfind` (a name clash with another package), so
# accept either. Honor .gitignore, show hidden, follow symlinks, never enter .git.
# install: brew install fd · cargo install fd-find · apt/dnf install fd-find
_kronuz_fd=''
(( $+commands[fd] ))     && _kronuz_fd=fd
(( $+commands[fdfind] )) && [[ -z $_kronuz_fd ]] && _kronuz_fd=fdfind
if [[ -n $_kronuz_fd ]]; then
  export FZF_DEFAULT_COMMAND="$_kronuz_fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_kronuz_fd --type d --hidden --follow --exclude .git"
  # Kronuz file colours for fd's output (and GNU ls), via LS_COLORS — only if you
  # haven't set your own. dir blue, link green, exec orange, archives red, images gold,
  # media tan. (eza has its own theme.yml; this is for fd / ls.)
  export LS_COLORS="${LS_COLORS:-di=38;2;110;156;190:ln=38;2;165;194;97:so=38;2;202;164;115:pi=38;2;202;164;115:ex=01;38;2;204;120;51:bd=38;2;232;191;106:cd=38;2;232;191;106:or=01;38;2;218;73;57:mi=01;38;2;218;73;57:*.tar=38;2;218;73;57:*.tgz=38;2;218;73;57:*.gz=38;2;218;73;57:*.bz2=38;2;218;73;57:*.xz=38;2;218;73;57:*.zip=38;2;218;73;57:*.7z=38;2;218;73;57:*.jpg=38;2;232;191;106:*.jpeg=38;2;232;191;106:*.png=38;2;232;191;106:*.gif=38;2;232;191;106:*.svg=38;2;232;191;106:*.mp3=38;2;202;164;115:*.flac=38;2;202;164;115:*.mp4=38;2;202;164;115:*.mkv=38;2;202;164;115:*.pdf=38;2;218;73;57:*.md=38;2;165;194;97}"
fi
unset _kronuz_fd
