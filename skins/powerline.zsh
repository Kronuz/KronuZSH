# powerline — an agnoster-style ribbon: user@host, path, and branch as coloured segments
# joined by Nerd Font separators (needs a patched font). The branch segment shows only in
# a repo; the final cap takes the colour of whichever segment it follows. Backgrounds come
# from ${bcol[...]}, foregrounds from ${fcol[...]}; %k/%f are precise fg/bg resets.
PROMPT_KRONUZ_GIT='${_prompt_kronuz_git_branch:+${bcol[green]}${fcol[blue]}'$'\ue0b0''${fcol[gray]} '$'\ue0a0'' ${_prompt_kronuz_git_branch} }'
PROMPT_KRONUZ_PS1='${bcol[gray]}${fcol[white]} %n@%m ${fcol[darkgrey]}${bcol[blue]}'$'\ue0b0''${fcol[white]} %~ $kronuz[git]%k${${_prompt_kronuz_git_branch:+${fcol[green]}}:-${fcol[blue]}}'$'\ue0b0''%f '
PROMPT_KRONUZ_RPS1=''
PROMPT_KRONUZ_TRANSIENT='${bcol[blue]}${fcol[white]} %~ %k${fcol[blue]}'$'\ue0b0''%f '
