# ys — Oh My Zsh's classic explanatory two-line prompt.
KZ_PROMPT_GIT='${kz[git.branch]:+ on${kz[FG.blue]} git:${kz[FG.cyan]}${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.red]}x}${kz[git.clean]:+ ${kz[FG.green]}o}${kz[RESET]}}'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='$kz[nl]${kz[BOLD]}${kz[FG.blue]}#${kz[RESET]} %(!.${kz[BG.yellow]}${kz[FG.black]}.${kz[FG.cyan]})%n${kz[RESET]} @ ${kz[FG.green]}%m ${kz[RESET]}in ${kz[BOLD]}${kz[FG.yellow]}%~${kz[RESET]}$kz[git]${kz[venv.name]:+ ${kz[FG.green]}${kz[venv.name]} ${kz[RESET]}%} [%*] %(?..C:${kz[FG.red]}%?${kz[RESET]})$kz[nl]${kz[BOLD]}${kz[FG.red]}$ ${kz[RESET]}'
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
