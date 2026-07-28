# pure — a visual compatibility skin for Pure's default two-line prompt. It covers
# Pure's path, branch/dirty state, fetch arrows, stash, duration, virtualenv, jobs,
# host context and red-on-error prompt symbol with the original default colours.
KZ_PROMPT_PALETTE_PURE_GRAY=242
KZ_PROMPT_PALETTE_PURE_DIRTY=218
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.pure_gray]}${kz[git.branch]}${kz[git.dirty]:+${kz[FG.pure_dirty]}*}${kz[RESET]}}${kz[git.behind]:+ ${kz[FG.cyan]}⇣${kz[RESET]}}${kz[git.ahead]:+ ${kz[FG.cyan]}⇡${kz[RESET]}}${kz[git.stashed]:+ ${kz[FG.cyan]}≡${kz[RESET]}}'
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='%(1j.${kz[FG.red]}✦${kz[RESET]} .)${kz[context.ssh]:+${kz[FG.pure_gray]}%n@%m${kz[RESET]} }${kz[FG.blue]}%~${kz[RESET]}$kz[git]${kz[duration]:+ ${kz[FG.yellow]}${kz[duration]}${kz[RESET]}}$kz[nl]${VIRTUAL_ENV:+${kz[FG.pure_gray]}${VIRTUAL_ENV:t}${kz[RESET]} }%(?.${kz[FG.magenta]}.${kz[FG.red]})❯${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
