# shellcheck shell=bash
# zoxide: generate its zsh integration once at install time. Runtime sources this
# cache (and its .zwc) instead of spawning `zoxide init zsh` for every shell.

_kz_setup_zoxide() {
  command -v zoxide >/dev/null 2>&1 || return 0

  local cache replacement
  local -a generated
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/generated/zoxide.zsh"
  generated=("zoxide zsh integration" "$cache")

  if [ -n "$KRONUZ_DRY_RUN" ]; then
    kz_info "would cache zoxide's zsh integration in $(kz_tilde "$cache")"
    kz_manage_file "${generated[@]}"
    return 0
  fi

  replacement="$(mktemp)"
  if ! zoxide init zsh > "$replacement"; then
    rm -f "$replacement"
    kz_skip "zoxide" "could not generate zsh integration"
    return 0
  fi
  if cmp -s "$replacement" "$cache"; then
    rm -f "$replacement"
    kz_ok "zoxide" "zsh integration already cached"
  else
    kz_commit_file "${generated[@]}" "$replacement"
    kz_ok "zoxide" "zsh integration cached"
  fi
  kz_manage_file "${generated[@]}"
}

_kz_setup_zoxide
unset -f _kz_setup_zoxide
