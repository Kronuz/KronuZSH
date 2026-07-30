# steeef — Oh My Zsh's prose-like user at host in path, with colored Git dots.
KZ_PROMPT_PALETTE_STEEEF_PURPLE=135
KZ_PROMPT_PALETTE_STEEEF_ORANGE=166
KZ_PROMPT_PALETTE_STEEEF_GREEN=118
KZ_PROMPT_PALETTE_STEEEF_BRANCH=81
KZ_PROMPT_PALETTE_STEEEF_UNTRACKED=161
KZ_PROMPT_GIT='${kz[git.branch]:+(${kz[FG.steeef_branch]}${kz[git.branch]}${kz[git.unstaged]:+${kz[FG.steeef_orange]}●}${kz[git.staged]:+${kz[FG.steeef_green]}●}${kz[git.untracked]:+${kz[FG.steeef_untracked]}●}${kz[RESET]}) }'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='$kz[NL]${kz[FG.steeef_purple]}%n${kz[RESET]} at ${kz[FG.steeef_orange]}%m${kz[RESET]} in ${kz[FG.steeef_green]}%~${kz[RESET]} $kz[git]${kz[venv.name]:+(${kz[FG.blue]}${kz[venv.name]}${kz[RESET]}) }$kz[NL]$ '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
