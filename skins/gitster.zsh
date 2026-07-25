# gitster — Zim's compact arrow, path, and Git verdict.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.white]}${kz[git.branch]}${kz[git.commit]:+ ${kz[git.commit]}}${kz[git.clean]:+ ${kz[FG.green]}✓}${kz[git.dirty]:+ ${kz[FG.yellow]}✗}${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[FG.green]}➜ ${kz[RESET]}%~ $kz[git] '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
