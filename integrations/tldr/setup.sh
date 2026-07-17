# shellcheck shell=bash
# tealdeer (tldr): merge the Kronuz style into tealdeer's config and enable automatic
# cache updates while preserving every unrelated setting.

_kronuz_tldr_merge() {
  local theme="$1" config="$2" output="$3" rest

  rest="$(mktemp)"

  # Remove only style tables and normalize auto_update inside [updates].
  awk '
    function finish_updates() {
      if (in_updates && !auto_seen) print "auto_update = true"
    }
    /^\[style\.[^]]+\][[:space:]]*$/ { in_style = 1; next }
    /^\[[^]]+\][[:space:]]*$/ {
      if (in_style) in_style = 0
      finish_updates()
      in_updates = ($0 == "[updates]")
      if (in_updates) { updates_seen = 1; auto_seen = 0 }
      print
      next
    }
    in_style { next }
    in_updates && /^auto_update[[:space:]]*=/ {
      print "auto_update = true"
      auto_seen = 1
      next
    }
    { print }
    END {
      finish_updates()
      if (!updates_seen) print "\n[updates]\nauto_update = true"
    }
  ' "$config" > "$rest"

  {
    cat "$theme"
    printf '\n'
    cat "$rest"
  } > "$output"

  rm -f "$rest"
}

_kronuz_setup_tldr() {
  command -v tldr >/dev/null 2>&1 || return 0

  local here theme config_path replacement apply=0
  local -a config

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  theme="$here/kronuz.toml"

  # Ask tealdeer for its native path; older versions need a platform fallback.
  config_path="$(tldr --show-paths 2>/dev/null \
    | sed -n 's/^Config path:[[:space:]]*//p' \
    | sed -E 's/ \([^)]*\)$//' \
    | head -n1)"
  if [ -z "$config_path" ]; then
    case "$(uname -s)" in
      Darwin) config_path="$HOME/Library/Application Support/tealdeer/config.toml" ;;
      *)      config_path="${XDG_CONFIG_HOME:-$HOME/.config}/tealdeer/config.toml" ;;
    esac
  fi
  config=("tldr config" "$config_path")

  if [ -f "$config_path" ] \
    && grep -q '^# Kronuz theme for tealdeer' "$config_path" \
    && awk '/^\[updates\]/{s=1; next} /^\[/{s=0} s && /^auto_update[[:space:]]*=[[:space:]]*true/{ok=1} END{exit !ok}' "$config_path"; then
    kz_ok "tldr" "already themed"
  elif [ ! -f "$config_path" ]; then
    mkdir -p "$(dirname "$config_path")"
    if tldr --config-path "$config_path" --seed-config >/dev/null 2>&1; then
      apply=1
    else
      kz_skip "tldr" "could not seed config"
    fi
  elif kz_confirm "Enable the Kronuz theme for tldr"; then
    apply=1
  else
    kz_skip "tldr" "not themed"
    kz_info "enable later: re-run integrations/setup.sh and accept the tldr theme"
  fi

  if [ "$apply" -eq 1 ]; then
    replacement="$(mktemp)"
    _kronuz_tldr_merge "$theme" "$config_path" "$replacement"
    kz_commit_file "${config[@]}" "$replacement"
    kz_ok "tldr" "Kronuz theme set in $(kz_tilde "$config_path")"
  fi

  if [ -f "$config_path" ] \
    && grep -q '^# Kronuz theme for tealdeer' "$config_path"; then
    kz_manage_file "${config[@]}"
    kz_hint "refresh pages now: tldr --update"
  fi
}

_kronuz_setup_tldr
unset -f _kronuz_setup_tldr _kronuz_tldr_merge
