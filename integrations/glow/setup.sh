# shellcheck shell=bash
# glow: point glow's own `style:` setting at the bundled glamour theme. The CLI does
# not read $GLAMOUR_STYLE, so this must live in glow.yml. Existing custom styles are
# respected unless --force is used. Sourced by ../setup.sh; idempotent.
_kronuz_glow_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_kronuz_glow_style="$_kronuz_glow_dir/kronuz.json"
if command -v glow >/dev/null 2>&1; then
  # glow prints its resolved config path in --help (it uses go-app-paths, so macOS is
  # ~/Library/Preferences, not Application Support); ask glow itself, fall back per-OS.
  _kronuz_glow_cfg="$(glow --help 2>/dev/null | sed -n 's/.*--config string.*(default \(.*\))$/\1/p' | head -n1)"
  if [ -z "$_kronuz_glow_cfg" ]; then
    case "$(uname -s)" in
      Darwin) _kronuz_glow_cfg="$HOME/Library/Preferences/glow/glow.yml" ;;
      *)      _kronuz_glow_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/glow/glow.yml" ;;
    esac
  fi
  # Read the current style, stripping the key, whitespace, and optional quotes.
  _kronuz_glow_cur=''
  if [ -f "$_kronuz_glow_cfg" ]; then
    _kronuz_glow_cur="$(sed -n 's/^[[:space:]]*style:[[:space:]]*//p' "$_kronuz_glow_cfg" | head -n1)"
    _kronuz_glow_cur="${_kronuz_glow_cur%\"}"
    _kronuz_glow_cur="${_kronuz_glow_cur#\"}"
    _kronuz_glow_cur="${_kronuz_glow_cur%\'}"
    _kronuz_glow_cur="${_kronuz_glow_cur#\'}"
  fi

  if [ "$_kronuz_glow_cur" = "$_kronuz_glow_style" ]; then
    kz_ok "glow" "already themed"
  elif [ -z "$KRONUZ_FORCE" ] \
    && [ -n "$_kronuz_glow_cur" ] \
    && [ "$_kronuz_glow_cur" != auto ]; then
    kz_skip "glow" "respecting your style: \"$_kronuz_glow_cur\""
    kz_info "enable later: set style to $(kz_tilde "$_kronuz_glow_style") via \`glow config\`"
  else
    mkdir -p "$(dirname "$_kronuz_glow_cfg")"
    _kronuz_glow_tmp="$(mktemp)"
    if [ -f "$_kronuz_glow_cfg" ]; then
      kz_backup_file "$_kronuz_glow_cfg"
      grep -v -E '^[[:space:]]*style:' "$_kronuz_glow_cfg" > "$_kronuz_glow_tmp" || true
    else
      printf 'mouse: false\npager: false\nwidth: 80\nall: false\n' > "$_kronuz_glow_tmp"
    fi
    printf 'style: "%s"\n' "$_kronuz_glow_style" >> "$_kronuz_glow_tmp"
    mv "$_kronuz_glow_tmp" "$_kronuz_glow_cfg"
    kz_ok "glow" "Kronuz style set in $(kz_tilde "$_kronuz_glow_cfg")"
  fi
  unset _kronuz_glow_cfg _kronuz_glow_cur _kronuz_glow_tmp
fi
unset _kronuz_glow_dir _kronuz_glow_style
