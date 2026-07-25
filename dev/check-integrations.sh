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
mkdir -p "$sandbox/project"
cat > "$sandbox/project/.autoenv.zsh" <<'EOF'
autostash KZ_PROMPT_COLOR_HOST='$kz[FG.green]'
autostash AUTOENV_NEW_VALUE=created
autostash AUTOENV_EXPORTED_VALUE
export AUTOENV_EXPORTED_VALUE=overridden
EOF

if ! AUTOENV_AUTH_FILE="$sandbox/auth" zsh -fc '
  KZ_PROMPT_COLOR_HOST=original
  export AUTOENV_EXPORTED_VALUE=exported-original
  source "$1/plugins/zsh-autoenv/autoenv.zsh"
  _autoenv_authorize "$2/project/.autoenv.zsh"
  _autoenv_authorized_env_file "$2/project/.autoenv.zsh" || return 1

  cd "$2/project"
  [[ "$KZ_PROMPT_COLOR_HOST" == '\''$kz[FG.green]'\'' \
    && "$AUTOENV_NEW_VALUE" == created \
    && "$AUTOENV_EXPORTED_VALUE" == overridden \
    && "${_autoenv_stack_entered[-1]:t}" == .autoenv.zsh ]] || return 1

  cd "$2"
  [[ "$KZ_PROMPT_COLOR_HOST" == original \
    && ${+AUTOENV_NEW_VALUE} -eq 0 \
    && "$AUTOENV_EXPORTED_VALUE" == exported-original \
    && ${#_autoenv_stack_entered} -eq 0 ]]
' zsh "$root" "$sandbox"; then
  printf 'zsh-autoenv must load approved files and restore shell state on exit\n' >&2
  failed=1
fi

exit "$failed"
