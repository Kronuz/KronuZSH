# glow: theme its Markdown rendering with the bundled Kronuz glamour style
# (./kronuz.json). The catch that wastes everyone's afternoon: glow the CLI does NOT read
# $GLAMOUR_STYLE — only the glamour *library* does, and glow bypasses that path. glow only
# themes when its own config's `style:` key (or a -s/--style flag) names a style, and that
# key happily takes a JSON path. So we point it there: write `style: <abs kronuz.json>`
# into glow's config — but only when you haven't already chosen one (current value is
# glow's default "auto", empty, or there's no config yet); your own pick is left alone.
# Backs the file up first and is idempotent. POSIX-ish bash, sourced by ../setup.sh at
# install time. install: brew install glow · or the prebuilt binary from
# https://github.com/charmbracelet/glow/releases into ~/.local/bin (it's Go).
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
  # current style: value, if any — strip the key, surrounding whitespace and quotes.
  _kronuz_glow_cur=''
  if [ -f "$_kronuz_glow_cfg" ]; then
    _kronuz_glow_cur="$(sed -n 's/^[[:space:]]*style:[[:space:]]*//p' "$_kronuz_glow_cfg" | head -n1)"
    _kronuz_glow_cur="${_kronuz_glow_cur%\"}"; _kronuz_glow_cur="${_kronuz_glow_cur#\"}"
    _kronuz_glow_cur="${_kronuz_glow_cur%\'}"; _kronuz_glow_cur="${_kronuz_glow_cur#\'}"
  fi
  if [ "$_kronuz_glow_cur" = "$_kronuz_glow_style" ]; then
    kz_skip "glow" "already themed"
  elif [ -n "$_kronuz_glow_cur" ] && [ "$_kronuz_glow_cur" != auto ]; then
    kz_skip "glow" "respecting your style: \"$_kronuz_glow_cur\""
    kz_info "enable later: set style to $(kz_tilde "$_kronuz_glow_style") via \`glow config\`"
  else
    mkdir -p "$(dirname "$_kronuz_glow_cfg")"
    _kronuz_glow_tmp="$(mktemp)"
    if [ -f "$_kronuz_glow_cfg" ]; then
      cp -p "$_kronuz_glow_cfg" "$_kronuz_glow_cfg.kronuz.bak"
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
