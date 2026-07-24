# powerline — an agnoster-style ribbon: user@host, path, and branch as coloured segments
# joined by Nerd Font separators (needs a patched font). The branch segment shows only in
# a repo; the final cap takes the colour of whichever segment it follows.
typeset -g _pl_kgreen='%K{2}'   # a background ($col is foreground-only)
PROMPT_KRONUZ_GIT='${_prompt_kronuz_git_branch:+${_pl_kgreen}${col[blue]}'$'\ue0b0''${col[gray]} '$'\ue0a0'' ${_prompt_kronuz_git_branch} }'
PROMPT_KRONUZ_PS1='%K{240}%F{255} %n@%m %F{240}%K{4}'$'\ue0b0''%F{255} %~ $kronuz[git]%k%F{${${_prompt_kronuz_git_branch:+2}:-4}}'$'\ue0b0''%f '
PROMPT_KRONUZ_RPS1=''
PROMPT_KRONUZ_TRANSIENT='%K{4}%F{255} %~ %k%F{4}'$'\ue0b0''%f '
