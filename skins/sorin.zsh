# sorin — Zim/Prezto's bold blue path and right-aligned Git verdict.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.green]}${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.red]}✗}${kz[git.staged]:+ ${kz[FG.green]}✚}${kz[git.ahead]:+ ${kz[FG.magenta]}↑}${kz[git.behind]:+ ${kz[FG.magenta]}↓}${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[BOLD]}${kz[FG.blue]}%~${kz[RESET]} '
KZ_PROMPT_RPROMPT='${kz[venv.name]:+${kz[FG.green]}(${kz[venv.name]}) ${kz[RESET]}}${kz[FG.green]}${kz[GLYPH.caret]}${kz[RESET]}$kz[git]'
KZ_PROMPT_TRANSIENT_PROMPT=''
