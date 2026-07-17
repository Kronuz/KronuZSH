# shellcheck shell=bash
# vivid: the generator behind our rich $LS_COLORS. Runtime needs no vivid — lib/colors.zsh
# loads the committed integrations/vivid/ls_colors. This step only makes the Kronuz theme
# available to vivid (symlink into its config dir) so you can REGENERATE after editing
# integrations/vivid/kronuz.yml:  vivid generate kronuz > integrations/vivid/ls_colors
# Passive + idempotent (just places the theme file); no prompt. Sourced by ../setup.sh.
# install: brew install vivid · cargo install vivid
_kronuz_vivid_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
if command -v vivid >/dev/null 2>&1; then
  _kronuz_vdir="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes"
  mkdir -p "$_kronuz_vdir"
  ln -sf "$_kronuz_vivid_dir/kronuz.yml" "$_kronuz_vdir/kronuz.yml"
  kz_ok "vivid" "Kronuz theme available ($(kz_tilde "$_kronuz_vdir/kronuz.yml"))"
  kz_info "regenerate colours: vivid generate kronuz > $(kz_tilde "$_kronuz_vivid_dir/ls_colors")"
fi
unset _kronuz_vivid_dir _kronuz_vdir
