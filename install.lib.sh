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

: "${KRONUZ_FORCE:=}"
: "${KRONUZ_FILES:=}"
: "${KRONUZ_HINTS:=}"
: "${KRONUZ_NO_BACKUP:=}"

# Ephemeral managed-file registry. Integrations rebuild it on every setup run; it is
# an inventory of the active configuration, not a log of changes from this invocation.
declare -a _kz_managed_labels=() _kz_managed_paths=()

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _kz_b=$'\033[1m'
  _kz_d=$'\033[2m'
  _kz_g=$'\033[32m'
  _kz_c=$'\033[36m'
  _kz_rs=$'\033[0m'
  _kz_fancy=1
else
  _kz_b=''
  _kz_d=''
  _kz_g=''
  _kz_c=''
  _kz_rs=''
  _kz_fancy=0
fi

# _kz_em <emoji> <plain>: the emoji on a fancy TTY, the plain fallback otherwise.
_kz_em() {
  if [ "$_kz_fancy" = 1 ]; then
    printf '%s' "$1"
  else
    printf '%s' "$2"
  fi
}

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

# kz_skip <label> [detail]: a skipped / unavailable step (dim · and text).
kz_skip() {
  if [ -n "${2:-}" ]; then
    printf '  %s·%s %s%s  %s%s\n' "$_kz_d" "$_kz_rs" "$_kz_d" "$1" "$2" "$_kz_rs"
  else
    printf '  %s· %s%s\n' "$_kz_d" "$1" "$_kz_rs"
  fi
}

# kz_info <text>: a dim, indented note.
kz_info() {
  printf '  %s%s%s\n' "$_kz_d" "$1" "$_kz_rs"
}

# kz_hint <text>: an optional usage hint, shown only with --hints.
kz_hint() {
  if [ -n "$KRONUZ_HINTS" ]; then kz_info "$1"; fi
}

# kz_manage_file <label> <path>: declare a path currently managed by KronuZSH.
# Re-declaring a path updates its label and never duplicates the inventory entry.
kz_manage_file() {
  if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    printf 'kz_manage_file: expected <label> <path>\n' >&2
    return 2
  fi

  local label="$1" path="$2" i

  for ((i = 0; i < ${#_kz_managed_paths[@]}; i++)); do
    if [ "${_kz_managed_paths[i]}" = "$path" ]; then
      _kz_managed_labels[i]="$label"
      return 0
    fi
  done

  _kz_managed_labels+=("$label")
  _kz_managed_paths+=("$path")
}

# kz_show_managed_files: with --files, render the active inventory and every adjacent
# timestamped KronuZSH backup. Missing managed paths are omitted.
kz_show_managed_files() {
  [ -n "$KRONUZ_FILES" ] || return 0
  [ "${#_kz_managed_paths[@]}" -gt 0 ] || return 0

  local i label path backup

  kz_head "Managed files" "📁"

  for ((i = 0; i < ${#_kz_managed_paths[@]}; i++)); do
    label="${_kz_managed_labels[i]}"
    path="${_kz_managed_paths[i]}"

    if [ -e "$path" ] || [ -L "$path" ]; then
      kz_info "file ($label): $(kz_tilde "$path")"
    fi

    for backup in "$path".*.kronuzsh.bak; do
      [ -e "$backup" ] || [ -L "$backup" ] || continue
      kz_info "backup ($label): $(kz_tilde "$backup")"
    done
  done
}

# kz_tilde <path>: collapse a leading $HOME to ~ for tidy messages.
kz_tilde() {
  case "$1" in
    "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;;
    *)         printf '%s' "$1" ;;
  esac
}

# kz_script_dir <source>: resolve the physical directory containing a sourced script.
kz_script_dir() {
  if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    printf 'kz_script_dir: expected <source>\n' >&2
    return 2
  fi

  (cd -- "$(dirname -- "$1")" && pwd -P)
}

# kz_option <option>: apply one shared installer option. Returns 1 if unknown.
kz_option() {
  case "$1" in
    -f|--force)     KRONUZ_FORCE=1 ;;
    --files)        KRONUZ_FILES=1 ;;
    --hints)        KRONUZ_HINTS=1 ;;
    --no-backup)    KRONUZ_NO_BACKUP=1 ;;
    *)              return 1 ;;
  esac
}

# kz_backup [--move] <file>: copy FILE (preserving metadata), or move it with --move,
# to the shared timestamped backup convention. Prints the backup path for reporting.
kz_backup() {
  local mode=copy src backup stamp

  if [ "${1:-}" = --move ]; then
    mode=move
    shift
  fi
  src="$1"

  if [ -n "$KRONUZ_NO_BACKUP" ]; then
    if [ "$mode" = move ]; then
      rm -f "$src" || return
    fi
    return 0
  fi

  stamp="$(date +%Y%m%d%H%M%S)"
  backup="$src.$stamp.kronuzsh.bak"

  if [ "$mode" = move ]; then
    mv "$src" "$backup" || return
  else
    cp -p "$src" "$backup" || return
  fi
  printf '%s' "$backup"
}

# kz_backup_info <source> <backup>: report a backup unless --no-backup suppressed it.
kz_backup_info() {
  [ -n "$2" ] && kz_info "backed up $(kz_tilde "$1") -> $(kz_tilde "$2")"
}

# kz_backup_file <label> <path>: manage, copy, and report a user config file before
# editing it. With --no-backup the path is still registered, but no copy is created.
kz_backup_file() {
  if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    printf 'kz_backup_file: expected <label> <path>\n' >&2
    return 2
  fi

  local label="$1" path="$2" backup

  kz_manage_file "$label" "$path"
  backup="$(kz_backup "$path")" || return
  kz_backup_info "$path" "$backup"
}

# kz_commit_file <label> <path> <replacement>: atomically install a prepared config
# file. Parent creation, backup policy, and managed-file registration live here so an
# integration cannot accidentally perform only part of the ownership protocol.
kz_commit_file() {
  if [ "$#" -ne 3 ] || [ -z "$1" ] || [ -z "$2" ] || [ ! -f "$3" ]; then
    printf 'kz_commit_file: expected <label> <path> <replacement-file>\n' >&2
    return 2
  fi

  local label="$1" path="$2" replacement="$3"

  mkdir -p "$(dirname "$path")"
  if [ -f "$path" ] || [ -L "$path" ]; then
    kz_backup_file "$label" "$path"
  fi

  mv "$replacement" "$path"
  kz_manage_file "$label" "$path"
}

# kz_managed_link_active <label> <source> <destination>: whether a managed-link
# descriptor already points at its intended source. The label is accepted so callers
# can pass one descriptor unchanged to both link helpers.
kz_managed_link_active() {
  if [ "$#" -ne 3 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    printf 'kz_managed_link_active: expected <label> <source> <destination>\n' >&2
    return 2
  fi

  [ -L "$3" ] && [ "$(readlink "$3")" = "$2" ]
}

# kz_manage_link <label> <source> <destination>: declare and install a managed link.
# The operation is idempotent; conflicts pass through the shared backup policy.
kz_manage_link() {
  if [ "$#" -ne 3 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    printf 'kz_manage_link: expected <label> <source> <destination>\n' >&2
    return 2
  fi

  local label="$1" source="$2" destination="$3" backup

  kz_manage_file "$label" "$destination"
  kz_managed_link_active "$label" "$source" "$destination" && return 0

  mkdir -p "$(dirname "$destination")"

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    backup="$(kz_backup --move "$destination")" || return
    kz_backup_info "$destination" "$backup"
  fi

  ln -s "$source" "$destination"
}

# kz_done <text>: the closing success line.
kz_done() {
  printf '\n%s%s %s%s%s\n' "$_kz_g" "$(_kz_em '✨' '✓')" "$_kz_b" "$1" "$_kz_rs"
}

# kz_confirm <question>: ask a y/N question (default No). Honors KRONUZ_YES / KRONUZ_NO
# for non-interactive installs; off a TTY (no answer possible) it defaults to No.
# Returns 0 for yes, 1 for no.
kz_confirm() {
  if [ -n "$KRONUZ_FORCE" ] || [ -n "${KRONUZ_YES:-}" ]; then
    return 0
  fi
  if [ -n "${KRONUZ_NO:-}" ]; then
    return 1
  fi

  if [ -t 0 ] && [ -t 1 ]; then
    local _kz_ans=''

    printf '  %s%s? [y/N]%s ' "$_kz_c" "$1" "$_kz_rs"
    read -r _kz_ans 2>/dev/null || _kz_ans=''
    case "$_kz_ans" in
      [yY]|[yY][eE][sS]) return 0 ;;
      *)                  return 1 ;;
    esac
  fi

  return 1
}
