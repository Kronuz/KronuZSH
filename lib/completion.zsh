# Completion. A lean version of prezto's completion module.

zmodload -i zsh/complist

# Cached compinit: only run the security check once a day.
autoload -Uz compinit
_zthin_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zthin_zcompdump:h}"
if [[ -n ${_zthin_zcompdump}(#qNmh-24) ]]; then
  compinit -C -d "$_zthin_zcompdump"   # trust the cache, skip the scan
else
  compinit -d "$_zthin_zcompdump"
  touch "$_zthin_zcompdump"
fi
unset _zthin_zcompdump

setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end on a single match.
setopt PATH_DIRS           # Complete on subcommands after a slash.
setopt AUTO_MENU           # Show completion menu on a successive tab.
setopt AUTO_LIST           # List choices on an ambiguous completion.
setopt AUTO_PARAM_SLASH    # Add a trailing slash on a directory completion.
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Free up Ctrl-S / Ctrl-Q.

# Group, colorize, and make matching case-/dash-insensitive.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
