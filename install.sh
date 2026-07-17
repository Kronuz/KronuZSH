#!/usr/bin/env bash
#
# KronuZSH installer. Symlinks the runcoms into $HOME, backs up anything it
# replaces, and inits the plugin submodules. Idempotent: safe
# to re-run.
#
#   ./install.sh              install / refresh
#   ./install.sh --uninstall  remove our symlinks and restore the backups
#
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
runcoms=(zshenv zprofile zshrc zlogin zlogout)

# shellcheck source=install.lib.sh
source "$here/install.lib.sh"

# Return 0 if any of the given command names is on PATH.
_have_any() {
  local c
  for c in "$@"; do
    if command -v "$c" >/dev/null 2>&1; then return 0; fi
  done
  return 1
}

# Report which recommended CLI tools (the integrations.md catalog) are present, and name
# the missing ones — without installing anything (KronuZSH wires in whatever's there).
recommend_tools() {
  # "<name> <command(s) to probe>"; fd/bat ship under two names on Debian.
  local -a tools=(
    "fd fd fdfind" "bat bat batcat" "fzf fzf" "zoxide zoxide" "ripgrep rg"
    "git-delta delta" "eza eza" "yazi yazi" "lazygit lazygit" "hyperfine hyperfine"
    "jq jq" "yq yq" "dust dust" "duf duf" "btop btop" "procs procs" "sd sd"
    "tealdeer tldr" "tokei tokei" "glow glow" "xh xh"
  )
  local entry name total=0 have=0 missing=""
  local -a probes
  kz_head "Optional tools" "🧰"
  for entry in "${tools[@]}"; do
    name="${entry%% *}"
    total=$((total + 1))
    read -r -a probes <<< "${entry#* }"
    if _have_any "${probes[@]}"; then
      have=$((have + 1))
    else
      missing="$missing $name"
    fi
  done
  if [ -z "$missing" ]; then
    kz_ok "all $total recommended CLI tools installed"
  else
    kz_ok "$have of $total recommended CLI tools installed"
    kz_skip "missing:$missing"
    kz_info "install the rest from integrations.md (per-platform matrix); KronuZSH wires in whatever's present"
  fi
}

install() {
  kz_title "KronuZSH"

  kz_head "Plugins" "🧩"
  if git -C "$here" submodule update --init --recursive --quiet; then
    kz_ok "plugin submodules" "initialized / up to date"
  else
    kz_info "submodule update skipped (no git, or offline)"
  fi

  kz_head "Shell config" "🔗"
  local rc target link bak
  for rc in "${runcoms[@]}"; do
    target="$here/runcoms/$rc"
    link="$HOME/.$rc"
    if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
      kz_skip "$(kz_tilde "$link")" "already linked"
      continue
    fi
    if [[ -e "$link" || -L "$link" ]]; then
      bak="$(kz_backup --move "$link")"
      kz_info "backed up $(kz_tilde "$link") -> $(kz_tilde "$bak")"
    fi
    ln -s "$target" "$link"
    kz_ok "$(kz_tilde "$link")" "linked"
  done

  # External-tool integrations' install-time setup (theme caches, opt-in wiring). Lives
  # in integrations/setup.sh (prints its own "Tool integrations" heading), guarded +
  # idempotent. shellcheck source=integrations/setup.sh
  source "$here/integrations/setup.sh"

  recommend_tools

  kz_done "Done. Start a fresh shell:  exec zsh"
  kz_info "Personal tweaks (optional):  cp $here/zshrc.local.example ~/.zshrc.local"
}

uninstall() {
  kz_title "KronuZSH — uninstall"
  local rc link bak orig
  for rc in "${runcoms[@]}"; do
    link="$HOME/.$rc"
    if [[ -L "$link" && "$(readlink "$link")" == "$here/runcoms/$rc" ]]; then
      rm -f "$link"
      kz_ok "removed ~/.$rc"
    fi
  done
  for bak in "$HOME"/.z*.*.kronuzsh.bak; do
    [[ -e "$bak" ]] || continue
    orig="${bak%.*.kronuzsh.bak}"
    mv -f "$bak" "$orig"
    kz_ok "restored $orig"
  done
  kz_done "Uninstalled. Open a new shell."
}

case "${1:-}" in
  --uninstall|-u) uninstall ;;
  -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) install ;;
esac
