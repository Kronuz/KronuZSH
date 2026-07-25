# starship — the common Starship look, limited to universally available state.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.purple]}${kz[GLYPH.branch]} ${kz[git.branch]}${kz[git.dirty]:+ ✘}${kz[git.ahead]:+ ⇡}${kz[git.behind]:+ ⇣}${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[FG.blue]}➜ ${kz[FG.cyan]}%~${kz[RESET]}$kz[git]${kz[venv.name]:+ ${kz[FG.yellow]}${kz[venv.name]}${kz[RESET]}}$kz[nl]${kz[FG.green]}❯${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
