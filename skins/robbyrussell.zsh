# robbyrussell — oh-my-zsh's flagship theme: a green arrow (red after a failure), the
# directory basename in cyan, then git:(branch) in blue/red with a yellow ✗ when dirty.
# ${kz[FG.*]} everywhere (a literal %F{...} would end the git conditional early).
PROMPT_KRONUZ_GIT='${kz[git.branch]:+ ${kz[FG.blue]}git:(${kz[FG.red]}${kz[git.branch]}${kz[FG.blue]})${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.yellow]}✗${kz[RESET]}}}'
PROMPT_KRONUZ_PROMPT='%(?.${kz[FG.green]}.${kz[FG.red]})➜%f  ${kz[FG.cyan]}%c%f$kz[git] '
PROMPT_KRONUZ_RPROMPT=''
PROMPT_KRONUZ_TRANSIENT_PROMPT='${kz[FG.green]}➜%f  ${kz[FG.cyan]}%c%f '
