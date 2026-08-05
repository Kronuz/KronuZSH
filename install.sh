#!/usr/bin/env bash
#
# KronuZSH installer. Symlinks the runcoms into $HOME, backs up anything it
# replaces, and inits the plugin submodules. Idempotent: safe
# to re-run.
#
#   ./install.sh              install / refresh
#   ./install.sh --dry-run    show what would change
#   ./install.sh --files      list integration-managed files and backups
#   ./install.sh --force      replace conflicting integration settings
#   ./install.sh --hints      show optional usage and maintenance hints
#   ./install.sh --no-backup  modify files without keeping recovery copies
#   ./install.sh --uninstall  remove our symlinks and restore the backups
#
set -euo pipefail

# Preserve a symlinked installation path (for example ~/.local/share/KronuZSH)
# in the runcom links. Individual integrations resolve their assets physically.
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -L)"
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

# Compile every zsh script reached by normal startup, plus skins loaded on demand and
# generated integration code. The .zwc files sit beside their source, so zsh selects
# them natively and automatically falls back to newer text after a git update.
compile_zsh_sources() {
  if ! command -v zsh >/dev/null 2>&1; then
    kz_skip "zsh wordcode" "zsh unavailable"
    return 0
  fi

  local generated_dir result compiled current failed source existing seen
  local -a candidates sources=()
  generated_dir="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/generated"
  candidates=(
    "$here"/runcoms/*
    "$here"/lib/*.zsh
    "$here"/skins/*.zsh
    "$here"/integrations/init.zsh
    "$here"/integrations/*/init.zsh
    "$here"/plugins/gitstatus/gitstatus.plugin.zsh
    "$here"/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    "$here"/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    "$here"/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    "$here"/plugins/fast-syntax-highlighting/fast-highlight
    "$here"/plugins/fast-syntax-highlighting/fast-string-highlight
    "$generated_dir"/*.zsh
    "${FAST_WORK_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/fast-syntax-highlighting}"/current_theme.zsh
    "${FAST_WORK_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/fast-syntax-highlighting}"/secondary_theme.zsh
    "${FAST_WORK_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/fast-syntax-highlighting}"/theme_overlay.zsh
    "${XDG_CACHE_HOME:-$HOME/.cache}/fsh"/current_theme.zsh
    "${XDG_CACHE_HOME:-$HOME/.cache}/fsh"/secondary_theme.zsh
    "${XDG_CACHE_HOME:-$HOME/.cache}/fsh"/theme_overlay.zsh
    "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  )
  for source in "${candidates[@]}"; do
    case "$source" in *.zwc) continue ;; esac
    if [ ! -r "$source" ] || [ ! -f "$source" ]; then
      continue
    fi
    seen=
    if ((${#sources[@]})); then
      for existing in "${sources[@]}"; do
        if [ "$existing" = "$source" ]; then seen=1; break; fi
      done
    fi
    [ -z "$seen" ] && sources+=("$source")
  done

  kz_head "Shell bytecode" "⚡"
  if [ -n "$KRONUZ_DRY_RUN" ]; then
    kz_info "would compile ${#sources[@]} zsh source files"
    return 0
  fi

  if ((${#sources[@]})) && result="$(zsh "$here/zcompile.zsh" "${sources[@]}")"; then
    read -r compiled current failed <<< "$result"
    kz_ok "zsh wordcode" "${#sources[@]} files ready ($compiled refreshed, $current current)"
  elif ((${#sources[@]} == 0)); then
    kz_skip "zsh wordcode" "no readable source files found"
  else
    read -r compiled current failed <<< "${result:-0 0 1}"
    kz_skip "zsh wordcode" "$failed files could not be compiled; text fallback remains active"
  fi
}

install() {
  kz_title "KronuZSH"

  kz_head "Plugins" "🧩"
  if [ -n "$KRONUZ_DRY_RUN" ]; then
    kz_info "would initialize / update plugin submodules"
  elif git -C "$here" submodule update --init --recursive --quiet; then
    kz_ok "plugin submodules" "initialized / up to date"
  else
    kz_info "submodule update skipped (no git, or offline)"
  fi

  kz_head "Shell config" "🔗"
  local rc target link
  local -a runcom
  for rc in "${runcoms[@]}"; do
    target="$here/runcoms/$rc"
    link="$HOME/.$rc"
    runcom=("shell config" "$target" "$link")
    if kz_managed_link_active "${runcom[@]}"; then
      kz_manage_file "${runcom[0]}" "${runcom[2]}"
      kz_ok "$(kz_tilde "$link")" "already linked"
      continue
    fi
    kz_manage_link "${runcom[@]}"
    if [ -n "$KRONUZ_DRY_RUN" ]; then
      kz_info "planned $(kz_tilde "$link")"
    else
      kz_ok "$(kz_tilde "$link")" "linked"
    fi
  done

  # External-tool integrations' install-time setup (theme caches, opt-in wiring). Lives
  # in integrations/setup.sh (prints its own "Tool integrations" heading), guarded +
  # idempotent. shellcheck source=integrations/setup.sh
  source "$here/integrations/setup.sh"

  compile_zsh_sources

  recommend_tools

  kz_done "Done. Start a fresh shell:  exec zsh"
  kz_info "Personal tweaks (optional):  cp $here/zshrc.local.example ~/.zshrc.local"
}

uninstall() {
  kz_title "KronuZSH — uninstall"
  local rc link bak orig latest
  for rc in "${runcoms[@]}"; do
    link="$HOME/.$rc"
    if [[ -L "$link" && "$(readlink "$link")" == "$here/runcoms/$rc" ]]; then
      if [ -n "$KRONUZ_DRY_RUN" ]; then
        kz_info "would remove ~/.$rc"
      else
        rm -f "$link"
        kz_ok "removed ~/.$rc"
      fi
    fi
  done
  for rc in "${runcoms[@]}"; do
    orig="$HOME/.$rc"
    latest=
    for bak in "$KRONUZ_BACKUP_ROOT"/*/home/".$rc"; do
      [[ -e "$bak" || -L "$bak" ]] || continue
      latest="$bak"
    done
    if [[ -z "$latest" ]]; then
      for bak in "$orig".*.kronuzsh.bak; do
        [[ -e "$bak" || -L "$bak" ]] || continue
        latest="$bak"
      done
    fi
    [[ -n "$latest" ]] || continue
    if [ -n "$KRONUZ_DRY_RUN" ]; then
      kz_info "would restore $(kz_tilde "$orig") from $(kz_tilde "$latest")"
    else
      mv -f "$latest" "$orig"
      kz_ok "restored $orig"
    fi
  done
  kz_done "Uninstalled. Open a new shell."
}

action=install
for arg in "$@"; do
  case "$arg" in
    --uninstall|-u) action=uninstall ;;
    -h|--help)      action=help ;;
    *) kz_option "$arg" || { printf 'Unknown option: %s\n' "$arg" >&2; exit 2; } ;;
  esac
done
case "$action" in
  uninstall) uninstall ;;
  help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//' ;;
  install) install ;;
esac
