# robbyrussell — a visual compatibility skin for Oh My Zsh's default theme: a bold
# green arrow (red after failure), directory basename in cyan, then git:(branch) in
# bold blue/red with a yellow ✗ when dirty.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[BOLD]}${kz[FG.blue]}git:(${kz[FG.red]}${kz[git.branch]}${kz[FG.blue]})${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.yellow]}✗${kz[RESET]}}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='%(?.${kz[BOLD]}${kz[FG.green]}.${kz[BOLD]}${kz[FG.red]})➜${kz[RESET]}  ${kz[FG.cyan]}%c${kz[RESET]}$kz[git] '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
