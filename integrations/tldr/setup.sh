# shellcheck shell=bash
# tealdeer (tldr): merge the bundled Kronuz style into tealdeer's own config.
# A missing config is created with `tldr --seed-config`; an existing config is
# changed only after confirmation. It also enables tealdeer's own automatic cache
# updates while preserving the interval/source/TLS settings. The original is backed
# up, and the marker makes re-runs idempotent. Sourced by ../setup.sh.
_kronuz_tldr_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_kronuz_tldr_theme="$_kronuz_tldr_dir/kronuz.toml"
if command -v tldr >/dev/null 2>&1; then
  # Ask tealdeer for its platform-native path (not ~/.config on macOS), removing the
  # explanatory suffix printed by --show-paths. Fall back to the documented OS paths.
  _kronuz_tldr_cfg="$(tldr --show-paths 2>/dev/null \
    | sed -n 's/^Config path:[[:space:]]*//p' | sed -E 's/ \([^)]*\)$//' | head -n1)"
  if [ -z "$_kronuz_tldr_cfg" ]; then
    case "$(uname -s)" in
      Darwin) _kronuz_tldr_cfg="$HOME/Library/Application Support/tealdeer/config.toml" ;;
      *)      _kronuz_tldr_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/tealdeer/config.toml" ;;
    esac
  fi

  if [ -f "$_kronuz_tldr_cfg" ] \
    && grep -q '^# Kronuz theme for tealdeer' "$_kronuz_tldr_cfg" \
    && awk '/^\[updates\]/{s=1; next} /^\[/{s=0} s && /^auto_update[[:space:]]*=[[:space:]]*true/{ok=1} END{exit !ok}' "$_kronuz_tldr_cfg"; then
    kz_ok "tldr" "already themed"
  else
    _kronuz_tldr_apply=0
    if [ ! -f "$_kronuz_tldr_cfg" ]; then
      mkdir -p "$(dirname "$_kronuz_tldr_cfg")"
      if tldr --config-path "$_kronuz_tldr_cfg" --seed-config >/dev/null 2>&1; then
        _kronuz_tldr_apply=1
      else
        kz_skip "tldr" "could not seed config"
      fi
    elif kz_confirm "Enable the Kronuz theme for tldr"; then
      _kronuz_tldr_apply=1
    else
      kz_skip "tldr" "not themed"
      kz_info "enable later: re-run integrations/setup.sh and accept the tldr theme"
    fi

    if [ "$_kronuz_tldr_apply" -eq 1 ]; then
      _kronuz_tldr_bak="$(kz_backup "$_kronuz_tldr_cfg")"
      kz_info "backed up $(kz_tilde "$_kronuz_tldr_cfg") -> $(kz_tilde "$_kronuz_tldr_bak")"
      _kronuz_tldr_rest="$(mktemp)"
      _kronuz_tldr_new="$(mktemp)"
      # Drop only [style.*] tables and enable auto_update inside [updates]. Preserve
      # every other table/key, including the update interval, source, and TLS backend.
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
      ' "$_kronuz_tldr_cfg" > "$_kronuz_tldr_rest"
      {
        cat "$_kronuz_tldr_theme"
        printf '\n'
        cat "$_kronuz_tldr_rest"
      } > "$_kronuz_tldr_new"
      mv "$_kronuz_tldr_new" "$_kronuz_tldr_cfg"
      rm -f "$_kronuz_tldr_rest"
      kz_ok "tldr" "Kronuz theme set in $(kz_tilde "$_kronuz_tldr_cfg")"
    fi
  fi
  unset _kronuz_tldr_apply _kronuz_tldr_bak _kronuz_tldr_cfg _kronuz_tldr_new _kronuz_tldr_rest
fi
unset _kronuz_tldr_dir _kronuz_tldr_theme
