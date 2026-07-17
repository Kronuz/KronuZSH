# shellcheck shell=bash
# Yazi: link the Kronuz UI theme and its syntect preview theme into Yazi's config.
# Existing files are preserved through the shared managed-link backup policy.

_kronuz_setup_yazi() {
  command -v yazi >/dev/null 2>&1 || return 0

  local here config_dir active=0
  local -a theme preview_theme

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  config_dir="${YAZI_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/yazi}"

  theme=(
    "yazi theme"
    "$here/theme.toml"
    "$config_dir/theme.toml"
  )
  preview_theme=(
    "yazi preview theme"
    "$(cd -- "$here/../themes" && pwd -P)/Kronuz.tmTheme"
    "$config_dir/Kronuz.tmTheme"
  )

  if kz_managed_link_active "${theme[@]}" \
    && kz_managed_link_active "${preview_theme[@]}"; then
    kz_ok "yazi" "already themed in $(kz_tilde "$config_dir")"
    active=1
  elif kz_confirm "Enable the Kronuz theme for yazi in $(kz_tilde "$config_dir")"; then
    kz_ok "yazi" "Kronuz theme + syntect preview in $(kz_tilde "$config_dir")"
    active=1
  else
    kz_skip "yazi" "not themed"
    kz_info "enable later: re-run install, or link theme.toml into $(kz_tilde "$config_dir")"
  fi

  if [ "$active" -eq 1 ]; then
    kz_manage_link "${theme[@]}"
    kz_manage_link "${preview_theme[@]}"
    kz_hint "theme directory: $(kz_tilde "$config_dir")"
  fi
}

_kronuz_setup_yazi
unset -f _kronuz_setup_yazi
