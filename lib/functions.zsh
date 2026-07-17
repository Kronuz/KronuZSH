# Small, generally useful shell functions. Machine- or tool-specific helpers
# belong in ~/.zshrc.local or the matching integration instead.

# Creates one directory (including missing parents), then enters it.
function mkdcd {
  (( $# == 1 )) || {
    print -u2 'usage: mkdcd directory'
    return 64
  }

  command mkdir -p -- "$1" && builtin cd -- "$1"
}
