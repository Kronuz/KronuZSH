# sobole — Sobole's spacious two-line path/Git and black » caret (light-mode default).
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.green]}${kz[git.branch]}${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.red]}✗${kz[RESET]}}${kz[git.clean]:+ ${kz[FG.green]}✔${kz[RESET]}}}'
KZ_PROMPT_PPROMPT=''
KZ_PROMPT_PROMPT='${VIRTUAL_ENV:+(${VIRTUAL_ENV:t}) }${kz[BOLD]}${kz[FG.blue]}%~${kz[RESET]} $kz[git]$kz[nl]${kz[FG.black]}»${kz[RESET]} '
KZ_PROMPT_RPROMPT='%(?..${kz[FG.red]}%? ⚠️${kz[RESET]})'
KZ_PROMPT_TRANSIENT_PROMPT=''
