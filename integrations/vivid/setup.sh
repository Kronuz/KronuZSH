# shellcheck shell=bash
# vivid: the generator behind our rich $LS_COLORS. Runtime needs no vivid — lib/colors.zsh
# loads the committed integrations/vivid/ls_colors. This step only makes the Kronuz theme
# available to vivid (symlink into its config dir) so you can REGENERATE after editing
# integrations/vivid/kronuz.yml:  vivid generate kronuz > integrations/vivid/ls_colors
# Idempotent: an existing Kronuz theme is left alone unless confirmed or --force is
# used. Sourced by ../setup.sh.
# install: brew install vivid · cargo install vivid
_kronuz_vivid_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
if command -v vivid >/dev/null 2>&1; then
  _kronuz_vdir="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes"
  _kronuz_vlink="$_kronuz_vdir/kronuz.yml"
  if kz_is_link "$_kronuz_vivid_dir/kronuz.yml" "$_kronuz_vlink"; then
    kz_ok "vivid" "Kronuz theme already available"
  elif { [ ! -e "$_kronuz_vlink" ] && [ ! -L "$_kronuz_vlink" ]; } \
    || kz_confirm "Replace $(kz_tilde "$_kronuz_vlink") with the Kronuz theme"; then
    kz_link "$_kronuz_vivid_dir/kronuz.yml" "$_kronuz_vlink"
    kz_ok "vivid" "Kronuz theme available ($(kz_tilde "$_kronuz_vlink"))"
    kz_info "after editing: vivid generate kronuz > $(kz_tilde "$_kronuz_vivid_dir/ls_colors")"
  else
    kz_skip "vivid" "respecting existing theme at $(kz_tilde "$_kronuz_vlink")"
  fi
fi
unset _kronuz_vdir _kronuz_vivid_dir _kronuz_vlink
