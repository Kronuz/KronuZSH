# Plugins. All vendored as git submodules under plugins/.
# Load order matters: gitstatus (for the prompt) first, autosuggestions and
# history-substring-search next, fast-syntax-highlighting LAST.

# gitstatus: a fast git status daemon (powers the prompt's git segment).
# gitstatus_start launches a 'KRONUZ' daemon; the prompt queries it per precmd.
source "$KRONUZSH/plugins/gitstatus/gitstatus.plugin.zsh"
gitstatus_start -s -1 -u -1 -c -1 -d -1 KRONUZ 2>/dev/null

# zsh-autosuggestions: fish-style suggestions from history. Dim grey (Kronuz) so the
# ghost suggestion sits behind what you're typing. The plugin stack is fixed and fsh
# loads last, so bind once on the first precmd instead of rescanning every widget after
# every Enter (the upstream automatic mode costs roughly 15ms per prompt here).
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#676867'
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source "$KRONUZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# history-substring-search: type a fragment, press Up to match in history. Kronuz
# match colors echo the delta diff tints: a green wash when found, red when not.
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#26331a,fg=#e8e6e5,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#3a1d1d,fg=#e8e6e5,bold'
source "$KRONUZSH/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down

# fast-syntax-highlighting: MUST be sourced last (it wraps ZLE widgets).
source "$KRONUZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
