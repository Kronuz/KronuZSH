#
# Kronuz prompt — a thin, framework-free zsh prompt, evolved from the Kronuz
# theme for Prezto and incorporating ideas and code from Prezto prompt themes.
#
# Copyright (c) 2014-2026 Germán Méndez Bravo
# Portions copyright (c) 2009-2017 the Prezto contributors
# SPDX-License-Identifier: MIT
# See LICENSE for the full copyright and license notice.
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
#   $fcol    named colour palette         ($kz[FG.red], $kz[FG.chartreuse], ...)
#   $glyph  icon set, Nerd Font or plain  ($kz[GLYPH.branch], $kz[GLYPH.venv], ...)
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

# Base palette: named neutral colour codes, populated at load. A snapshot ($_col_base,
# just below) is the immutable source that every rebuild wraps into $kz[FG.<name>] /
# $kz[BG.<name>] (in prompt_kronuz_colors), blanking every entry in no-colour mode so a
# skin's ${kz[FG.green]} (and ${kz[BG.green]}) emit nothing. ANSI 0..15 stay symbolic so
# they track the terminal theme; 16..255 are exact hex (truecolor), downsampled by
# zsh/nearcolor on non-truecolor terminals. $col is the internal code palette; a skin
# defines/overrides a hue with $PROMPT_KRONUZ_PALETTE_<NAME> and uses $kz[FG.<name>].
unset col _col_base
typeset -gA col=(
  black                '0'        red                  '1'
  lightgreen           '10'       olive                '#878700'
  darkkhaki            '#87875f'  gray                 '#878787'
  lavender             '#8787af'  mediumpurple         '#8787d7'
  mediumslateblue      '#8787ff'  darkolivegreen       '#87af5f'
  darkseagreen         '#87af87'  powderblue           '#87afaf'
  lightyellow          '11'       skyblue              '#87afd7'
  cornflowerblue       '#87afff'  lawngreen            '#87d700'
  palegreen            '#87d787'  mediumaquamarine     '#87d7af'
  cadetblue            '#87d7d7'  lightskyblue         '#87d7ff'
  chartreuse           '#87ff00'  limegreen            '#87ff5f'
  lightblue            '12'       aquamarine           '#87ffaf'
  darkred              '#af0000'  mediumvioletred      '#af005f'
  darkmagenta          '#af0087'  purple               '#af00af'
  darkviolet           '#af00d7'  fuchsia              '#af00ff'
  lightmagenta         '13'       chocolate            '#af5f00'
  lightcoral           '#af5f5f'  palevioletred        '#af5f87'
  orchid               '#af5faf'  mediumorchid         '#af5fd7'
  darkorchid           '#af5fff'  darkgoldenrod        '#af8700'
  burlywood            '#af875f'  rosybrown            '#af8787'
  plum                 '#af87af'  lightcyan            '14'
  violet               '#af87d7'  khaki                '#afaf5f'
  palegoldenrod        '#afaf87'  darkgray             '#afafaf'
  slategray            '#afafd7'  lightsteelblue       '#afafff'
  yellowgreen          '#afd75f'  lightgrey            '15'
  honeydew             '#afd7af'  paleturquoise        '#afd7d7'
  greenyellow          '#afff5f'  dimgray              '#000000'
  tomato               '#d70000'  deeppink             '#d7005f'
  darkorange           '#d75f00'  indianred            '#d75f5f'
  hotpink              '#d75f87'  navy                 '#00005f'
  goldenrod            '#d78700'  lightsalmon          '#d7875f'
  lightpink            '#d787af'  gold                 '#d7af00'
  sandybrown           '#d7af5f'  darkblue             '#000087'
  tan                  '#d7af87'  mistyrose            '#d7afaf'
  thistle              '#d7afd7'  lemonchiffon         '#d7d7af'
  whitesmoke           '#d7d7d7'  ghostwhite           '#d7d7ff'
  mediumblue           '#0000af'  azure                '#d7ffff'
  orangered            '#ff0000'  crimson              '#ff005f'
  green                '2'        salmon               '#ff5f5f'
  orange               '#ff8700'  coral                '#ff875f'
  peru                 '#ffaf5f'  darksalmon           '#ffaf87'
  pink                 '#ffafd7'  darkgreen            '#005f00'
  navajowhite          '#ffd7af'  peachpuff            '#ffd7d7'
  teal                 '#005f5f'  lightgoldenrodyellow '#ffffd7'
  white                '#ffffff'  darkcyan             '#005f87'
  deepskyblue          '#005faf'  silver               '#bcbcbc'
  lightgray            '#c6c6c6'  gainsboro            '#d0d0d0'
  dodgerblue           '#005fd7'  yellow               '3'
  darkturquoise        '#0087af'  mediumspringgreen    '#00af5f'
  aqua                 '#00afff'  blue                 '4'
  lime                 '#00d700'  springgreen          '#00d75f'
  magenta              '5'        maroon               '#5f0000'
  indigo               '#5f0087'  cyan                 '6'
  lightslategray       '#5f5f87'  darkslateblue        '#5f5faf'
  slateblue            '#5f5fd7'  darkslategray        '#5f8787'
  steelblue            '#5f87d7'  royalblue            '#5f87ff'
  grey                 '7'        mediumseagreen       '#5fd787'
  darkgrey             '8'        mediumturquoise      '#5fd7d7'
  forestgreen          '#5fff5f'  turquoise            '#5fffd7'
  lightred             '9'        blueviolet           '#8700ff'
  brown                '#875f00'
)
# Immutable snapshot of the base palette; prompt_kronuz_colors rebuilds $fcol from it.
typeset -gA _col_base=("${(@kv)col}")

# The 16 ANSI colours, by palette name -> index. They default to symbolic %F{N} (above)
# so they track the terminal theme, but each is overridable to a concrete colour via
# $PROMPT_KRONUZ_PALETTE_<NAME> (a #RRGGBB or a 0-255 index), applied to $fcol in
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
# precmd, so overrides / TTL / timeout set in ~/.zshrc.local are in effect.
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

  # Per-colour overrides win (from ~/.zshrc.local); resolved to RGB, never cached.
  for name in ${(k)_kronuz_basic}; do
    ov="PROMPT_KRONUZ_PALETTE_${name:u}"; [[ -n "${(P)ov}" ]] || continue
    _kronuz_color_rgb "${(P)ov}"
    (( ${#reply} )) && _kronuz_pal[${_kronuz_basic[$name]}]="${reply[*]}"
  done
}

# Semantic colours: map each prompt element to a base-palette colour, resolved with
# the live palette into the same $fcol array the segments read ($_ksem[host], $_ksem[branch],
# ...). Mirrors prompt_kronuz_glyphs: a defaults table, then one loop that applies any
# $PROMPT_KRONUZ_COLOR_<NAME> override and writes the final value. No-colour mode
# ($_kronuz_nocolor) blanks the built-in defaults (so the layout still renders with zero
# escapes) while still honouring an explicit override. Recomputed every precmd, so
# toggling $NO_COLOR / $TERM takes effect on the next prompt.
typeset -gA _ksem
typeset -g _kronuz_colors_sig=''
function prompt_kronuz_colors {
  # Change-detection: colours are fully determined by $_kronuz_nocolor and the
  # $PROMPT_KRONUZ_{COLOR,PALETTE}_* overrides, so skip the rebuild (base palette from
  # source, then semantics) when none of those changed since the last prompt.
  local _sig="${_kronuz_nocolor:-0}" _k
  for _k in ${(k)parameters[(I)PROMPT_KRONUZ_(COLOR|PALETTE)_*]}; do _sig+=$'\x1f'"$_k=${(P)_k}"; done
  [[ "$_sig" == "$_kronuz_colors_sig" ]] && return
  _kronuz_colors_sig="$_sig"

  # Live neutral code palette: the immutable base plus any PROMPT_KRONUZ_PALETTE_<NAME>,
  # which may redefine a built-in hue or define a brand-new one (a #RRGGBB or 0-255 index).
  local _cn _pv
  col=("${(@kv)_col_base}")
  for _k in ${(k)parameters[(I)PROMPT_KRONUZ_PALETTE_*]}; do
    _pv="${(P)_k}"; _cn="${${_k#PROMPT_KRONUZ_PALETTE_}:l}"
    [[ -n "$_pv" ]] && col[$_cn]="$_pv"
  done

  # Public styling in $kz: FG./BG. wrap each code (no %F->%K string surgery); the attribute
  # setters and RESET are the raw zsh escapes. All blank in no-colour, so ${kz[FG.green]} /
  # ${kz[BG.green]} emit nothing and the layout still renders with zero escapes.
  if (( ${_kronuz_nocolor:-0} )); then
    for _cn in ${(k)col}; do kz[FG.$_cn]='' kz[BG.$_cn]=''; done
    kz[RESET]='' kz[BOLD]='' kz[UNDERLINE]='' kz[STANDOUT]=''
  else
    for _cn in ${(k)col}; do kz[FG.$_cn]="%F{$col[$_cn]}" kz[BG.$_cn]="%K{$col[$_cn]}"; done
    kz[RESET]='%b%u%s%f%k' kz[BOLD]='%B' kz[UNDERLINE]='%U' kz[STANDOUT]='%S'
  fi

  local -A d=(
    caret1     '%(!.%B$kz[FG.red].%B$kz[FG.red])'
    caret2     '%(!.%B$kz[FG.red].%B$kz[FG.yellow])'
    caret3     '%(!.$kz[FG.red].%B$kz[FG.green])'
    status_err '$kz[FG.red]'
    status_ok  '$kz[FG.green]'
    venv       '$kz[FG.white]'
    vim        '%B$kz[FG.green]'
    emacs      '%B$kz[FG.green]'
    etctl      '%B$kz[FG.magenta]'
    overwrite  '$kz[FG.red]'
    jobs       '$kz[FG.gold]'
    duration   '$kz[FG.goldenrod]'
    ssh        '$kz[FG.mediumpurple]'
    container  '$kz[FG.deepskyblue]'
    transmuted '$kz[FG.darkgrey]'
    transient_caret '%B$kz[FG.white]'
    action     '$kz[FG.darkorange]'
    fallback   '$kz[FG.gold]'
    added      '$kz[FG.darkorange]'
    ahead      '$kz[FG.chartreuse]'
    behind     '$kz[FG.deeppink]'
    dirty      '$kz[FG.brown]'
    clean      '$kz[FG.forestgreen]'
    branch     '%B$kz[FG.white]'
    remote     '$kz[FG.white]'
    commit     '$kz[FG.white]'
    modified   '$kz[FG.red]'
    stashed    '$kz[FG.lightsteelblue]'
    unmerged   '$kz[FG.red]'
    untracked  '$kz[FG.darkgrey]'
    info       '$kz[FG.darkgrey]'
    loading    '$kz[FG.darkgrey]'
    sep        '$kz[FG.darkgrey]'
    ip         '$kz[FG.darkgrey]'
    time       '$kz[FG.darkgrey]'
    host       '$kz[FG.silver]'
    pwd        '%(!.$kz[FG.tomato].$kz[FG.white])'
    user       '%(!.%B$kz[FG.tomato].%B$kz[FG.white])'
  )
  local name ov raw def
  for name in ${(k)d}; do
    ov="PROMPT_KRONUZ_COLOR_${name:u}"
    # No-colour blanks the built-in default, but an explicit override still colours.
    def="${d[$name]}"; (( ${_kronuz_nocolor:-0} )) && def=''
    raw="${(P)ov}"
    [[ -z "$raw" ]] && raw="$def"
    _ksem[$name]="${(e)raw}"
  done
}

# ============================================================================
# Glyphs
# ============================================================================

# Two glyph sets feed $glyph: a Nerd Font icon set (default) and a plain-Unicode
# fallback that renders in any font. $PROMPT_KRONUZ_NERD_FONT=0 (or no/off/false)
# picks the plain set; dumb/unknown terminals force it too. Any single glyph is
# overridable via $PROMPT_KRONUZ_GLYPH_<NAME> (a character, or '' to hide it).
typeset -gA kz glyph_pad
typeset -g _kronuz_glyphs_sig=''
function prompt_kronuz_glyphs {
  # Change-detection: glyphs depend only on terminal dumb-ness, the nerd-font toggle,
  # $OSTYPE, the legacy $_kronuz_os, and any $PROMPT_KRONUZ_GLYPH_* override. Skip the
  # rebuild when none of those changed since the last prompt.
  local _sig="${_kronuz_dumb:-0}|${(L)PROMPT_KRONUZ_NERD_FONT:-1}|$OSTYPE|${+_kronuz_os}:${_kronuz_os-}" _k
  for _k in ${(k)parameters[(I)PROMPT_KRONUZ_GLYPH_*]}; do _sig+=$'\x1f'"$_k=${(P)_k}"; done
  [[ "$_sig" == "$_kronuz_glyphs_sig" ]] && return
  _kronuz_glyphs_sig="$_sig"

  local -A g
  local os_nerd=''
  case "$OSTYPE" in
    darwin*) os_nerd=$'\uf179' ;;  # nf-fa-apple
    linux*)  os_nerd=$'\uf17c' ;;  # nf-fa-linux (Tux)
  esac
  if (( ${_kronuz_dumb:-0} )) || [[ "${(L)PROMPT_KRONUZ_NERD_FONT:-1}" == (0|no|off|false) ]]; then
    g=(
      os             ''         # no plain OS glyph; hidden by default
      branch         $'\u2387'  # ⎇  local branch
      tag            $'\u2691'  # ⚑  tag ref
      commit         '@'        # @  detached HEAD
      remote         $'\u21c5'  # ⇅  upstream / remote tracking
      host_github    ''         # remote host GitHub; no plain logo, uses the remote glyph
      host_gitlab    ''         # remote host GitLab; no plain logo, uses the remote glyph
      host_bitbucket ''         # remote host Bitbucket; no plain logo, uses the remote glyph
      action         $'\u2699'  # ⚙  in-progress op (rebase/merge)
      fallback       $'\u26a0'  # ⚠  direct-git fallback warning
      clean          $'\u2714'  # ✔  worktree clean
      dirty          $'\u2717'  # ✗  worktree dirty
      stashed        $'\u2261'  # ≡  stash entries
      ahead          $'\u21e1'  # ⇡  commits ahead of upstream
      behind         $'\u21e3'  # ⇣  commits behind upstream
      push_ahead     $'\u21e7'  # ⇧  commits ahead of a distinct push remote
      push_behind    $'\u21e9'  # ⇩  commits behind a distinct push remote
      staged         $'\u271b'  # ✛  staged changes
      modified       $'\u2734'  # ✴  unstaged changes
      added          '+'        # +  split view: staged new file
      changed        '~'        # ~  split view: modified file
      deleted        '-'        # -  split view: deleted file
      conflicted     $'\u2756'  # ❖  merge conflicts
      untracked      $'\u2296'  # ⊖  untracked files
      unknown        $'\u221e'  # ∞  dirty, count not scanned (index over -m cap)
      loading        $'\u2026'  # …  async git query in flight
      venv           'venv'     # active virtualenv
      vim            'V'        # inside vim
      emacs          'E'        # inside emacs
      jobs           '&'        # backgrounded jobs
      duration       ''         # no glyph; the formatted time stands alone
      ssh            'ssh'      # inside an SSH session
      container      'box'      # inside a container
    )
  else
    g=(
      os             "$os_nerd"  # nf-fa-apple / nf-fa-linux by $OSTYPE
      branch         $'\ue0a0'   # nf-pl-branch           local branch
      tag            $'\uf412'   # nf-oct-tag             tag ref
      commit         $'\uf417'   # nf-oct-git_commit      detached HEAD
      remote         $'\uf47f'   # nf-oct-git_compare     upstream / remote tracking
      host_github    $'\uf09b'   # nf-fa-github           remote host: GitHub
      host_gitlab    $'\uf296'   # nf-fa-gitlab           remote host: GitLab
      host_bitbucket $'\uf171'   # nf-fa-bitbucket        remote host: Bitbucket
      action         $'\uf419'   # nf-oct-git_merge       in-progress op (rebase/merge)
      fallback       $'\uf071'   # nf-fa-warning          direct-git fallback warning
      clean          $'\u2714'   # ✔                      worktree clean
      dirty          $'\u2717'   # ✗                      worktree dirty
      stashed        $'\uf187'   # nf-fa-archive          stash entries
      ahead          $'\u21e1'   # ⇡                      commits ahead of upstream
      behind         $'\u21e3'   # ⇣                      commits behind upstream
      push_ahead     $'\u21e7'   # ⇧                      commits ahead of a distinct push remote
      push_behind    $'\u21e9'   # ⇩                      commits behind a distinct push remote
      staged         $'\uf457'   # nf-oct-diff_added      staged changes
      modified       $'\uf040'   # nf-fa-pencil           unstaged changes
      added          $'\uf457'   # nf-oct-diff_added      split view: staged new file
      changed        $'\uf459'   # nf-oct-diff_modified   split view: modified file
      deleted        $'\uf458'   # nf-oct-diff_removed    split view: deleted file
      conflicted     $'\uf071'   # nf-fa-exclamation_tri  merge conflicts
      untracked      $'\u2296'   # ⊖                      untracked files
      unknown        $'\u221e'   # ∞ (uncounted)          dirty, scan skipped (-m cap)
      loading        $'\uf021'   # nf-fa-refresh          async git query in flight
      venv           $'\ue606'   # nf-seti-python         active virtualenv
      vim            $'\ue7c5'   # nf-dev-vim             inside vim
      emacs          $'\ue7cf'   # nf-dev-emacs           inside emacs
      jobs           $'\uf51e'   # nf-oct-stack           backgrounded jobs
      duration       $'\uf017'   # nf-fa-clock_o          last command duration
      ssh            $'\ueb3a'   # nf-cod-remote          inside an SSH session
      container      $'\uf4b7'   # nf-oct-container       inside a container
    )
  fi
  # Mode-independent marks: plain BMP, identical in both sets (still overridable).
  g[dot]=$'\u25cf'        # ● command status dot
  g[return]=$'\u23ce'     # ⏎ nonzero-exit marker
  g[overwrite]=$'\u267a'  # ♺ overwrite (replace) mode
  g[caret]=$'\u276f'      # ❯ prompt caret (insert keymap)
  g[caret_alt]=$'\u276e'  # ❮ prompt caret (vicmd keymap)
  local name ov val padov padval sentinel='__KRONUZ_GLYPH_UNSET__'
  local -i c
  # Rebuild from scratch: drop any set-specific glyph (e.g. the Nerd-only host_* icons)
  # left over from a previous mode so it can't leak into the plain set.
  glyph_pad=()
  for name in ${(k)g}; do
    ov="PROMPT_KRONUZ_GLYPH_${name:u}"
    val="${(P)ov-$sentinel}"
    [[ "$val" == "$sentinel" ]] && val="$g[$name]"
    kz[GLYPH.$name]="$val"
    # Trailing (right-hand) pad, appended after the glyph. An explicit
    # $PROMPT_KRONUZ_GLYPH_PAD_<NAME> wins: set it to '' to hug tight, or to ' ', a
    # non-breaking space ($'\u00a0'), etc. to tune spacing for your font. Otherwise a
    # single Private-Use-Area glyph can render wider than its cell, so it gets a pad space
    # by default so an adjacent count/text doesn't collide; BMP and multi-char glyphs none.
    padov="PROMPT_KRONUZ_GLYPH_PAD_${name:u}"
    padval="${(P)padov-$sentinel}"
    if [[ "$padval" != "$sentinel" ]]; then
      glyph_pad[$name]="$padval"
    else
      c=0; [[ ${#val} -eq 1 ]] && c=$(( #val ))
      if (( (c >= 0xe000 && c <= 0xf8ff) || c >= 0xf0000 )); then
        glyph_pad[$name]=' '
      else
        glyph_pad[$name]=''
      fi
    fi
  done
  # Legacy override: an explicit $_kronuz_os (set in ~/.zshrc.local) wins for the OS glyph.
  (( ${+_kronuz_os} )) && kz[GLYPH.os]="$_kronuz_os"
}

# ============================================================================
# Segments  (each recomputed by prompt_kronuz_precmd into $_prompt_kronuz_*)
# ============================================================================

# ---- git ----
typeset -g _prompt_kronuz_git=''

# Git state, split out for skins. prompt.zsh computes these once per prompt (from
# gitstatusd, or the direct-git fallback), so a PROMPT_KRONUZ_GIT override can reshape the
# git segment declaratively -- e.g. '${kz[git.branch]:+ (${kz[git.branch]}${kz[git.dirty]:+*})}'
# -- with no hook of its own. Each is a string: empty when absent/zero, else the value or
# count, so a plain ${var:+...} tests it. All are '' outside a repo. The fallback knows
# presence, not counts, so there each count is '' or '1' (and ahead/behind/stashed/
# conflicted stay '').
# The normalised git state lives in $kz[git.<name>] (branch, remote, dirty, staged,
# unstaged, untracked, conflicted, stashed, ahead, behind), populated by both the daemon
# and fallback paths below and reset off-repo. Each is a string: empty when absent/zero,
# else the value or count, so a plain ${kz[git.<name>]:+...} tests it. The fallback knows
# presence, not counts, so there each count is '' or '1' (and ahead/behind/stashed/
# conflicted stay '').

function _kronuz_git_reset_state {
  kz[git.branch]='' kz[git.remote]='' kz[git.dirty]='' \
    kz[git.staged]='' kz[git.unstaged]='' kz[git.untracked]='' \
    kz[git.conflicted]='' kz[git.stashed]='' \
    kz[git.ahead]='' kz[git.behind]=''
}

# Direct-git fallback, used when gitstatusd isn't running (no tty, not installed).
function _kronuz_git_fallback {
  # The git binary is overridable, so the fallback can be pointed at a wrapper or, in
  # previews/tests, a fake (see dev/fake-git). Word-split into an array; the default
  # keeps the `command` builtin so a user git function/alias can't shadow it.
  local -a gitcmd=( ${=PROMPT_KRONUZ_GIT_CMD:-command git} )
  $gitcmd rev-parse --is-inside-work-tree &>/dev/null || { _kronuz_git_reset_state; return }
  local branch
  branch="$($gitcmd symbolic-ref --short HEAD 2>/dev/null)" \
    || branch="$($gitcmd rev-parse --short HEAD 2>/dev/null)"
  [[ -z "$branch" ]] && { _kronuz_git_reset_state; return }
  local sep="${(e)_ksem[sep]}" none="${(e)kz[RESET]}" info="${(e)_ksem[info]}"
  local gly="$kz[GLYPH.branch]"
  $gitcmd symbolic-ref --quiet HEAD &>/dev/null || gly="$kz[GLYPH.commit]"
  local warning=''
  [[ -n "$kz[GLYPH.fallback]" ]] && warning="${(e)_ksem[fallback]}${kz[GLYPH.fallback]}${none} "
  local s=" ${warning}${info}${gly}${none} ${(e)_ksem[branch]}${branch}${none}"
  local remote
  remote="$($gitcmd rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)"
  [[ -n "$remote" ]] && s+=" ${info}${kz[GLYPH.remote]}${none} ${(e)_ksem[remote]}${remote}${none}"
  local staged='' unstaged='' untracked='' icons=''
  local isep="${PROMPT_KRONUZ_GIT_SEP-$DEFAULT_PROMPT_KRONUZ_GIT_SEP}"
  $gitcmd diff --cached --quiet --ignore-submodules 2>/dev/null || staged=1
  $gitcmd diff --quiet --ignore-submodules 2>/dev/null || unstaged=1
  [[ -n "$($gitcmd ls-files --others --exclude-standard 2>/dev/null | head -1)" ]] && untracked=1
  if [[ -n "$staged$unstaged$untracked" ]]; then
    icons+="${(e)_ksem[dirty]}${kz[GLYPH.dirty]}${none}"
    [[ -n "$staged" ]]    && icons+="${icons:+$isep}${(e)_ksem[added]}${kz[GLYPH.staged]}${none}"
    [[ -n "$unstaged" ]]  && icons+="${icons:+$isep}${(e)_ksem[modified]}${kz[GLYPH.modified]}${none}"
    [[ -n "$untracked" ]] && icons+="${icons:+$isep}${(e)_ksem[untracked]}${kz[GLYPH.untracked]}${none}"
  else
    icons="${(e)_ksem[clean]}${kz[GLYPH.clean]}${none}"
  fi
  kz[git.branch]="$branch" kz[git.remote]="$remote"
  kz[git.staged]="${staged:+1}" kz[git.unstaged]="${unstaged:+1}" \
    kz[git.untracked]="${untracked:+1}" kz[git.dirty]="${staged}${unstaged}${untracked:+1}"
  _prompt_kronuz_git="${s}${sep} (${none}${icons}${sep})${none}"
}

# Async git segment. The prompt must never block on git, so we talk to the KRONUZ
# gitstatusd instance non-blockingly: wait at most $PROMPT_KRONUZ_GIT_SYNC_TIMEOUT seconds
# for an answer (default 0.05). Fast/cached repos answer within that budget and render
# fresh; anything slower renders the last-known status immediately and repaints in place
# when the daemon catches up, via _kronuz_gitstatus_cb. gitstatus forbids overlapping
# queries on one name ("CONCURRENT CALLS WITH THE SAME NAME ARE NOT ALLOWED", per its
# header), so we never issue a new query while one is in flight -- $_kronuz_git_inflight
# tracks that. Only when gitstatusd isn't usable at all do we fall back to blocking git.
typeset -g _kronuz_git_last='' _kronuz_git_inflight=0

# Render the git segment from the current VCS_STATUS_* into $_prompt_kronuz_git, caching
# the result in $_kronuz_git_last so an in-flight prompt can show it while a query runs.
function _kronuz_git_render {
  local sep="${(e)_ksem[sep]}" none="${(e)kz[RESET]}" info="${(e)_ksem[info]}" s=''
  if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    s+=" ${info}${kz[GLYPH.branch]}${none} ${(e)_ksem[branch]}${VCS_STATUS_LOCAL_BRANCH}${none}"
  elif [[ -n "$VCS_STATUS_TAG" ]]; then
    s+=" ${info}${kz[GLYPH.tag]}${none} ${(e)_ksem[branch]}${VCS_STATUS_TAG}${none}"
  else
    s+=" ${info}${kz[GLYPH.commit]}${none} ${(e)_ksem[commit]}${VCS_STATUS_COMMIT[1,7]}${none}"
  fi
  # Remote tracking branch, tagged with a per-host icon (GitHub / GitLab / Bitbucket)
  # picked from $VCS_STATUS_REMOTE_URL. Unknown hosts and the plain-Unicode set (which has
  # no logos) fall back to the generic ${kz[GLYPH.remote]} mark.
  if [[ -n "$VCS_STATUS_REMOTE_NAME" ]]; then
    local rg="${kz[GLYPH.remote]}"
    case "$VCS_STATUS_REMOTE_URL" in
      (*github*)    rg="${kz[GLYPH.host_github]:-$rg}" ;;
      (*gitlab*)    rg="${kz[GLYPH.host_gitlab]:-$rg}" ;;
      (*bitbucket*) rg="${kz[GLYPH.host_bitbucket]:-$rg}" ;;
    esac
    s+=" ${info}${rg}${none} ${(e)_ksem[remote]}${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}${none}"
  fi
  [[ -n "$VCS_STATUS_ACTION" ]] && \
    s+=" ${info}${kz[GLYPH.action]}${none} ${(e)_ksem[action]}${VCS_STATUS_ACTION}${none}"

  # Indicators inside the (...), joined by $PROMPT_KRONUZ_GIT_SEP (a space by
  # default, from $DEFAULT_PROMPT_KRONUZ_GIT_SEP; set it to '·', ':', '' or anything
  # to taste). ${icons:+$isep} inserts the separator before every indicator except the first.
  local isep="${PROMPT_KRONUZ_GIT_SEP-$DEFAULT_PROMPT_KRONUZ_GIT_SEP}"
  local icons=''
  (( VCS_STATUS_STASHES )) && icons+="${icons:+$isep}${(e)_ksem[stashed]}${kz[GLYPH.stashed]}${glyph_pad[stashed]}${VCS_STATUS_STASHES}${none}"
  # gitstatusd reports HAS_* = -1 for unstaged/conflicted/untracked when the index is
  # larger than its -m cap and it skipped the dirty scan (see PROMPT_KRONUZ_GITSTATUS_ARGS
  # in lib/plugins.zsh). Staged is always counted exactly; the rest are then unknown, so
  # we render the dirty mark plus a single "∞" instead of guessing "clean".
  local -i dirty_unknown=$(( ${VCS_STATUS_HAS_UNSTAGED:-0} == -1 ))
  if (( dirty_unknown || VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )); then
    icons+="${icons:+$isep}${(e)_ksem[dirty]}${kz[GLYPH.dirty]}${none}"
  else
    icons+="${icons:+$isep}${(e)_ksem[clean]}${kz[GLYPH.clean]}${none}"
  fi
  (( VCS_STATUS_COMMITS_AHEAD ))  && icons+="${icons:+$isep}${(e)_ksem[ahead]}${kz[GLYPH.ahead]}${glyph_pad[ahead]}${VCS_STATUS_COMMITS_AHEAD}${none}"
  (( VCS_STATUS_COMMITS_BEHIND )) && icons+="${icons:+$isep}${(e)_ksem[behind]}${kz[GLYPH.behind]}${glyph_pad[behind]}${VCS_STATUS_COMMITS_BEHIND}${none}"
  # Push-remote divergence (⇧/⇩), shown only when the push target is a *different* remote
  # than the upstream (triangular / fork workflow: push to your fork, pull from upstream).
  # gitstatusd fills these in the same payload, so it costs no extra git call.
  if [[ -n "$VCS_STATUS_PUSH_REMOTE_NAME" && "$VCS_STATUS_PUSH_REMOTE_URL" != "$VCS_STATUS_REMOTE_URL" ]]; then
    (( VCS_STATUS_PUSH_COMMITS_AHEAD ))  && icons+="${icons:+$isep}${(e)_ksem[ahead]}${kz[GLYPH.push_ahead]}${glyph_pad[push_ahead]}${VCS_STATUS_PUSH_COMMITS_AHEAD}${none}"
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && icons+="${icons:+$isep}${(e)_ksem[behind]}${kz[GLYPH.push_behind]}${glyph_pad[push_behind]}${VCS_STATUS_PUSH_COMMITS_BEHIND}${none}"
  fi
  # Staged / unstaged detail. With PROMPT_KRONUZ_GIT_SPLIT set, the single staged and
  # unstaged counts break into per-type marks -- added (+), changed (~), deleted (-) --
  # coloured by group (staged the added colour, unstaged the modified colour); gitstatusd already reports the
  # *_NEW / *_DELETED breakdown, so this costs no extra git call. Off by default (one
  # aggregate count per group). The -m-capped "unknown" path keeps the aggregate.
  local -i split=0
  [[ "${(L)PROMPT_KRONUZ_GIT_SPLIT:-0}" == (1|yes|on|true) ]] && split=1

  if (( split && ! dirty_unknown )); then
    local -i s_new=VCS_STATUS_NUM_STAGED_NEW s_del=VCS_STATUS_NUM_STAGED_DELETED
    local -i s_mod=VCS_STATUS_NUM_STAGED-s_new-s_del
    (( s_new > 0 )) && icons+="${icons:+$isep}${(e)_ksem[added]}${kz[GLYPH.added]}${glyph_pad[added]}${s_new}${none}"
    (( s_mod > 0 )) && icons+="${icons:+$isep}${(e)_ksem[added]}${kz[GLYPH.changed]}${glyph_pad[changed]}${s_mod}${none}"
    (( s_del > 0 )) && icons+="${icons:+$isep}${(e)_ksem[added]}${kz[GLYPH.deleted]}${glyph_pad[deleted]}${s_del}${none}"
  else
    (( VCS_STATUS_NUM_STAGED )) && icons+="${icons:+$isep}${(e)_ksem[added]}${kz[GLYPH.staged]}${glyph_pad[staged]}${VCS_STATUS_NUM_STAGED}${none}"
  fi

  if (( dirty_unknown )); then
    icons+="${icons:+$isep}${(e)_ksem[untracked]}${kz[GLYPH.unknown]}${glyph_pad[unknown]}${none}"
  else
    if (( split )); then
      local -i u_del=VCS_STATUS_NUM_UNSTAGED_DELETED u_mod=VCS_STATUS_NUM_UNSTAGED-u_del
      (( u_mod > 0 )) && icons+="${icons:+$isep}${(e)_ksem[modified]}${kz[GLYPH.changed]}${glyph_pad[changed]}${u_mod}${none}"
      (( u_del > 0 )) && icons+="${icons:+$isep}${(e)_ksem[modified]}${kz[GLYPH.deleted]}${glyph_pad[deleted]}${u_del}${none}"
    else
      (( VCS_STATUS_NUM_UNSTAGED )) && icons+="${icons:+$isep}${(e)_ksem[modified]}${kz[GLYPH.modified]}${glyph_pad[modified]}${VCS_STATUS_NUM_UNSTAGED}${none}"
    fi
    (( VCS_STATUS_NUM_CONFLICTED )) && icons+="${icons:+$isep}${(e)_ksem[unmerged]}${kz[GLYPH.conflicted]}${glyph_pad[conflicted]}${VCS_STATUS_NUM_CONFLICTED}${none}"
    (( VCS_STATUS_NUM_UNTRACKED ))  && icons+="${icons:+$isep}${(e)_ksem[untracked]}${kz[GLYPH.untracked]}${glyph_pad[untracked]}${VCS_STATUS_NUM_UNTRACKED}${none}"
  fi

  kz[git.branch]="${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_TAG:-${VCS_STATUS_COMMIT[1,7]}}}"
  kz[git.remote]="${VCS_STATUS_REMOTE_NAME:+${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}}"
  kz[git.staged]="${VCS_STATUS_NUM_STAGED:#0}" kz[git.unstaged]="${VCS_STATUS_NUM_UNSTAGED:#0}"
  kz[git.untracked]="${VCS_STATUS_NUM_UNTRACKED:#0}" kz[git.conflicted]="${VCS_STATUS_NUM_CONFLICTED:#0}"
  kz[git.stashed]="${VCS_STATUS_STASHES:#0}" kz[git.ahead]="${VCS_STATUS_COMMITS_AHEAD:#0}" \
    kz[git.behind]="${VCS_STATUS_COMMITS_BEHIND:#0}"
  kz[git.dirty]=''
  (( dirty_unknown || VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )) \
    && kz[git.dirty]=1
  _prompt_kronuz_git="${s}${sep} (${none}${icons}${sep})${none}"
  _kronuz_git_last="$_prompt_kronuz_git"
}

# gitstatusd calls this (from its own zle -F handler) when a timed-out query finally has
# data. Re-render and repaint the live prompt in place: `zle reset-prompt` re-expands
# $PROMPT with the fresh $_prompt_kronuz_git -- it runs no precmd and issues no new query.
function _kronuz_gitstatus_cb {
  _kronuz_git_inflight=0
  if [[ "$VCS_STATUS_RESULT" == ok-async ]]; then
    _kronuz_git_render
  else
    _prompt_kronuz_git=''
    _kronuz_git_last=''
  fi
  zle && zle reset-prompt
}

# Drop the stale cache when the directory changes, so a new dir never briefly shows the
# previous repo's status while its first query is still in flight.
function _kronuz_git_chpwd { _kronuz_git_last='' }

function _kronuz_git_segment {
  # No usable daemon -> blocking direct-git fallback (not installed / not yet ready).
  if (( ! ${+functions[gitstatus_query]} )) || ! gitstatus_check KRONUZ 2>/dev/null; then
    _kronuz_git_inflight=0
    _prompt_kronuz_git=''
    _kronuz_git_fallback
    return
  fi
  # A query is already outstanding: starting another for the same name is illegal, so show
  # the last-known status and let the pending callback repaint when it lands.
  if (( _kronuz_git_inflight )); then
    _prompt_kronuz_git="$_kronuz_git_last"
    return
  fi
  # Non-blocking query, bounded by the sync-latency budget.
  if ! gitstatus_query -t ${PROMPT_KRONUZ_GIT_SYNC_TIMEOUT:-0.05} -c _kronuz_gitstatus_cb KRONUZ 2>/dev/null; then
    _kronuz_git_inflight=0
    _prompt_kronuz_git=''
    _kronuz_git_fallback
    return
  fi
  case "$VCS_STATUS_RESULT" in
    ok-sync)     _kronuz_git_inflight=0; _kronuz_git_render ;;                   # answered in budget
    norepo-sync) _kronuz_git_inflight=0; _prompt_kronuz_git=''; _kronuz_git_last=''; _kronuz_git_reset_state ;;  # not a repo
    *)  # tout: a query is in flight. Show the last-known status (if any) plus a subtle
        # loading mark, so a slow or first paint reads as "refreshing", not blank/frozen.
        _kronuz_git_inflight=1
        _prompt_kronuz_git="${_kronuz_git_last} ${(e)_ksem[loading]}${kz[GLYPH.loading]}${glyph_pad[loading]}${(e)kz[RESET]}"
        ;;
  esac
}

# ---- venv ----
typeset -g _prompt_kronuz_venv=''
function _kronuz_venv_segment {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    _prompt_kronuz_venv=" ${(e)_ksem[info]}${kz[GLYPH.venv]}${(e)kz[RESET]} ${(e)_ksem[venv]}${VIRTUAL_ENV:t}${(e)kz[RESET]}"
  else
    _prompt_kronuz_venv=''
  fi
}

# ---- working directory ----
# Render $PWD into _prompt_kronuz_pwd, per PROMPT_KRONUZ_PWD_STYLE:
#   full     (default) the whole path, home as ~      ~/.config/KronuZSH/integrations/bat
#   short    shortest-unique-prefix (truncate_to_unique) ~/.c/K/i/bat
#            each parent shrunk only as far as it stays unambiguous; leaf full
#   base     just the current directory name          bat
#   absolute the full path with $HOME expanded         /home/kronuz/.config/KronuZSH/.../bat
# (literal % are doubled so print -P won't expand them.)

# Set $REPLY to the shortest prefix of directory name $2 that is unique among the
# sub-directories of parent $1 (empty parent = filesystem root). Used by the 'short'
# PWD style below; globs the parent directory once.
function _kronuz_unique_prefix {
  emulate -L zsh -o extended_glob
  local parent="${1:-/}" name="$2" s
  local -a sibs=( ${parent%/}/*(ND/:t) )
  local -i n=1 c
  while (( n < $#name )); do
    c=0
    for s in $sibs; do [[ "$s" == "${name[1,n]}"* ]] && (( c++ )); done
    (( c <= 1 )) && break
    (( n++ ))
  done
  typeset -g REPLY="${name[1,n]}"
}
typeset -g _kronuz_pwd_sig=''
function _kronuz_pwd_segment {
  # Skip the recompute (for the 'short' style, ~1ms of globbing) when neither the
  # directory nor the style changed since the last prompt. Keyed on both, so a cd or a
  # runtime PROMPT_KRONUZ_PWD_STYLE change still refreshes; the cached string persists in
  # $_prompt_kronuz_pwd. (A new sibling directory sharing your prefix won't re-shorten
  # until the next cd -- an acceptable staleness for the 'short' style.)
  local sig="${PROMPT_KRONUZ_PWD_STYLE:-full}|$PWD"
  [[ "$sig" == "$_kronuz_pwd_sig" ]] && return
  _kronuz_pwd_sig="$sig"

  local p="${(%):-%~}"
  case "${PROMPT_KRONUZ_PWD_STYLE:-full}" in
    base)
      p="${p:t}"; [[ -z "$p" ]] && p='/'
      ;;
    absolute)
      p="$PWD"
      ;;
    short)
      # Shortest-unique-prefix truncation (like p10k truncate_to_unique): shorten each
      # parent to the fewest leading chars that still tell it apart from its siblings; the
      # leaf keeps its full name. Globs each parent once (readdir) -- pricier than the
      # styles above, but still fork-free.
      local -a parts=("${(@s:/:)p}")
      local out='' rp='' seg
      local -i i last=$#parts
      for (( i = 1; i <= last; i++ )); do
        seg="$parts[i]"
        if [[ "$seg" == '~' ]]; then
          out+='~'; rp="$HOME"
        elif [[ -z "$seg" ]]; then
          rp=''                              # leading empty = filesystem root
        elif (( i == last )); then
          out+="/$seg"                       # leaf keeps its full name
        else
          _kronuz_unique_prefix "$rp" "$seg"; out+="/$REPLY"
          rp+="/$seg"
        fi
      done
      p="${out:-/}"
      ;;
  esac
  _prompt_kronuz_pwd="${p//\%/%%}"
}

# ---- LAN IP -------------------------------------------------------------------
# The primary LAN IP changes rarely, but the only portable way to read it is to
# fork `ifconfig` (there is no zsh builtin for it), and that pipeline costs ~16ms.
# So we never compute it on the prompt path: each prompt reads the last value from
# a cache file with $(<...) (a builtin read, no fork), and at most once per TTL we
# kick off a *detached* refresh whose result lands in the cache for the next prompt.
# Hot-path cost drops from ~16ms to a cheap file read. Trade-off: the first prompt
# after a network change shows the previous IP, the next one shows the new IP.
typeset -g _prompt_kronuz_ip='' _kronuz_ip_ts=0
typeset -g _kronuz_ip_cache="${TMPDIR:-/tmp}/kronuz-ip.$UID"
function _kronuz_ip_segment {
  # Show whatever the last background refresh wrote (no fork).
  [[ -r "$_kronuz_ip_cache" ]] && _prompt_kronuz_ip="$(<$_kronuz_ip_cache)"
  # Throttle refreshes to once per TTL (default 60s).
  (( ${EPOCHSECONDS:-0} - _kronuz_ip_ts < ${PROMPT_KRONUZ_IP_TTL:-60} )) && return
  _kronuz_ip_ts=${EPOCHSECONDS:-0}
  # Detached, non-blocking refresh (one awk instead of grep|grep|head|awk), written
  # to a temp then renamed so a concurrent reader never sees a half-written line.
  {
    ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" { print $2; exit }' > "$_kronuz_ip_cache.new" \
      && command mv -f "$_kronuz_ip_cache.new" "$_kronuz_ip_cache"
  } &!
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
# is shown on the live prompt when transience is enabled. By default, accepting the
# next command keeps that line in history outside the next command's OSC 133 A/B region.
# In non-transient mode, the same status option controls whether the line is shown.
typeset -g _prompt_kronuz_status='' _prompt_kronuz_status_live=''
typeset -g _prompt_kronuz_last_exit=0

function _kronuz_status_segment {
  _prompt_kronuz_status='' _prompt_kronuz_status_live=''
  # Only after a real command ran: a blank Enter leaves $? unchanged and must not
  # re-show (and, via the transient copy, re-keep) the previous command's exit code.
  (( ${_kronuz_cmd_ran:-0} )) || return
  local out='' body item sp
  if (( ${_prompt_kronuz_last_exit:-0} != 0 )); then
    body="${(e)PROMPT_KRONUZ_ERROR-$DEFAULT_PROMPT_KRONUZ_ERROR}"
    if [[ -n "$body" ]]; then
      item="${(e)_ksem[status_err]}${body}${(e)kz[RESET]}"
      out+="$item"
    fi
  fi
  if [[ -n "$_prompt_kronuz_duration" ]]; then
    body="${(e)PROMPT_KRONUZ_DURATION-$DEFAULT_PROMPT_KRONUZ_DURATION}"
    if [[ -n "$body" ]]; then
      sp="${out:+ }"; item="${(e)_ksem[duration]}${body}${(e)kz[RESET]}"
      out+="${sp}${item}"
    fi
  fi
  if [[ -n "$out" ]]; then
    _prompt_kronuz_status="${out}%E"$'\n'
    if _kronuz_transient_enabled || _kronuz_status_enabled; then
      _prompt_kronuz_status_live=$_prompt_kronuz_status
    fi
  fi
  _kronuz_cmd_ran=0
}

# ============================================================================
# Editor keymap indicator
# ============================================================================

# Update the vi/emacs keymap caret ($_prompt_kronuz_keymap) and overwrite mark
# ($_prompt_kronuz_overwrite) from zle state, then redraw. The three public format parameters
# are evaluated here so palette/glyph changes remain live. Driven by the widgets below.
typeset -g _prompt_kronuz_keymap='' _prompt_kronuz_overwrite=''
function _kronuz_keymap_update {
  if [[ "$KEYMAP" == 'vicmd' ]]; then
    _prompt_kronuz_keymap="${(e)PROMPT_KRONUZ_KEYMAP_ALTERNATE-$DEFAULT_PROMPT_KRONUZ_KEYMAP_ALTERNATE}"
  else
    _prompt_kronuz_keymap="${(e)PROMPT_KRONUZ_KEYMAP_PRIMARY-$DEFAULT_PROMPT_KRONUZ_KEYMAP_PRIMARY}"
  fi
  if [[ "$ZLE_STATE" == *overwrite* ]]; then
    _prompt_kronuz_keymap="${(e)PROMPT_KRONUZ_KEYMAP_OVERWRITE-$DEFAULT_PROMPT_KRONUZ_KEYMAP_OVERWRITE}"
    _prompt_kronuz_overwrite=" ${(e)_ksem[overwrite]}${kz[GLYPH.overwrite]}${(e)kz[RESET]}"
  else
    _prompt_kronuz_overwrite=''
  fi
  # reset-prompt redraws in place, which needs cursor addressing; skip it on dumb
  # terminals (it would reprint the multi-line prompt). The seed in setup means the
  # first render already shows the caret even where zle-line-init never fires.
  (( ${_kronuz_dumb:-0} )) || zle reset-prompt 2>/dev/null
}
function zle-keymap-select { _kronuz_keymap_update }
function zle-line-init {
  # Non-transient A/B have already marked the editable line on the first paint.
  # Keep line-init and later keymap redraws from creating duplicate command marks.
  _kronuz_osc_d='' _kronuz_osc_a='' _kronuz_osc_b=''
  _kronuz_keymap_update
}
# Toggling overwrite mode does not change keymaps, so zle-keymap-select does not fire.
# Wrap the standard widget, as Prezto does, so inherited and explicit bindings both
# refresh the caret and RPROMPT after invoking the builtin.
function _kronuz_overwrite_toggle {
  zle .overwrite-mode
  _kronuz_keymap_update
}

# ============================================================================
# Terminal integration  (OSC 7/1337 cwd, OSC 133 command boundaries)
# ============================================================================
# This section owns the whole shell-integration state machine. Hook functions decide
# *when* a boundary occurs; the small helpers below decide *which bytes* each terminal
# receives. Keep prompt-rendered bytes in $_kronuz_osc_{d,a,b}: A/B must surround the
# editable prompt, while non-transient D must appear after the live status row.
typeset -g _kronuz_osc_d='' _kronuz_osc_a='' _kronuz_osc_b=''
typeset -g _kronuz_is_iterm=0 _kronuz_osc_command_active=0 _kronuz_osc_line_submitted=0

function _kronuz_osc_active {
  [[ "${PROMPT_KRONUZ_TERMINAL_INTEGRATION:-1}" != (0|no|off|false) \
    && -n "$TERM" && "$TERM" != (dumb|unknown) ]]
}

function _kronuz_transient_enabled {
  local tp="${(e)${(e)PROMPT_KRONUZ_TRANSIENT_PROMPT-$DEFAULT_PROMPT_KRONUZ_TRANSIENT_PROMPT}}"
  [[ -n "$tp" && -n "$TERM" && "$TERM" != (dumb|unknown) ]]
}

function _kronuz_osc_clear_prompt_boundaries {
  _kronuz_osc_d='' _kronuz_osc_a='' _kronuz_osc_b=''
}

# Detection is deferred until precmd so ~/.zshrc.local can disable integration after
# prompt setup. The announcement is once per shell; $_kronuz_is_iterm then selects all
# later iTerm-specific protocol forms.
function _kronuz_osc_detect_iterm {
  (( _kronuz_is_iterm )) && return
  [[ "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]] || return
  _kronuz_is_iterm=1
  print -n '\e]1337;ShellIntegrationVersion=14;shell=zsh\a'
}

# Report the same cwd through one protocol only. iTerm2's OSC 7 implementation creates
# a prompt mark, so combining it with OSC 133 produces a duplicate blue triangle.
function _kronuz_osc_report_context {
  if (( _kronuz_is_iterm )); then
    print -Pn "\e]1337;RemoteHost=${USER}@%M\a\e]1337;CurrentDir=%d\a"
  else
    print -Pn '\e]7;file://%M%d\a'
  fi
}

# Close the command whose C was emitted by preexec. Transient D is written now because
# its following live prompt is deliberately unmarked. Static D is deferred into PROMPT
# so the status row remains outside the completed command's output range.
function _kronuz_osc_finish_command {
  local ret=$1
  typeset -g _prompt_kronuz_last_exit=$ret
  if _kronuz_transient_enabled; then
    print -n "\e]133;D;${ret}\a"
  else
    _kronuz_osc_d=$'%{\e]133;D;'"${ret}"$'\a%}'
  fi
  _kronuz_osc_command_active=0
}

# A transient live prompt is a preview and is not recorded. Its A/B pair is added only
# by the accept-line widget after the prompt collapses to its permanent history form.
function _kronuz_osc_prepare_prompt_boundaries {
  if _kronuz_transient_enabled; then
    _kronuz_osc_a='' _kronuz_osc_b=''
  else
    _kronuz_osc_a=$'%{\e]133;A\a%}'
    _kronuz_osc_b=$'%{\e]133;B\a%}'
  fi
}

function _kronuz_osc_preexec {
  _kronuz_osc_active || return
  _kronuz_osc_command_active=1
  # Match iTerm2's own Zsh integration exactly there; the carriage return keeps the
  # command boundary correct for its screen-scraping command capture. Other terminals
  # receive the parameter-free OSC 133 form from the shared protocol.
  if (( _kronuz_is_iterm )); then
    print -n '\e]133;C;\r\a'
  else
    print -n '\e]133;C\a'
  fi
}
function _kronuz_osc_precmd {
  local ret=$?
  # Snapshot and clear the "a line was submitted" flag the accept widget sets, so
  # exactly one precmd acts on it.
  local submitted=$_kronuz_osc_line_submitted
  _kronuz_osc_line_submitted=0
  if ! _kronuz_osc_active; then
    _kronuz_osc_clear_prompt_boundaries
    _kronuz_osc_command_active=0
    return
  fi
  _kronuz_osc_d=''
  _kronuz_osc_detect_iterm
  if (( _kronuz_osc_command_active )); then
    # A command ran: close the C region preexec opened, with the real exit status.
    _kronuz_osc_finish_command "$ret"
  elif (( submitted )) && (( ret != 130 )); then
    # A structurally complete line that zsh rejected at parse time: preexec never
    # fired, so the normal C/D pair was never emitted. Still mark the line done
    # with its exit status so consumers get a boundary + status for the failure.
    # (Blank Enter sets no flag; ret==130 is a Ctrl-C abort of an unfinished line,
    # which submitted no command -- neither should invent a D.)
    _kronuz_osc_finish_command "$ret"
  fi
  _kronuz_osc_report_context
  _kronuz_osc_prepare_prompt_boundaries
}

# ============================================================================
# Transient prompt
# ============================================================================
# On accept-line, $PROMPT collapses to a minimal caret so scrollback keeps only a
# caret + the command for past prompts (restored before the next prompt). The
# accepted command is restyled per $PROMPT_KRONUZ_TRANSIENT_STYLE: dim (same hues,
# darker), mute (one grey span), or keep. Off on dumb and when $PROMPT_KRONUZ_TRANSIENT_PROMPT=''.
typeset -g _kronuz_prompt_full='' _kronuz_rprompt_full='' _kronuz_muting=0

# Transient styling is shared by prompt strings and ZLE command highlights. Keep the
# colour math here so segment renderers only decide what to display, not how history
# is repainted.
function _kronuz_dim_rgb {
  local -a reply
  _kronuz_color_rgb "$1"
  (( $#reply == 3 )) || return 1
  local -F f=${PROMPT_KRONUZ_TRANSIENT_DIM:-0.7}
  local -i r=$(( reply[1]*f )) g=$(( reply[2]*f )) b=$(( reply[3]*f ))
  printf -v REPLY '#%02x%02x%02x' r g b
}

# Resolve keep/mute/dim into $REPLY without changing prompt structure. The dim path
# rewrites each %F{} span; mute replaces every foreground with the configured grey.
function _kronuz_dim_string {
  emulate -L zsh
  local s=$1 style="${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}"
  [[ "$style" == (keep|none|off) ]] && { REPLY="$s"; return }
  local mute=0; [[ "$style" == (mute|grey|gray) ]] && mute=1
  local grey="${(e)_ksem[transmuted]}"
  local -a parts=("${(@ps:%F{:)s}")
  local out="${parts[1]}" p spec rest
  for p in "${(@)parts[2,-1]}"; do
    spec="${p%%\}*}"; rest="${p#*\}}"
    if (( mute )); then out+="${grey}${rest}"
    elif _kronuz_dim_rgb "$spec"; then out+="%F{$REPLY}$rest"
    else out+="%F{$spec}$rest"; fi
  done
  REPLY="$out"
}

# Resolve the public whole-prompt override. `-` rather than `:-` makes an explicit
# empty value disable transience while an unset value selects the default.
function _kronuz_transient_prompt {
  REPLY="${(e)${(e)PROMPT_KRONUZ_TRANSIENT_PROMPT-$DEFAULT_PROMPT_KRONUZ_TRANSIENT_PROMPT}}"
}

# The collapsed right prompt, mirror of _kronuz_transient_prompt. Empty by default, so
# past prompts collapse with no right side unless a skin sets PROMPT_KRONUZ_TRANSIENT_RPROMPT.
function _kronuz_transient_rprompt {
  REPLY="${(e)${(e)PROMPT_KRONUZ_TRANSIENT_RPROMPT-$DEFAULT_PROMPT_KRONUZ_TRANSIENT_RPROMPT}}"
}

function _kronuz_status_enabled {
  [[ "${PROMPT_KRONUZ_STATUS:-1}" != (0|no|off|false) ]]
}

# Preserve the previous result above the collapsed prompt. It must remain outside OSC
# A/B: putting A before this prefix moves the next command's gutter mark onto ⏎/time.
function _kronuz_transient_status_prefix {
  REPLY=''
  _kronuz_status_enabled || return
  [[ -n "$_prompt_kronuz_status" ]] || return
  _kronuz_dim_string "$_prompt_kronuz_status"
}

# Add OSC 133 only to the collapsed prompt that will survive in scrollback. REPLY is
# the complete temporary PROMPT value; the full live prompt remains untouched here.
function _kronuz_transient_marked_prompt {
  local prompt=$1
  if _kronuz_osc_active; then
    REPLY=$'%{\e]133;A\a%}'"${prompt}"$'%{\e]133;B\a%}'
  else
    REPLY=$prompt
  fi
}

# Restyle the command's region_highlight in place (zsh has no faint attribute, so
# `dim` recolours each fg toward black at truecolor precision).
function _kronuz_transient_style {
  case "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" in
    keep|none|off) ;;
    mute|grey|gray)
      region_highlight=("0 ${#BUFFER} ${PROMPT_KRONUZ_TRANSIENT_HL:-fg=8}") ;;
    *)
      setopt localoptions extendedglob
      local -a out p; local e REPLY
      for e in "${region_highlight[@]}"; do
        p=("${(z)e}")
        if [[ ${p[3]} = (#b)(*)fg=([^, ]##)(*) ]] && _kronuz_dim_rgb "${match[2]}"; then
          p[3]="${match[1]}fg=${REPLY}${match[3]}"
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
  # A non-empty buffer is being submitted. Record it so the OSC precmd can emit a
  # D;<exit> boundary even when zsh rejects the line at parse time -- preexec (and
  # thus the normal C/D path) never fires for a line that fails to parse.
  [[ -n "$BUFFER" ]] && _kronuz_osc_line_submitted=1
  _kronuz_transient_prompt
  local tp=$REPLY
  if (( ! ${_kronuz_dumb:-0} )) && [[ -n "$tp" ]]; then
    _kronuz_prompt_full=$PROMPT _kronuz_rprompt_full=$RPROMPT
    _kronuz_transient_status_prefix
    local status_prefix=$REPLY
    _kronuz_dim_string "$tp"; tp="$REPLY"     # restyle the whole line (dim/mute/keep)
    _kronuz_transient_rprompt; local rp=$REPLY
    [[ -n "$rp" ]] && { _kronuz_dim_string "$rp"; rp=$REPLY }   # restyle the right side the same way
    # A/B also delimit a blank prompt, so iTerm can navigate it independently. Since
    # no command runs, preexec emits no C and precmd emits no D for that blank entry.
    _kronuz_transient_marked_prompt "$tp"
    PROMPT="${status_prefix}${REPLY}" RPROMPT="$rp"
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
  # Resolve the initial/primary caret here, after ~/.zshrc.local has loaded. ZLE's
  # line-init/keymap-select widgets take over while the user is editing a command.
  _prompt_kronuz_keymap="${(e)PROMPT_KRONUZ_KEYMAP_PRIMARY-$DEFAULT_PROMPT_KRONUZ_KEYMAP_PRIMARY}"
  _prompt_kronuz_overwrite=''
  # Load the dim palette once, here rather than in setup, so any PROMPT_KRONUZ_PALETTE_*
  # override / TTL / timeout from ~/.zshrc.local (sourced after setup) is in effect.
  if (( ! ${_kronuz_pal_loaded:-0} )); then
    _kronuz_pal_loaded=1
    [[ "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" != (keep|none|off|mute|grey|gray) ]] && _kronuz_load_palette
  fi
  _kronuz_pwd_segment
  _kronuz_venv_segment
  _kronuz_ip_segment
  _kronuz_duration_segment
  _kronuz_status_segment
  _kronuz_git_segment
}

# Register lifecycle hooks and editor widgets in one place. Ordering is semantic:
# OSC precmd must capture $? before the render hook changes it, while duration and OSC
# preexec observe the same accepted command.
function _kronuz_setup_lifecycle {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd prompt_kronuz_precmd
  add-zsh-hook preexec _kronuz_duration_preexec
  add-zsh-hook precmd _kronuz_osc_precmd
  add-zsh-hook preexec _kronuz_osc_preexec
  add-zsh-hook chpwd _kronuz_git_chpwd
  precmd_functions=(_kronuz_osc_precmd ${precmd_functions:#_kronuz_osc_precmd})

  zle -N zle-keymap-select
  zle -N zle-line-init
  zle -N overwrite-mode _kronuz_overwrite_toggle
  if [[ -n "${terminfo[kich1]-}" ]]; then
    bindkey -M emacs "$terminfo[kich1]" overwrite-mode
    bindkey -M viins "$terminfo[kich1]" overwrite-mode
  fi
}

# Install the accept-line replacement and the syntax-highlighter bridge. This is kept
# separate from prompt composition because it mutates ZLE's widget graph.
function _kronuz_setup_transient_widgets {
  zle -N _kronuz_transient_accept
  bindkey '^M' _kronuz_transient_accept
  bindkey '^J' _kronuz_transient_accept
  add-zsh-hook precmd _kronuz_transient_restore

  # Fast-syntax-highlighting repaints region_highlight on line-finish. Wrap its shared
  # painter once, then apply the transient style after it while a command is accepting.
  if (( ${+functions[_zsh_highlight]} )) && (( ! ${+functions[_kronuz_zsh_highlight_orig]} )); then
    functions[_kronuz_zsh_highlight_orig]=$functions[_zsh_highlight]
    function _zsh_highlight {
      _kronuz_zsh_highlight_orig "$@"
      local ret=$?
      (( ${_kronuz_muting:-0} )) && _kronuz_transient_style
      return ret
    }
  fi

  # Palette loading is lazy so ~/.zshrc.local, sourced after setup, can configure it.
  # Re-arm the one-shot when setup is explicitly run again.
  _kronuz_pal_loaded=0
}

function prompt_kronuz_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  zmodload -i zsh/parameter 2>/dev/null  # $parameters, for the no-colour path
  zmodload -i zsh/datetime 2>/dev/null   # $EPOCHSECONDS, for the cached IP segment
  zmodload -i zsh/terminfo 2>/dev/null   # $terminfo, including the terminal's Insert key

  # The palette's 16..255 entries are hex (%F{#RRGGBB}); zsh/nearcolor maps them to
  # the nearest 256-colour (or the default fg on 8/16-colour terminals) so one palette
  # works everywhere. Skip it on a truecolor terminal, which renders the hex directly.
  if [[ "${COLORTERM-}" != (24bit|truecolor) && "${terminfo[colors]:-0}" -ne 16777216 ]]; then
    zmodload zsh/nearcolor 2>/dev/null
  fi

  _kronuz_setup_lifecycle

  DEFAULT_PROMPT_KRONUZ_KEYMAP_PRIMARY='${_ksem[caret1]}${kz[GLYPH.caret]}${kz[RESET]}${_ksem[caret2]}${kz[GLYPH.caret]}${kz[RESET]}${_ksem[caret3]}${kz[GLYPH.caret]}${kz[RESET]}'
  DEFAULT_PROMPT_KRONUZ_KEYMAP_ALTERNATE='${_ksem[caret3]}${kz[GLYPH.caret_alt]}${kz[RESET]}${_ksem[caret2]}${kz[GLYPH.caret_alt]}${kz[RESET]}${_ksem[caret1]}${kz[GLYPH.caret_alt]}${kz[RESET]}'
  DEFAULT_PROMPT_KRONUZ_KEYMAP_OVERWRITE='${_ksem[overwrite]}${kz[GLYPH.caret]}${kz[GLYPH.caret]}${kz[GLYPH.caret]}${kz[RESET]}'

  # Seed the keymap caret so a prompt char shows even where zle-line-init never fires
  # (e.g. Emacs `M-x shell`). precmd resolves it again after ~/.zshrc.local loads.
  _prompt_kronuz_keymap="${(e)DEFAULT_PROMPT_KRONUZ_KEYMAP_PRIMARY}"

  _prompt_kronuz_git=''
  _prompt_kronuz_pwd=''

  # Session context, fixed for the shell's life: SSH session and/or container.
  typeset -g _kronuz_is_ssh='' _kronuz_is_container=''
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && _kronuz_is_ssh=1
  [[ -f /.dockerenv || -f /run/.containerenv || -n "$container" ]] && _kronuz_is_container=1

  # Per-segment defaults. Each is a deferred string; dynamic ones read the
  # $_prompt_kronuz_* / state vars the precmd computes.
  DEFAULT_PROMPT_KRONUZ_OS='${kz[GLYPH.os]:+"${_ksem[host]}${kz[GLYPH.os]}${kz[RESET]} "}'
  DEFAULT_PROMPT_KRONUZ_CONTEXT='${_kronuz_is_container:+" ${_ksem[container]}${kz[GLYPH.container]}${kz[RESET]}"}${_kronuz_is_ssh:+" ${_ksem[ssh]}${kz[GLYPH.ssh]}${kz[RESET]}"}'
  DEFAULT_PROMPT_KRONUZ_ERR='%(?.${_ksem[status_ok]}${kz[GLYPH.dot]}${kz[RESET]}.${_ksem[status_err]}${kz[GLYPH.dot]}${kz[RESET]})'
  DEFAULT_PROMPT_KRONUZ_ERROR='${kz[GLYPH.return]} ${_prompt_kronuz_last_exit}'
  DEFAULT_PROMPT_KRONUZ_VIM='${VIM:+" ${_ksem[vim]}${kz[GLYPH.vim]}${kz[RESET]}"}'
  DEFAULT_PROMPT_KRONUZ_EMACS='${INSIDE_EMACS:+" ${_ksem[emacs]}${kz[GLYPH.emacs]}${kz[RESET]}"}'
  DEFAULT_PROMPT_KRONUZ_ETCTL='${ETCTL_SESSION:+" ${_ksem[info]}etctl${kz[RESET]}:${_ksem[etctl]}${ETCTL_SESSION}${kz[RESET]}"}'
  DEFAULT_PROMPT_KRONUZ_JOBS='%(1j. ${_ksem[jobs]}${kz[GLYPH.jobs]}${glyph_pad[jobs]}%j${kz[RESET]}.)'
  DEFAULT_PROMPT_KRONUZ_DURATION='${kz[GLYPH.duration]}${glyph_pad[duration]}${_prompt_kronuz_duration}'
  DEFAULT_PROMPT_KRONUZ_USER='%n'
  DEFAULT_PROMPT_KRONUZ_HOST='%M'
  DEFAULT_PROMPT_KRONUZ_IP='${_prompt_kronuz_ip}'
  DEFAULT_PROMPT_KRONUZ_GIT='${_prompt_kronuz_git:+${(e)_prompt_kronuz_git}}'
  DEFAULT_PROMPT_KRONUZ_GIT_SEP=' '
  DEFAULT_PROMPT_KRONUZ_VENV='${(e)_prompt_kronuz_venv}'
  DEFAULT_PROMPT_KRONUZ_OVERWRITE='${(e)_prompt_kronuz_overwrite}'
  DEFAULT_PROMPT_KRONUZ_CARET='${(e)_prompt_kronuz_keymap}'
  DEFAULT_PROMPT_KRONUZ_TIME='[%*]'
  DEFAULT_PROMPT_KRONUZ_PWD='${_prompt_kronuz_pwd:+${(e)_prompt_kronuz_pwd}}'

  # Compose the segments into $kronuz. The plain ones share one shape: a user override
  # ($PROMPT_KRONUZ_<SEG>) or the default, both (e)-evaluated at render.
  typeset -gA kz
  kz[nl]=$'%E\n'
  local seg
  for seg in os err vim emacs etctl context jobs git venv caret; do
    kz[$seg]="\${(e)PROMPT_KRONUZ_${seg:u}:-\$DEFAULT_PROMPT_KRONUZ_${seg:u}}"
  done
  # Unlike the older segments, an explicit empty value hides the overwrite marker.
  kz[overwrite]='${(e)PROMPT_KRONUZ_OVERWRITE-$DEFAULT_PROMPT_KRONUZ_OVERWRITE}'
  # The rest wrap a segment in its own colour, or compose other segments.
  kz[user]='${_ksem[user]}${(e)PROMPT_KRONUZ_USER:-$DEFAULT_PROMPT_KRONUZ_USER}${kz[RESET]}'
  kz[time]='${_ksem[time]}${(e)PROMPT_KRONUZ_TIME:-$DEFAULT_PROMPT_KRONUZ_TIME}${kz[RESET]}'
  kz[pwd]='${_ksem[pwd]}${(e)PROMPT_KRONUZ_PWD:-$DEFAULT_PROMPT_KRONUZ_PWD}${kz[RESET]}'
  # The transient caret, as a handle, so the transient layout composes it the way PROMPT
  # composes $kz[caret] -- no $DEFAULT_PROMPT_KRONUZ_* leaks into a copyable skin.
  kz[transient_caret]='${(e)PROMPT_KRONUZ_TRANSIENT_CARET:-$DEFAULT_PROMPT_KRONUZ_TRANSIENT_CARET}'
  kz[host]="$kz[os]\${_ksem[host]}\${(e)PROMPT_KRONUZ_HOST:-\$DEFAULT_PROMPT_KRONUZ_HOST}\${kz[RESET]} \${_ksem[ip]}(\${(e)PROMPT_KRONUZ_IP:-\$DEFAULT_PROMPT_KRONUZ_IP})\${kz[RESET]}"
  kz[info]="$kz[user] at $kz[host]"

  SPROMPT='zsh: correct $kz[FG.red]%R%f to $kz[FG.green]%r%f [nyae]? '
  # The visible layout is deferred and overridable end to end. PROMPT_KRONUZ_PROMPT (the two
  # prompt lines) and PROMPT_KRONUZ_RPROMPT (the right prompt) compose the $kz[<segment>]
  # array -- os err info context etctl git venv jobs nl time pwd caret transient_caret
  # overwrite vim emacs -- plus any fcol[]/glyph[]/prompt escapes, so a skin can reorder,
  # drop, or replace the whole thing (see skins/). The collapsed scrollback prompt is the
  # third knob a full skin sets, PROMPT_KRONUZ_TRANSIENT_PROMPT (default: pwd + caret). $kz[]
  # is the palette (the composed segments); PROMPT/RPROMPT are the layout that arranges them,
  # kept separate on purpose.
  # Because the layout is deferred (see the vars below), an override set in ~/.zshrc.local,
  # after setup, takes effect at render with no rebuild. The OSC 133 A/B/D marks and the
  # status line stay wrapped around it, so iTerm integration survives any skin.
  DEFAULT_PROMPT_KRONUZ_RPROMPT='$kz[overwrite]$kz[vim]$kz[emacs]'
  DEFAULT_PROMPT_KRONUZ_PROMPT='$kz[err] $kz[info]$kz[context]$kz[etctl]$kz[git]$kz[venv]$kz[jobs]$kz[nl]$kz[time] $kz[pwd] $kz[caret] '
  # The chosen layout (a skin's PROMPT_KRONUZ_PROMPT/RPROMPT or the default), deferred with the
  # doubled ${(e)${(e)...}} so one PROMPT_SUBST pass resolves both levels: the layout, then
  # the $kz[...] segments it names. Named so PROMPT/RPROMPT below stay readable.
  local _prompt_kronuz_prompt='${(e)${(e)PROMPT_KRONUZ_PROMPT-$DEFAULT_PROMPT_KRONUZ_PROMPT}}'
  local _prompt_kronuz_rprompt='${(e)${(e)PROMPT_KRONUZ_RPROMPT-$DEFAULT_PROMPT_KRONUZ_RPROMPT}}'
  RPROMPT="$_prompt_kronuz_rprompt"
  PROMPT="\${_prompt_kronuz_status_live}\${_kronuz_osc_d}\${_kronuz_osc_a}$_prompt_kronuz_prompt\${_kronuz_osc_b}"

  # Transient prompt (collapsed past prompts), the TRANSIENT_ mirror of the live grid:
  #   PROMPT_KRONUZ_TRANSIENT_PROMPT   — the collapsed left prompt   (like PROMPT_KRONUZ_PROMPT)
  #   PROMPT_KRONUZ_TRANSIENT_RPROMPT  — the collapsed right prompt  (like PROMPT_KRONUZ_RPROMPT; empty by default)
  #   PROMPT_KRONUZ_TRANSIENT_CARET    — just the caret/emoji piece  (like PROMPT_KRONUZ_CARET)
  # The default composes the pwd (live colour + PROMPT_KRONUZ_PWD_STYLE) and the caret;
  # each line is resolved and restyled (dim/mute/keep) per-accept. An explicit
  # PROMPT_KRONUZ_TRANSIENT_PROMPT='' disables transience.
  DEFAULT_PROMPT_KRONUZ_TRANSIENT_CARET='${_ksem[transient_caret]}${kz[GLYPH.caret]}${kz[RESET]}'
  DEFAULT_PROMPT_KRONUZ_TRANSIENT_PROMPT='$kz[pwd] $kz[transient_caret] '
  DEFAULT_PROMPT_KRONUZ_TRANSIENT_RPROMPT=''
  _kronuz_setup_transient_widgets
}
