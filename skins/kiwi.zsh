# kiwi — Oh My Zsh's framed "kiwish" prompt.
KZ_PROMPT_GIT='${kz[git.branch]:+[${kz[FG.white]}git:${kz[BOLD]}${kz[git.branch]}${kz[BOLD]}${kz[FG.green]}]-}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='${kz[BOLD]}${kz[FG.green]}┌[${kz[FG.cyan]}kiwish-4.2${kz[FG.green]}]-(${kz[FG.white]}%2~${kz[FG.green]})-$kz[git]$kz[NL]└> % ${kz[RESET]}'
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
