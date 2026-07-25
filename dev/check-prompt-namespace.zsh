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
