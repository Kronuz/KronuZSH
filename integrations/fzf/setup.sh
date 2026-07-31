# shellcheck shell=bash
# fzf: generate its zsh integration once at install time. Runtime sources this cache
# (and its .zwc) instead of spawning `fzf --zsh` for every interactive shell.

_kz_setup_fzf() {
  command -v fzf >/dev/null 2>&1 || return 0

  local cache replacement
  local -a generated
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/generated/fzf.zsh"
  generated=("fzf zsh integration" "$cache")

  if [ -n "$KRONUZ_DRY_RUN" ]; then
    kz_info "would cache fzf's zsh integration in $(kz_tilde "$cache")"
    kz_manage_file "${generated[@]}"
    return 0
  fi

  replacement="$(mktemp)"
  if ! fzf --zsh > "$replacement"; then
    rm -f "$replacement"
    kz_skip "fzf" "could not generate zsh integration"
    return 0
  fi
  if cmp -s "$replacement" "$cache"; then
    rm -f "$replacement"
    kz_ok "fzf" "zsh integration already cached"
  else
    kz_commit_file "${generated[@]}" "$replacement"
    kz_ok "fzf" "zsh integration cached"
  fi
  kz_manage_file "${generated[@]}"
}

_kz_setup_fzf
unset -f _kz_setup_fzf
