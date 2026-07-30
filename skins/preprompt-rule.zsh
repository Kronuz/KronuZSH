# preprompt-rule — the built-in prompt, plus a full-width horizontal rule above every
# command that doubles as the exit-status signal: muted normally, red when the last
# command failed. It makes scrollback scannable (each command is visibly separated) and
# failures jump out — you can scroll back and spot the red rules.
#
# This is a showcase of KZ_PROMPT_PPROMPT, the preprompt knob: its value (composed from
# $kz[...] like PROMPT) is printed as output on its own row above the prompt, once per
# command. Here it replaces the default ($kz[status]) with a rule whose colour is chosen
# by whether $kz[status] is set (i.e. the last command failed or was slow):
#   ${${kz[status]:+RED}:-MUTED}  red when there is a status, muted otherwise
# ${(pl:$COLUMNS::─:)} left-pads an empty string to the terminal width with ─, so the rule
# always spans the screen. It is pure parameter expansion (no subshell) and blanks safely
# under NO_COLOR. Use $kz[FG.name] inside the ${..:+..}/${..:-..} conditionals, never a
# literal %F{...} (a bare } would end the conditional early).
KZ_PROMPT_PPROMPT='${${kz[status]:+${kz[FG.red]}}:-${kz[FG.muted]}}${(pl:$COLUMNS::─:)}${kz[RESET]}'
