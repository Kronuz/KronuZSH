#!/usr/bin/env bash
# Enforce the small setup framework's ownership boundary. This is intentionally a
# narrow structural check; ShellCheck and the integration tests cover shell behavior.
set -euo pipefail

files=(integrations/*/setup.sh)
failed=0

for file in "${files[@]}"; do
  if ! grep -Eq '^_kz_setup_[a-z0-9_]+\(\)' "$file"; then
    printf '%s: setup must be wrapped in _kz_setup_<tool>()\n' "$file" >&2
    failed=1
  fi
done

if grep -En '\bln[[:space:]]+(-[^[:space:]]*[[:space:]]+)*-?s' "${files[@]}"; then
  printf 'integration setup must use kz_manage_link, not ln -s\n' >&2
  failed=1
fi

if grep -En 'kz_backup([[:space:]]|\()|\.kronuzsh\.bak' "${files[@]}"; then
  printf 'integration setup must use managed helpers, not raw backup operations\n' >&2
  failed=1
fi

if grep -En '\bmv[[:space:]]' "${files[@]}"; then
  printf 'integration setup must use kz_commit_file for config replacement\n' >&2
  failed=1
fi

# A bare return preserves the preceding failure status. Because install.sh uses
# `set -e`, optional-tool guards and declined setup paths must return success explicitly.
if grep -En '(\|\|[[:space:]]+return[[:space:]]*$|^[[:space:]]*return[[:space:]]*$)' \
  "${files[@]}"; then
  printf 'integration early exits must use an explicit return status\n' >&2
  failed=1
fi

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
sandbox="$(mktemp -d)"
trap 'rm -rf -- "$sandbox"' EXIT
mkdir -p "$sandbox/bin"
cat > "$sandbox/bin/direnv" <<'EOF'
#!/bin/sh
[ "$#" -eq 2 ] && [ "$1" = hook ] && [ "$2" = zsh ] || exit 64
printf '%s\n' 'typeset -g _kz_direnv_test=loaded'
EOF
chmod +x "$sandbox/bin/direnv"

if ! PATH="$sandbox/bin:$PATH" zsh -fc \
  'source "$1"; [[ $_kz_direnv_test == loaded ]]' \
  zsh "$root/integrations/direnv/init.zsh"; then
  printf 'direnv integration must evaluate the Zsh hook when direnv is present\n' >&2
  failed=1
fi

exit "$failed"
