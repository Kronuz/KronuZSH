# spaceship — Spaceship's familiar two-line directory/context/Git layout.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.blue]}on ${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.red]}✗}${kz[git.staged]:+ ${kz[FG.green]}✚}${kz[git.ahead]:+ ⇡}${kz[git.behind]:+ ⇣}${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[FG.cyan]}➜ ${kz[FG.green]}%~${kz[RESET]}$kz[git]${kz[venv.name]:+ ${kz[FG.yellow]}via ${kz[venv.name]}${kz[RESET]}}$kz[nl]${kz[FG.green]}❯${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT='${kz[FG.green]}%~${kz[RESET]} ${kz[FG.green]}❯${kz[RESET]} '
