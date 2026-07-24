# powerline — an agnoster-style ribbon: user@host, path, and branch as coloured segments
# joined by Nerd Font separators (needs a patched font). The branch segment shows only in
# a repo; the final cap takes the colour of whichever segment it follows. Backgrounds come
# from ${kz[BG.*]}, foregrounds from ${kz[FG.*]}; %k/%f are precise fg/bg resets.
PROMPT_KRONUZ_GIT='${kz[git.branch]:+${kz[BG.green]}${kz[FG.blue]}'$'\ue0b0''${kz[FG.gray]} '$'\ue0a0'' ${kz[git.branch]} }'
PROMPT_KRONUZ_PROMPT='${kz[BG.gray]}${kz[FG.white]} %n@%m ${kz[FG.darkgrey]}${kz[BG.blue]}'$'\ue0b0''${kz[FG.white]} %~ $kz[git]%k${${kz[git.branch]:+${kz[FG.green]}}:-${kz[FG.blue]}}'$'\ue0b0''%f '
PROMPT_KRONUZ_RPROMPT=''
PROMPT_KRONUZ_TRANSIENT_PROMPT='${kz[BG.blue]}${kz[FG.white]} %~ %k${kz[FG.blue]}'$'\ue0b0''%f '
