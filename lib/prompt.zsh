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
#   kz_prompt_setup   runs once: builds the $PROMPT / $RPROMPT templates and
#                         registers the precmd / preexec / zle hooks.
#   kz_prompt_precmd  runs before every prompt: recomputes the dynamic pieces
#                         (git, venv, cwd, command duration, ...).
# zsh then re-renders $PROMPT at each prompt with PROMPT_SUBST enabled.
#
# $PROMPT is assembled from deferred strings. Each segment is
#   ${(e)KZ_PROMPT_<NAME>:-$DEFAULT_KZ_PROMPT_<NAME>}
# i.e. a user override or the built-in default, re-expanded ((e) flag) every render.
# One public array feeds the segments:
#   $kz  presentation and content handles ($kz[FG.red], $kz[GLYPH.branch], ...)
#
# Naming: $_kz_prompt_* holds a rendered segment string spliced into $PROMPT;
# $_kz_* holds internal state and flags.
#
# Git status comes from gitstatus (gitstatusd), with a direct-git fallback. The
# venv / keymap / cwd segments are small native pieces (prezto used its python-info
# / editor-info / prompt-pwd modules for these).
#

# ============================================================================
# Colours
# ============================================================================

# Base palette: named neutral colour codes, populated at load. $_kz_col_base is the
# immutable source that every rebuild wraps into $kz[FG.<name>] /
# $kz[BG.<name>] (in kz_prompt_colors), blanking every entry in no-colour mode so a
# skin's ${kz[FG.green]} (and ${kz[BG.green]}) emit nothing. ANSI 0..15 stay symbolic so
# they track the terminal theme; 16..255 are exact hex (truecolor), downsampled by
# zsh/nearcolor on non-truecolor terminals. The mutable palette is local to
# kz_prompt_colors; a skin defines/overrides a hue with $KZ_PROMPT_PALETTE_<NAME> and
# uses $kz[FG.<name>]. Clear pre-unification names when re-sourcing an older shell.
unset col _col_base _ksem glyph_pad
typeset -gA _kz_col_base=(
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
# The 16 ANSI colours, by palette name -> index. They default to symbolic %F{N} (above)
# so they track the terminal theme, but each is overridable to a concrete colour via
# $KZ_PROMPT_PALETTE_<NAME> (a #RRGGBB or a 0-255 index), applied to the public
# $kz[FG.*] / $kz[BG.*] handles and fed to `dim`'s RGB in _kz_load_palette.
typeset -gA _kz_basic=(
  black 0  red 1  green 2  yellow 3  blue 4  magenta 5  cyan 6  grey 7
  darkgrey 8  lightred 9  lightgreen 10  lightyellow 11  lightblue 12
  lightmagenta 13  lightcyan 14  lightgrey 15
)

# Resolve a colour to (r g b), into $reply: a #rrggbb hex, a 0-255 index, or a basic
# colour name. $reply is left empty if it can't be resolved. Indices 0..15 use the
# terminal's queried palette ($_kz_pal) when available, else the xterm defaults.
function _kz_color_rgb {
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
    if [[ -n ${_kz_pal[$n]-} ]]; then reply=( ${=_kz_pal[$n]} ); return; fi
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

# Query the terminal's 16 ANSI colours (OSC 4) into $_kz_pal, so `dim` darkens the
# real theme rather than a guessed table. A no-op (leaving the xterm-default fallback in
# place) without a tty, or on tmux/screen/dumb. The budget ($KZ_PROMPT_PALETTE_TIMEOUT,
# default 0.6s) is generous so the round-trip survives a slow link (e.g. a remote shell
# over the network); the loop still exits the instant all 16 answers arrive, so a local
# terminal pays nothing.
typeset -gA _kz_pal
function _kz_query_palette {
  emulate -L zsh -o extendedglob
  _kz_pal=()
  [[ -t 0 && -t 1 ]] || return
  [[ "$TERM" = (dumb|unknown|linux) || -n "${TMUX-}" || "$TERM" = (screen*|tmux*) ]] && return
  zmodload zsh/datetime zsh/system 2>/dev/null || return
  local saved chunk resp='' piece
  saved="$(stty -g 2>/dev/null)" || return
  {
    stty -echo -icanon min 0 time 0 2>/dev/null
    local -i i; for i in {0..15}; do print -n -- "\e]4;${i};?\e\\"; done
    local -F end=$(( EPOCHREALTIME + ${KZ_PROMPT_PALETTE_TIMEOUT:-0.6} )); local -i n=0
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
    _kz_pal[${match[1]}]="$(( 16#${match[2][1,2]} )) $(( 16#${match[3][1,2]} )) $(( 16#${match[4][1,2]} ))"
  done
}

# Populate $_kz_pal (RGB of the 16 ANSI colours) for `dim`. The base layer is the
# terminal's real colours, from a fresh on-disk cache (kept $KZ_PROMPT_PALETTE_TTL
# seconds, default a day, per terminal; TTL=0 disables it) or a one-off OSC 4 query.
# Per-colour $KZ_PROMPT_PALETTE_<NAME> overrides then win on top (never cached); if
# all 16 are overridden the terminal is never queried at all. Run once from the first
# precmd, so overrides / TTL / timeout set in ~/.zshrc.local are in effect.
function _kz_load_palette {
  emulate -L zsh -o extendedglob
  zmodload zsh/datetime 2>/dev/null
  zmodload -F zsh/stat b:zstat 2>/dev/null
  _kz_pal=()

  local name ov reply
  local -i n_over=0
  for name in ${(k)_kz_basic}; do
    ov="KZ_PROMPT_PALETTE_${name:u}"; [[ -n "${(P)ov}" ]] && (( n_over++ ))
  done

  # Base layer: the terminal's real colours, unless every basic is overridden.
  if (( n_over < 16 )); then
    local -i ttl=${KZ_PROMPT_PALETTE_TTL:-86400}
    local term="${LC_TERMINAL:-${TERM_PROGRAM:-$TERM}}"
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/kronuzsh/palette-${term//[^A-Za-z0-9._-]/_}"
    local -a mt
    if (( ttl > 0 )) && [[ -r $cache ]] && zstat -A mt +mtime -- $cache 2>/dev/null \
       && (( EPOCHSECONDS - mt[1] < ttl )); then
      local k r g b
      while read -r k r g b; do _kz_pal[$k]="$r $g $b"; done < $cache
      (( ${#_kz_pal} == 16 )) || _kz_pal=()
    fi
    if (( ${#_kz_pal} != 16 )); then
      _kz_query_palette
      if (( ttl > 0 && ${#_kz_pal} == 16 )); then
        mkdir -p ${cache:h} 2>/dev/null && {
          local k; for k in ${(onk)_kz_pal}; do print -r -- "$k ${_kz_pal[$k]}"; done
        } > $cache 2>/dev/null
      fi
    fi
  fi

  # Per-colour overrides win (from ~/.zshrc.local); resolved to RGB, never cached.
  for name in ${(k)_kz_basic}; do
    ov="KZ_PROMPT_PALETTE_${name:u}"; [[ -n "${(P)ov}" ]] || continue
    _kz_color_rgb "${(P)ov}"
    (( ${#reply} )) && _kz_pal[${_kz_basic[$name]}]="${reply[*]}"
  done
}

# Semantic colours: map each prompt element to a base-palette colour, resolved with
# the live palette into the semantic array the segments read ($_kz_sem[host], $_kz_sem[branch],
# ...). Mirrors kz_prompt_glyphs: a defaults table, then one loop that applies any
# $KZ_PROMPT_COLOR_<NAME> override and writes the final value. No-colour mode
# ($_kz_nocolor) blanks the built-in defaults (so the layout still renders with zero
# escapes) while still honouring an explicit override. Recomputed every precmd, so
# toggling $NO_COLOR / $TERM takes effect on the next prompt.
typeset -gA _kz_sem
typeset -g _kz_colors_sig=''
function kz_prompt_colors {
  # Change-detection: colours are fully determined by $_kz_nocolor and the
  # $KZ_PROMPT_{COLOR,PALETTE}_* overrides, so skip the rebuild (base palette from
  # source, then semantics) when none of those changed since the last prompt.
  local _sig="${_kz_nocolor:-0}" _k
  for _k in ${(k)parameters[(I)KZ_PROMPT_(COLOR|PALETTE)_*]}; do _sig+=$'\x1f'"$_k=${(P)_k}"; done
  [[ "$_sig" == "$_kz_colors_sig" ]] && return
  _kz_colors_sig="$_sig"

  # Live neutral code palette: the immutable base plus any KZ_PROMPT_PALETTE_<NAME>,
  # which may redefine a built-in hue or define a brand-new one (a #RRGGBB or 0-255 index).
  local _cn _pv
  local -A _col=("${(@kv)_kz_col_base}")
  for _k in ${(k)parameters[(I)KZ_PROMPT_PALETTE_*]}; do
    _pv="${(P)_k}"; _cn="${${_k#KZ_PROMPT_PALETTE_}:l}"
    [[ -n "$_pv" ]] && _col[$_cn]="$_pv"
  done

  # Public styling in $kz: FG./BG. wrap each code (no %F->%K string surgery); the attribute
  # setters and RESET are the raw zsh escapes. All blank in no-colour, so ${kz[FG.green]} /
  # ${kz[BG.green]} emit nothing and the layout still renders with zero escapes.
  if (( ${_kz_nocolor:-0} )); then
    for _cn in ${(k)_col}; do kz[FG.$_cn]='' kz[BG.$_cn]=''; done
    kz[RESET]='' kz[BOLD]='' kz[UNDERLINE]='' kz[STANDOUT]=''
  else
    for _cn in ${(k)_col}; do
      kz[FG.$_cn]="%F{${_col[$_cn]}}" kz[BG.$_cn]="%K{${_col[$_cn]}}"
    done
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
    ov="KZ_PROMPT_COLOR_${name:u}"
    # No-colour blanks the built-in default, but an explicit override still colours.
    def="${d[$name]}"; (( ${_kz_nocolor:-0} )) && def=''
    raw="${(P)ov}"
    [[ -z "$raw" ]] && raw="$def"
    _kz_sem[$name]="${(e)raw}"
  done
}

# ============================================================================
# Glyphs
# ============================================================================

# Two private glyph tables feed $kz[GLYPH.*]: a Nerd Font set (default) and a plain-Unicode
# fallback that renders in any font. $KZ_PROMPT_NERD_FONT=0 (or no/off/false)
# picks the plain set; dumb/unknown terminals force it too. Any single glyph is
# overridable via $KZ_PROMPT_GLYPH_<NAME> (a character, or '' to hide it).
typeset -gA kz _kz_glyph_pad
typeset -g _kz_glyphs_sig=''
function kz_prompt_glyphs {
  # Change-detection: glyphs depend only on terminal dumb-ness, the nerd-font toggle,
  # $OSTYPE, the legacy $_kz_os, and any $KZ_PROMPT_GLYPH_* override. Skip the
  # rebuild when none of those changed since the last prompt.
  local _sig="${_kz_dumb:-0}|${(L)KZ_PROMPT_NERD_FONT:-1}|$OSTYPE|${+_kz_os}:${_kz_os-}" _k
  for _k in ${(k)parameters[(I)KZ_PROMPT_GLYPH_*]}; do _sig+=$'\x1f'"$_k=${(P)_k}"; done
  [[ "$_sig" == "$_kz_glyphs_sig" ]] && return
  _kz_glyphs_sig="$_sig"

  local -A g
  local os_nerd=''
  case "$OSTYPE" in
    darwin*) os_nerd=$'\uf179' ;;  # nf-fa-apple
    linux*)  os_nerd=$'\uf17c' ;;  # nf-fa-linux (Tux)
  esac
  if (( ${_kz_dumb:-0} )) || [[ "${(L)KZ_PROMPT_NERD_FONT:-1}" == (0|no|off|false) ]]; then
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
  _kz_glyph_pad=()
  for name in ${(k)g}; do
    ov="KZ_PROMPT_GLYPH_${name:u}"
    val="${(P)ov-$sentinel}"
    [[ "$val" == "$sentinel" ]] && val="$g[$name]"
    kz[GLYPH.$name]="$val"
    # Trailing (right-hand) pad, appended after the glyph. An explicit
    # $KZ_PROMPT_GLYPH_PAD_<NAME> wins: set it to '' to hug tight, or to ' ', a
    # non-breaking space ($'\u00a0'), etc. to tune spacing for your font. Otherwise a
    # single Private-Use-Area glyph can render wider than its cell, so it gets a pad space
    # by default so an adjacent count/text doesn't collide; BMP and multi-char glyphs none.
    padov="KZ_PROMPT_GLYPH_PAD_${name:u}"
    padval="${(P)padov-$sentinel}"
    if [[ "$padval" != "$sentinel" ]]; then
      _kz_glyph_pad[$name]="$padval"
    else
      c=0; [[ ${#val} -eq 1 ]] && c=$(( #val ))
      if (( (c >= 0xe000 && c <= 0xf8ff) || c >= 0xf0000 )); then
        _kz_glyph_pad[$name]=' '
      else
        _kz_glyph_pad[$name]=''
      fi
    fi
  done
  # Legacy override: an explicit $_kz_os (set in ~/.zshrc.local) wins for the OS glyph.
  (( ${+_kz_os} )) && kz[GLYPH.os]="$_kz_os"
}

# ============================================================================
# Segments  (each recomputed by kz_prompt_precmd into $_kz_prompt_*)
# ============================================================================

# ---- git ----
typeset -g _kz_prompt_git=''

# Git state, split out for skins. prompt.zsh computes these once per prompt (from
# gitstatusd, or the direct-git fallback), so a KZ_PROMPT_GIT override can reshape the
# git segment declaratively -- e.g. '${kz[git.branch]:+ (${kz[git.branch]}${kz[git.dirty]:+*})}'
# -- with no hook of its own. Each is a string: empty when absent/zero, else the value or
# count, so a plain ${var:+...} tests it. All are '' outside a repo. The fallback knows
# presence, not counts, so there each count is '' or '1' (and ahead/behind/stashed/
# conflicted stay '').
# The normalised git state lives in $kz[git.<name>] (repo, branch, tag, commit,
# detached, action, remote, clean, dirty, staged, unstaged, untracked, conflicted,
# stashed, ahead, behind), populated by both the daemon and fallback paths below and
# reset off-repo. Each is a string: empty when absent/zero,
# else the value or count, so a plain ${kz[git.<name>]:+...} tests it. The fallback knows
# presence, not counts, so there each count is '' or '1' (and ahead/behind/stashed/
# conflicted stay '').

function _kz_git_reset_state {
  kz[git.repo]='' kz[git.branch]='' kz[git.tag]='' kz[git.commit]='' \
    kz[git.detached]='' kz[git.action]='' kz[git.remote]='' \
    kz[git.clean]='' kz[git.dirty]='' \
    kz[git.staged]='' kz[git.unstaged]='' kz[git.untracked]='' \
    kz[git.conflicted]='' kz[git.stashed]='' \
    kz[git.ahead]='' kz[git.behind]=''
}

# Direct-git fallback, used when gitstatusd isn't running (no tty, not installed).
function _kz_git_fallback {
  # The git binary is overridable, so the fallback can be pointed at a wrapper or, in
  # previews/tests, a fake (see dev/fake-git). Word-split into an array; the default
  # keeps the `command` builtin so a user git function/alias can't shadow it.
  local -a gitcmd=( ${=KZ_PROMPT_GIT_CMD:-command git} )
  $gitcmd rev-parse --is-inside-work-tree &>/dev/null || { _kz_git_reset_state; return }
  local branch detached=''
  branch="$($gitcmd symbolic-ref --short HEAD 2>/dev/null)" \
    || { detached=1; branch="$($gitcmd rev-parse --short HEAD 2>/dev/null)"; }
  [[ -z "$branch" ]] && { _kz_git_reset_state; return }
  local sep="${(e)_kz_sem[sep]}" none="${(e)kz[RESET]}" info="${(e)_kz_sem[info]}"
  local gly="$kz[GLYPH.branch]"
  $gitcmd symbolic-ref --quiet HEAD &>/dev/null || gly="$kz[GLYPH.commit]"
  local warning=''
  [[ -n "$kz[GLYPH.fallback]" ]] && warning="${(e)_kz_sem[fallback]}${kz[GLYPH.fallback]}${none} "
  local s=" ${warning}${info}${gly}${none} ${(e)_kz_sem[branch]}${branch}${none}"
  local remote
  remote="$($gitcmd rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)"
  [[ -n "$remote" ]] && s+=" ${info}${kz[GLYPH.remote]}${none} ${(e)_kz_sem[remote]}${remote}${none}"
  local staged='' unstaged='' untracked='' icons=''
  local isep="${KZ_PROMPT_GIT_SEP-$DEFAULT_KZ_PROMPT_GIT_SEP}"
  $gitcmd diff --cached --quiet --ignore-submodules 2>/dev/null || staged=1
  $gitcmd diff --quiet --ignore-submodules 2>/dev/null || unstaged=1
  [[ -n "$($gitcmd ls-files --others --exclude-standard 2>/dev/null | head -1)" ]] && untracked=1
  if [[ -n "$staged$unstaged$untracked" ]]; then
    icons+="${(e)_kz_sem[dirty]}${kz[GLYPH.dirty]}${none}"
    [[ -n "$staged" ]]    && icons+="${icons:+$isep}${(e)_kz_sem[added]}${kz[GLYPH.staged]}${none}"
    [[ -n "$unstaged" ]]  && icons+="${icons:+$isep}${(e)_kz_sem[modified]}${kz[GLYPH.modified]}${none}"
    [[ -n "$untracked" ]] && icons+="${icons:+$isep}${(e)_kz_sem[untracked]}${kz[GLYPH.untracked]}${none}"
  else
    icons="${(e)_kz_sem[clean]}${kz[GLYPH.clean]}${none}"
  fi
  kz[git.repo]=1 kz[git.branch]="$branch" kz[git.tag]='' kz[git.commit]="$($gitcmd rev-parse --short HEAD 2>/dev/null)"
  kz[git.detached]="$detached" kz[git.action]='' kz[git.remote]="$remote"
  kz[git.staged]="${staged:+1}" kz[git.unstaged]="${unstaged:+1}" \
    kz[git.untracked]="${untracked:+1}" kz[git.dirty]="${staged}${unstaged}${untracked:+1}"
  kz[git.clean]=''
  [[ -z "${kz[git.dirty]}" ]] && kz[git.clean]=1
  _kz_prompt_git="${s}${sep} (${none}${icons}${sep})${none}"
}

# Async git segment. The prompt must never block on git, so we talk to the KRONUZ
# gitstatusd instance non-blockingly: wait at most $KZ_PROMPT_GIT_SYNC_TIMEOUT seconds
# for an answer (default 0.05). Fast/cached repos answer within that budget and render
# fresh; anything slower renders the last-known status immediately and repaints in place
# when the daemon catches up, via _kz_gitstatus_cb. gitstatus forbids overlapping
# queries on one name ("CONCURRENT CALLS WITH THE SAME NAME ARE NOT ALLOWED", per its
# header), so we never issue a new query while one is in flight -- $_kz_git_inflight
# tracks that. Only when gitstatusd isn't usable at all do we fall back to blocking git.
typeset -g _kz_git_last='' _kz_git_inflight=0

# Render the git segment from the current VCS_STATUS_* into $_kz_prompt_git, caching
# the result in $_kz_git_last so an in-flight prompt can show it while a query runs.
function _kz_git_render {
  local sep="${(e)_kz_sem[sep]}" none="${(e)kz[RESET]}" info="${(e)_kz_sem[info]}" s=''
  if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    s+=" ${info}${kz[GLYPH.branch]}${none} ${(e)_kz_sem[branch]}${VCS_STATUS_LOCAL_BRANCH}${none}"
  elif [[ -n "$VCS_STATUS_TAG" ]]; then
    s+=" ${info}${kz[GLYPH.tag]}${none} ${(e)_kz_sem[branch]}${VCS_STATUS_TAG}${none}"
  else
    s+=" ${info}${kz[GLYPH.commit]}${none} ${(e)_kz_sem[commit]}${VCS_STATUS_COMMIT[1,7]}${none}"
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
    s+=" ${info}${rg}${none} ${(e)_kz_sem[remote]}${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}${none}"
  fi
  [[ -n "$VCS_STATUS_ACTION" ]] && \
    s+=" ${info}${kz[GLYPH.action]}${none} ${(e)_kz_sem[action]}${VCS_STATUS_ACTION}${none}"

  # Indicators inside the (...), joined by $KZ_PROMPT_GIT_SEP (a space by
  # default, from $DEFAULT_KZ_PROMPT_GIT_SEP; set it to '·', ':', '' or anything
  # to taste). ${icons:+$isep} inserts the separator before every indicator except the first.
  local isep="${KZ_PROMPT_GIT_SEP-$DEFAULT_KZ_PROMPT_GIT_SEP}"
  local icons=''
  (( VCS_STATUS_STASHES )) && icons+="${icons:+$isep}${(e)_kz_sem[stashed]}${kz[GLYPH.stashed]}${_kz_glyph_pad[stashed]}${VCS_STATUS_STASHES}${none}"
  # gitstatusd reports HAS_* = -1 for unstaged/conflicted/untracked when the index is
  # larger than its -m cap and it skipped the dirty scan (see KZ_PROMPT_GITSTATUS_ARGS
  # in lib/plugins.zsh). Staged is always counted exactly; the rest are then unknown, so
  # we render the dirty mark plus a single "∞" instead of guessing "clean".
  local -i dirty_unknown=$(( ${VCS_STATUS_HAS_UNSTAGED:-0} == -1 ))
  if (( dirty_unknown || VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )); then
    icons+="${icons:+$isep}${(e)_kz_sem[dirty]}${kz[GLYPH.dirty]}${none}"
  else
    icons+="${icons:+$isep}${(e)_kz_sem[clean]}${kz[GLYPH.clean]}${none}"
  fi
  (( VCS_STATUS_COMMITS_AHEAD ))  && icons+="${icons:+$isep}${(e)_kz_sem[ahead]}${kz[GLYPH.ahead]}${_kz_glyph_pad[ahead]}${VCS_STATUS_COMMITS_AHEAD}${none}"
  (( VCS_STATUS_COMMITS_BEHIND )) && icons+="${icons:+$isep}${(e)_kz_sem[behind]}${kz[GLYPH.behind]}${_kz_glyph_pad[behind]}${VCS_STATUS_COMMITS_BEHIND}${none}"
  # Push-remote divergence (⇧/⇩), shown only when the push target is a *different* remote
  # than the upstream (triangular / fork workflow: push to your fork, pull from upstream).
  # gitstatusd fills these in the same payload, so it costs no extra git call.
  if [[ -n "$VCS_STATUS_PUSH_REMOTE_NAME" && "$VCS_STATUS_PUSH_REMOTE_URL" != "$VCS_STATUS_REMOTE_URL" ]]; then
    (( VCS_STATUS_PUSH_COMMITS_AHEAD ))  && icons+="${icons:+$isep}${(e)_kz_sem[ahead]}${kz[GLYPH.push_ahead]}${_kz_glyph_pad[push_ahead]}${VCS_STATUS_PUSH_COMMITS_AHEAD}${none}"
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && icons+="${icons:+$isep}${(e)_kz_sem[behind]}${kz[GLYPH.push_behind]}${_kz_glyph_pad[push_behind]}${VCS_STATUS_PUSH_COMMITS_BEHIND}${none}"
  fi
  # Staged / unstaged detail. With KZ_PROMPT_GIT_SPLIT set, the single staged and
  # unstaged counts break into per-type marks -- added (+), changed (~), deleted (-) --
  # coloured by group (staged the added colour, unstaged the modified colour); gitstatusd already reports the
  # *_NEW / *_DELETED breakdown, so this costs no extra git call. Off by default (one
  # aggregate count per group). The -m-capped "unknown" path keeps the aggregate.
  local -i split=0
  [[ "${(L)KZ_PROMPT_GIT_SPLIT:-0}" == (1|yes|on|true) ]] && split=1

  if (( split && ! dirty_unknown )); then
    local -i s_new=VCS_STATUS_NUM_STAGED_NEW s_del=VCS_STATUS_NUM_STAGED_DELETED
    local -i s_mod=VCS_STATUS_NUM_STAGED-s_new-s_del
    (( s_new > 0 )) && icons+="${icons:+$isep}${(e)_kz_sem[added]}${kz[GLYPH.added]}${_kz_glyph_pad[added]}${s_new}${none}"
    (( s_mod > 0 )) && icons+="${icons:+$isep}${(e)_kz_sem[added]}${kz[GLYPH.changed]}${_kz_glyph_pad[changed]}${s_mod}${none}"
    (( s_del > 0 )) && icons+="${icons:+$isep}${(e)_kz_sem[added]}${kz[GLYPH.deleted]}${_kz_glyph_pad[deleted]}${s_del}${none}"
  else
    (( VCS_STATUS_NUM_STAGED )) && icons+="${icons:+$isep}${(e)_kz_sem[added]}${kz[GLYPH.staged]}${_kz_glyph_pad[staged]}${VCS_STATUS_NUM_STAGED}${none}"
  fi

  if (( dirty_unknown )); then
    icons+="${icons:+$isep}${(e)_kz_sem[untracked]}${kz[GLYPH.unknown]}${_kz_glyph_pad[unknown]}${none}"
  else
    if (( split )); then
      local -i u_del=VCS_STATUS_NUM_UNSTAGED_DELETED u_mod=VCS_STATUS_NUM_UNSTAGED-u_del
      (( u_mod > 0 )) && icons+="${icons:+$isep}${(e)_kz_sem[modified]}${kz[GLYPH.changed]}${_kz_glyph_pad[changed]}${u_mod}${none}"
      (( u_del > 0 )) && icons+="${icons:+$isep}${(e)_kz_sem[modified]}${kz[GLYPH.deleted]}${_kz_glyph_pad[deleted]}${u_del}${none}"
    else
      (( VCS_STATUS_NUM_UNSTAGED )) && icons+="${icons:+$isep}${(e)_kz_sem[modified]}${kz[GLYPH.modified]}${_kz_glyph_pad[modified]}${VCS_STATUS_NUM_UNSTAGED}${none}"
    fi
    (( VCS_STATUS_NUM_CONFLICTED )) && icons+="${icons:+$isep}${(e)_kz_sem[unmerged]}${kz[GLYPH.conflicted]}${_kz_glyph_pad[conflicted]}${VCS_STATUS_NUM_CONFLICTED}${none}"
    (( VCS_STATUS_NUM_UNTRACKED ))  && icons+="${icons:+$isep}${(e)_kz_sem[untracked]}${kz[GLYPH.untracked]}${_kz_glyph_pad[untracked]}${VCS_STATUS_NUM_UNTRACKED}${none}"
  fi

  kz[git.repo]=1
  kz[git.branch]="${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_TAG:-${VCS_STATUS_COMMIT[1,7]}}}"
  kz[git.tag]="$VCS_STATUS_TAG" kz[git.commit]="${VCS_STATUS_COMMIT[1,7]}"
  kz[git.detached]=''
  [[ -z "$VCS_STATUS_LOCAL_BRANCH" ]] && kz[git.detached]=1
  kz[git.action]="$VCS_STATUS_ACTION"
  kz[git.remote]="${VCS_STATUS_REMOTE_NAME:+${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}}"
  kz[git.staged]="${VCS_STATUS_NUM_STAGED:#0}" kz[git.unstaged]="${VCS_STATUS_NUM_UNSTAGED:#0}"
  kz[git.untracked]="${VCS_STATUS_NUM_UNTRACKED:#0}" kz[git.conflicted]="${VCS_STATUS_NUM_CONFLICTED:#0}"
  kz[git.stashed]="${VCS_STATUS_STASHES:#0}" kz[git.ahead]="${VCS_STATUS_COMMITS_AHEAD:#0}" \
    kz[git.behind]="${VCS_STATUS_COMMITS_BEHIND:#0}"
  kz[git.dirty]=''
  (( dirty_unknown || VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )) \
    && kz[git.dirty]=1
  kz[git.clean]=''
  [[ -z "${kz[git.dirty]}" ]] && kz[git.clean]=1
  _kz_prompt_git="${s}${sep} (${none}${icons}${sep})${none}"
  _kz_git_last="$_kz_prompt_git"
}

# gitstatusd calls this (from its own zle -F handler) when a timed-out query finally has
# data. Re-render and repaint the live prompt in place: `zle reset-prompt` re-expands
# $PROMPT with the fresh $_kz_prompt_git -- it runs no precmd and issues no new query.
function _kz_gitstatus_cb {
  _kz_git_inflight=0
  if [[ "$VCS_STATUS_RESULT" == ok-async ]]; then
    _kz_git_render
  else
    _kz_prompt_git=''
    _kz_git_last=''
  fi
  zle && zle reset-prompt
}

# Drop the stale cache when the directory changes, so a new dir never briefly shows the
# previous repo's status while its first query is still in flight.
function _kz_git_chpwd { _kz_git_last='' }

function _kz_git_segment {
  # No usable daemon -> blocking direct-git fallback (not installed / not yet ready).
  if (( ! ${+functions[gitstatus_query]} )) || ! gitstatus_check KRONUZ 2>/dev/null; then
    _kz_git_inflight=0
    _kz_prompt_git=''
    _kz_git_fallback
    return
  fi
  # A query is already outstanding: starting another for the same name is illegal, so show
  # the last-known status and let the pending callback repaint when it lands.
  if (( _kz_git_inflight )); then
    _kz_prompt_git="$_kz_git_last"
    return
  fi
  # Non-blocking query, bounded by the sync-latency budget.
  if ! gitstatus_query -t ${KZ_PROMPT_GIT_SYNC_TIMEOUT:-0.05} -c _kz_gitstatus_cb KRONUZ 2>/dev/null; then
    _kz_git_inflight=0
    _kz_prompt_git=''
    _kz_git_fallback
    return
  fi
  case "$VCS_STATUS_RESULT" in
    ok-sync)     _kz_git_inflight=0; _kz_git_render ;;                   # answered in budget
    norepo-sync) _kz_git_inflight=0; _kz_prompt_git=''; _kz_git_last=''; _kz_git_reset_state ;;  # not a repo
    *)  # tout: a query is in flight. Show the last-known status (if any) plus a subtle
        # loading mark, so a slow or first paint reads as "refreshing", not blank/frozen.
        _kz_git_inflight=1
        _kz_prompt_git="${_kz_git_last} ${(e)_kz_sem[loading]}${kz[GLYPH.loading]}${_kz_glyph_pad[loading]}${(e)kz[RESET]}"
        ;;
  esac
}

# ---- venv ----
typeset -g _kz_prompt_venv=''
function _kz_venv_segment {
  kz[venv.name]=''
  if [[ -n "$VIRTUAL_ENV" ]]; then
    kz[venv.name]="$VIRTUAL_ENV:t"
    _kz_prompt_venv=" ${(e)_kz_sem[info]}${kz[GLYPH.venv]}${(e)kz[RESET]} ${(e)_kz_sem[venv]}${VIRTUAL_ENV:t}${(e)kz[RESET]}"
  else
    _kz_prompt_venv=''
  fi
}

# ---- working directory ----
# Render $PWD into _kz_prompt_pwd, per KZ_PROMPT_PWD_STYLE:
#   full     (default) the whole path, home as ~      ~/.config/KronuZSH/integrations/bat
#   short    shortest-unique-prefix (truncate_to_unique) ~/.c/K/i/bat
#            each parent shrunk only as far as it stays unambiguous; leaf full
#   base     just the current directory name          bat
#   absolute the full path with $HOME expanded         /home/kronuz/.config/KronuZSH/.../bat
# (literal % are doubled so print -P won't expand them.)

# Set $REPLY to the shortest prefix of directory name $2 that is unique among the
# sub-directories of parent $1 (empty parent = filesystem root). Used by the 'short'
# PWD style below; globs the parent directory once.
function _kz_unique_prefix {
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
typeset -g _kz_pwd_sig=''
function _kz_pwd_segment {
  # Skip the recompute (for the 'short' style, ~1ms of globbing) when neither the
  # directory nor the style changed since the last prompt. Keyed on both, so a cd or a
  # runtime KZ_PROMPT_PWD_STYLE change still refreshes; the cached string persists in
  # $_kz_prompt_pwd. (A new sibling directory sharing your prefix won't re-shorten
  # until the next cd -- an acceptable staleness for the 'short' style.)
  local sig="${KZ_PROMPT_PWD_STYLE:-full}|$PWD"
  [[ "$sig" == "$_kz_pwd_sig" ]] && return
  _kz_pwd_sig="$sig"

  local p="${(%):-%~}"
  case "${KZ_PROMPT_PWD_STYLE:-full}" in
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
          _kz_unique_prefix "$rp" "$seg"; out+="/$REPLY"
          rp+="/$seg"
        fi
      done
      p="${out:-/}"
      ;;
  esac
  _kz_prompt_pwd="${p//\%/%%}"
}

# ---- LAN IP -------------------------------------------------------------------
# The primary LAN IP changes rarely, but the only portable way to read it is to
# fork `ifconfig` (there is no zsh builtin for it), and that pipeline costs ~16ms.
# So we never compute it on the prompt path: each prompt reads the last value from
# a cache file with $(<...) (a builtin read, no fork), and at most once per TTL we
# kick off a *detached* refresh whose result lands in the cache for the next prompt.
# Hot-path cost drops from ~16ms to a cheap file read. Trade-off: the first prompt
# after a network change shows the previous IP, the next one shows the new IP.
typeset -g _kz_prompt_ip='' _kz_ip_ts=0
typeset -g _kz_ip_cache="${TMPDIR:-/tmp}/kronuz-ip.$UID"
function _kz_ip_segment {
  # Show whatever the last background refresh wrote (no fork).
  [[ -r "$_kz_ip_cache" ]] && _kz_prompt_ip="$(<$_kz_ip_cache)"
  # Throttle refreshes to once per TTL (default 60s).
  (( ${EPOCHSECONDS:-0} - _kz_ip_ts < ${KZ_PROMPT_IP_TTL:-60} )) && return
  _kz_ip_ts=${EPOCHSECONDS:-0}
  # Detached, non-blocking refresh (one awk instead of grep|grep|head|awk), written
  # to a temp then renamed so a concurrent reader never sees a half-written line.
  {
    ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" { print $2; exit }' > "$_kz_ip_cache.new" \
      && command mv -f "$_kz_ip_cache.new" "$_kz_ip_cache"
  } &!
}

# ---- command duration ----
# preexec stamps the start time; precmd formats the delta once it exceeds
# $KZ_PROMPT_CMD_DURATION_MIN seconds (default 3). $_kz_cmd_ran also marks
# that a real command ran (vs a blank Enter), which the status line below reads.
typeset -g _kz_cmd_start=0 _kz_prompt_duration='' _kz_cmd_ran=0
function _kz_duration_preexec { _kz_cmd_start=${EPOCHREALTIME:-0}; _kz_cmd_ran=1 }
function _kz_duration_fmt {
  local -F e=$1
  local -i t=$1
  if   (( t >= 3600 )); then printf '%dh%02dm%02ds' $((t/3600)) $((t/60%60)) $((t%60))
  elif (( t >= 60 ));   then printf '%dm%02ds' $((t/60)) $((t%60))
  else printf '%.1fs' $e
  fi
}
function _kz_duration_segment {
  _kz_prompt_duration='' kz[duration]=''
  (( _kz_cmd_start )) || return
  local -F elapsed=$(( ${EPOCHREALTIME:-0} - _kz_cmd_start ))
  _kz_cmd_start=0
  (( elapsed >= ${KZ_PROMPT_CMD_DURATION_MIN:-3} )) || return
  _kz_prompt_duration="$(_kz_duration_fmt $elapsed)"
  kz[duration]="$_kz_prompt_duration"
}

# ---- status line (exit code + duration, on a line above the info row) ----
# $_kz_prompt_last_exit is captured by the OSC precmd (it runs first). The line
# is shown on the live prompt when transience is enabled. By default, accepting the
# next command keeps that line in history outside the next command's OSC 133 A/B region.
# In non-transient mode, the same status option controls whether the line is shown.
typeset -g _kz_prompt_status='' _kz_prompt_status_live=''
typeset -g _kz_prompt_last_exit=0

function _kz_status_segment {
  _kz_prompt_status='' _kz_prompt_status_live=''
  # Only after a real command ran: a blank Enter leaves $? unchanged and must not
  # re-show (and, via the transient copy, re-keep) the previous command's exit code.
  (( ${_kz_cmd_ran:-0} )) || return
  local out='' body item sp
  if (( ${_kz_prompt_last_exit:-0} != 0 )); then
    body="${(e)KZ_PROMPT_ERROR-$DEFAULT_KZ_PROMPT_ERROR}"
    if [[ -n "$body" ]]; then
      item="${(e)_kz_sem[status_err]}${body}${(e)kz[RESET]}"
      out+="$item"
    fi
  fi
  if [[ -n "$_kz_prompt_duration" ]]; then
    body="${(e)KZ_PROMPT_DURATION-$DEFAULT_KZ_PROMPT_DURATION}"
    if [[ -n "$body" ]]; then
      sp="${out:+ }"; item="${(e)_kz_sem[duration]}${body}${(e)kz[RESET]}"
      out+="${sp}${item}"
    fi
  fi
  if [[ -n "$out" ]]; then
    _kz_prompt_status="${out}%E"$'\n'
    if _kz_transient_enabled || _kz_status_enabled; then
      _kz_prompt_status_live=$_kz_prompt_status
    fi
  fi
  _kz_cmd_ran=0
}

# ============================================================================
# Editor keymap indicator
# ============================================================================

# Update the vi/emacs keymap caret ($_kz_prompt_keymap) and overwrite mark
# ($_kz_prompt_overwrite) from zle state, then redraw. The three public format parameters
# are evaluated here so palette/glyph changes remain live. Driven by the widgets below.
typeset -g _kz_prompt_keymap='' _kz_prompt_overwrite=''
function _kz_keymap_update {
  if [[ "$KEYMAP" == 'vicmd' ]]; then
    _kz_prompt_keymap="${(e)KZ_PROMPT_KEYMAP_ALTERNATE-$DEFAULT_KZ_PROMPT_KEYMAP_ALTERNATE}"
  else
    _kz_prompt_keymap="${(e)KZ_PROMPT_KEYMAP_PRIMARY-$DEFAULT_KZ_PROMPT_KEYMAP_PRIMARY}"
  fi
  if [[ "$ZLE_STATE" == *overwrite* ]]; then
    _kz_prompt_keymap="${(e)KZ_PROMPT_KEYMAP_OVERWRITE-$DEFAULT_KZ_PROMPT_KEYMAP_OVERWRITE}"
    _kz_prompt_overwrite=" ${(e)_kz_sem[overwrite]}${kz[GLYPH.overwrite]}${(e)kz[RESET]}"
  else
    _kz_prompt_overwrite=''
  fi
  # reset-prompt redraws in place, which needs cursor addressing; skip it on dumb
  # terminals (it would reprint the multi-line prompt). The seed in setup means the
  # first render already shows the caret even where zle-line-init never fires.
  (( ${_kz_dumb:-0} )) || zle reset-prompt 2>/dev/null
}
function zle-keymap-select { _kz_keymap_update }
function zle-line-init {
  # Non-transient A/B have already marked the editable line on the first paint.
  # Keep line-init and later keymap redraws from creating duplicate command marks.
  _kz_osc_d='' _kz_osc_a='' _kz_osc_b=''
  _kz_keymap_update
}
# Toggling overwrite mode does not change keymaps, so zle-keymap-select does not fire.
# Wrap the standard widget, as Prezto does, so inherited and explicit bindings both
# refresh the caret and RPROMPT after invoking the builtin.
function _kz_overwrite_toggle {
  zle .overwrite-mode
  _kz_keymap_update
}

# ============================================================================
# Terminal integration  (OSC 7/1337 cwd, OSC 133 command boundaries)
# ============================================================================
# This section owns the whole shell-integration state machine. Hook functions decide
# *when* a boundary occurs; the small helpers below decide *which bytes* each terminal
# receives. Keep prompt-rendered bytes in $_kz_osc_{d,a,b}: A/B must surround the
# editable prompt, while non-transient D must appear after the live status row.
typeset -g _kz_osc_d='' _kz_osc_a='' _kz_osc_b=''
typeset -g _kz_is_iterm=0 _kz_osc_command_active=0 _kz_osc_line_submitted=0

function _kz_osc_active {
  [[ "${KZ_PROMPT_TERMINAL_INTEGRATION:-1}" != (0|no|off|false) \
    && -n "$TERM" && "$TERM" != (dumb|unknown) ]]
}

function _kz_transient_enabled {
  local tp="${(e)${(e)KZ_PROMPT_TRANSIENT_PROMPT-$DEFAULT_KZ_PROMPT_TRANSIENT_PROMPT}}"
  [[ -n "$tp" && -n "$TERM" && "$TERM" != (dumb|unknown) ]]
}

function _kz_osc_clear_prompt_boundaries {
  _kz_osc_d='' _kz_osc_a='' _kz_osc_b=''
}

# Detection is deferred until precmd so ~/.zshrc.local can disable integration after
# prompt setup. The announcement is once per shell; $_kz_is_iterm then selects all
# later iTerm-specific protocol forms.
function _kz_osc_detect_iterm {
  (( _kz_is_iterm )) && return
  [[ "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]] || return
  _kz_is_iterm=1
  print -n '\e]1337;ShellIntegrationVersion=14;shell=zsh\a'
}

# Report the same cwd through one protocol only. iTerm2's OSC 7 implementation creates
# a prompt mark, so combining it with OSC 133 produces a duplicate blue triangle.
function _kz_osc_report_context {
  if (( _kz_is_iterm )); then
    print -Pn "\e]1337;RemoteHost=${USER}@%M\a\e]1337;CurrentDir=%d\a"
  else
    print -Pn '\e]7;file://%M%d\a'
  fi
}

# Close the command whose C was emitted by preexec. Transient D is written now because
# its following live prompt is deliberately unmarked. Static D is deferred into PROMPT
# so the status row remains outside the completed command's output range.
function _kz_osc_finish_command {
  local ret=$1
  typeset -g _kz_prompt_last_exit=$ret
  if _kz_transient_enabled; then
    print -n "\e]133;D;${ret}\a"
  else
    _kz_osc_d=$'%{\e]133;D;'"${ret}"$'\a%}'
  fi
  _kz_osc_command_active=0
}

# A transient live prompt is a preview and is not recorded. Its A/B pair is added only
# by the accept-line widget after the prompt collapses to its permanent history form.
function _kz_osc_prepare_prompt_boundaries {
  if _kz_transient_enabled; then
    _kz_osc_a='' _kz_osc_b=''
  else
    _kz_osc_a=$'%{\e]133;A\a%}'
    _kz_osc_b=$'%{\e]133;B\a%}'
  fi
}

function _kz_osc_preexec {
  _kz_osc_active || return
  _kz_osc_command_active=1
  # Match iTerm2's own Zsh integration exactly there; the carriage return keeps the
  # command boundary correct for its screen-scraping command capture. Other terminals
  # receive the parameter-free OSC 133 form from the shared protocol.
  if (( _kz_is_iterm )); then
    print -n '\e]133;C;\r\a'
  else
    print -n '\e]133;C\a'
  fi
}
function _kz_osc_precmd {
  local ret=$?
  # Snapshot and clear the "a line was submitted" flag the accept widget sets, so
  # exactly one precmd acts on it.
  local submitted=$_kz_osc_line_submitted
  _kz_osc_line_submitted=0
  if ! _kz_osc_active; then
    _kz_osc_clear_prompt_boundaries
    _kz_osc_command_active=0
    return
  fi
  _kz_osc_d=''
  _kz_osc_detect_iterm
  if (( _kz_osc_command_active )); then
    # A command ran: close the C region preexec opened, with the real exit status.
    _kz_osc_finish_command "$ret"
  elif (( submitted )) && (( ret != 130 )); then
    # A structurally complete line that zsh rejected at parse time: preexec never
    # fired, so the normal C/D pair was never emitted. Still mark the line done
    # with its exit status so consumers get a boundary + status for the failure.
    # (Blank Enter sets no flag; ret==130 is a Ctrl-C abort of an unfinished line,
    # which submitted no command -- neither should invent a D.)
    _kz_osc_finish_command "$ret"
  fi
  _kz_osc_report_context
  _kz_osc_prepare_prompt_boundaries
}

# ============================================================================
# Transient prompt
# ============================================================================
# On accept-line, $PROMPT collapses to a minimal caret so scrollback keeps only a
# caret + the command for past prompts (restored before the next prompt). The
# accepted command is restyled per $KZ_PROMPT_TRANSIENT_STYLE: dim (same hues,
# darker), mute (one grey span), or keep. Off on dumb and when $KZ_PROMPT_TRANSIENT_PROMPT=''.
typeset -g _kz_prompt_full='' _kz_rprompt_full='' _kz_muting=0

# Transient styling is shared by prompt strings and ZLE command highlights. Keep the
# colour math here so segment renderers only decide what to display, not how history
# is repainted.
function _kz_dim_rgb {
  local -a reply
  _kz_color_rgb "$1"
  (( $#reply == 3 )) || return 1
  local -F f=${KZ_PROMPT_TRANSIENT_DIM:-0.7}
  local -i r=$(( reply[1]*f )) g=$(( reply[2]*f )) b=$(( reply[3]*f ))
  printf -v REPLY '#%02x%02x%02x' r g b
}

# Resolve keep/mute/dim into $REPLY without changing prompt structure. The dim path
# rewrites each %F{} span; mute replaces every foreground with the configured grey.
function _kz_dim_string {
  emulate -L zsh
  local s=$1 style="${KZ_PROMPT_TRANSIENT_STYLE:-dim}"
  [[ "$style" == (keep|none|off) ]] && { REPLY="$s"; return }
  local mute=0; [[ "$style" == (mute|grey|gray) ]] && mute=1
  local grey="${(e)_kz_sem[transmuted]}"
  local -a parts=("${(@ps:%F{:)s}")
  local out="${parts[1]}" p spec rest
  for p in "${(@)parts[2,-1]}"; do
    spec="${p%%\}*}"; rest="${p#*\}}"
    if (( mute )); then out+="${grey}${rest}"
    elif _kz_dim_rgb "$spec"; then out+="%F{$REPLY}$rest"
    else out+="%F{$spec}$rest"; fi
  done
  REPLY="$out"
}

# Resolve the public whole-prompt override. `-` rather than `:-` makes an explicit
# empty value disable transience while an unset value selects the default.
function _kz_transient_prompt {
  REPLY="${(e)${(e)KZ_PROMPT_TRANSIENT_PROMPT-$DEFAULT_KZ_PROMPT_TRANSIENT_PROMPT}}"
}

# The collapsed right prompt, mirror of _kz_transient_prompt. Empty by default, so
# past prompts collapse with no right side unless a skin sets KZ_PROMPT_TRANSIENT_RPROMPT.
function _kz_transient_rprompt {
  REPLY="${(e)${(e)KZ_PROMPT_TRANSIENT_RPROMPT-$DEFAULT_KZ_PROMPT_TRANSIENT_RPROMPT}}"
}

function _kz_status_enabled {
  [[ "${KZ_PROMPT_STATUS:-1}" != (0|no|off|false) ]]
}

# Preserve the previous result above the collapsed prompt. It must remain outside OSC
# A/B: putting A before this prefix moves the next command's gutter mark onto ⏎/time.
function _kz_transient_status_prefix {
  REPLY=''
  _kz_status_enabled || return
  [[ -n "$_kz_prompt_status" ]] || return
  _kz_dim_string "$_kz_prompt_status"
}

# Add OSC 133 only to the collapsed prompt that will survive in scrollback. REPLY is
# the complete temporary PROMPT value; the full live prompt remains untouched here.
function _kz_transient_marked_prompt {
  local prompt=$1
  if _kz_osc_active; then
    REPLY=$'%{\e]133;A\a%}'"${prompt}"$'%{\e]133;B\a%}'
  else
    REPLY=$prompt
  fi
}

# Restyle the command's region_highlight in place (zsh has no faint attribute, so
# `dim` recolours each fg toward black at truecolor precision).
function _kz_transient_style {
  case "${KZ_PROMPT_TRANSIENT_STYLE:-dim}" in
    keep|none|off) ;;
    mute|grey|gray)
      region_highlight=("0 ${#BUFFER} ${KZ_PROMPT_TRANSIENT_HL:-fg=8}") ;;
    *)
      setopt localoptions extendedglob
      local -a out p; local e REPLY
      for e in "${region_highlight[@]}"; do
        p=("${(z)e}")
        if [[ ${p[3]} = (#b)(*)fg=([^, ]##)(*) ]] && _kz_dim_rgb "${match[2]}"; then
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
function _kz_transient_accept {
  # A non-empty buffer is being submitted. Record it so the OSC precmd can emit a
  # D;<exit> boundary even when zsh rejects the line at parse time -- preexec (and
  # thus the normal C/D path) never fires for a line that fails to parse.
  [[ -n "$BUFFER" ]] && _kz_osc_line_submitted=1
  _kz_transient_prompt
  local tp=$REPLY
  if (( ! ${_kz_dumb:-0} )) && [[ -n "$tp" ]]; then
    _kz_prompt_full=$PROMPT _kz_rprompt_full=$RPROMPT
    _kz_transient_status_prefix
    local status_prefix=$REPLY
    _kz_dim_string "$tp"; tp="$REPLY"     # restyle the whole line (dim/mute/keep)
    _kz_transient_rprompt; local rp=$REPLY
    [[ -n "$rp" ]] && { _kz_dim_string "$rp"; rp=$REPLY }   # restyle the right side the same way
    # A/B also delimit a blank prompt, so iTerm can navigate it independently. Since
    # no command runs, preexec emits no C and precmd emits no D for that blank entry.
    _kz_transient_marked_prompt "$tp"
    PROMPT="${status_prefix}${REPLY}" RPROMPT="$rp"
    POSTDISPLAY=''
    [[ "${KZ_PROMPT_TRANSIENT_STYLE:-dim}" != (keep|none|off) ]] && _kz_muting=1
    zle .reset-prompt
    zle .accept-line
    return
  fi
  zle accept-line
}
function _kz_transient_restore {
  _kz_muting=0
  [[ -n "$_kz_prompt_full" ]] || return
  PROMPT=$_kz_prompt_full RPROMPT=$_kz_rprompt_full
  _kz_prompt_full=''
}

# ============================================================================
# Lifecycle: precmd + setup
# ============================================================================

typeset -g _kz_dumb=0 _kz_nocolor=0 _kz_pal_loaded=0
function kz_prompt_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  # Terminal capability, re-checked every prompt so toggling $TERM / $NO_COLOR takes
  # effect live. dumb also forces plain glyphs; nocolor strips colour but keeps the
  # full layout ($NO_COLOR per no-color.org).
  _kz_dumb=0
  [[ -z "$TERM" || "$TERM" == (dumb|unknown) ]] && _kz_dumb=1
  _kz_nocolor=$_kz_dumb
  [[ -n "${NO_COLOR-}" ]] && _kz_nocolor=1
  kz_prompt_colors
  kz_prompt_glyphs
  # Resolve the initial/primary caret here, after ~/.zshrc.local has loaded. ZLE's
  # line-init/keymap-select widgets take over while the user is editing a command.
  _kz_prompt_keymap="${(e)KZ_PROMPT_KEYMAP_PRIMARY-$DEFAULT_KZ_PROMPT_KEYMAP_PRIMARY}"
  _kz_prompt_overwrite=''
  # Load the dim palette once, here rather than in setup, so any KZ_PROMPT_PALETTE_*
  # override / TTL / timeout from ~/.zshrc.local (sourced after setup) is in effect.
  if (( ! ${_kz_pal_loaded:-0} )); then
    _kz_pal_loaded=1
    [[ "${KZ_PROMPT_TRANSIENT_STYLE:-dim}" != (keep|none|off|mute|grey|gray) ]] && _kz_load_palette
  fi
  _kz_pwd_segment
  _kz_venv_segment
  _kz_ip_segment
  _kz_duration_segment
  _kz_status_segment
  _kz_git_segment
}

# Register lifecycle hooks and editor widgets in one place. Ordering is semantic:
# OSC precmd must capture $? before the render hook changes it, while duration and OSC
# preexec observe the same accepted command.
function _kz_setup_lifecycle {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd kz_prompt_precmd
  add-zsh-hook preexec _kz_duration_preexec
  add-zsh-hook precmd _kz_osc_precmd
  add-zsh-hook preexec _kz_osc_preexec
  add-zsh-hook chpwd _kz_git_chpwd
  precmd_functions=(_kz_osc_precmd ${precmd_functions:#_kz_osc_precmd})

  zle -N zle-keymap-select
  zle -N zle-line-init
  zle -N overwrite-mode _kz_overwrite_toggle
  if [[ -n "${terminfo[kich1]-}" ]]; then
    bindkey -M emacs "$terminfo[kich1]" overwrite-mode
    bindkey -M viins "$terminfo[kich1]" overwrite-mode
  fi
}

# Install the accept-line replacement and the syntax-highlighter bridge. This is kept
# separate from prompt composition because it mutates ZLE's widget graph.
function _kz_setup_transient_widgets {
  zle -N _kz_transient_accept
  bindkey '^M' _kz_transient_accept
  bindkey '^J' _kz_transient_accept
  add-zsh-hook precmd _kz_transient_restore

  # Fast-syntax-highlighting repaints region_highlight on line-finish. Wrap its shared
  # painter once, then apply the transient style after it while a command is accepting.
  if (( ${+functions[_zsh_highlight]} )) && (( ! ${+functions[_kz_zsh_highlight_orig]} )); then
    functions[_kz_zsh_highlight_orig]=$functions[_zsh_highlight]
    function _zsh_highlight {
      _kz_zsh_highlight_orig "$@"
      local ret=$?
      (( ${_kz_muting:-0} )) && _kz_transient_style
      return ret
    }
  fi

  # Palette loading is lazy so ~/.zshrc.local, sourced after setup, can configure it.
  # Re-arm the one-shot when setup is explicitly run again.
  _kz_pal_loaded=0
}

function kz_prompt_setup {
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

  _kz_setup_lifecycle

  DEFAULT_KZ_PROMPT_KEYMAP_PRIMARY='${_kz_sem[caret1]}${kz[GLYPH.caret]}${kz[RESET]}${_kz_sem[caret2]}${kz[GLYPH.caret]}${kz[RESET]}${_kz_sem[caret3]}${kz[GLYPH.caret]}${kz[RESET]}'
  DEFAULT_KZ_PROMPT_KEYMAP_ALTERNATE='${_kz_sem[caret3]}${kz[GLYPH.caret_alt]}${kz[RESET]}${_kz_sem[caret2]}${kz[GLYPH.caret_alt]}${kz[RESET]}${_kz_sem[caret1]}${kz[GLYPH.caret_alt]}${kz[RESET]}'
  DEFAULT_KZ_PROMPT_KEYMAP_OVERWRITE='${_kz_sem[overwrite]}${kz[GLYPH.caret]}${kz[GLYPH.caret]}${kz[GLYPH.caret]}${kz[RESET]}'

  # Seed the keymap caret so a prompt char shows even where zle-line-init never fires
  # (e.g. Emacs `M-x shell`). precmd resolves it again after ~/.zshrc.local loads.
  _kz_prompt_keymap="${(e)DEFAULT_KZ_PROMPT_KEYMAP_PRIMARY}"

  _kz_prompt_git=''
  _kz_prompt_pwd=''

  # Session context, fixed for the shell's life: SSH session and/or container.
  typeset -g _kz_is_ssh='' _kz_is_container=''
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && _kz_is_ssh=1
  [[ -f /.dockerenv || -f /run/.containerenv || -n "$container" ]] && _kz_is_container=1

  # Per-segment defaults. Each is a deferred string; dynamic ones read the
  # $_kz_prompt_* / state vars the precmd computes.
  DEFAULT_KZ_PROMPT_OS='${kz[GLYPH.os]:+"${_kz_sem[host]}${kz[GLYPH.os]}${kz[RESET]} "}'
  DEFAULT_KZ_PROMPT_CONTEXT='${_kz_is_container:+" ${_kz_sem[container]}${kz[GLYPH.container]}${kz[RESET]}"}${_kz_is_ssh:+" ${_kz_sem[ssh]}${kz[GLYPH.ssh]}${kz[RESET]}"}'
  DEFAULT_KZ_PROMPT_ERR='%(?.${_kz_sem[status_ok]}${kz[GLYPH.dot]}${kz[RESET]}.${_kz_sem[status_err]}${kz[GLYPH.dot]}${kz[RESET]})'
  DEFAULT_KZ_PROMPT_ERROR='${kz[GLYPH.return]} ${_kz_prompt_last_exit}'
  DEFAULT_KZ_PROMPT_VIM='${VIM:+" ${_kz_sem[vim]}${kz[GLYPH.vim]}${kz[RESET]}"}'
  DEFAULT_KZ_PROMPT_EMACS='${INSIDE_EMACS:+" ${_kz_sem[emacs]}${kz[GLYPH.emacs]}${kz[RESET]}"}'
  DEFAULT_KZ_PROMPT_ETCTL='${ETCTL_SESSION:+" ${_kz_sem[info]}etctl${kz[RESET]}:${_kz_sem[etctl]}${ETCTL_SESSION}${kz[RESET]}"}'
  DEFAULT_KZ_PROMPT_JOBS='%(1j. ${_kz_sem[jobs]}${kz[GLYPH.jobs]}${_kz_glyph_pad[jobs]}%j${kz[RESET]}.)'
  DEFAULT_KZ_PROMPT_DURATION='${kz[GLYPH.duration]}${_kz_glyph_pad[duration]}${_kz_prompt_duration}'
  DEFAULT_KZ_PROMPT_USER='%n'
  DEFAULT_KZ_PROMPT_HOST='%M'
  DEFAULT_KZ_PROMPT_IP='${_kz_prompt_ip}'
  DEFAULT_KZ_PROMPT_GIT='${_kz_prompt_git:+${(e)_kz_prompt_git}}'
  DEFAULT_KZ_PROMPT_GIT_SEP=' '
  DEFAULT_KZ_PROMPT_VENV='${(e)_kz_prompt_venv}'
  DEFAULT_KZ_PROMPT_OVERWRITE='${(e)_kz_prompt_overwrite}'
  DEFAULT_KZ_PROMPT_CARET='${(e)_kz_prompt_keymap}'
  DEFAULT_KZ_PROMPT_TIME='[%*]'
  DEFAULT_KZ_PROMPT_PWD='${_kz_prompt_pwd:+${(e)_kz_prompt_pwd}}'

  # Compose the segments into $kz. The plain ones share one shape: a user override
  # ($KZ_PROMPT_<SEG>) or the default, both (e)-evaluated at render.
  typeset -gA kz
  kz[nl]=$'%E\n'
  local seg
  for seg in os err vim emacs etctl context jobs git venv caret; do
    kz[$seg]="\${(e)KZ_PROMPT_${seg:u}:-\$DEFAULT_KZ_PROMPT_${seg:u}}"
  done
  # Unlike the older segments, an explicit empty value hides the overwrite marker.
  kz[overwrite]='${(e)KZ_PROMPT_OVERWRITE-$DEFAULT_KZ_PROMPT_OVERWRITE}'
  # The rest wrap a segment in its own colour, or compose other segments.
  kz[user]='${_kz_sem[user]}${(e)KZ_PROMPT_USER:-$DEFAULT_KZ_PROMPT_USER}${kz[RESET]}'
  kz[time]='${_kz_sem[time]}${(e)KZ_PROMPT_TIME:-$DEFAULT_KZ_PROMPT_TIME}${kz[RESET]}'
  kz[pwd]='${_kz_sem[pwd]}${(e)KZ_PROMPT_PWD:-$DEFAULT_KZ_PROMPT_PWD}${kz[RESET]}'
  # The transient caret, as a handle, so the transient layout composes it the way PROMPT
  # composes $kz[caret] -- no $DEFAULT_KZ_PROMPT_* leaks into a copyable skin.
  kz[transient_caret]='${(e)KZ_PROMPT_TRANSIENT_CARET:-$DEFAULT_KZ_PROMPT_TRANSIENT_CARET}'
  kz[host]="$kz[os]\${_kz_sem[host]}\${(e)KZ_PROMPT_HOST:-\$DEFAULT_KZ_PROMPT_HOST}\${kz[RESET]} \${_kz_sem[ip]}(\${(e)KZ_PROMPT_IP:-\$DEFAULT_KZ_PROMPT_IP})\${kz[RESET]}"
  kz[info]="$kz[user] at $kz[host]"

  SPROMPT='zsh: correct $kz[FG.red]%R%f to $kz[FG.green]%r%f [nyae]? '
  # The visible layout is deferred and overridable end to end. KZ_PROMPT_PROMPT (the two
  # prompt lines) and KZ_PROMPT_RPROMPT (the right prompt) compose the $kz[<segment>]
  # array -- os err info context etctl git venv jobs nl time pwd caret transient_caret
  # overwrite vim emacs -- plus any fcol[]/glyph[]/prompt escapes, so a skin can reorder,
  # drop, or replace the whole thing (see skins/). The collapsed scrollback prompt is the
  # third knob a full skin sets, KZ_PROMPT_TRANSIENT_PROMPT (default: pwd + caret). $kz[]
  # is the palette (the composed segments); PROMPT/RPROMPT are the layout that arranges them,
  # kept separate on purpose.
  # Because the layout is deferred (see the vars below), an override set in ~/.zshrc.local,
  # after setup, takes effect at render with no rebuild. The OSC 133 A/B/D marks and the
  # status line stay wrapped around it, so iTerm integration survives any skin.
  DEFAULT_KZ_PROMPT_RPROMPT='$kz[overwrite]$kz[vim]$kz[emacs]'
  DEFAULT_KZ_PROMPT_PROMPT='$kz[err] $kz[info]$kz[context]$kz[etctl]$kz[git]$kz[venv]$kz[jobs]$kz[nl]$kz[time] $kz[pwd] $kz[caret] '
  # The chosen layout (a skin's KZ_PROMPT_PROMPT/RPROMPT or the default), deferred with the
  # doubled ${(e)${(e)...}} so one PROMPT_SUBST pass resolves both levels: the layout, then
  # the $kz[...] segments it names. Named so PROMPT/RPROMPT below stay readable.
  local _kz_prompt_prompt='${(e)${(e)KZ_PROMPT_PROMPT-$DEFAULT_KZ_PROMPT_PROMPT}}'
  local _kz_prompt_rprompt='${(e)${(e)KZ_PROMPT_RPROMPT-$DEFAULT_KZ_PROMPT_RPROMPT}}'
  RPROMPT="$_kz_prompt_rprompt"
  PROMPT="\${_kz_prompt_status_live}\${_kz_osc_d}\${_kz_osc_a}$_kz_prompt_prompt\${_kz_osc_b}"

  # Transient prompt (collapsed past prompts), the TRANSIENT_ mirror of the live grid:
  #   KZ_PROMPT_TRANSIENT_PROMPT   — the collapsed left prompt   (like KZ_PROMPT_PROMPT)
  #   KZ_PROMPT_TRANSIENT_RPROMPT  — the collapsed right prompt  (like KZ_PROMPT_RPROMPT; empty by default)
  #   KZ_PROMPT_TRANSIENT_CARET    — just the caret/emoji piece  (like KZ_PROMPT_CARET)
  # The default composes the pwd (live colour + KZ_PROMPT_PWD_STYLE) and the caret;
  # each line is resolved and restyled (dim/mute/keep) per-accept. An explicit
  # KZ_PROMPT_TRANSIENT_PROMPT='' disables transience.
  DEFAULT_KZ_PROMPT_TRANSIENT_CARET='${_kz_sem[transient_caret]}${kz[GLYPH.caret]}${kz[RESET]}'
  DEFAULT_KZ_PROMPT_TRANSIENT_PROMPT='$kz[pwd] $kz[transient_caret] '
  DEFAULT_KZ_PROMPT_TRANSIENT_RPROMPT=''
  _kz_setup_transient_widgets
}
