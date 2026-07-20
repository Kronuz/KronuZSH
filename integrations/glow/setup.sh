# shellcheck shell=bash
# glow: point glow.yml at the bundled glamour theme and wrap at 120 columns.
# The CLI does not honor $GLAMOUR_STYLE, so both settings must live in glow's
# own config file.

_kronuz_setup_glow() {
  command -v glow >/dev/null 2>&1 || return 0

  local here style config_path current_style='' current_width='' temp set_style=
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
    current_width="$(sed -n 's/^[[:space:]]*width:[[:space:]]*//p' "$config_path" \
      | head -n1)"
    current_style="${current_style%\"}"
    current_style="${current_style#\"}"
    current_style="${current_style%\'}"
    current_style="${current_style#\'}"
  fi

  if [ "$current_style" = "$style" ]; then
    set_style=1
  elif [ -z "$KRONUZ_FORCE" ] \
    && [ -n "$current_style" ] \
    && [ "$current_style" != auto ]; then
    kz_skip "glow" "respecting your style: \"$current_style\""
    kz_info "enable later: set style to $(kz_tilde "$style") via \`glow config\`"
  else
    set_style=1
  fi

  if [ "$current_width" = 120 ] \
    && { [ "$current_style" = "$style" ] || [ -z "$set_style" ]; }; then
    kz_ok "glow" "already configured"
  else
    temp="$(mktemp)"

    if [ -f "$config_path" ]; then
      if [ -n "$set_style" ]; then
        grep -v -E '^[[:space:]]*(style|width):' "$config_path" > "$temp" || true
      else
        grep -v -E '^[[:space:]]*width:' "$config_path" > "$temp" || true
      fi
    else
      printf 'mouse: false\npager: false\nall: false\n' > "$temp"
    fi

    printf 'width: 120\n' >> "$temp"
    if [ -n "$set_style" ]; then
      printf 'style: "%s"\n' "$style" >> "$temp"
    fi
    kz_commit_file "${config[@]}" "$temp"
    kz_ok "glow" "configured in $(kz_tilde "$config_path")"
  fi

  if grep -Eq '^[[:space:]]*width:[[:space:]]*120[[:space:]]*$' "$config_path" 2>/dev/null; then
    kz_manage_file "${config[@]}"
    kz_hint "settings: width: 120 in $(kz_tilde "$config_path")"
  fi
}

_kronuz_setup_glow
unset -f _kronuz_setup_glow
