# bat (+ delta): build bat's theme cache so the bundled Kronuz theme
# (./themes/Kronuz.tmTheme) registers; delta reads the same cache, so both pick it up.
# Debian ships bat as `batcat`; accept either. POSIX sh, sourced by ../setup.sh at
# install time; idempotent (re-running just rebuilds the cache).
_kronuz_bat=""
command -v bat    >/dev/null 2>&1 && _kronuz_bat=bat
[ -z "$_kronuz_bat" ] && command -v batcat >/dev/null 2>&1 && _kronuz_bat=batcat
if [ -n "$_kronuz_bat" ]; then
  # BAT_CONFIG_DIR points at this dir, where bat finds ./themes/.
  _kronuz_bat_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
  if BAT_CONFIG_DIR="$_kronuz_bat_dir" "$_kronuz_bat" cache --build >/dev/null 2>&1; then
    echo "built bat cache (Kronuz theme registered for bat + delta)"
  fi
  unset _kronuz_bat_dir
fi
unset _kronuz_bat
