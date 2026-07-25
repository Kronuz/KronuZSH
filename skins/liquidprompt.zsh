# liquidprompt — Liquid Prompt's adaptive two-line core (directory, VCS, status).
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.cyan]}(${kz[git.branch]}${kz[git.dirty]:+ ${kz[FG.red]}✗}${kz[git.staged]:+ ${kz[FG.green]}+}${kz[git.untracked]:+ ${kz[FG.yellow]}?}${kz[RESET]})}'
KZ_PROMPT_PROMPT='${kz[FG.blue]}%~${kz[RESET]}$kz[git]${kz[venv.name]:+ ${kz[FG.magenta]}${kz[venv.name]}${kz[RESET]}}$kz[nl]%(?.${kz[FG.green]}.%F{red})%# '
KZ_PROMPT_RPROMPT='%*'
KZ_PROMPT_TRANSIENT_PROMPT=''
