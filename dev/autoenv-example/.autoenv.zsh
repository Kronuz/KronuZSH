# zsh-autoenv displays this file and asks for approval before sourcing it.
autostash KRONUZSH_AUTOENV_EXAMPLE
export KRONUZSH_AUTOENV_EXAMPLE="loaded from ${PWD:t}"

# autostash preserves shell-local parameters as well as exported variables.
autostash KZ_PROMPT_COLOR_HOST KZ_PROMPT_COLOR_PWD
KZ_PROMPT_COLOR_HOST='$kz[FG.green]'
KZ_PROMPT_COLOR_PWD='%(!.$kz[FG.tomato].$kz[FG.green])'
