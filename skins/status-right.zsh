# status-right — the built-in layout, but the exit-status / duration line moves from its
# own row above the prompt to the right-hand side of the caret line.
#
# Two pieces make it work:
#   1. KZ_PROMPT_PPROMPT='' turns off the default behaviour of printing the status on its own
#      line above the prompt, so it is not shown twice.
#   2. $kz[status] (the inline styled exit indicator + duration, empty on a clean, fast
#      command) is placed in KZ_PROMPT_RPROMPT. The right prompt renders on the caret line
#      and is redrawn every prompt, so the status shows while you decide the next command
#      and vanishes when that command runs -- a compact, live-only status that never lands
#      in scrollback (and so is inherently immune to a screen clear like iTerm2's Cmd-K).
KZ_PROMPT_PPROMPT=''
# Live prompt, unchanged from the built-in layout.
KZ_PROMPT_PROMPT='$kz[err] $kz[info]$kz[context]$kz[etctl]$kz[git]$kz[venv]$kz[jobs]$kz[nl]$kz[time] $kz[pwd] $kz[caret] '
# Right prompt: the status (with a trailing space only when present), then the usual
# overwrite-mode marker and vi / emacs keymap indicator.
KZ_PROMPT_RPROMPT='${kz[status]:+$kz[status] }$kz[overwrite]$kz[vim]$kz[emacs]'
# Collapsed scrollback line: submission time, path, then the transient caret (the status is
# gone by now).
KZ_PROMPT_TRANSIENT_PROMPT='$kz[time] $kz[pwd] $kz[transient_caret] '
