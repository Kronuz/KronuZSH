#!/usr/bin/env zsh
# Bundled skins are declarative configuration, never executable prompt code.
emulate -L zsh
setopt err_return null_glob

local file line
local -i number failed=0
for file in skins/*.zsh; do
  number=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    (( ++number ))
    [[ -z "${line//[[:space:]]/}" || "$line" =~ '^[[:space:]]*#' ]] && continue
    if [[ ! "$line" =~ '^KZ_[A-Z0-9_]+=' ]]; then
      print -u2 -r -- "$file:$number: skins may contain only KZ_* assignments"
      failed=1
    fi
  done < "$file"
done

return failed
