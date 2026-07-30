# sunaku — Oh My Zsh's Git-first status stream followed by path and >.
KZ_PROMPT_GIT='${kz[git.repo]:+${kz[git.staged]:+${kz[FG.green]}+}${kz[git.unstaged]:+${kz[FG.magenta]}!}${kz[git.conflicted]:+${kz[FG.cyan]}#}${kz[git.untracked]:+${kz[FG.yellow]}?}${kz[RESET]}${kz[git.branch]} }'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='%(?..${kz[BOLD]}${kz[FG.red]}exit %?$kz[NL]${kz[RESET]})$kz[git]${kz[FG.green]}%~${kz[RESET]}%(!.#.>) '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
