# integrations/init.zsh: wire up optional external CLI tools when installed.
# Sourced by runcoms/zshrc at interactive startup. Every block is guarded on the
# command existing, so a machine missing a tool just skips it and the shell still
# works everywhere (the VM, a fresh box, ...). The install-time half (bat cache,
# delta gitconfig) lives next to this in integrations/setup.sh.
#
# Install per platform (package names differ; see Integrations.md for the full
# catalog, the install matrix, and a ranked list of more tools worth adding):
#   macOS:           brew install fd bat fzf zoxide ripgrep git-delta
#   Linux w/ Rust:   cargo install --locked fd-find bat zoxide git-delta ripgrep
#   Debian/Ubuntu:   apt install fd-find bat fzf zoxide ripgrep git-delta
#   Fedora:          dnf install fd-find bat fzf zoxide ripgrep git-delta
# fzf is Go, not Rust: where there's no package, grab its prebuilt binary into
# ~/.local/bin (https://github.com/junegunn/fzf/releases).
#
# Loaded after keybindings.zsh + plugins.zsh, so fzf's Ctrl-R wins over the
# plain incremental search and its widgets layer cleanly over the plugins.

# fd: a faster, friendlier `find`, and the engine behind fzf's file/dir pickers
# below. Debian/Ubuntu ship the binary as `fdfind` (a name clash with another
# package), so accept either. Honor .gitignore, show hidden, follow symlinks,
# but never descend into .git.
# install: brew install fd · cargo install fd-find · apt/dnf install fd-find
_kronuz_fd=''
(( $+commands[fd] ))     && _kronuz_fd=fd
(( $+commands[fdfind] )) && [[ -z $_kronuz_fd ]] && _kronuz_fd=fdfind
if [[ -n $_kronuz_fd ]]; then
  export FZF_DEFAULT_COMMAND="$_kronuz_fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_kronuz_fd --type d --hidden --follow --exclude .git"
fi
unset _kronuz_fd

# bat: a `cat`/pager with syntax highlighting (Debian/Ubuntu ship it as `batcat`,
# again a name clash). We don't shadow `cat` (too surprising); we use bat where
# it clearly helps: as the man pager, and as fzf's file preview below.
# `MANROFFOPT=-c` avoids the groff/col spacing glitch.
# install: brew install bat · cargo install bat · apt/dnf install bat
_kronuz_bat=''
(( $+commands[bat] ))    && _kronuz_bat=bat
(( $+commands[batcat] )) && [[ -z $_kronuz_bat ]] && _kronuz_bat=batcat
if [[ -n $_kronuz_bat ]]; then
  # Use the bundled Kronuz theme, but only once install.sh has built bat's cache
  # (themes are read at cache-build time, not live). Guard on the cache file so
  # we never trip bat's "unknown theme" warning on a box where it wasn't built.
  [[ -f ${BAT_CACHE_PATH:-$HOME/.cache/bat}/themes.bin ]] && \
    export BAT_THEME="${BAT_THEME:-Kronuz}"
  export MANPAGER="sh -c 'col -bx | $_kronuz_bat -l man -p --paging=always'"
  export MANROFFOPT='-c'
fi

# fzf: the fuzzy finder. The modern one-shot integration (`fzf --zsh`, fzf >=
# 0.48) adds Ctrl-T (paste a file path), Ctrl-R (search history), and Alt-C
# (cd into a chosen dir). Preview files with bat when it's around.
# install: brew install fzf · apt/dnf install fzf · else the prebuilt binary
# from https://github.com/junegunn/fzf/releases into ~/.local/bin (it's Go).
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=fg:-1,bg:-1,hl:#cc7833,fg+:#e8e6e5,bg+:#454545,hl+:#fd971f,info:#95815e,border:#676867,prompt:#a5c261,pointer:#da4939,marker:#219186,spinner:#caa473,header:#6089b4'
  [[ -n $_kronuz_bat ]] && \
    export FZF_CTRL_T_OPTS="--preview '$_kronuz_bat -n --color=always --line-range :200 {}'"
  source <(fzf --zsh)
fi
unset _kronuz_bat

# zoxide: a smarter `cd` that learns your most-visited directories. Adds `z`
# (jump) and `zi` (interactive pick). We leave the real `cd` untouched, so
# AUTO_CD and plain `cd` keep working exactly as before.
# install: brew install zoxide · cargo install zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# eza: a modern `ls` with colors, icons, and (optionally) inline git status.
# When present it takes over the ls aliases (overriding aliases.zsh, which loads
# before this). NB: `--git` is deliberately left off `ll`/`la` because it walks
# git status per entry, which is slow in large/deep dirs; use `llg`/`lag` when
# you actually want the git column. EZA_CONFIG_DIR points eza at our bundled
# Kronuz theme (integrations/eza/theme.yml); override it in local.zsh for your own.
# install: brew install eza · cargo install eza
if (( $+commands[eza] )); then
  export EZA_CONFIG_DIR="${EZA_CONFIG_DIR:-$KRONUZSH/integrations/eza}"
  alias ls='eza --group-directories-first --classify=auto'
  alias l='eza -1a --group-directories-first'
  alias ll='eza -lgh --group-directories-first'
  alias la='eza -lgha --group-directories-first'
  alias llg='ll --git'   # long + git status (slower in big repos)
  alias lag='la --git'
  alias lt='eza -T --level=2 --group-directories-first'   # tree
fi

# atuin: a SQLite-backed shell history with a great fuzzy search. It is the one
# tool here that *competes* with fzf for Ctrl-R: installing it means you want it,
# so we let it own Ctrl-R (it inits after fzf, so it wins), and pass
# --disable-up-arrow to keep our Up/Down history-substring-search intact.
# install: brew install atuin · cargo install atuin
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# yazi: a fast terminal file manager. `y` opens it and cd's to wherever you quit
# (yazi's official shell wrapper); plain `yazi` still works without the cd.
# install: brew install yazi · cargo install --locked yazi-fm yazi-cli
if (( $+commands[yazi] )); then
  function y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# ripgrep (`rg`): a faster `grep` for code. Nothing to wire into the shell; it
# works out of the box and reads an optional config from $RIPGREP_CONFIG_PATH
# if you want defaults (set it in local.zsh).
# install: brew install ripgrep · cargo install ripgrep · apt/dnf install ripgrep
#
# git-delta is configured in git, not zsh (so you get navigate, line numbers,
# and `git add -p` highlighting, not just the pager): integrations/setup.sh sets
# it in your global gitconfig, guarded with `command -v delta` so it falls back to
# less/cat on a box without delta. See Integrations.md ("External tools").
# install: brew install git-delta · cargo install git-delta
#
# Plenty of other good tools need no shell wiring (they're just commands you run
# directly): lazygit, hyperfine, jq/yq, dust, duf, btop, procs, tokei, sd, tldr
# (tealdeer), glow, xh. See Integrations.md for the full catalog + install hints.
