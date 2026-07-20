#!/usr/bin/env zsh

# Compare real interactive prompt streams from a reference tree and this checkout.
# The reference may be an archive or worktree; it needs only the KronuZSH source, not
# these harness scripts.
set -eu

[[ $# == 1 && -r "$1/runcoms/zshrc" ]] || {
  print -u2 'usage: check-prompt-streams.zsh REFERENCE_KRONUZSH_ROOT'
  exit 2
}

local reference=${1:A}
local current=${0:A:h:h}
local work
work=$(mktemp -d "${TMPDIR:-/tmp}/kronuzsh-prompt-streams.XXXXXX")
trap 'rm -rf "$work"' EXIT

local -a scenarios=(
  iterm-transient
  generic-transient
  iterm-static
  generic-static
  iterm-disabled
  generic-disabled
)

local scenario side root
for scenario in $scenarios; do
  for side in reference current; do
    if [[ $side == reference ]]; then
      root=$reference
    else
      root=$current
    fi
    /usr/bin/expect "$current/scripts/capture-prompt-stream.exp" \
      "$work/${scenario}.${side}.raw" "$scenario" "$root" >/dev/null
    zsh "$current/scripts/normalize-prompt-stream.zsh" \
      "$work/${scenario}.${side}.raw" "$work/${scenario}.${side}.norm" "$root"
  done
  if cmp -s "$work/${scenario}.reference.norm" "$work/${scenario}.current.norm"; then
    print "ok  $scenario"
  else
    print -u2 "FAIL  $scenario"
    cmp -l "$work/${scenario}.reference.norm" "$work/${scenario}.current.norm" | head -n 20 >&2
    exit 1
  fi
done
