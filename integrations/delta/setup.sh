# shellcheck shell=bash
# git-delta: configure Git to use delta when available, with a less/cat fallback on
# machines where the binary is absent. The settings are idempotent.

_kronuz_setup_delta() {
  command -v git >/dev/null 2>&1 || return 0

  local config_origin

  git config --global core.pager \
    'if command -v delta >/dev/null 2>&1; then delta; else less; fi'
  git config --global interactive.diffFilter \
    'if command -v delta >/dev/null 2>&1; then delta --color-only; else cat; fi'
  git config --global delta.navigate true
  git config --global delta.line-numbers true

  # Warm add/remove backgrounds match the Kronuz palette.
  git config --global delta.plus-style         'syntax #26331a'
  git config --global delta.minus-style        'syntax #3a1d1d'
  git config --global delta.plus-emph-style    'syntax #34471f'
  git config --global delta.minus-emph-style   'syntax #57231f'

  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    git config --global delta.syntax-theme Kronuz
  fi

  kz_ok "git-delta" "wired into git (falls back to less)"

  config_origin="$(git config --global --show-origin --get core.pager \
    | awk 'NR == 1 { print $1 }')"
  kz_manage_file "git config" "${config_origin#file:}"
}

_kronuz_setup_delta
unset -f _kronuz_setup_delta
