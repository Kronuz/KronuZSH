#!/usr/bin/env zsh
# Exercise initial compilation, a no-op refresh, source invalidation, and corrupt
# wordcode recovery without touching the checkout's own install-time caches.
emulate -L zsh
setopt err_return no_unset pipe_fail

local root=${0:A:h:h}
local scratch
scratch=$(mktemp -d "${TMPDIR:-/tmp}/kronuzsh-zcompile.XXXXXX")
trap '[[ $scratch == *kronuzsh-zcompile.* ]] && rm -rf -- "$scratch"' EXIT

local source=$scratch/fixture.zsh result output
print -r -- "typeset -g KZ_FIXTURE=one" > "$source"

result=$(zsh "$root/zcompile.zsh" "$source")
[[ $result == '1 0 0' && -r $source.zwc ]] || {
  print -u2 -r -- "initial compilation failed: $result"
  return 1
}
output=$(zsh -fc "source ${(q)source}; print -r -- \$KZ_FIXTURE")
[[ $output == one ]] || { print -u2 -r -- "compiled source returned: $output"; return 1; }

result=$(zsh "$root/zcompile.zsh" "$source")
[[ $result == '0 1 0' ]] || {
  print -u2 -r -- "current wordcode was rebuilt: $result"
  return 1
}

sleep 1
print -r -- "typeset -g KZ_FIXTURE=two" > "$source"
result=$(zsh "$root/zcompile.zsh" "$source")
[[ $result == '1 0 0' ]] || {
  print -u2 -r -- "newer source did not invalidate wordcode: $result"
  return 1
}
output=$(zsh -fc "source ${(q)source}; print -r -- \$KZ_FIXTURE")
[[ $output == two ]] || { print -u2 -r -- "refreshed source returned: $output"; return 1; }

chmod u+w "$source.zwc"
print -n corrupt > "$source.zwc"
touch "$source.zwc"
result=$(zsh "$root/zcompile.zsh" "$source")
[[ $result == '1 0 0' ]] || {
  print -u2 -r -- "invalid wordcode was not rebuilt: $result"
  return 1
}
zcompile -t "$source.zwc" >/dev/null

print -r -- "zcompile cache checks passed"
