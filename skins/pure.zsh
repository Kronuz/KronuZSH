# pure — a two-line homage to Sindre Sorhus's Pure: the path in blue, the git branch in
# dim grey (a trailing * when dirty), then a lone magenta caret on its own line.
PROMPT_KRONUZ_GIT='${kz[git.branch]:+ ${kz[FG.gray]}${kz[git.branch]}${kz[git.dirty]:+*}${kz[RESET]}}'
PROMPT_KRONUZ_PROMPT='${kz[FG.blue]}%~%f$kz[git]$kz[nl]${kz[FG.magenta]}${kz[GLYPH.caret]}%f '
PROMPT_KRONUZ_RPROMPT=''
PROMPT_KRONUZ_TRANSIENT_PROMPT='${kz[FG.blue]}%~%f ${kz[FG.magenta]}${kz[GLYPH.caret]}%f '
