# shellcheck shell=bash
# btop: link the Kronuz theme and select it in btop.conf. The config rewrite preserves
# every unrelated setting and follows the shared backup policy.

_kronuz_setup_btop() {
  command -v btop >/dev/null 2>&1 || return

  local here config_dir config temp
  local -a config_file theme

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/btop"
  config="$config_dir/btop.conf"
  config_file=("btop config" "$config")
  theme=("btop theme" "$here/Kronuz.theme" "$config_dir/themes/Kronuz.theme")

  if [ -f "$config" ] \
    && grep -q '^color_theme *= *"Kronuz"' "$config" 2>/dev/null \
    && kz_managed_link_active "${theme[@]}"; then
    kz_ok "btop" "already themed"
  elif kz_confirm "Enable the Kronuz theme for btop"; then
    temp="$(mktemp)"

    if [ -f "$config" ]; then
      if grep -q '^color_theme *=' "$config"; then
        sed 's#^color_theme *=.*#color_theme = "Kronuz"#' "$config" > "$temp"
      else
        cat "$config" > "$temp"
        printf 'color_theme = "Kronuz"\n' >> "$temp"
      fi
    else
      printf 'color_theme = "Kronuz"\n' > "$temp"
    fi

    kz_commit_file "${config_file[@]}" "$temp"
    kz_ok "btop" "Kronuz theme set in $(kz_tilde "$config")"
  else
    kz_skip "btop" "not themed"
    kz_info "enable later: re-run install, or set color_theme=\"Kronuz\" in btop.conf"
  fi

  if grep -q '^color_theme *= *"Kronuz"' "$config" 2>/dev/null; then
    kz_manage_link "${theme[@]}"
    kz_manage_file "${config_file[@]}"
    kz_hint "theme setting: color_theme=\"Kronuz\" in $(kz_tilde "$config")"
  fi
}

_kronuz_setup_btop
unset -f _kronuz_setup_btop
