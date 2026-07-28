#!/usr/bin/env zsh
# Guard the prompt's public/private variable boundary.
emulate -L zsh
setopt err_return

# Simulate re-sourcing over a shell that loaded the pre-$kz prompt.
typeset -gA col=(aqua '#00afff')
typeset -gA _col_base=(legacy yes)
typeset -gA _ksem=(legacy yes)
typeset -gA glyph_pad=(legacy yes)

source lib/prompt.zsh

local name
for name in col _col_base _ksem glyph_pad; do
  if (( ${+parameters[$name]} )); then
    print -u2 -r -- "$name: legacy prompt variable leaked globally"
    return 1
  fi
done

# An old raw-palette reference must disappear cleanly, never print its hex code.
KZ_PROMPT_COLOR_HOST='$col[aqua]'
kz_prompt_colors
[[ -z ${_kz_sem[host]} ]] || {
  print -u2 -r -- "legacy \$col reference rendered as: ${_kz_sem[host]}"
  return 1
}

# The supported public path must still accept new hues.
KZ_PROMPT_PALETTE_OCEAN='#123456'
kz_prompt_colors
[[ ${kz[FG.ocean]} == '%F{#123456}' ]] || {
  print -u2 -r -- "public palette handle is wrong: ${kz[FG.ocean]-<unset>}"
  return 1
}

# Reset through the public skin command. Every present and future prompt override
# must disappear, while settings outside the KZ_PROMPT_* namespace survive.
typeset -g KRONUZSH=$PWD
KZ_PROMPT_FUTURE_OPTION=must-disappear
KZ_PROMPT_TERMINAL_INTEGRATION=0
KZ_AUTO_VENV=off
_kz_pal_loaded=1
kz_skin reset
local -a prompt_overrides=(${(k)parameters[(I)KZ_PROMPT_*]})
(( $#prompt_overrides == 0 )) || {
  print -u2 -r -- "prompt overrides survived reset: ${prompt_overrides[*]}"
  return 1
}
[[ $KZ_AUTO_VENV == off ]] || {
  print -u2 -r -- "reset removed an unrelated KZ_* setting"
  return 1
}
(( _kz_pal_loaded == 0 )) || {
  print -u2 -r -- "reset left the transient palette cache armed"
  return 1
}
kz_skin reset || {
  print -u2 -r -- "reset was not idempotent"
  return 1
}
