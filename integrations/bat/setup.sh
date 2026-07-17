# shellcheck shell=bash
# bat (+ delta): build bat's shared theme cache from integrations/themes. Debian ships
# bat as `batcat`, so either executable is accepted.

_kronuz_setup_bat() {
  local bat integration_dir cache_dir

  if command -v bat >/dev/null 2>&1; then
    bat=bat
  elif command -v batcat >/dev/null 2>&1; then
    bat=batcat
  else
    return
  fi

  integration_dir="$(cd -- "$(kz_script_dir "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)"

  if BAT_CONFIG_DIR="$integration_dir" "$bat" cache --build >/dev/null 2>&1; then
    kz_ok "bat + delta" "Kronuz theme cached"
    kz_hint "rebuild after editing: BAT_CONFIG_DIR=$(kz_tilde "$integration_dir") $bat cache --build"

    cache_dir="$("$bat" --cache-dir 2>/dev/null || true)"
    if [ -n "$cache_dir" ]; then
      kz_manage_file "bat theme cache" "$cache_dir"
    fi
  fi
}

_kronuz_setup_bat
unset -f _kronuz_setup_bat
