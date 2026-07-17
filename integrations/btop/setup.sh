# shellcheck shell=bash
# btop: opt-in Kronuz theming. btop has no env/flag to select a theme — it reads
# color_theme from btop.conf and themes from <config>/themes/ — so enabling means
# placing the theme and setting the key. We ask first (kz_confirm), then symlink
# Kronuz.theme into the themes dir and set color_theme = "Kronuz" in btop.conf (backing
# it up first). Idempotent; honors KRONUZ_YES / KRONUZ_NO. Sourced by ../setup.sh.
_kronuz_btop_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
if command -v btop >/dev/null 2>&1; then
  _kronuz_bcfg="${XDG_CONFIG_HOME:-$HOME/.config}/btop"
  _kronuz_bconf="$_kronuz_bcfg/btop.conf"
  if [ -f "$_kronuz_bconf" ] \
    && grep -q '^color_theme *= *"Kronuz"' "$_kronuz_bconf" 2>/dev/null; then
    kz_ok "btop" "already themed"
  elif kz_confirm "Enable the Kronuz theme for btop"; then
    kz_link "$_kronuz_btop_dir/Kronuz.theme" "$_kronuz_bcfg/themes/Kronuz.theme"

    # Select Kronuz while preserving every unrelated btop setting.
    if [ -f "$_kronuz_bconf" ]; then
      kz_backup_file "$_kronuz_bconf"
      if grep -q '^color_theme *=' "$_kronuz_bconf"; then
        _kronuz_btmp="$(mktemp)"
        sed 's#^color_theme *=.*#color_theme = "Kronuz"#' "$_kronuz_bconf" > "$_kronuz_btmp"
        mv "$_kronuz_btmp" "$_kronuz_bconf"
      else
        printf 'color_theme = "Kronuz"\n' >> "$_kronuz_bconf"
      fi
    else
      printf 'color_theme = "Kronuz"\n' > "$_kronuz_bconf"
    fi
    kz_ok "btop" "Kronuz theme set in $(kz_tilde "$_kronuz_bconf")"
  else
    kz_skip "btop" "not themed"
    kz_info "enable later: re-run install, or set color_theme=\"Kronuz\" in btop.conf"
  fi
  unset _kronuz_bcfg _kronuz_bconf _kronuz_btmp
fi
unset _kronuz_btop_dir
