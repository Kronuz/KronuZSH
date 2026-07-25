# eriner — Zim's Agnoster-family ribbon, reduced to declarative path/Git pieces.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[BG.yellow]}${kz[FG.black]}  ${kz[git.branch]}${kz[git.dirty]:+ ± }${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[BG.cyan]}${kz[FG.black]} %~ ${kz[RESET]}$kz[git]${kz[FG.cyan]}${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
