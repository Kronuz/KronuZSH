# bat (+ delta): build bat's theme cache so the bundled Kronuz themes
# (../themes/Kronuz.tmTheme + Kronuz-Light.tmTheme) register; delta reads the same
# cache, so both pick them up. Debian ships bat as `batcat`; accept either. Sourced by
# ../setup.sh at install time; idempotent (re-running just rebuilds the cache).
_kronuz_bat=""
if command -v bat >/dev/null 2>&1; then
  _kronuz_bat=bat
elif command -v batcat >/dev/null 2>&1; then
  _kronuz_bat=batcat
fi
if [ -n "$_kronuz_bat" ]; then
  # BAT_CONFIG_DIR points at integrations/ (this file's parent), where bat finds themes/.
  _kronuz_int_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)"
  if BAT_CONFIG_DIR="$_kronuz_int_dir" "$_kronuz_bat" cache --build >/dev/null 2>&1; then
    kz_ok "bat + delta" "Kronuz theme cached"
  fi
  unset _kronuz_int_dir
fi
unset _kronuz_bat
