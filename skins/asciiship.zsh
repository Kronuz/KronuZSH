# asciiship — Zim's two-line ASCII-friendly prompt with branch and environment.
KZ_PROMPT_GIT='${kz[git.branch]:+on branch ${kz[git.branch]}${kz[git.action]:+ (${kz[git.action]})}${kz[git.staged]:+ +}${kz[git.unstaged]:+ !}${kz[git.untracked]:+ ?}${kz[git.ahead]:+ >}${kz[git.behind]:+ <}}'
KZ_PROMPT_PROMPT='$kz[NL]%~${kz[git]:+ [$kz[git]]}${kz[venv.name]:+ via ${kz[venv.name]}} %(1j.* )${kz[FG.green]}%#${kz[RESET]} '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT='%~ ${kz[FG.green]}%#${kz[RESET]} '
