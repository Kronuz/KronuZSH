# Plugins. All vendored as git submodules under plugins/.
# Load order matters: gitstatus (for the prompt) first, autosuggestions and
# history-substring-search next, fast-syntax-highlighting LAST.

# gitstatus: a fast git status daemon (powers the prompt's git segment).
# gitstatus_start launches a 'KRONUZ' daemon; the prompt queries it per precmd.
source "$KRONUZSH/plugins/gitstatus/gitstatus.plugin.zsh"
gitstatus_start -s -1 -u -1 -c -1 -d -1 KRONUZ 2>/dev/null

# zsh-autosuggestions: fish-style suggestions from history.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source "$KRONUZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# history-substring-search: type a fragment, press Up to match in history.
source "$KRONUZSH/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down

# fast-syntax-highlighting: MUST be sourced last (it wraps ZLE widgets).
source "$KRONUZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
