# terminal.zsh: set the window/tab title (zsh-native, replaces prezto's terminal module).

if [[ "$TERM" == (xterm*|rxvt*|screen*|tmux*|alacritty*|wezterm*|vte*|konsole*) ]]; then
  autoload -Uz add-zsh-hook

  # Idle: show user@host:cwd.
  function _kronuz_title_precmd { print -Pn '\e]2;%n@%m: %~\a' }
  # Running a command: show it.
  function _kronuz_title_preexec { print -Pn '\e]2;'; print -rn -- "${(q)1}"; print -Pn '\a' }

  add-zsh-hook precmd  _kronuz_title_precmd
  add-zsh-hook preexec _kronuz_title_preexec
fi
