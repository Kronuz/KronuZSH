# pure — a two-line homage to Sindre Sorhus's Pure: the path in blue, the git branch in
# dim grey (a trailing * when dirty), then a lone magenta caret on its own line.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.gray]}${kz[git.branch]}${kz[git.dirty]:+*}${kz[RESET]}}'
KZ_PROMPT_PROMPT='${kz[FG.blue]}%~%f$kz[git]$kz[nl]${kz[FG.magenta]}${kz[GLYPH.caret]}%f '
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT='${kz[FG.blue]}%~%f ${kz[FG.magenta]}${kz[GLYPH.caret]}%f '
