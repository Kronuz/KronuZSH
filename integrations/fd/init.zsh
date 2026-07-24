# fd: a faster, friendlier `find`, and the engine behind fzf's file/dir pickers.
# Debian/Ubuntu ship the binary as `fdfind` (a name clash with another package), so
# accept either. Honor .gitignore, show hidden, follow symlinks, never enter .git.
# install: brew install fd · cargo install fd-find · apt/dnf install fd-find
_kz_fd=''
(( $+commands[fd] ))     && _kz_fd=fd
(( $+commands[fdfind] )) && [[ -z $_kz_fd ]] && _kz_fd=fdfind
if [[ -n $_kz_fd ]]; then
  export FZF_DEFAULT_COMMAND="$_kz_fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_kz_fd --type d --hidden --follow --exclude .git"
fi
unset _kz_fd
