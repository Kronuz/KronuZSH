# cloud — Oh My Zsh's cyan cloud prompt.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.green]}[${kz[FG.cyan]}${kz[git.branch]}${kz[FG.green]}]${kz[git.dirty]:+ ${kz[FG.yellow]}⚡ }${kz[RESET]}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='${kz[BOLD]}${kz[FG.cyan]}☁  ${kz[FG.green]}%c ${kz[FG.cyan]}$kz[git]${kz[BOLD]}${kz[FG.blue]} % ${kz[RESET]}'
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
