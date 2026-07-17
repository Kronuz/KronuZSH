# shellcheck shell=bash
# vivid: expose the source theme to vivid. Runtime uses the committed ls_colors file,
# so vivid itself is needed only when regenerating that file after a theme edit.

_kronuz_setup_vivid() {
  command -v vivid >/dev/null 2>&1 || return

  local here destination hint active=0
  local -a theme

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  destination="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes/kronuz.yml"
  hint="after editing: vivid generate kronuz > $(kz_tilde "$here/ls_colors")"
  theme=("vivid theme" "$here/kronuz.yml" "$destination")

  if kz_managed_link_active "${theme[@]}"; then
    kz_ok "vivid" "Kronuz theme already available"
    kz_hint "$hint"
    active=1
  elif { [ ! -e "$destination" ] && [ ! -L "$destination" ]; } \
    || kz_confirm "Replace $(kz_tilde "$destination") with the Kronuz theme"; then
    kz_ok "vivid" "Kronuz theme available ($(kz_tilde "$destination"))"
    kz_info "$hint"
    active=1
  else
    kz_skip "vivid" "respecting existing theme at $(kz_tilde "$destination")"
  fi

  if [ "$active" -eq 1 ]; then
    kz_manage_link "${theme[@]}"
  fi
}

_kronuz_setup_vivid
unset -f _kronuz_setup_vivid
