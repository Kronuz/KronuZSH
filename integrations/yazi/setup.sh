# shellcheck shell=bash
# yazi: opt-in Kronuz theming. yazi reads its theme from its config dir
# ($YAZI_CONFIG_HOME, else $XDG_CONFIG_HOME/yazi, else ~/.config/yazi), so enabling it
# means placing files there. We ask first (kz_confirm), then symlink this theme.toml
# plus the shared Kronuz.tmTheme (for syntect code-preview highlighting, which theme.toml
# points at by absolute path) into that dir. Backs up an existing theme.toml; idempotent;
# honors KRONUZ_YES / KRONUZ_NO. Sourced by ../setup.sh at install time.
_kronuz_yazi_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
if command -v yazi >/dev/null 2>&1; then
  _kronuz_ycfg="${YAZI_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/yazi}"
  _kronuz_ytoml="$_kronuz_yazi_dir/theme.toml"
  _kronuz_ytm="$(cd -- "$_kronuz_yazi_dir/../themes" && pwd -P)/Kronuz.tmTheme"
  if kz_is_link "$_kronuz_ytoml" "$_kronuz_ycfg/theme.toml" \
    && kz_is_link "$_kronuz_ytm" "$_kronuz_ycfg/Kronuz.tmTheme"; then
    kz_ok "yazi" "already themed in $(kz_tilde "$_kronuz_ycfg")"
  elif kz_confirm "Enable the Kronuz theme for yazi in $(kz_tilde "$_kronuz_ycfg")"; then
    kz_link "$_kronuz_ytoml" "$_kronuz_ycfg/theme.toml"
    kz_link "$_kronuz_ytm" "$_kronuz_ycfg/Kronuz.tmTheme"
    kz_ok "yazi" "Kronuz theme + syntect preview in $(kz_tilde "$_kronuz_ycfg")"
  else
    kz_skip "yazi" "not themed"
    kz_info "enable later: re-run install, or link theme.toml into $(kz_tilde "$_kronuz_ycfg")"
  fi
  unset _kronuz_ycfg _kronuz_ytoml _kronuz_ytm
fi
unset _kronuz_yazi_dir
