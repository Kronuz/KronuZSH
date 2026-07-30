# af-magic — Oh My Zsh's full-width dashed header, path/Git line and context RPROMPT.
KZ_PROMPT_PALETTE_AF_DIM=237
KZ_PROMPT_PALETTE_AF_PATH=32
KZ_PROMPT_PALETTE_AF_PUNCT=75
KZ_PROMPT_PALETTE_AF_BRANCH=78
KZ_PROMPT_PALETTE_AF_DIRTY=214
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.af_punct]}(${kz[FG.af_branch]}${kz[git.branch]}${kz[git.dirty]:+${kz[FG.af_dirty]}*}${kz[FG.af_punct]})${kz[RESET]}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='${kz[FG.af_dim]}${(l.$COLUMNS..-.)}${kz[RESET]}$kz[NL]${kz[FG.af_path]}%~${kz[RESET]}$kz[git] ${kz[FG.magenta]}»${kz[RESET]} '
KZ_PROMPT_RPROMPT='%(?..${kz[FG.red]}%? ↵${kz[RESET]})${kz[venv.name]:+ ${kz[FG.af_punct]}[${kz[venv.name]}]${kz[RESET]}} ${kz[FG.af_dim]}%n@%m${kz[RESET]}'
KZ_PROMPT_TRANSIENT_PROMPT=''
