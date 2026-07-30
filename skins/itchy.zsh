# itchy — Oh My Zsh's user/path over a happy-or-sad face, with Git at right.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.red]}✗}${kz[git.clean]:+ ${kz[FG.green]}✔}${kz[RESET]}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='${kz[FG.cyan]}%n@%m${kz[RESET]} ${kz[FG.yellow]}%~${kz[RESET]}$kz[NL]%(?.${kz[FG.green]}☺.${kz[FG.red]}☹)${kz[RESET]}  '
KZ_PROMPT_RPROMPT='$kz[git]'
KZ_PROMPT_TRANSIENT_PROMPT=''
