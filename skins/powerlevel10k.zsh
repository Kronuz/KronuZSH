# powerlevel10k — the compact classic two-line p10k shape (declarative core).
KZ_PROMPT_GIT='${kz[git.branch]:+ on ${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.yellow]}✘}${kz[git.ahead]:+ ${kz[FG.cyan]}⇡}${kz[git.behind]:+ ${kz[FG.cyan]}⇣}}'
KZ_PROMPT_PROMPT='${kz[FG.blue]}%~${kz[RESET]}$kz[git]$kz[nl]%(?.${kz[FG.green]}.%F{red})${kz[GLYPH.caret]} '
KZ_PROMPT_RPROMPT='${kz[venv.name]:+${kz[FG.green]}(${kz[venv.name]})${kz[RESET]} }%*'
KZ_PROMPT_TRANSIENT_PROMPT='${kz[FG.blue]}%~${kz[RESET]} %(?.${kz[FG.green]}.%F{red})${kz[GLYPH.caret]} '
