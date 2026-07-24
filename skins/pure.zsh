# pure — a two-line homage to Sindre Sorhus's Pure: the path in blue, the git branch in
# dim grey (a trailing * when dirty), then a lone magenta caret on its own line.
PROMPT_KRONUZ_GIT='${_prompt_kronuz_git_branch:+ ${fcol[gray]}${_prompt_kronuz_git_branch}${_prompt_kronuz_git_dirty:+*}${fcol[none]}}'
PROMPT_KRONUZ_PS1='${fcol[blue]}%~%f$kronuz[git]$kronuz[nl]${fcol[magenta]}${glyph[caret]}%f '
PROMPT_KRONUZ_RPS1=''
PROMPT_KRONUZ_TRANSIENT='${fcol[blue]}%~%f ${fcol[magenta]}${glyph[caret]}%f '
