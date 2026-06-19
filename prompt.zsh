#
# Kronuz prompt — a thin, framework-free zsh prompt (ported off a prezto theme).
#
# Author: German M. Bravo (Kronuz) <german.mb@gmail.com>
#
# Architecture
# ------------
# Two entry points, wired up by runcoms/zshrc:
#   prompt_kronuz_setup   runs once: builds the $PROMPT / $RPROMPT templates and
#                         registers the precmd / preexec / zle hooks.
#   prompt_kronuz_precmd  runs before every prompt: recomputes the dynamic pieces
#                         (git, venv, cwd, command duration, ...).
# zsh then re-renders $PROMPT at each prompt with PROMPT_SUBST enabled.
#
# $PROMPT is assembled from deferred strings. Each segment is
#   ${(e)PROMPT_KRONUZ_<NAME>:-$DEFAULT_PROMPT_KRONUZ_<NAME>}
# i.e. a user override or the built-in default, re-expanded ((e) flag) every render.
# Two arrays feed the segments, each element overridable:
#   $col    named colour palette         ($col[red], $col[chartreuse], ...)
#   $glyph  icon set, Nerd Font or plain  ($glyph[branch], $glyph[venv], ...)
#
# Naming: $_prompt_kronuz_* holds a rendered segment string spliced into $PROMPT;
# $_kronuz_* holds internal state and flags.
#
# Git status comes from gitstatus (gitstatusd), with a direct-git fallback. The
# venv / keymap / cwd segments are small native pieces (prezto used its python-info
# / editor-info / prompt-pwd modules for these).
#

# ============================================================================
# Colours
# ============================================================================

# Base palette: named %F{...} entries. ANSI 0..15 stay symbolic so they track the
# terminal theme; 16..255 are exact hex (truecolor), downsampled by zsh/nearcolor
# on non-truecolor terminals (loaded in setup). Overridable: $col is public, users
# reference $col[name] in their $PROMPT_KRONUZ_COLOR_* overrides.
unset col
typeset -gA col=(
  black                '%F{0}'        red                  '%F{1}'
  lightgreen           '%F{10}'       olive                '%F{#878700}'
  darkkhaki            '%F{#87875f}'  gray                 '%F{#878787}'
  lavender             '%F{#8787af}'  mediumpurple         '%F{#8787d7}'
  mediumslateblue      '%F{#8787ff}'  darkolivegreen       '%F{#87af5f}'
  darkseagreen         '%F{#87af87}'  powderblue           '%F{#87afaf}'
  lightyellow          '%F{11}'       skyblue              '%F{#87afd7}'
  cornflowerblue       '%F{#87afff}'  lawngreen            '%F{#87d700}'
  palegreen            '%F{#87d787}'  mediumaquamarine     '%F{#87d7af}'
  cadetblue            '%F{#87d7d7}'  lightskyblue         '%F{#87d7ff}'
  chartreuse           '%F{#87ff00}'  limegreen            '%F{#87ff5f}'
  lightblue            '%F{12}'       aquamarine           '%F{#87ffaf}'
  darkred              '%F{#af0000}'  mediumvioletred      '%F{#af005f}'
  darkmagenta          '%F{#af0087}'  purple               '%F{#af00af}'
  darkviolet           '%F{#af00d7}'  fuchsia              '%F{#af00ff}'
  lightmagenta         '%F{13}'       chocolate            '%F{#af5f00}'
  lightcoral           '%F{#af5f5f}'  palevioletred        '%F{#af5f87}'
  orchid               '%F{#af5faf}'  mediumorchid         '%F{#af5fd7}'
  darkorchid           '%F{#af5fff}'  darkgoldenrod        '%F{#af8700}'
  burlywood            '%F{#af875f}'  rosybrown            '%F{#af8787}'
  plum                 '%F{#af87af}'  lightcyan            '%F{14}'
  violet               '%F{#af87d7}'  khaki                '%F{#afaf5f}'
  palegoldenrod        '%F{#afaf87}'  darkgray             '%F{#afafaf}'
  slategray            '%F{#afafd7}'  lightsteelblue       '%F{#afafff}'
  yellowgreen          '%F{#afd75f}'  lightgrey            '%F{15}'
  honeydew             '%F{#afd7af}'  paleturquoise        '%F{#afd7d7}'
  greenyellow          '%F{#afff5f}'  dimgray              '%F{#000000}'
  tomato               '%F{#d70000}'  deeppink             '%F{#d7005f}'
  darkorange           '%F{#d75f00}'  indianred            '%F{#d75f5f}'
  hotpink              '%F{#d75f87}'  navy                 '%F{#00005f}'
  goldenrod            '%F{#d78700}'  lightsalmon          '%F{#d7875f}'
  lightpink            '%F{#d787af}'  gold                 '%F{#d7af00}'
  sandybrown           '%F{#d7af5f}'  darkblue             '%F{#000087}'
  tan                  '%F{#d7af87}'  mistyrose            '%F{#d7afaf}'
  thistle              '%F{#d7afd7}'  lemonchiffon         '%F{#d7d7af}'
  whitesmoke           '%F{#d7d7d7}'  ghostwhite           '%F{#d7d7ff}'
  mediumblue           '%F{#0000af}'  azure                '%F{#d7ffff}'
  orangered            '%F{#ff0000}'  crimson              '%F{#ff005f}'
  green                '%F{2}'        salmon               '%F{#ff5f5f}'
  orange               '%F{#ff8700}'  coral                '%F{#ff875f}'
  peru                 '%F{#ffaf5f}'  darksalmon           '%F{#ffaf87}'
  pink                 '%F{#ffafd7}'  darkgreen            '%F{#005f00}'
  navajowhite          '%F{#ffd7af}'  peachpuff            '%F{#ffd7d7}'
  teal                 '%F{#005f5f}'  lightgoldenrodyellow '%F{#ffffd7}'
  white                '%F{#ffffff}'  darkcyan             '%F{#005f87}'
  deepskyblue          '%F{#005faf}'  silver               '%F{#bcbcbc}'
  lightgray            '%F{#c6c6c6}'  gainsboro            '%F{#d0d0d0}'
  dodgerblue           '%F{#005fd7}'  yellow               '%F{3}'
  darkturquoise        '%F{#0087af}'  mediumspringgreen    '%F{#00af5f}'
  aqua                 '%F{#00afff}'  blue                 '%F{4}'
  lime                 '%F{#00d700}'  springgreen          '%F{#00d75f}'
  magenta              '%F{5}'        maroon               '%F{#5f0000}'
  indigo               '%F{#5f0087}'  cyan                 '%F{6}'
  lightslategray       '%F{#5f5f87}'  darkslateblue        '%F{#5f5faf}'
  slateblue            '%F{#5f5fd7}'  darkslategray        '%F{#5f8787}'
  steelblue            '%F{#5f87d7}'  royalblue            '%F{#5f87ff}'
  grey                 '%F{7}'        mediumseagreen       '%F{#5fd787}'
  darkgrey             '%F{8}'        mediumturquoise      '%F{#5fd7d7}'
  forestgreen          '%F{#5fff5f}'  turquoise            '%F{#5fffd7}'
  lightred             '%F{9}'        blueviolet           '%F{#8700ff}'
  brown                '%F{#875f00}'
)

# The 16 ANSI colours, by palette name -> index. They default to symbolic %F{N} (above)
# so they track the terminal theme, but each is overridable to a concrete colour via
# $PROMPT_KRONUZ_PALETTE_<NAME> (a #RRGGBB or a 0-255 index), applied to $col in
# prompt_kronuz_colors and fed to `dim`'s RGB in _kronuz_load_palette.
typeset -gA _kronuz_basic=(
  black 0  red 1  green 2  yellow 3  blue 4  magenta 5  cyan 6  grey 7
  darkgrey 8  lightred 9  lightgreen 10  lightyellow 11  lightblue 12
  lightmagenta 13  lightcyan 14  lightgrey 15
)

# Resolve a colour to (r g b), into $reply: a #rrggbb hex, a 0-255 index, or a basic
# colour name. $reply is left empty if it can't be resolved. Indices 0..15 use the
# terminal's queried palette ($_kronuz_pal) when available, else the xterm defaults.
function _kronuz_color_rgb {
  emulate -L zsh -o extendedglob
  local v=$1; reply=()
  if [[ $v = (#i)'#'[0-9a-f](#c6) ]]; then
    reply=( $(( 16#${v[2,3]} )) $(( 16#${v[4,5]} )) $(( 16#${v[6,7]} )) ); return
  fi
  local -A nm=(black 0 red 1 green 2 yellow 3 blue 4 magenta 5 cyan 6 white 7)
  [[ -n ${nm[$v]-} ]] && v=${nm[$v]}
  [[ $v = <0-255> ]] || return
  local -i n=$v
  if (( n < 16 )); then
    if [[ -n ${_kronuz_pal[$n]-} ]]; then reply=( ${=_kronuz_pal[$n]} ); return; fi
    local -a sys=(000000 cd0000 00cd00 cdcd00 0000ee cd00cd 00cdcd e5e5e5
                  7f7f7f ff0000 00ff00 ffff00 5c5cff ff00ff 00ffff ffffff)
    local h=${sys[n+1]}
    reply=( $(( 16#${h[1,2]} )) $(( 16#${h[3,4]} )) $(( 16#${h[5,6]} )) )
  elif (( n < 232 )); then
    local -i i=n-16; local -a lv=(0 95 135 175 215 255)
    reply=( ${lv[i/36+1]} ${lv[i/6%6+1]} ${lv[i%6+1]} )
  else
    local -i l=8+10*(n-232); reply=( $l $l $l )
  fi
}

# Query the terminal's 16 ANSI colours (OSC 4) into $_kronuz_pal, so `dim` darkens the
# real theme rather than a guessed table. A no-op (leaving the xterm-default fallback in
# place) without a tty, or on tmux/screen/dumb. The budget ($PROMPT_KRONUZ_PALETTE_TIMEOUT,
# default 0.6s) is generous so the round-trip survives a slow link (e.g. a remote shell
# over the network); the loop still exits the instant all 16 answers arrive, so a local
# terminal pays nothing.
typeset -gA _kronuz_pal
function _kronuz_query_palette {
  emulate -L zsh -o extendedglob
  _kronuz_pal=()
  [[ -t 0 && -t 1 ]] || return
  [[ "$TERM" = (dumb|unknown|linux) || -n "${TMUX-}" || "$TERM" = (screen*|tmux*) ]] && return
  zmodload zsh/datetime zsh/system 2>/dev/null || return
  local saved chunk resp='' piece
  saved="$(stty -g 2>/dev/null)" || return
  {
    stty -echo -icanon min 0 time 0 2>/dev/null
    local -i i; for i in {0..15}; do print -n -- "\e]4;${i};?\e\\"; done
    local -F end=$(( EPOCHREALTIME + ${PROMPT_KRONUZ_PALETTE_TIMEOUT:-0.6} )); local -i n=0
    while (( EPOCHREALTIME < end && n < 16 )); do
      chunk=''; sysread -t 0.05 chunk 2>/dev/null
      resp+="$chunk"
      n=$(( (${#resp} - ${#${resp//;rgb:/}}) / 5 ))
    done
  } always {
    stty "$saved" 2>/dev/null
  }
  for piece in "${(@ps.\e]4;.)resp}"; do
    [[ "$piece" = (#b)(<0-15>)';rgb:'([0-9a-fA-F]##)'/'([0-9a-fA-F]##)'/'([0-9a-fA-F]##)* ]] || continue
    _kronuz_pal[${match[1]}]="$(( 16#${match[2][1,2]} )) $(( 16#${match[3][1,2]} )) $(( 16#${match[4][1,2]} ))"
  done
}

# Populate $_kronuz_pal (RGB of the 16 ANSI colours) for `dim`. The base layer is the
# terminal's real colours, from a fresh on-disk cache (kept $PROMPT_KRONUZ_PALETTE_TTL
# seconds, default a day, per terminal; TTL=0 disables it) or a one-off OSC 4 query.
# Per-colour $PROMPT_KRONUZ_PALETTE_<NAME> overrides then win on top (never cached); if
# all 16 are overridden the terminal is never queried at all. Run once from the first
# precmd, so overrides / TTL / timeout set in local.zsh are in effect.
function _kronuz_load_palette {
  emulate -L zsh -o extendedglob
  zmodload zsh/datetime 2>/dev/null
  zmodload -F zsh/stat b:zstat 2>/dev/null
  _kronuz_pal=()

  local name ov reply
  local -i n_over=0
  for name in ${(k)_kronuz_basic}; do
    ov="PROMPT_KRONUZ_PALETTE_${name:u}"; [[ -n "${(P)ov}" ]] && (( n_over++ ))
  done

  # Base layer: the terminal's real colours, unless every basic is overridden.
  if (( n_over < 16 )); then
    local -i ttl=${PROMPT_KRONUZ_PALETTE_TTL:-86400}
    local term="${LC_TERMINAL:-${TERM_PROGRAM:-$TERM}}"
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/palette-${term//[^A-Za-z0-9._-]/_}"
    local -a mt
    if (( ttl > 0 )) && [[ -r $cache ]] && zstat -A mt +mtime -- $cache 2>/dev/null \
       && (( EPOCHSECONDS - mt[1] < ttl )); then
      local k r g b
      while read -r k r g b; do _kronuz_pal[$k]="$r $g $b"; done < $cache
      (( ${#_kronuz_pal} == 16 )) || _kronuz_pal=()
    fi
    if (( ${#_kronuz_pal} != 16 )); then
      _kronuz_query_palette
      if (( ttl > 0 && ${#_kronuz_pal} == 16 )); then
        mkdir -p ${cache:h} 2>/dev/null && {
          local k; for k in ${(onk)_kronuz_pal}; do print -r -- "$k ${_kronuz_pal[$k]}"; done
        } > $cache 2>/dev/null
      fi
    fi
  fi

  # Per-colour overrides win (from local.zsh); resolved to RGB, never cached.
  for name in ${(k)_kronuz_basic}; do
    ov="PROMPT_KRONUZ_PALETTE_${name:u}"; [[ -n "${(P)ov}" ]] || continue
    _kronuz_color_rgb "${(P)ov}"
    (( ${#reply} )) && _kronuz_pal[${_kronuz_basic[$name]}]="${reply[*]}"
  done
}

# Semantic colours: map each prompt element to a base-palette colour, resolved with
# the live palette into the same $col array the segments read ($col[host], $col[branch],
# ...). Mirrors prompt_kronuz_glyphs: a defaults table, then one loop that applies any
# $PROMPT_KRONUZ_COLOR_<NAME> override and writes the final value. No-colour mode
# ($_kronuz_nocolor) blanks the built-in defaults (so the layout still renders with zero
# escapes) while still honouring an explicit override. Recomputed every precmd, so
# toggling $NO_COLOR / $TERM takes effect on the next prompt.
function prompt_kronuz_colors {
  # Apply any per-colour overrides to the 16 ANSI basics (defaults live in the $col
  # palette table above); semantic colours below reference them, and `dim` picks up the
  # same overrides via _kronuz_load_palette.
  local bn bov
  for bn in ${(k)_kronuz_basic}; do
    bov="PROMPT_KRONUZ_PALETTE_${bn:u}"
    [[ -n "${(P)bov}" ]] && col[$bn]="%F{${(P)bov}}"
  done

  local -A d=(
    primary1   '%(!.%B$col[red].%B$col[red])'
    primary2   '%(!.%B$col[red].%B$col[yellow])'
    primary3   '%(!.$col[red].%B$col[green])'
    status_err '$col[red]'
    status_ok  '$col[green]'
    venv       '$col[white]'
    vim        '%B$col[green]'
    emacs      '%B$col[green]'
    etctl      '%B$col[magenta]'
    overwrite  '$col[red]'
    insert     '$col[darkgrey]'
    completing '%B$col[black]'
    jobs       '$col[gold]'
    duration   '$col[goldenrod]'
    ssh        '$col[mediumpurple]'
    container  '$col[deepskyblue]'
    transient  '$col[darkgrey]'
    action     '$col[darkorange]'
    added      '$col[darkorange]'
    ahead      '$col[chartreuse]'
    behind     '$col[deeppink]'
    dirty      '$col[brown]'
    clean      '$col[forestgreen]'
    branch     '%B$col[white]'
    remote     '$col[white]'
    commit     '$col[white]'
    deleted    '$col[red]'
    modified   '$col[red]'
    position   '$col[white]'
    renamed    '$col[darkorange]'
    stashed    '$col[lightsteelblue]'
    unmerged   '$col[red]'
    indexed    '$col[darkorange]'
    unindexed  '$col[red]'
    untracked  '$col[darkgrey]'
    info       '$col[darkgrey]'
    sep        '$col[darkgrey]'
    ip         '$col[darkgrey]'
    time       '$col[darkgrey]'
    host       '$col[blue]'
    pwd        '%(!.$col[tomato].$col[aqua])'
    user       '%(!.%B$col[tomato].%B$col[white])'
    none       '%b%u%s%f%k'
  )
  local name ov raw def
  for name in ${(k)d}; do
    ov="PROMPT_KRONUZ_COLOR_${name:u}"
    # No-colour blanks the built-in default, but an explicit override still colours.
    def="${d[$name]}"; (( ${_kronuz_nocolor:-0} )) && def=''
    raw="${(P)ov}"
    [[ -z "$raw" ]] && raw="$def"
    col[$name]="${(e)raw}"
  done
}

# ============================================================================
# Glyphs
# ============================================================================

# Two glyph sets feed $glyph: a Nerd Font icon set (default) and a plain-Unicode
# fallback that renders in any font. $PROMPT_KRONUZ_NERD_FONT=0 (or no/off/false)
# picks the plain set; dumb/unknown terminals force it too. Any single glyph is
# overridable via $PROMPT_KRONUZ_GLYPH_<NAME> (a character, or '' to hide it).
typeset -gA glyph glyph_pad
function prompt_kronuz_glyphs {
  local -A g
  local os_nerd=''
  case "$OSTYPE" in
    darwin*) os_nerd=$'\uf179' ;;  # nf-fa-apple
    linux*)  os_nerd=$'\uf17c' ;;  # nf-fa-linux (Tux)
  esac
  if (( ${_kronuz_dumb:-0} )) || [[ "${(L)PROMPT_KRONUZ_NERD_FONT:-1}" == (0|no|off|false) ]]; then
    g=(
      os         ''         # no plain OS glyph; hidden by default
      branch     $'\u2387'  # ⎇  local branch
      tag        $'\u2691'  # ⚑  tag ref
      commit     '@'        # @  detached HEAD
      remote     $'\u21c5'  # ⇅  upstream / remote tracking
      action     $'\u2699'  # ⚙  in-progress op (rebase/merge)
      clean      $'\u2714'  # ✔  worktree clean
      dirty      $'\u2717'  # ✗  worktree dirty
      stashed    $'\u2261'  # ≡  stash entries
      ahead      $'\u21e1'  # ⇡  commits ahead of upstream
      behind     $'\u21e3'  # ⇣  commits behind upstream
      staged     $'\u271b'  # ✛  staged changes
      modified   $'\u2734'  # ✴  unstaged changes
      conflicted $'\u2756'  # ❖  merge conflicts
      untracked  $'\u2296'  # ⊖  untracked files
      venv       'venv'     # active virtualenv
      vim        'V'        # inside vim
      emacs      'E'        # inside emacs
      jobs       '&'        # backgrounded jobs
      duration   ''         # no glyph; the formatted time stands alone
      ssh        'ssh'      # inside an SSH session
      container  'box'      # inside a container
    )
  else
    g=(
      os         "$os_nerd" # nf-fa-apple / nf-fa-linux by $OSTYPE
      branch     $'\ue0a0'  # nf-pl-branch           local branch
      tag        $'\uf412'  # nf-oct-tag             tag ref
      commit     $'\uf417'  # nf-oct-git_commit      detached HEAD
      remote     $'\uf47f'  # nf-oct-git_compare     upstream / remote tracking
      action     $'\uf419'  # nf-oct-git_merge       in-progress op (rebase/merge)
      clean      $'\u2714'  # ✔                      worktree clean
      dirty      $'\u2717'  # ✗                      worktree dirty
      stashed    $'\uf187'  # nf-fa-archive          stash entries
      ahead      $'\u21e1'  # ⇡                      commits ahead of upstream
      behind     $'\u21e3'  # ⇣                      commits behind upstream
      staged     $'\uf457'  # nf-oct-diff_added      staged changes
      modified   $'\uf040'  # nf-fa-pencil           unstaged changes
      conflicted $'\uf071'  # nf-fa-exclamation_tri  merge conflicts
      untracked  $'\uf128'  # nf-fa-question         untracked files
      venv       $'\ue606'  # nf-seti-python         active virtualenv
      vim        $'\ue7c5'  # nf-dev-vim             inside vim
      emacs      $'\ue7cf'  # nf-dev-emacs           inside emacs
      jobs       $'\uf51e'  # nf-oct-stack           backgrounded jobs
      duration   $'\uf017'  # nf-fa-clock_o          last command duration
      ssh        $'\ueb3a'  # nf-cod-remote          inside an SSH session
      container  $'\uf4b7'  # nf-oct-container       inside a container
    )
  fi
  # Mode-independent marks: plain BMP, identical in both sets (still overridable).
  g[dot]=$'\u25cf'        # ● command status dot
  g[return]=$'\u23ce'     # ⏎ nonzero-exit marker
  g[overwrite]=$'\u267a'  # ♺ overwrite (replace) mode
  g[caret]=$'\u276f'      # ❯ prompt caret (insert keymap)
  g[caret_alt]=$'\u276e'  # ❮ prompt caret (vicmd keymap)
  local name ov val sentinel='__KRONUZ_GLYPH_UNSET__'
  local -i c
  for name in ${(k)g}; do
    ov="PROMPT_KRONUZ_GLYPH_${name:u}"
    val="${(P)ov-$sentinel}"
    [[ "$val" == "$sentinel" ]] && val="$g[$name]"
    glyph[$name]="$val"
    # A single Private-Use-Area glyph can render wider than its cell; flag a trailing
    # pad space for it so an adjacent count/text doesn't collide. BMP and multi-char
    # glyphs are single-width and get none.
    c=0; [[ ${#val} -eq 1 ]] && c=$(( #val ))
    if (( (c >= 0xe000 && c <= 0xf8ff) || c >= 0xf0000 )); then
      glyph_pad[$name]=' '
    else
      glyph_pad[$name]=''
    fi
  done
  # Legacy override: an explicit $_kronuz_os (set in local.zsh) wins for the OS glyph.
  (( ${+_kronuz_os} )) && glyph[os]="$_kronuz_os"
}

# ============================================================================
# Segments  (each recomputed by prompt_kronuz_precmd into $_prompt_kronuz_*)
# ============================================================================

# ---- git ----
typeset -g _prompt_kronuz_git=''

# Direct-git fallback, used when gitstatusd isn't running (no tty, not installed).
function _kronuz_git_fallback {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch
  branch="$(command git symbolic-ref --short HEAD 2>/dev/null)" \
    || branch="$(command git rev-parse --short HEAD 2>/dev/null)"
  [[ -z "$branch" ]] && return
  local sep="${(e)col[sep]}" none="${(e)col[none]}" info="${(e)col[info]}"
  local gly="$glyph[branch]"
  command git symbolic-ref --quiet HEAD &>/dev/null || gly="$glyph[commit]"
  local s=" ${info}${gly}${none} ${(e)col[branch]}${branch}${none}"
  local remote
  remote="$(command git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)"
  [[ -n "$remote" ]] && s+=" ${info}${glyph[remote]}${none} ${(e)col[remote]}${remote}${none}"
  local staged='' unstaged='' untracked='' icons=''
  command git diff --cached --quiet --ignore-submodules 2>/dev/null || staged=1
  command git diff --quiet --ignore-submodules 2>/dev/null || unstaged=1
  [[ -n "$(command git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]] && untracked=1
  if [[ -n "$staged$unstaged$untracked" ]]; then
    icons+="${(e)col[dirty]}${glyph[dirty]}${none}"
    [[ -n "$staged" ]]    && icons+="${(e)col[added]}${glyph[staged]}${none}"
    [[ -n "$unstaged" ]]  && icons+="${(e)col[modified]}${glyph[modified]}${none}"
    [[ -n "$untracked" ]] && icons+=" ${(e)col[untracked]}${glyph[untracked]}${none}"
  else
    icons="${(e)col[clean]}${glyph[clean]}${none}"
  fi
  _prompt_kronuz_git="${s}${sep} (${none}${icons}${sep})${none}"
}

# Primary path: query the KRONUZ gitstatusd instance, else fall back to direct git.
function _kronuz_git_segment {
  _prompt_kronuz_git=''
  if ! { (( ${+functions[gitstatus_query]} )) && gitstatus_query KRONUZ 2>/dev/null && [[ "$VCS_STATUS_RESULT" == ok-sync ]] }; then
    _kronuz_git_fallback
    return
  fi

  local sep="${(e)col[sep]}" none="${(e)col[none]}" info="${(e)col[info]}" s=''
  if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    s+=" ${info}${glyph[branch]}${none} ${(e)col[branch]}${VCS_STATUS_LOCAL_BRANCH}${none}"
  elif [[ -n "$VCS_STATUS_TAG" ]]; then
    s+=" ${info}${glyph[tag]}${none} ${(e)col[branch]}${VCS_STATUS_TAG}${none}"
  else
    s+=" ${info}${glyph[commit]}${none} ${(e)col[commit]}${VCS_STATUS_COMMIT[1,7]}${none}"
  fi
  [[ -n "$VCS_STATUS_REMOTE_NAME" ]] && \
    s+=" ${info}${glyph[remote]}${none} ${(e)col[remote]}${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}${none}"
  [[ -n "$VCS_STATUS_ACTION" ]] && \
    s+=" ${info}${glyph[action]}${none} ${(e)col[action]}${VCS_STATUS_ACTION}${none}"

  local icons=''
  (( VCS_STATUS_STASHES )) && icons+="${(e)col[stashed]}${glyph[stashed]}${glyph_pad[stashed]}${VCS_STATUS_STASHES}${none}"
  if (( VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )); then
    icons+="${(e)col[dirty]}${glyph[dirty]}${none}"
  else
    icons+="${(e)col[clean]}${glyph[clean]}${none}"
  fi
  (( VCS_STATUS_COMMITS_AHEAD ))  && icons+="${(e)col[ahead]}${glyph[ahead]}${glyph_pad[ahead]}${VCS_STATUS_COMMITS_AHEAD}${none}"
  (( VCS_STATUS_COMMITS_BEHIND )) && icons+="${(e)col[behind]}${glyph[behind]}${glyph_pad[behind]}${VCS_STATUS_COMMITS_BEHIND}${none}"
  (( VCS_STATUS_NUM_STAGED ))     && icons+="${(e)col[added]}${glyph[staged]}${glyph_pad[staged]}${VCS_STATUS_NUM_STAGED}${none}"
  (( VCS_STATUS_NUM_UNSTAGED ))   && icons+="${(e)col[modified]}${glyph[modified]}${glyph_pad[modified]}${VCS_STATUS_NUM_UNSTAGED}${none}"
  (( VCS_STATUS_NUM_CONFLICTED )) && icons+="${(e)col[unmerged]}${glyph[conflicted]}${glyph_pad[conflicted]}${VCS_STATUS_NUM_CONFLICTED}${none}"
  (( VCS_STATUS_NUM_UNTRACKED ))  && icons+=" ${(e)col[untracked]}${glyph[untracked]}${glyph_pad[untracked]}${VCS_STATUS_NUM_UNTRACKED}${none}"

  _prompt_kronuz_git="${s}${sep} (${none}${icons}${sep})${none}"
}

# ---- venv ----
typeset -g _kronuz_venv=''
function _kronuz_venv_segment {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    _kronuz_venv=" ${(e)col[info]}${glyph[venv]}${(e)col[none]} ${(e)col[venv]}${VIRTUAL_ENV:t}${(e)col[none]}"
  else
    _kronuz_venv=''
  fi
}

# ---- LAN IP (cached; the lookup forks, so refresh at most every 10s) ----
typeset -g _prompt_kronuz_ip='' _kronuz_ip_ts=0
function _kronuz_ip_segment {
  (( ${EPOCHSECONDS:-0} - _kronuz_ip_ts < 10 )) && return
  _kronuz_ip_ts=${EPOCHSECONDS:-0}
  _prompt_kronuz_ip="$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')"
}

# ---- command duration ----
# preexec stamps the start time; precmd formats the delta once it exceeds
# $PROMPT_KRONUZ_CMD_DURATION_MIN seconds (default 3). $_kronuz_cmd_ran also marks
# that a real command ran (vs a blank Enter), which the status line below reads.
typeset -g _kronuz_cmd_start=0 _prompt_kronuz_duration='' _kronuz_cmd_ran=0
function _kronuz_duration_preexec { _kronuz_cmd_start=${EPOCHREALTIME:-0}; _kronuz_cmd_ran=1 }
function _kronuz_duration_fmt {
  local -F e=$1
  local -i t=$1
  if   (( t >= 3600 )); then printf '%dh%02dm%02ds' $((t/3600)) $((t/60%60)) $((t%60))
  elif (( t >= 60 ));   then printf '%dm%02ds' $((t/60)) $((t%60))
  else printf '%.1fs' $e
  fi
}
function _kronuz_duration_segment {
  _prompt_kronuz_duration=''
  (( _kronuz_cmd_start )) || return
  local -F elapsed=$(( ${EPOCHREALTIME:-0} - _kronuz_cmd_start ))
  _kronuz_cmd_start=0
  (( elapsed >= ${PROMPT_KRONUZ_CMD_DURATION_MIN:-3} )) || return
  _prompt_kronuz_duration="$(_kronuz_duration_fmt $elapsed)"
}

# ---- status line (exit code + duration, on a line above the info row) ----
# $_prompt_kronuz_last_exit is captured by the OSC precmd (it runs first). The line
# is built twice: full colour for the live prompt, and dimmed for the copy the
# transient prompt leaves in scrollback.
typeset -g _prompt_kronuz_status='' _prompt_kronuz_status_dim='' _kronuz_last_exit=0

# Dimmed colour escape for a palette name, per $PROMPT_KRONUZ_TRANSIENT_STYLE:
# keep = original, mute = grey (like the caret), dim = same hue darkened. Into $REPLY.
function _kronuz_dim_col {
  emulate -L zsh -o extendedglob
  local reply
  case "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" in
    keep|none|off)  REPLY="${(e)col[$1]}"; return ;;
    mute|grey|gray) REPLY="${(e)col[transient]}"; return ;;
  esac
  local esc="${(e)col[$1]}"
  if [[ "$esc" == (#b)'%F{'(*)'}' ]]; then
    _kronuz_color_rgb "$match[1]"
    if (( $#reply == 3 )); then
      local -F f=${PROMPT_KRONUZ_TRANSIENT_DIM:-0.7}
      local -i r=$(( reply[1]*f )) g=$(( reply[2]*f )) b=$(( reply[3]*f ))
      local hex; printf -v hex '%02x%02x%02x' r g b
      REPLY="%F{#$hex}"; return
    fi
  fi
  REPLY="$esc"
}
function _kronuz_status_segment {
  _prompt_kronuz_status='' _prompt_kronuz_status_dim=''
  # Only after a real command ran: a blank Enter leaves $? unchanged and must not
  # re-show (and, via the transient copy, re-keep) the previous command's exit code.
  (( ${_kronuz_cmd_ran:-0} )) || return
  local out='' dim='' body sp REPLY
  if (( ${_kronuz_last_exit:-0} != 0 )); then
    body="${glyph[return]} ${_kronuz_last_exit}"
    out+="${(e)col[status_err]}${body}${(e)col[none]}"
    _kronuz_dim_col status_err; dim+="${REPLY}${body}${(e)col[none]}"
  fi
  if [[ -n "$_prompt_kronuz_duration" ]]; then
    sp="${out:+ }"; body="${glyph[duration]}${glyph_pad[duration]}${_prompt_kronuz_duration}"
    out+="${sp}${(e)col[duration]}${body}${(e)col[none]}"
    _kronuz_dim_col duration; dim+="${sp}${REPLY}${body}${(e)col[none]}"
  fi
  [[ -n "$out" ]] && { _prompt_kronuz_status="${out}%E"$'\n'; _prompt_kronuz_status_dim="${dim}%E"$'\n'; }
  _kronuz_cmd_ran=0
}

# ============================================================================
# Editor keymap indicator
# ============================================================================

# Update the vi/emacs keymap caret ($_kronuz_keymap) and overwrite mark
# ($_kronuz_overwrite) from zle state, then redraw. Driven by the zle widgets below.
typeset -g _kronuz_keymap='' _kronuz_overwrite=''
function _kronuz_keymap_update {
  local REPLY
  if [[ "$KEYMAP" == 'vicmd' ]]; then
    zstyle -s ':kronuz:editor:keymap:alternate' format 'REPLY'
  else
    zstyle -s ':kronuz:editor:keymap:primary' format 'REPLY'
  fi
  _kronuz_keymap="$REPLY"
  if [[ "$ZLE_STATE" == *overwrite* ]]; then
    zstyle -s ':kronuz:editor:keymap:overwrite' format 'REPLY'
    _kronuz_overwrite="$REPLY"
  else
    _kronuz_overwrite=''
  fi
  # reset-prompt redraws in place, which needs cursor addressing; skip it on dumb
  # terminals (it would reprint the multi-line prompt). The seed in setup means the
  # first render already shows the caret even where zle-line-init never fires.
  (( ${_kronuz_dumb:-0} )) || zle reset-prompt 2>/dev/null
}
function zle-keymap-select { _kronuz_keymap_update }
function zle-line-init { _kronuz_keymap_update }

# ============================================================================
# Terminal integration  (OSC 7 cwd, OSC 133 prompt marks, OSC 1337 iTerm2)
# ============================================================================
# Lets capable terminals open new tabs/splits in $PWD and jump between prompts /
# show per-command status. The B (input start) mark rides at the end of $PROMPT via
# $_kronuz_osc_b. Skipped on dumb/unknown terminals.
typeset -g _kronuz_osc_b='' _kronuz_is_iterm=0
function _kronuz_osc_active { [[ -n "$TERM" && "$TERM" != (dumb|unknown) ]] }
function _kronuz_osc_preexec {
  _kronuz_osc_active && print -n '\e]133;C\a'
}
function _kronuz_osc_precmd {
  local ret=$?
  typeset -g _kronuz_last_exit=$ret    # this hook runs first, so $? is the command's
  if ! _kronuz_osc_active; then _kronuz_osc_b=''; return; fi
  print -n "\e]133;D;${ret}\a\e]133;A\a"
  print -Pn '\e]7;file://%M%d\a'
  (( _kronuz_is_iterm )) && print -Pn "\e]1337;RemoteHost=${USER}@%M\a\e]1337;CurrentDir=%d\a"
  _kronuz_osc_b=$'%{\e]133;B\a%}'
}

# ============================================================================
# Transient prompt
# ============================================================================
# On accept-line, $PROMPT collapses to a minimal caret so scrollback keeps only a
# caret + the command for past prompts (restored before the next prompt). The
# accepted command is restyled per $PROMPT_KRONUZ_TRANSIENT_STYLE: dim (same hues,
# darker), mute (one grey span), or keep. Off on dumb and when $PROMPT_KRONUZ_TRANSIENT=''.
typeset -g _kronuz_prompt_full='' _kronuz_rprompt_full='' _kronuz_muting=0

# Restyle the command's region_highlight in place (zsh has no faint attribute, so
# `dim` recolours each fg toward black at truecolor precision).
function _kronuz_transient_style {
  case "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" in
    keep|none|off) ;;
    mute|grey|gray)
      region_highlight=("0 ${#BUFFER} ${PROMPT_KRONUZ_TRANSIENT_HL:-fg=8}") ;;
    *)
      setopt localoptions extendedglob
      local -F factor=${PROMPT_KRONUZ_TRANSIENT_DIM:-0.7}
      local -a out p reply; local e hex; local -i r g b
      for e in "${region_highlight[@]}"; do
        p=("${(z)e}")
        if [[ ${p[3]} = (#b)(*)fg=([^, ]##)(*) ]]; then
          _kronuz_color_rgb "${match[2]}"
          if (( $#reply == 3 )); then
            r=$(( reply[1]*factor )); g=$(( reply[2]*factor )); b=$(( reply[3]*factor ))
            printf -v hex '%02x%02x%02x' r g b
            p[3]="${match[1]}fg=#${hex}${match[3]}"
          fi
        fi
        out+=("${p[1]} ${p[2]} ${p[3]}")
      done
      region_highlight=("${out[@]}") ;;
  esac
}
# Bound directly to ^M/^J, so it bypasses the autosuggestions / fsh accept-line
# wrappers: clear the autosuggestion ghost ourselves (else reset-prompt bakes it into
# scrollback), keep the dimmed status line, then accept.
function _kronuz_transient_accept {
  if (( ! ${_kronuz_dumb:-0} )) && [[ -n "$_kronuz_transient_prompt" ]]; then
    _kronuz_prompt_full=$PROMPT _kronuz_rprompt_full=$RPROMPT
    PROMPT="${_prompt_kronuz_status_dim}${_kronuz_transient_prompt}" RPROMPT=''
    POSTDISPLAY=''
    [[ "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" != (keep|none|off) ]] && _kronuz_muting=1
    zle .reset-prompt
    zle .accept-line
    return
  fi
  zle accept-line
}
function _kronuz_transient_restore {
  _kronuz_muting=0
  [[ -n "$_kronuz_prompt_full" ]] || return
  PROMPT=$_kronuz_prompt_full RPROMPT=$_kronuz_rprompt_full
  _kronuz_prompt_full=''
}

# ============================================================================
# Lifecycle: precmd + setup
# ============================================================================

typeset -g _kronuz_dumb=0 _kronuz_nocolor=0 _kronuz_pal_loaded=0
function prompt_kronuz_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  # Terminal capability, re-checked every prompt so toggling $TERM / $NO_COLOR takes
  # effect live. dumb also forces plain glyphs; nocolor strips colour but keeps the
  # full layout ($NO_COLOR per no-color.org).
  _kronuz_dumb=0
  [[ -z "$TERM" || "$TERM" == (dumb|unknown) ]] && _kronuz_dumb=1
  _kronuz_nocolor=$_kronuz_dumb
  [[ -n "${NO_COLOR-}" ]] && _kronuz_nocolor=1
  prompt_kronuz_colors
  prompt_kronuz_glyphs
  # Load the dim palette once, here rather than in setup, so any PROMPT_KRONUZ_PALETTE_*
  # override / TTL / timeout from local.zsh (sourced after setup) is in effect.
  if (( ! ${_kronuz_pal_loaded:-0} )); then
    _kronuz_pal_loaded=1
    [[ "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" != (keep|none|off|mute|grey|gray) ]] && _kronuz_load_palette
  fi
  _prompt_kronuz_pwd="${${(%):-%~}//\%/%%}"
  _kronuz_venv_segment
  _kronuz_ip_segment
  _kronuz_duration_segment
  _kronuz_status_segment
  _kronuz_git_segment
}

function prompt_kronuz_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  zmodload -i zsh/parameter 2>/dev/null  # $parameters, for the no-colour path
  zmodload -i zsh/datetime 2>/dev/null   # $EPOCHSECONDS, for the cached IP segment

  # The palette's 16..255 entries are hex (%F{#RRGGBB}); zsh/nearcolor maps them to
  # the nearest 256-colour (or the default fg on 8/16-colour terminals) so one palette
  # works everywhere. Skip it on a truecolor terminal, which renders the hex directly.
  if [[ "${COLORTERM-}" != (24bit|truecolor) && "${terminfo[colors]:-0}" -ne 16777216 ]]; then
    zmodload zsh/nearcolor 2>/dev/null
  fi

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd prompt_kronuz_precmd
  add-zsh-hook preexec _kronuz_duration_preexec
  add-zsh-hook precmd _kronuz_osc_precmd
  add-zsh-hook preexec _kronuz_osc_preexec
  # Run the OSC precmd first so it captures the command's real exit status.
  precmd_functions=(_kronuz_osc_precmd ${precmd_functions:#_kronuz_osc_precmd})
  # iTerm2: announce shell integration once. $LC_TERMINAL survives ssh; $TERM_PROGRAM
  # is the local case.
  if [[ "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]] && _kronuz_osc_active; then
    _kronuz_is_iterm=1
    print -n '\e]1337;ShellIntegrationVersion=14;shell=zsh\a'
  fi
  zle -N zle-keymap-select
  zle -N zle-line-init

  zstyle ':kronuz:editor:keymap:primary' format "\${col[primary1]}\${glyph[caret]}\${col[none]}\${col[primary2]}\${glyph[caret]}\${col[none]}\${col[primary3]}\${glyph[caret]}\${col[none]}"
  zstyle ':kronuz:editor:keymap:alternate' format "\${col[primary3]}\${glyph[caret_alt]}\${col[none]}\${col[primary2]}\${glyph[caret_alt]}\${col[none]}\${col[primary1]}\${glyph[caret_alt]}\${col[none]}"
  zstyle ':kronuz:editor:keymap:overwrite' format " \${col[overwrite]}\${glyph[overwrite]}\${col[none]}"

  # Seed the keymap caret so a prompt char shows even where zle-line-init never fires
  # (e.g. Emacs `M-x shell`).
  local REPLY
  zstyle -s ':kronuz:editor:keymap:primary' format 'REPLY'
  _kronuz_keymap="$REPLY"

  _prompt_kronuz_git=''
  _prompt_kronuz_pwd=''

  # Session context, fixed for the shell's life: SSH session and/or container.
  typeset -g _kronuz_is_ssh='' _kronuz_is_container=''
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && _kronuz_is_ssh=1
  [[ -f /.dockerenv || -f /run/.containerenv || -n "$container" ]] && _kronuz_is_container=1

  # Per-segment defaults. Each is a deferred string; dynamic ones read the
  # $_prompt_kronuz_* / state vars the precmd computes.
  DEFAULT_PROMPT_KRONUZ_OS="\${glyph[os]:+\"\${col[host]}\${glyph[os]}\${col[none]} \"}"
  DEFAULT_PROMPT_KRONUZ_CONTEXT="\${_kronuz_is_container:+\" \${col[container]}\${glyph[container]}\${col[none]}\"}\${_kronuz_is_ssh:+\" \${col[ssh]}\${glyph[ssh]}\${col[none]}\"}"
  DEFAULT_PROMPT_KRONUZ_ERR="%(?.\${col[status_ok]}\${glyph[dot]}\${col[none]}.\${col[status_err]}\${glyph[dot]}\${col[none]})"
  DEFAULT_PROMPT_KRONUZ_ERROR="%(?.. \${col[status_err]}\${glyph[return]} %?\${col[none]})"
  DEFAULT_PROMPT_KRONUZ_VIM="\${VIM:+\" \${col[vim]}\${glyph[vim]}\${col[none]}\"}"
  DEFAULT_PROMPT_KRONUZ_EMACS="\${INSIDE_EMACS:+\" \${col[emacs]}\${glyph[emacs]}\${col[none]}\"}"
  DEFAULT_PROMPT_KRONUZ_ETCTL="\${ETCTL_SESSION:+\" \${col[info]}etctl\${col[none]}:\${col[etctl]}\${ETCTL_SESSION}\${col[none]}\"}"
  DEFAULT_PROMPT_KRONUZ_JOBS="%(1j. \${col[jobs]}\${glyph[jobs]}\${glyph_pad[jobs]}%j\${col[none]}.)"
  DEFAULT_PROMPT_KRONUZ_DURATION="\${_prompt_kronuz_duration:+\" \${col[duration]}\${glyph[duration]}\${glyph_pad[duration]}\${_prompt_kronuz_duration}\${col[none]}\"}"
  DEFAULT_PROMPT_KRONUZ_USER="%n"
  DEFAULT_PROMPT_KRONUZ_IP="\${_prompt_kronuz_ip}"
  DEFAULT_PROMPT_KRONUZ_GIT="\${_prompt_kronuz_git:+\${(e)_prompt_kronuz_git}}"
  DEFAULT_PROMPT_KRONUZ_VENV="\${(e)_kronuz_venv}"
  DEFAULT_PROMPT_KRONUZ_OVERWRITE="\${(e)_kronuz_overwrite}"
  DEFAULT_PROMPT_KRONUZ_PROMPT="\${(e)_kronuz_keymap}"
  DEFAULT_PROMPT_KRONUZ_TIME="[%*]"
  DEFAULT_PROMPT_KRONUZ_PWD="\${_prompt_kronuz_pwd:+\${(e)_prompt_kronuz_pwd}}"

  # Compose the segments into $kronuz. The plain ones share one shape: a user override
  # ($PROMPT_KRONUZ_<SEG>) or the default, both (e)-evaluated at render.
  unset kronuz
  typeset -gA kronuz
  kronuz[nl]=$'%E\n'
  local seg
  for seg in os err error vim emacs etctl context jobs duration git venv overwrite prompt; do
    kronuz[$seg]="\${(e)PROMPT_KRONUZ_${seg:u}:-\$DEFAULT_PROMPT_KRONUZ_${seg:u}}"
  done
  # The rest wrap a segment in its own colour, or compose other segments.
  kronuz[user]="\${col[user]}\${(e)PROMPT_KRONUZ_USER:-\$DEFAULT_PROMPT_KRONUZ_USER}\${col[none]}"
  kronuz[time]="\${col[time]}\${(e)PROMPT_KRONUZ_TIME:-\$DEFAULT_PROMPT_KRONUZ_TIME}\${col[none]}"
  kronuz[pwd]="\${col[pwd]}\${(e)PROMPT_KRONUZ_PWD:-\$DEFAULT_PROMPT_KRONUZ_PWD}\${col[none]}"
  kronuz[host]="$kronuz[os]\${col[host]}%M\${col[none]} \${col[ip]}(\${(e)PROMPT_KRONUZ_IP:-\$DEFAULT_PROMPT_KRONUZ_IP})\${col[none]}"
  kronuz[info]="$kronuz[user] at $kronuz[host]"

  SPROMPT='zsh: correct $col[red]%R%f to $col[green]%r%f [nyae]? '
  RPROMPT="$kronuz[overwrite]$kronuz[vim]$kronuz[emacs]"
  PROMPT="\${_prompt_kronuz_status}$kronuz[err] $kronuz[info]$kronuz[context]$kronuz[etctl]$kronuz[git]$kronuz[venv]$kronuz[jobs]$kronuz[nl]$kronuz[time] $kronuz[pwd] $kronuz[prompt] \${_kronuz_osc_b}"

  # Transient caret left in scrollback for past commands; $PROMPT_KRONUZ_TRANSIENT
  # overrides it, '' disables. (if/else, not ${VAR:-default}: the default contains
  # ${glyph[caret]}, whose braces the outer ${...} expansion would mis-match.)
  if (( ${+PROMPT_KRONUZ_TRANSIENT} )); then
    _kronuz_transient_prompt="$PROMPT_KRONUZ_TRANSIENT"
  else
    _kronuz_transient_prompt="\${col[transient]}\${glyph[caret]}\${col[none]} "
  fi
  zle -N _kronuz_transient_accept
  bindkey '^M' _kronuz_transient_accept
  bindkey '^J' _kronuz_transient_accept
  add-zsh-hook precmd _kronuz_transient_restore
  # The dim/mute styles repaint region_highlight, which fast-syntax-highlighting then
  # rebuilds on its own zle-line-finish. Wrap _zsh_highlight once (rather than hook
  # the widget, which recurses with fsh's wrapper) to re-apply our style on top while
  # $_kronuz_muting is set; the unconditional rebuild also covers a buffer fsh skipped
  # (e.g. a paste). Works for fast-syntax-highlighting and zsh-syntax-highlighting.
  if (( ${+functions[_zsh_highlight]} )) && (( ! ${+functions[_kronuz_zsh_highlight_orig]} )); then
    functions[_kronuz_zsh_highlight_orig]=$functions[_zsh_highlight]
    function _zsh_highlight {
      _kronuz_zsh_highlight_orig "$@"
      local ret=$?
      (( ${_kronuz_muting:-0} )) && _kronuz_transient_style
      return ret
    }
  fi
  # The dim palette is loaded lazily on the first precmd (so local.zsh, sourced after
  # setup, can configure it); re-arm that one-shot here in case setup is re-run.
  _kronuz_pal_loaded=0
}
