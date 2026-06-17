#!/usr/bin/env bash
#
# kronuzsh installer. Symlinks the runcoms into $HOME, backs up anything it
# replaces, inits the plugin submodules, and seeds local.zsh. Idempotent: safe
# to re-run.
#
#   ./install.sh              install / refresh
#   ./install.sh --uninstall  remove our symlinks and restore the backups
#
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
runcoms=(zshenv zprofile zshrc zlogin zlogout)
stamp="$(date +%Y%m%d%H%M%S)"

install() {
  git -C "$here" submodule update --init --recursive --quiet || true

  if [[ ! -e "$here/local.zsh" && -e "$here/local.zsh.example" ]]; then
    cp "$here/local.zsh.example" "$here/local.zsh"
    echo "seeded local.zsh from the example"
  fi

  local rc target link
  for rc in "${runcoms[@]}"; do
    target="$here/runcoms/$rc"
    link="$HOME/.$rc"
    if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
      continue  # already ours
    fi
    if [[ -e "$link" || -L "$link" ]]; then
      mv "$link" "$link.kronuzsh-bak.$stamp"
      echo "backed up $link -> .${rc}.kronuzsh-bak.$stamp"
    fi
    ln -s "$target" "$link"
    echo "linked  ~/.$rc -> $target"
  done

  # git-delta: use it as git's diff pager and `git add -p` highlighter, guarded
  # with `command -v delta` so a box without delta falls back to less/cat. Set
  # in the global gitconfig (the env can't carry interactive.diffFilter), and
  # idempotent: re-running just re-sets the same keys.
  if command -v git >/dev/null; then
    git config --global core.pager \
      'if command -v delta >/dev/null 2>&1; then delta; else less; fi'
    git config --global interactive.diffFilter \
      'if command -v delta >/dev/null 2>&1; then delta --color-only; else cat; fi'
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    echo "configured git to use delta when available (falls back to less)"
  fi

  echo
  echo "done. start a fresh shell:  exec zsh"
}

uninstall() {
  local rc link bak orig
  for rc in "${runcoms[@]}"; do
    link="$HOME/.$rc"
    if [[ -L "$link" && "$(readlink "$link")" == "$here/runcoms/$rc" ]]; then
      rm -f "$link"
      echo "removed ~/.$rc"
    fi
  done
  for bak in "$HOME"/.z*.kronuzsh-bak.*; do
    [[ -e "$bak" ]] || continue
    orig="${bak%.kronuzsh-bak.*}"
    mv -f "$bak" "$orig"
    echo "restored $orig"
  done
  echo "uninstalled. open a new shell."
}

case "${1:-}" in
  --uninstall|-u) uninstall ;;
  -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) install ;;
esac
