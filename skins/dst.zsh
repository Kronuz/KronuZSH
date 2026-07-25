# dst — Oh My Zsh's failure banner, user/host/path, clock RPROMPT.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.green]}${kz[git.branch]}${kz[git.dirty]:+${kz[FG.red]}!}${kz[RESET]}}'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='%(?..${kz[FG.red]}FAIL${kz[RESET]}$kz[nl])$kz[nl]${kz[FG.magenta]}%n${kz[RESET]}@${kz[FG.yellow]}%m${kz[RESET]}: ${kz[BOLD]}${kz[FG.blue]}%~${kz[RESET]}$kz[git]$kz[nl]%(!.${kz[FG.red]}#${kz[RESET]}.$) '
KZ_PROMPT_RPROMPT='${kz[FG.green]}[%*]${kz[RESET]}'
KZ_PROMPT_TRANSIENT_PROMPT=''
