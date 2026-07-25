# agnoster — the closest declarative rendering of Agnoster's default ribbon. It
# reproduces path and clean/dirty Git transitions exactly; status, context, and
# virtualenv segments require conditional segment composition the skin API lacks.
KZ_PROMPT_GIT='${kz[git.branch]:+${${kz[git.dirty]:+${kz[BG.yellow]}}:-${kz[BG.green]}}${kz[FG.blue]}${kz[FG.black]}  ${kz[git.branch]}${kz[git.dirty]:+ ±} }'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='${kz[BG.blue]}${kz[FG.black]} %~ $kz[git]%k${${kz[git.branch]:+${${kz[git.dirty]:+${kz[FG.yellow]}}:-${kz[FG.green]}}}:-${kz[FG.blue]}}%f '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
