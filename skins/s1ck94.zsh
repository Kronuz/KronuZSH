# s1ck94 — Zim's clean arrow with path and Git state on the right.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[git.branch]}${kz[git.commit]:+ ${kz[git.commit]}}${kz[git.dirty]:+ ✗}${kz[git.ahead]:+ ↑}${kz[git.behind]:+ ↓}}'
KZ_PROMPT_PROMPT='%(?.${kz[FG.green]}.%F{red})❯ '
KZ_PROMPT_RPROMPT='%~$kz[git]'
KZ_PROMPT_TRANSIENT_PROMPT=''
