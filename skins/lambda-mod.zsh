# lambda-mod — Lambda Mod's two-line user/path/Git prompt. The original commit SHA
# RPROMPT has no normalized state handle, so it is intentionally empty.
KZ_PROMPT_GIT='${kz[git.branch]:+ at ${kz[FG.blue]} ${kz[git.branch]}${kz[RESET]}${kz[git.dirty]:+ ${kz[git.staged]:+${kz[BOLD]}${kz[FG.green]}+}${kz[git.unstaged]:+${kz[BOLD]}${kz[FG.blue]}!}${kz[git.conflicted]:+${kz[BOLD]}${kz[FG.yellow]}#}${kz[git.untracked]:+${kz[BOLD]}${kz[FG.cyan]}?}${kz[RESET]}}${kz[git.clean]:+ ${kz[BOLD]}${kz[FG.green]}✔${kz[RESET]}}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='$kz[NL]%(?.${kz[BOLD]}${kz[FG.green]}.${kz[BOLD]}${kz[FG.red]})λ${kz[RESET]} ${kz[BOLD]}${kz[FG.yellow]}%n${kz[RESET]} ${kz[FG.magenta]}[%3~]${kz[RESET]}$kz[git]$kz[NL]${kz[BOLD]}${kz[FG.cyan]}→${kz[RESET]} '
KZ_PROMPT_RPROMPT='${kz[git.repo]:+ ${kz[BOLD]}${kz[FG.white]}[${kz[FG.blue]}${kz[git.commit]}${kz[FG.white]}]${kz[RESET]}}'
KZ_PROMPT_TRANSIENT_PROMPT=''
