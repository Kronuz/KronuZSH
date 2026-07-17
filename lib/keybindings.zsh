# Key bindings: emacs keymap with a faithful, terminal-agnostic word/line set.
# Ported from prezto's editor module, trimmed to the parts worth keeping.

bindkey -e

# Disable software flow control when a real terminal is available. This frees
# Ctrl-S/Ctrl-Q for ZLE and prevents an accidental Ctrl-S from freezing output.
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] &&
  stty -ixon <"$TTY" >"$TTY"

# Treat path separators (and "=") as word boundaries; zsh's default lumps them
# into the word. This is what makes Ctrl-W on "a/b/c" delete just "c" (leaving
# "a/b/") instead of the whole path, and word motions stop at each slash.
# Same value prezto's editor module used.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# --- Line motion -------------------------------------------------------------
bindkey '^[[H'  beginning-of-line    # Home
bindkey '^[[F'  end-of-line          # End
bindkey '^[OH'  beginning-of-line    # Home (application/cursor-key mode)
bindkey '^[OF'  end-of-line          # End  (application/cursor-key mode)
bindkey '^[[1~' beginning-of-line    # Home (linux console / screen / tmux)
bindkey '^[[4~' end-of-line          # End  (linux console / screen / tmux)

# --- Editing -----------------------------------------------------------------
bindkey '^[[3~' delete-char          # Delete (forward)
bindkey '^U'    backward-kill-line   # Ctrl-U kills to the start of line, not all.

# --- Word motion -------------------------------------------------------------
# Bind every escape sequence Option/Alt/Ctrl + Left/Right can emit, so word
# navigation works regardless of how iTerm2's "Left Option key" is set (Esc+,
# Meta, or Normal) and on Linux terminals too. All respect WORDCHARS above.
for _seq in '^[[1;3D' '^[[1;5D' '^[[1;9D' '^[^[[D' '^[[5D' '^[Od' '^[b' '^[B'; do
  bindkey "$_seq" backward-word
done
for _seq in '^[[1;3C' '^[[1;5C' '^[[1;9C' '^[^[[C' '^[[5C' '^[Oc' '^[f' '^[F'; do
  bindkey "$_seq" forward-word
done
unset _seq

# Ctrl/Alt + Backspace: delete the previous word (WORDCHARS-aware, like Ctrl-W).
bindkey '^[^?' backward-kill-word    # Alt-Backspace
bindkey '^W'   backward-kill-word    # explicit (matches the emacs default)

# --- Completion menu ---------------------------------------------------------
bindkey '^[[Z' reverse-menu-complete # Shift-Tab walks the completion menu back.

# --- History search ----------------------------------------------------------
# Incremental pattern search (FLOW_CONTROL is off, so Ctrl-S is free for fwd).
if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey '^R' history-incremental-pattern-search-backward
  bindkey '^S' history-incremental-pattern-search-forward
fi

# --- External editor ---------------------------------------------------------
# Ctrl-X Ctrl-E opens the current command line in $EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- ZLE appearance ----------------------------------------------------------
# Don't reverse-video (standout) pasted text. zsh's default zle_highlight highlights
# the bracketed-paste region until the next keypress, which flashes the pasted text as
# a background block; German prefers to see the real syntax-highlighted colors right
# away. Other contexts (region, isearch, special, suffix) keep their defaults.
zle_highlight=(paste:none)
