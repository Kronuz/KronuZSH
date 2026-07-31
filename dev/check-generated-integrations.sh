#!/usr/bin/env bash
# Verify install-time generation, compiled-cache loading, and the no-cache runtime
# fallback for fzf and zoxide without requiring either real tool.
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
scratch="$(mktemp -d "${TMPDIR:-/tmp}/kronuzsh-generated.XXXXXX")"
trap 'case "$scratch" in *kronuzsh-generated.*) rm -rf -- "$scratch" ;; esac' EXIT
mkdir -p "$scratch/bin"

cat > "$scratch/bin/fzf" <<'SH'
#!/bin/sh
[ "$1" = --zsh ] || exit 2
printf '%s\n' 'typeset -g KZ_TEST_FZF=loaded'
SH
cat > "$scratch/bin/zoxide" <<'SH'
#!/bin/sh
[ "$1 $2" = 'init zsh' ] || exit 2
printf '%s\n' 'typeset -g KZ_TEST_ZOXIDE=loaded'
SH
chmod +x "$scratch/bin/fzf" "$scratch/bin/zoxide"

export PATH="$scratch/bin:$PATH"
export XDG_CACHE_HOME="$scratch/cache"
export NO_COLOR=1

# Paths are rooted dynamically so the check works from any checkout location.
# shellcheck disable=SC1091
source "$root/install.lib.sh"
# shellcheck disable=SC1091
source "$root/integrations/fzf/setup.sh" >/dev/null
# shellcheck disable=SC1091
source "$root/integrations/zoxide/setup.sh" >/dev/null

fzf_cache="$XDG_CACHE_HOME/kronuzsh/generated/fzf.zsh"
zoxide_cache="$XDG_CACHE_HOME/kronuzsh/generated/zoxide.zsh"
[ -s "$fzf_cache" ] && [ -s "$zoxide_cache" ]
zsh "$root/zcompile.zsh" "$fzf_cache" "$zoxide_cache" >/dev/null

zsh -fc '
  source "$1/integrations/fzf/init.zsh"
  source "$1/integrations/zoxide/init.zsh"
  [[ $KZ_TEST_FZF == loaded && $KZ_TEST_ZOXIDE == loaded ]]
' -- "$root"

# A fresh cache directory exercises the original per-shell generators.
XDG_CACHE_HOME="$scratch/empty-cache" zsh -fc '
  source "$1/integrations/fzf/init.zsh"
  source "$1/integrations/zoxide/init.zsh"
  [[ $KZ_TEST_FZF == loaded && $KZ_TEST_ZOXIDE == loaded ]]
' -- "$root"

printf '%s\n' "generated integration cache checks passed"
