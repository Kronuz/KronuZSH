# shellcheck shell=bash
# fast-syntax-highlighting: compile the bundled Kronuz theme into the plugin's active
# theme cache. The plugin and zsh must both be available.

_kronuz_setup_fsh() {
  command -v zsh >/dev/null 2>&1 || return

  local here plugin cache

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  plugin="$here/../../plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  cache="$(dirname "$plugin")/current_theme.zsh"

  [ -r "$plugin" ] || return

  if zsh -fc "source '$plugin'; fast-theme '$here/Kronuz.ini' -q" >/dev/null 2>&1; then
    kz_ok "fast-syntax-highlighting" "Kronuz theme applied"
    kz_manage_file "syntax theme cache" "$cache"
  fi
}

_kronuz_setup_fsh
unset -f _kronuz_setup_fsh
