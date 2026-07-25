# magicmace — Zim's bracketed path and long rule, with compact Git hints.
KZ_PROMPT_GIT='${kz[git.branch]:+ [${kz[git.branch]}${kz[git.dirty]:+ *}${kz[git.ahead]:+ ↑}${kz[git.behind]:+ ↓}]}'
KZ_PROMPT_PROMPT='${kz[FG.blue]}%n${kz[RESET]} ${kz[FG.green]}[%~]${kz[RESET]}$kz[git]── '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
