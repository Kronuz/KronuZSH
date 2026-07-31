#!/usr/bin/env zsh
# Compile sourceable zsh scripts in place. Zsh automatically prefers FILE.zwc when
# it is newer than FILE, and falls back to the text source after an update. The
# wordcode is install-time cache state: no runtime loader or manifest is required.
emulate -L zsh
setopt no_aliases

integer compiled=0 current=0 failed=0
local file wordcode

for file in "$@"; do
  [[ -r $file && -f $file ]] || continue
  wordcode=$file.zwc
  if [[ -r $wordcode && $wordcode -nt $file ]] \
    && zcompile -t "$wordcode" >/dev/null 2>&1; then
    (( ++current ))
  elif zcompile -UR -- "$file"; then
    (( ++compiled ))
  else
    print -u2 -r -- "could not compile: $file"
    (( ++failed ))
  fi
done

print -r -- "$compiled $current $failed"
(( failed == 0 ))
