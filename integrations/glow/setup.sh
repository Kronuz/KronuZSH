# shellcheck shell=bash
# glow: point glow.yml at the bundled glamour theme. The CLI does not honor
# $GLAMOUR_STYLE, so the setting must live in glow's own config file.

_kronuz_setup_glow() {
  command -v glow >/dev/null 2>&1 || return

  local here style config_path current_style='' temp
  local -a config

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  style="$here/kronuz.json"

  # Ask glow for its platform-native path, then fall back for older versions.
  config_path="$(glow --help 2>/dev/null \
    | sed -n 's/.*--config string.*(default \(.*\))$/\1/p' \
    | head -n1)"
  if [ -z "$config_path" ]; then
    case "$(uname -s)" in
      Darwin) config_path="$HOME/Library/Preferences/glow/glow.yml" ;;
      *)      config_path="${XDG_CONFIG_HOME:-$HOME/.config}/glow/glow.yml" ;;
    esac
  fi
  config=("glow config" "$config_path")

  # Read style:, removing optional surrounding quotes.
  if [ -f "$config_path" ]; then
    current_style="$(sed -n 's/^[[:space:]]*style:[[:space:]]*//p' "$config_path" \
      | head -n1)"
    current_style="${current_style%\"}"
    current_style="${current_style#\"}"
    current_style="${current_style%\'}"
    current_style="${current_style#\'}"
  fi

  if [ "$current_style" = "$style" ]; then
    kz_ok "glow" "already themed"
  elif [ -z "$KRONUZ_FORCE" ] \
    && [ -n "$current_style" ] \
    && [ "$current_style" != auto ]; then
    kz_skip "glow" "respecting your style: \"$current_style\""
    kz_info "enable later: set style to $(kz_tilde "$style") via \`glow config\`"
  else
    temp="$(mktemp)"

    if [ -f "$config_path" ]; then
      grep -v -E '^[[:space:]]*style:' "$config_path" > "$temp" || true
    else
      printf 'mouse: false\npager: false\nwidth: 80\nall: false\n' > "$temp"
    fi

    printf 'style: "%s"\n' "$style" >> "$temp"
    kz_commit_file "${config[@]}" "$temp"
    kz_ok "glow" "Kronuz style set in $(kz_tilde "$config_path")"
  fi

  if grep -Fqx "style: \"$style\"" "$config_path" 2>/dev/null; then
    kz_manage_file "${config[@]}"
    kz_hint "theme setting: style: \"$(kz_tilde "$style")\" in $(kz_tilde "$config_path")"
  fi
}

_kronuz_setup_glow
unset -f _kronuz_setup_glow
