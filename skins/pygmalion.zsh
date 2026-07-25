# pygmalion — Oh My Zsh's high-voltage user@host:path Git prompt.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.green]}${kz[git.branch]}${kz[git.dirty]:+${kz[FG.yellow]}⚡}${kz[RESET]} }'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='${kz[FG.magenta]}%n${kz[FG.cyan]}@${kz[FG.yellow]}%m${kz[FG.red]}:${kz[FG.cyan]}%0~${kz[FG.red]}|${kz[RESET]}$kz[git]${kz[FG.cyan]}⇒${kz[RESET]}  '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
