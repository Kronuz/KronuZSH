# geometry — Geometry's sparse left status/path and asynchronous Git-style RPROMPT.
KZ_PROMPT_PALETTE_GEOMETRY_BRANCH=242
KZ_PROMPT_PALETTE_GEOMETRY_STASH=144
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_PROMPT=' %(?.${kz[FG.default]}▲.${kz[FG.red]}△)${kz[RESET]} ${kz[FG.blue]}%3~${kz[RESET]} '
KZ_PROMPT_RPROMPT='${kz[git.branch]:+${kz[git.ahead]:+⇡ }${kz[git.behind]:+⇣ }${kz[FG.geometry_branch]}${kz[git.branch]}${kz[RESET]} ${kz[git.stashed]:+${kz[FG.geometry_stash]}●${kz[RESET]} }${kz[git.dirty]:+${kz[FG.red]}⬡${kz[RESET]}}${kz[git.clean]:+${kz[FG.green]}⬢${kz[RESET]}}}'
KZ_PROMPT_TRANSIENT_PROMPT=''
