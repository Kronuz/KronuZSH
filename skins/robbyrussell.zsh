# robbyrussell — oh-my-zsh's flagship theme: a green arrow (red after a failure), the
# directory basename in cyan, then git:(branch) in blue/red with a yellow ✗ when dirty.
# ${kz[FG.*]} everywhere (a literal %F{...} would end the git conditional early).
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.blue]}git:(${kz[FG.red]}${kz[git.branch]}${kz[FG.blue]})${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.yellow]}✗${kz[RESET]}}}'
KZ_PROMPT_PROMPT='%(?.${kz[FG.green]}.${kz[FG.red]})➜%f  ${kz[FG.cyan]}%c%f$kz[git] '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT='${kz[FG.green]}➜%f  ${kz[FG.cyan]}%c%f '
