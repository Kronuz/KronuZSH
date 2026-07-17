# shellcheck shell=bash
# install.lib.sh — shared output + prompt helpers for the KronuZSH installer and the
# integrations' install-time setup steps. One small, consistent style: a title, bold
# section headings, and ✓/· status lines, plus a y/N prompt (kz_confirm). Everything
# degrades to plain text when stdout isn't a TTY or NO_COLOR is set, so a piped or
# logged install stays clean. Sourced by install.sh and by integrations/setup.sh
# (re-sourcing is harmless — it only (re)defines functions).
#
# Targets bash (install.sh is bash and sources this first). ✓ and · are plain Unicode
# and always used; colour and the wider emoji are gated on an interactive colour TTY.

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _kz_b=$'\033[1m'; _kz_d=$'\033[2m'; _kz_g=$'\033[32m'; _kz_c=$'\033[36m'
  _kz_rs=$'\033[0m'; _kz_fancy=1
else
  _kz_b=''; _kz_d=''; _kz_g=''; _kz_c=''; _kz_rs=''; _kz_fancy=0
fi

# _kz_em <emoji> <plain>: the emoji on a fancy TTY, the plain fallback otherwise.
_kz_em() { if [ "$_kz_fancy" = 1 ]; then printf '%s' "$1"; else printf '%s' "$2"; fi; }

# kz_title <text>: the installer banner.
kz_title() {
  printf '\n%s%s %s%s\n' "$_kz_b" "$(_kz_em '🐚' '::')" "$1" "$_kz_rs"
}

# kz_head <text> [emoji]: a section heading, Homebrew-style ==> plus an optional emoji.
kz_head() {
  local emoji=''
  if [ "$_kz_fancy" = 1 ] && [ -n "${2:-}" ]; then emoji="$2 "; fi
  printf '\n%s%s==>%s %s%s%s%s\n' "$_kz_b" "$_kz_c" "$_kz_rs" "$emoji" "$_kz_b" "$1" "$_kz_rs"
}

# kz_ok <label> [detail]: a completed step (green ✓, bold label, dim detail).
kz_ok() {
  if [ -n "${2:-}" ]; then
    printf '  %s✓%s %s%s%s  %s%s%s\n' "$_kz_g" "$_kz_rs" "$_kz_b" "$1" "$_kz_rs" "$_kz_d" "$2" "$_kz_rs"
  else
    printf '  %s✓%s %s%s%s\n' "$_kz_g" "$_kz_rs" "$_kz_b" "$1" "$_kz_rs"
  fi
}

# kz_skip <label> [detail]: an already-done / no-op step (dim · and text).
kz_skip() {
  if [ -n "${2:-}" ]; then
    printf '  %s·%s %s%s  %s%s\n' "$_kz_d" "$_kz_rs" "$_kz_d" "$1" "$2" "$_kz_rs"
  else
    printf '  %s· %s%s\n' "$_kz_d" "$1" "$_kz_rs"
  fi
}

# kz_info <text>: a dim, indented note.
kz_info() { printf '  %s%s%s\n' "$_kz_d" "$1" "$_kz_rs"; }

# kz_tilde <path>: print PATH with a leading $HOME collapsed to ~ (for tidy messages).
kz_tilde() { case "$1" in "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;; *) printf '%s' "$1" ;; esac; }

# kz_done <text>: the closing success line.
kz_done() { printf '\n%s%s %s%s%s\n' "$_kz_g" "$(_kz_em '✨' '✓')" "$_kz_b" "$1" "$_kz_rs"; }

# kz_confirm <question>: ask a y/N question (default No). Honors KRONUZ_YES / KRONUZ_NO
# for non-interactive installs; off a TTY (no answer possible) it defaults to No.
# Returns 0 for yes, 1 for no.
kz_confirm() {
  if [ -n "${KRONUZ_YES:-}" ]; then return 0; fi
  if [ -n "${KRONUZ_NO:-}" ];  then return 1; fi
  if [ -t 0 ] && [ -t 1 ]; then
    local _kz_ans=''
    printf '  %s%s? [y/N]%s ' "$_kz_c" "$1" "$_kz_rs"
    read -r _kz_ans 2>/dev/null || _kz_ans=''
    case "$_kz_ans" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
  fi
  return 1
}
