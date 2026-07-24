#!/usr/bin/env zsh

# Preserve every control byte while replacing values that necessarily vary between
# runs. This is intentionally narrow: a protocol or cursor-motion change must survive
# normalization and fail the golden comparison.
set -eu
setopt extendedglob

[[ $# == 2 || $# == 3 ]] || {
  print -u2 'usage: normalize-prompt-stream.zsh INPUT OUTPUT [KRONUZSH_ROOT]'
  exit 2
}

local input=$1 output=$2
data="$(<"$input")"

# Wall-clock prompt values.
data=${data//(#m)\[[0-9]##:[0-9]##:[0-9]##\]/'[TIME]'}
# `script`/expect may expose a host-specific default prompt before KronuZSH loads.
data=${data//Germans-MacBook-Pro.local/'[FQDN]'}
data=${data//Germans-MacBook-Pro/'[HOST]'}
if [[ $# == 3 ]]; then
  local root=${3:A}
  data=${data//$root/'[ROOT]'}
fi
data=${data//\/Users\/kronuz\/code\/KronuZSH/'[ROOT]'}
data=${data//\/private\/tmp\/KronuZSH-baseline/'[ROOT]'}
data=${data//\/tmp\/KronuZSH-baseline/'[ROOT]'}

print -rn -- "$data" >| "$output"
