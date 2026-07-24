# robbyrussell — oh-my-zsh's flagship theme: a green arrow (red after a failure), the
# directory basename in cyan, then git:(branch) in blue/red with a yellow ✗ when dirty.
# ${fcol[...]} everywhere (a literal %F{...} would end the git conditional early).
PROMPT_KRONUZ_GIT='${_prompt_kronuz_git_branch:+ ${fcol[blue]}git:(${fcol[red]}${_prompt_kronuz_git_branch}${fcol[blue]})${fcol[none]}${_prompt_kronuz_git_dirty:+ ${fcol[yellow]}✗${fcol[none]}}}'
PROMPT_KRONUZ_PS1='%(?.${fcol[green]}.${fcol[red]})➜%f  ${fcol[cyan]}%c%f$kronuz[git] '
PROMPT_KRONUZ_RPS1=''
PROMPT_KRONUZ_TRANSIENT='${fcol[green]}➜%f  ${fcol[cyan]}%c%f '
