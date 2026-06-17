# integrations.zsh: wire up optional external CLI tools when they're installed
# (separately, e.g. `brew install fzf zoxide fd ripgrep bat git-delta`). Every
# block is guarded on the command existing, so a machine missing a tool just
# skips it and the shell still works everywhere (the VM, a fresh box, ...).
#
# Loaded after keybindings.zsh + plugins.zsh, so fzf's Ctrl-R wins over the
# plain incremental search and its widgets layer cleanly over the plugins.

# fd: a faster, friendlier `find`, and the engine behind fzf's file/dir pickers
# below. Nothing to source; it just runs as `fd`. Honor .gitignore, show hidden,
# follow symlinks, but never descend into .git.
if (( $+commands[fd] )); then
  _kronuz_fd_files='fd --type f --hidden --follow --exclude .git'
  _kronuz_fd_dirs='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_COMMAND="$_kronuz_fd_files"
  export FZF_CTRL_T_COMMAND="$_kronuz_fd_files"
  export FZF_ALT_C_COMMAND="$_kronuz_fd_dirs"
  unset _kronuz_fd_files _kronuz_fd_dirs
fi

# bat: a `cat`/pager with syntax highlighting. We don't shadow `cat` (too
# surprising); we use bat where it clearly helps: as the man pager, and as
# fzf's file preview. `MANROFFOPT=-c` avoids the groff/col spacing glitch.
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p --paging=always'"
  export MANROFFOPT='-c'
fi

# fzf: the fuzzy finder. The modern one-shot integration (`fzf --zsh`, fzf >=
# 0.48) adds Ctrl-T (paste a file path), Ctrl-R (search history), and Alt-C
# (cd into a chosen dir). Preview files with bat when it's around.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  (( $+commands[bat] )) && \
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :200 {}'"
  source <(fzf --zsh)
fi

# zoxide: a smarter `cd` that learns your most-visited directories. Adds `z`
# (jump) and `zi` (interactive pick). We leave the real `cd` untouched, so
# AUTO_CD and plain `cd` keep working exactly as before.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# ripgrep (`rg`): a faster `grep` for code. Nothing to wire into the shell; it
# works out of the box and reads an optional config from $RIPGREP_CONFIG_PATH
# if you want defaults (set it in local.zsh).
#
# git-delta is configured in git, not zsh (so you get navigate, line numbers,
# and `git add -p` highlighting, not just the pager): install.sh sets it in your
# global gitconfig, guarded with `command -v delta` so it falls back to less/cat
# on a box without delta. See the README ("External tools").
