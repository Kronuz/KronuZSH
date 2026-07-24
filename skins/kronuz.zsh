# kronuz — the built-in KronuZSH layout, written out as a skin. Copy it into your
# ~/.zshrc.local and rearrange it: each $kz[<segment>] is a ready-made piece
# (os err info context etctl git venv jobs nl time pwd caret overwrite vim emacs).
#
# Live prompt. Line 1: error dot, user@host, ssh/container badge, etctl session, git,
# venv, jobs. Then a newline, and line 2: time, path, caret.
PROMPT_KRONUZ_PROMPT='$kz[err] $kz[info]$kz[context]$kz[etctl]$kz[git]$kz[venv]$kz[jobs]$kz[nl]$kz[time] $kz[pwd] $kz[caret] '
# Right prompt: overwrite-mode marker, then the vi / emacs keymap indicator.
PROMPT_KRONUZ_RPROMPT='$kz[overwrite]$kz[vim]$kz[emacs]'
# Collapsed scrollback line (see the scrollback post): the path, then a dimmed caret.
PROMPT_KRONUZ_TRANSIENT_PROMPT='$kz[pwd] $kz[transient_caret] '
