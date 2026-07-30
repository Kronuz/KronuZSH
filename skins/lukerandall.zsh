# lukerandall — Oh My Zsh's bold user/path and detailed punctuation-only Git status.
KZ_PROMPT_GIT='${kz[git.branch]:+${kz[FG.yellow]}(${kz[git.branch]}${kz[git.untracked]:+ %%}${kz[git.staged]:+ +}${kz[git.unstaged]:+ *}${kz[git.conflicted]:+ ?}) ${kz[RESET]}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='${kz[BOLD]}${kz[FG.green]}%n@%m${kz[RESET]} ${kz[BOLD]}${kz[FG.blue]}%2~${kz[RESET]} $kz[git]${kz[BOLD]}»${kz[RESET]} '
KZ_PROMPT_RPROMPT='%(?..${kz[BOLD]}${kz[FG.red]}%? ↵${kz[RESET]})'
KZ_PROMPT_TRANSIENT_PROMPT=''
