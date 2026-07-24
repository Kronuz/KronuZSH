# kronuz — the built-in KronuZSH layout, written out as a skin. Copy it into your
# ~/.zshrc.local and rearrange it: each $kronuz[<segment>] is a ready-made piece
# (os err info context etctl git venv jobs nl time pwd caret overwrite vim emacs).
#
# Live prompt. Line 1: error dot, user@host, ssh/container badge, etctl session, git,
# venv, jobs. Then a newline, and line 2: time, path, caret.
PROMPT_KRONUZ_PROMPT='$kronuz[err] $kronuz[info]$kronuz[context]$kronuz[etctl]$kronuz[git]$kronuz[venv]$kronuz[jobs]$kronuz[nl]$kronuz[time] $kronuz[pwd] $kronuz[caret] '
# Right prompt: overwrite-mode marker, then the vi / emacs keymap indicator.
PROMPT_KRONUZ_RPROMPT='$kronuz[overwrite]$kronuz[vim]$kronuz[emacs]'
# Collapsed scrollback line (see the scrollback post): the path, then a dimmed caret.
PROMPT_KRONUZ_TRANSIENT_PROMPT='$kronuz[pwd] $kronuz[transient_caret] '
