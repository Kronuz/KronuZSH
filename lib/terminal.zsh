# terminal.zsh: set the window and tab titles (zsh-native, replaces prezto's terminal module).

if [[ "$TERM" == (xterm*|rxvt*|screen*|tmux*|alacritty*|wezterm*|vte*|konsole*) ]]; then
  autoload -Uz add-zsh-hook

  # Two titles: the window (OSC 2) gets the long form, the tab (OSC 1) a short
  # one (prezto set both; we only set the window before, so tabs never updated).

  # Idle, before each prompt: user@host:cwd in the window, just the cwd in the tab.
  function _kronuz_title_precmd {
    print -Pn '\e]2;%n@%m: %~\a'
    print -Pn '\e]1;%~\a'
  }
  # Running a command: the full command in the window, its name in the tab
  # (the first word's basename, so `git status` -> `git`, `/usr/bin/vim f` -> `vim`).
  function _kronuz_title_preexec {
    print -Pn '\e]2;'; print -rn -- "${(V)1}"; print -Pn '\a'
    print -Pn '\e]1;'; print -rn -- "${1[(w)1]:t}"; print -Pn '\a'
  }

  add-zsh-hook precmd  _kronuz_title_precmd
  add-zsh-hook preexec _kronuz_title_preexec
fi
