# typewritten — Typewritten's default single-line layout: prompt at left, project and
# detailed Git state at right.
KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='%(?.${kz[FG.blue]}❯.${kz[FG.red]}%? ❯)${kz[RESET]} '
KZ_PROMPT_RPROMPT='${kz[FG.magenta]}%c${kz[RESET]}${kz[git.branch]:+ -> ${kz[FG.magenta]}${kz[git.branch]}${kz[RESET]}${kz[git.staged]:+ ${kz[FG.green]}+}${kz[git.untracked]:+ ${kz[FG.blue]}?}${kz[git.unstaged]:+ ${kz[FG.yellow]}!}${kz[git.conflicted]:+ ${kz[FG.cyan]}#}${kz[git.ahead]:+ ${kz[FG.blue]}|•}${kz[git.behind]:+ ${kz[FG.blue]}•|}${kz[git.stashed]:+ ${kz[FG.yellow]}$}${kz[RESET]}}'
KZ_PROMPT_TRANSIENT_PROMPT=''
