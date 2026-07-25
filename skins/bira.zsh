# bira — Oh My Zsh's rounded two-line user/path/Git prompt.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.yellow]}‹${kz[git.branch]}${kz[git.dirty]:+${kz[FG.red]}●${kz[FG.yellow]}}› ${kz[RESET]}}'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='╭─${kz[BOLD]}${kz[FG.green]}%n@%m${kz[RESET]} ${kz[BOLD]}${kz[FG.blue]}%~ ${kz[RESET]}$kz[git]${kz[venv.name]:+${kz[FG.green]}‹${kz[venv.name]}› ${kz[RESET]}}$kz[nl]╰─${kz[BOLD]}%(!.#.$)${kz[RESET]} '
KZ_PROMPT_RPROMPT='%(?..${kz[BOLD]}${kz[FG.red]}%? ↵${kz[RESET]})'
KZ_PROMPT_TRANSIENT_PROMPT=''
