# zim-minimal — Zim's lambda prompt with path and Git on the right.
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[git.branch]}${kz[git.commit]:+ ${kz[git.commit]}}${kz[git.dirty]:+ *}}'
KZ_PROMPT_PROMPT='%(?.${kz[FG.green]}.%F{red})%(1j.* )${kz[GLYPH.caret]} '
KZ_PROMPT_RPROMPT='%~$kz[git]'
KZ_PROMPT_TRANSIENT_PROMPT='%~ %(?.${kz[FG.green]}.%F{red})${kz[GLYPH.caret]} '
