# History. HISTSIZE bumped to 10M (German's VM tweak, generalized).

# Force the history file rather than deferring to the system default (macOS
# /etc/zshrc presets HISTFILE=~/.zsh_history before us), so it's the same file
# on every machine and stays continuous.
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not on exit.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old event if a new one is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_NO_STORE             # Don't store the `history` command itself.
setopt HIST_NO_FUNCTIONS         # Don't store function definitions.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording.

# Don't store large (3+ line) commands — usually pasted blobs, not worth keeping.
zshaddhistory() { (( ${#${(f)1}} < 3 )) }
