# kronuz — the built-in KronuZSH configuration, written out as a skin. Copy it into your
# ~/.zshrc.local and rearrange it: each $kz[<segment>] is a ready-made piece
# (os status_dot identity context etctl git venv jobs NL time pwd caret caret_past
# mode_overwrite vim emacs).
#
# Live prompt. Line 1: error dot, user@host, ssh/container badge, etctl session, git,
# venv, jobs. Then a newline, and line 2: time, path, caret.
KZ_PROMPT_PROMPT='$kz[status_dot] $kz[identity]$kz[context]$kz[etctl]$kz[git]$kz[venv]$kz[jobs]$kz[NL]$kz[time] $kz[pwd] $kz[caret] '
# Right prompt: overwrite-mode marker, then the vi / emacs keymap indicator.
KZ_PROMPT_RPROMPT='$kz[mode_overwrite]$kz[vim]$kz[emacs]'
# Collapsed scrollback line: submission time, path, then the past caret.
KZ_PROMPT_TRANSIENT_PROMPT='$kz[time] $kz[pwd] $kz[caret_past] '
# Local shells use blue/aqua, SSH uses green, and containers take precedence with
# purple/violet. A root shell keeps the path red in every context.
KZ_PROMPT_COLOR_HOST='${${kz[context.container]:+${kz[FG.purple]}}:-${${kz[context.ssh]:+${kz[FG.green]}}:-${kz[FG.blue]}}}'
KZ_PROMPT_COLOR_PWD='%(!.${kz[FG.tomato]}.${${kz[context.container]:+${kz[FG.violet]}}:-${${kz[context.ssh]:+${kz[FG.mediumspringgreen]}}:-${kz[FG.aqua]}}})'
