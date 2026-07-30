# fino — Oh My Zsh's elegant two-line prose prompt.
KZ_PROMPT_PALETTE_FINO_USER=40
KZ_PROMPT_PALETTE_FINO_HOST=33
KZ_PROMPT_PALETTE_FINO_DIM=239
KZ_PROMPT_PALETTE_FINO_PATH=226
KZ_PROMPT_PALETTE_FINO_BRANCH=255
KZ_PROMPT_PALETTE_FINO_DIRTY=202
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.fino_dim]}on ${kz[FG.fino_branch]}${kz[git.branch]}${kz[git.dirty]:+${kz[FG.fino_dirty]}✘✘✘}${kz[git.clean]:+${kz[FG.fino_user]}✔}${kz[RESET]}}'
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT='╭─${kz[FG.fino_user]}%n ${kz[FG.fino_dim]}at ${kz[FG.fino_host]}%m ${kz[FG.fino_dim]}in ${kz[BOLD]}${kz[FG.fino_path]}%~${kz[RESET]}$kz[git]${kz[venv.name]:+ ${kz[FG.fino_dim]}using${kz[FG.gray]} «${kz[venv.name]}»${kz[RESET]}}$kz[NL]╰─±${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
