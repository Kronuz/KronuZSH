#!/usr/bin/env bash
# Enforce the small setup framework's ownership boundary. This is intentionally a
# narrow structural check; ShellCheck and the integration tests cover shell behavior.
set -euo pipefail

files=(integrations/*/setup.sh)
failed=0

for file in "${files[@]}"; do
  if ! grep -Eq '^_kronuz_setup_[a-z0-9_]+\(\)' "$file"; then
    printf '%s: setup must be wrapped in _kronuz_setup_<tool>()\n' "$file" >&2
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

exit "$failed"
