# hometown — Zim's multiline time/path prompt with the most useful Git signals.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.blue]}(${kz[git.branch]}${kz[git.dirty]:+ ±}${kz[git.ahead]:+ ↑}${kz[git.behind]:+ ↓}${kz[git.stashed]:+ $}${kz[RESET]})}'
KZ_PROMPT_PROMPT='$kz[NL]%* %~$kz[git]$kz[NL]${kz[FG.green]}%#${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
