# eza: a modern `ls` with colors, icons, and (optionally) inline git status. When
# present it takes over the ls aliases (overriding lib/aliases.zsh, which loads
# before the integrations). NB: `--git` is deliberately left off `ll`/`la` because it
# walks git status per entry, which is slow in large/deep dirs; use `llg`/`lag` when
# you actually want the git column. EZA_CONFIG_DIR points eza at the bundled Kronuz
# theme (./theme.yml); override it in ~/.zshrc.local for your own.
# install: brew install eza · cargo install eza
if (( $+commands[eza] )); then
  export EZA_CONFIG_DIR="${EZA_CONFIG_DIR:-${0:h}}"
  alias ls='eza --group-directories-first --classify=auto'
  alias l='eza -1a --group-directories-first'
  alias ll='eza -lg --group-directories-first'
  alias la='eza -lga --group-directories-first'
  alias llg='ll --git'   # long + git status (slower in big repos)
  alias lag='la --git'
  alias lt='eza -T --level=2 --group-directories-first'   # tree
fi
