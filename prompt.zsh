#
# Kronuz prompt, ported off prezto to a thin raw-zsh setup.
#
# Authors:
#   German M. Bravo (Kronuz) <german.mb@gmail.com>
#
# Layout (top to bottom):
#   - base colour palette   a named %F{...} table ($col)
#   - semantic colours      prompt_kronuz_colors -> $DEFAULT_PROMPT_KRONUZ_COLOR_*
#   - glyphs                prompt_kronuz_glyphs  -> $glyph / $glyph_pad
#   - segments              git, venv, keymap, ip, duration, OSC marks, transient
#   - precmd / setup        prompt_kronuz_precmd, prompt_kronuz_setup
#
# Git status comes from gitstatus (gitstatusd); venv/keymap/pwd are tiny native
# replacements for the prezto python-info/editor-info/prompt-pwd modules.
#

# ---- base colour palette (named %F{...} entries; ANSI 0..15 track the theme,
# 16..255 are exact hex, downsampled by zsh/nearcolor off truecolor) ----
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


function prompt_kronuz_colors {
  # One semantic palette for all terminals. The base palette is hex (truecolor) for
  # the 16..255 colors and ANSI %F{0..15} for the basic ones; on a non-truecolor
  # terminal `zsh/nearcolor` (loaded in setup) downsamples the hex codes to 256 (or
  # to the default fg on 8/16-color terminals), so there's no 256-vs-8 branch here.
  if (( ${_kronuz_nocolor:-0} )); then
    # No-color mode (TERM=dumb/unknown or $NO_COLOR set): blank every semantic color
    # so the full layout still renders, just with zero escapes. Recomputed every
    # precmd, so toggling TERM or NO_COLOR live takes effect on the next prompt.
    local v
    for v in ${(k)parameters[(I)DEFAULT_PROMPT_KRONUZ_COLOR_*]}; do : ${(P)v::=}; done
    return
  fi
  DEFAULT_PROMPT_KRONUZ_COLOR_PRIMARY1='%(!.%B$col[red].%B$col[red])'
  DEFAULT_PROMPT_KRONUZ_COLOR_PRIMARY2='%(!.%B$col[red].%B$col[yellow])'
  DEFAULT_PROMPT_KRONUZ_COLOR_PRIMARY3='%(!.$col[red].%B$col[green])'
  DEFAULT_PROMPT_KRONUZ_COLOR_STATUS_ERR='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_STATUS_OK='$col[green]'
  DEFAULT_PROMPT_KRONUZ_COLOR_VENV='$col[white]'
  DEFAULT_PROMPT_KRONUZ_COLOR_VIM='%B$col[green]'
  DEFAULT_PROMPT_KRONUZ_COLOR_EMACS='%B$col[green]'
  DEFAULT_PROMPT_KRONUZ_COLOR_ETCTL='%B$col[magenta]'
  DEFAULT_PROMPT_KRONUZ_COLOR_OVERWRITE='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_INSERT='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_COMPLETING='%B$col[black]'
  DEFAULT_PROMPT_KRONUZ_COLOR_JOBS='$col[gold]'
  DEFAULT_PROMPT_KRONUZ_COLOR_DURATION='$col[goldenrod]'
  DEFAULT_PROMPT_KRONUZ_COLOR_SSH='$col[mediumpurple]'
  DEFAULT_PROMPT_KRONUZ_COLOR_CONTAINER='$col[deepskyblue]'
  DEFAULT_PROMPT_KRONUZ_COLOR_TRANSIENT='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_ACTION='$col[darkorange]'
  DEFAULT_PROMPT_KRONUZ_COLOR_ADDED='$col[darkorange]'
  DEFAULT_PROMPT_KRONUZ_COLOR_AHEAD='$col[chartreuse]'
  DEFAULT_PROMPT_KRONUZ_COLOR_BEHIND='$col[deeppink]'
  DEFAULT_PROMPT_KRONUZ_COLOR_DIRTY='$col[brown]'
  DEFAULT_PROMPT_KRONUZ_COLOR_CLEAN='$col[forestgreen]' # 64 #5f8700
  DEFAULT_PROMPT_KRONUZ_COLOR_BRANCH='%B$col[white]'
  DEFAULT_PROMPT_KRONUZ_COLOR_REMOTE='$col[white]'
  DEFAULT_PROMPT_KRONUZ_COLOR_COMMIT='$col[white]'
  DEFAULT_PROMPT_KRONUZ_COLOR_DELETED='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_MODIFIED='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_POSITION='$col[white]'
  DEFAULT_PROMPT_KRONUZ_COLOR_RENAMED='$col[darkorange]'
  DEFAULT_PROMPT_KRONUZ_COLOR_STASHED='$col[lightsteelblue]'  # #5fd7ff
  DEFAULT_PROMPT_KRONUZ_COLOR_UNMERGED='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_INDEXED='$col[darkorange]'
  DEFAULT_PROMPT_KRONUZ_COLOR_UNINDEXED='$col[red]'
  DEFAULT_PROMPT_KRONUZ_COLOR_UNTRACKED='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_INFO='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_SEP='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_IP='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_TIME='$col[darkgrey]'
  DEFAULT_PROMPT_KRONUZ_COLOR_HOST='$col[blue]'
  DEFAULT_PROMPT_KRONUZ_COLOR_PWD='%(!.$col[tomato].$col[aqua])'
  DEFAULT_PROMPT_KRONUZ_COLOR_USER='%(!.%B$col[tomato].%B$col[white])'
  DEFAULT_PROMPT_KRONUZ_COLOR_NONE='%b%u%s%f%k'
}


# ---- glyphs (Nerd Font icons, with a plain-Unicode fallback set) ----
# No Nerd Font? Switch the whole prompt to plain-Unicode glyphs that render in a
# normal font with `PROMPT_KRONUZ_NERD_FONT=0` (also accepts no/off/false) in
# local.zsh. Independently, override any single glyph (in either mode) via
# `PROMPT_KRONUZ_GLYPH_<NAME>` — set it to a character of your choice, or to '' to
# hide it, e.g.  PROMPT_KRONUZ_GLYPH_MODIFIED='*'
#
# Glyph names and their two defaults (Nerd Font / plain):
#   branch  / ⎇   tag      ⚑   commit  @   remote  ⇅   action  ⚙
#   clean   ✔   dirty    ✗   stashed ≡(/archive)   ahead ⇡   behind ⇣
#   staged  +/✛   modified pencil/✴   conflicted ⚠/❖   untracked ?/⊖
#   venv    /venv   vim  /V   emacs  /E
typeset -gA glyph glyph_pad
function prompt_kronuz_glyphs {
  local -A g
  local os_nerd=''
  case "$OSTYPE" in
    darwin*) os_nerd=$'\uf179' ;;  # nf-fa-apple
    linux*)  os_nerd=$'\uf17c' ;;  # nf-fa-linux (Tux)
  esac
  if (( ${_kronuz_dumb:-0} )) || [[ "${(L)PROMPT_KRONUZ_NERD_FONT:-1}" == (0|no|off|false) ]]; then
    # Plain-Unicode set (no Nerd Font required; renders via normal font fallback).
    # Also forced on dumb/unknown terminals, where PUA glyphs would be tofu.
    g=(
      os         ''         # no good plain OS glyph; hidden by default
      branch     $'\u2387'  # ⎇  branch (Alternative key)
      tag        $'\u2691'  # ⚑  tag (flag)
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
      venv       'venv'     # text label
      vim        'V'        # text label
      emacs      'E'        # text label
      jobs       '&'        # backgrounded jobs (& = the shell operator)
      duration   ''         # no plain glyph; the formatted time stands alone
      ssh        'ssh'      # text label
      container  'box'      # text label
    )
  else
    # Nerd Font set (default)
    g=(
      os         "$os_nerd" # nf-fa-apple / nf-fa-linux by $OSTYPE
      branch     $'\ue0a0'  # nf-pl-branch           local branch / git marker
      tag        $'\uf412'  # nf-oct-tag             tag ref
      commit     $'\uf417'  # nf-oct-git_commit      detached HEAD
      remote     $'\uf47f'  # nf-oct-git_compare     upstream / remote tracking
      action     $'\uf419'  # nf-oct-git_merge       in-progress op (rebase/merge)
      clean      $'\u2714'  # \u2714 (check)         worktree clean
      dirty      $'\u2717'  # \u2717 (cross)         worktree dirty
      stashed    $'\uf187'  # nf-fa-archive          stash entries
      ahead      $'\u21e1'  # \u21e1 (up arrow)      commits ahead of upstream
      behind     $'\u21e3'  # \u21e3 (down arrow)    commits behind upstream
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
  # Mode-independent glyphs: plain BMP marks that render in any font, so they're the
  # same in both sets (kept here, not hard-coded inline, so they're overridable too).
  g[dot]=$'\u25cf'        # ● command/error status dot
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
    # A single Private-Use-Area Nerd Font glyph can render past its cell and collide
    # with adjacent text, so flag a trailing pad space for it; plain BMP symbols and
    # multi-char text glyphs are single-width and get none (per-glyph, not blanket).
    c=0; [[ ${#val} -eq 1 ]] && c=$(( #val ))
    if (( (c >= 0xe000 && c <= 0xf8ff) || c >= 0xf0000 )); then
      glyph_pad[$name]=' '
    else
      glyph_pad[$name]=''
    fi
  done
  # Back-compat: an explicit `_kronuz_os` (set in local.zsh) wins for the OS glyph.
  (( ${+_kronuz_os} )) && glyph[os]="$_kronuz_os"
}


# ---- git segment (gitstatus, with a direct-git fallback) ----
typeset -g _prompt_kronuz_git=''

# Fallback used when gitstatusd isn't running (no tty, not installed, etc.).
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

# ---- venv segment (replaces prezto python-info) ----
typeset -gA python_info
function _kronuz_venv_segment {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    python_info[virtualenv]=" ${(e)col[info]}${glyph[venv]}${(e)col[none]} ${(e)col[venv]}${VIRTUAL_ENV:t}${(e)col[none]}"
  else
    python_info[virtualenv]=''
  fi
}

# ---- editor keymap indicator (replaces prezto editor-info) ----
typeset -gA editor_info
function _kronuz_editor_info {
  local REPLY
  if [[ "$KEYMAP" == 'vicmd' ]]; then
    zstyle -s ':kronuz:editor:keymap:alternate' format 'REPLY'
  else
    zstyle -s ':kronuz:editor:keymap:primary' format 'REPLY'
  fi
  editor_info[keymap]="$REPLY"
  if [[ "$ZLE_STATE" == *overwrite* ]]; then
    zstyle -s ':kronuz:editor:keymap:overwrite' format 'REPLY'
    editor_info[overwrite]="$REPLY"
  else
    editor_info[overwrite]=''
  fi
  # reset-prompt redraws in place, which needs cursor addressing. A dumb terminal
  # has none, so on a multi-line prompt it reprints (duplicate line) instead — skip
  # it there. The seeded keymap means the first render already shows the arrow.
  (( ${_kronuz_dumb:-0} )) || zle reset-prompt 2>/dev/null
}
function zle-keymap-select { _kronuz_editor_info }
function zle-line-init { _kronuz_editor_info }

# ---- IP segment (cached; the lookup forks several procs, so don't run it on
# every prompt render — refresh at most every 10s) ----
typeset -g _prompt_kronuz_ip='' _prompt_kronuz_ip_ts=0
function _kronuz_ip_segment {
  (( ${EPOCHSECONDS:-0} - _prompt_kronuz_ip_ts < 10 )) && return
  _prompt_kronuz_ip_ts=${EPOCHSECONDS:-0}
  _prompt_kronuz_ip="$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')"
}

# ---- command duration (preexec timer) ----
# Show how long the last command ran, when it exceeds PROMPT_KRONUZ_CMD_DURATION_MIN
# seconds (default 3). preexec stamps the start, precmd computes the delta.
typeset -g _kronuz_cmd_start=0 _prompt_kronuz_duration=''
function _kronuz_duration_preexec { _kronuz_cmd_start=${EPOCHREALTIME:-0} }
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

# ---- terminal shell integration (OSC 7 cwd + OSC 133 prompt marks) ----
# Lets modern terminals (iTerm2/VSCode/WezTerm/kitty) open new tabs/splits in
# $PWD and jump between prompts / show per-command status. Skipped on dumb/unknown.
# The B mark (input start) rides at the end of PROMPT via $_kronuz_osc_b.
# In iTerm2 ($_kronuz_is_iterm), we also emit its proprietary OSC 1337 host/cwd
# (the OSC 133 marks above are the cross-terminal part).
typeset -g _kronuz_osc_b='' _kronuz_is_iterm=0
function _kronuz_osc_active { [[ -n "$TERM" && "$TERM" != (dumb|unknown) ]] }
function _kronuz_osc_preexec {
  _kronuz_osc_active && print -n '\e]133;C\a'
}
function _kronuz_osc_precmd {
  local ret=$?
  if ! _kronuz_osc_active; then _kronuz_osc_b=''; return; fi
  print -n "\e]133;D;${ret}\a\e]133;A\a"
  print -Pn '\e]7;file://%M%d\a'
  (( _kronuz_is_iterm )) && print -Pn "\e]1337;RemoteHost=${USER}@%M\a\e]1337;CurrentDir=%d\a"
  _kronuz_osc_b=$'%{\e]133;B\a%}'
}

# ---- transient prompt: collapse a submitted prompt to a minimal caret ----
# On accept-line, swap PROMPT to a one-line caret and redraw, so scrollback keeps
# only a minimal prompt for past commands; restored before the next prompt. The
# just-entered command is restyled per PROMPT_KRONUZ_TRANSIENT_STYLE (dim = keep the
# syntax hues but faint; mute = one grey span, PROMPT_KRONUZ_TRANSIENT_HL; keep =
# leave it), so the whole past line reads as history. Off on dumb (reset-prompt
# can't redraw in place there) and when PROMPT_KRONUZ_TRANSIENT=''.
typeset -g _kronuz_prompt_full='' _kronuz_rprompt_full='' _kronuz_muting=0
# Query the terminal's 16 ANSI palette colours (OSC 4) once at setup so `dim` darkens
# your actual theme rather than a guessed table. Cached in _kronuz_pal; falls back to
# the xterm defaults below when the terminal doesn't answer (or tmux/dumb/no-tty).
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
    local -F end=$(( EPOCHREALTIME + 0.3 )); local -i n=0
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
function _kronuz_color_rgb {
  # $1: #rrggbb | 0-255 index | basic colour name -> reply=(r g b), or reply=()
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
function _kronuz_transient_style {
  case "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" in
    keep|none|off) ;;
    mute|grey|gray)
      region_highlight=("0 ${#BUFFER} ${PROMPT_KRONUZ_TRANSIENT_HL:-fg=8}") ;;
    *)  # dim: same hues, darker — scale each fg toward black (truecolor output).
      # zsh region_highlight has no faint/dim attribute, so we recolour.
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
function _kronuz_transient_accept {
  if (( ! ${_kronuz_dumb:-0} )) && [[ -n "$_kronuz_transient_prompt" ]]; then
    _kronuz_prompt_full=$PROMPT _kronuz_rprompt_full=$RPROMPT
    PROMPT=$_kronuz_transient_prompt RPROMPT=''
    # `keep` leaves the command's own syntax colours. The other styles restyle the
    # buffer; flag our _zsh_highlight wrapper (installed in setup) to re-apply the
    # style after fast-syntax-highlighting rebuilds region_highlight on line-finish.
    [[ "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" != (keep|none|off) ]] && _kronuz_muting=1
    zle .reset-prompt
    zle .accept-line
    return
  fi
  zle accept-line
}
function _kronuz_transient_restore {
  _kronuz_muting=0          # resume highlighting for the next line (reset every prompt)
  [[ -n "$_kronuz_prompt_full" ]] || return
  PROMPT=$_kronuz_prompt_full RPROMPT=$_kronuz_rprompt_full
  _kronuz_prompt_full=''
}

# ---- precmd ----
typeset -g _kronuz_dumb=0 _kronuz_nocolor=0
function prompt_kronuz_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  # Terminal capability, re-checked every prompt so `export TERM=dumb` / `NO_COLOR=1`
  # (and back) take effect live. `dumb` also forces plain glyphs; `nocolor` strips
  # all color while keeping the full layout (NO_COLOR = the no-color.org standard).
  _kronuz_dumb=0
  [[ -z "$TERM" || "$TERM" == (dumb|unknown) ]] && _kronuz_dumb=1
  _kronuz_nocolor=$_kronuz_dumb
  [[ -n "${NO_COLOR-}" ]] && _kronuz_nocolor=1
  prompt_kronuz_colors
  prompt_kronuz_glyphs
  _prompt_kronuz_pwd="${${(%):-%~}//\%/%%}"
  _kronuz_venv_segment
  _kronuz_ip_segment
  _kronuz_duration_segment
  _kronuz_git_segment
}

# ---- setup ----
function prompt_kronuz_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  zmodload -i zsh/parameter 2>/dev/null  # $parameters, used by the no-color path
  zmodload -i zsh/datetime 2>/dev/null   # $EPOCHSECONDS, for the cached IP segment

  # The base palette uses hex (%F{#RRGGBB}) for the 16..255 colors so they render at
  # full 24-bit on a truecolor terminal. On anything else, load zsh/nearcolor, which
  # transparently maps those hex codes to the nearest 256-color (or to the default
  # foreground on 8/16-color terminals) — no broken escapes, one palette everywhere.
  if [[ "${COLORTERM-}" != (24bit|truecolor) && "${terminfo[colors]:-0}" -ne 16777216 ]]; then
    zmodload zsh/nearcolor 2>/dev/null
  fi

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd prompt_kronuz_precmd
  add-zsh-hook preexec _kronuz_duration_preexec
  add-zsh-hook precmd _kronuz_osc_precmd
  add-zsh-hook preexec _kronuz_osc_preexec
  # run the OSC precmd first so it captures the command's real exit status
  precmd_functions=(_kronuz_osc_precmd ${precmd_functions:#_kronuz_osc_precmd})
  # iTerm2: announce shell integration once (unlocks its command history / status /
  # alerts). $LC_TERMINAL survives ssh; $TERM_PROGRAM is the local case.
  if [[ "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]] && _kronuz_osc_active; then
    _kronuz_is_iterm=1
    print -n '\e]1337;ShellIntegrationVersion=14;shell=zsh\a'
  fi
  zle -N zle-keymap-select
  zle -N zle-line-init

  local -a COLORS
  COLORS=(action added ahead behind branch clean commit completing deleted
    dirty duration host indexed info insert ip jobs modified none overwrite position primary1
    primary2 primary3 pwd remote renamed sep stashed status_err status_ok time
    unindexed unmerged untracked user venv vim emacs etctl ssh container transient)

  local color C
  for color in "${COLORS[@]}" ; do
    C="\${(e)PROMPT_KRONUZ_COLOR_${color:u}:-\$DEFAULT_PROMPT_KRONUZ_COLOR_${color:u}}"
    col[$color]="$C"
  done

  zstyle ':kronuz:editor:keymap:primary' format "$col[primary1]\${glyph[caret]}$col[none]$col[primary2]\${glyph[caret]}$col[none]$col[primary3]\${glyph[caret]}$col[none]"
  zstyle ':kronuz:editor:keymap:alternate' format "$col[primary3]\${glyph[caret_alt]}$col[none]$col[primary2]\${glyph[caret_alt]}$col[none]$col[primary1]\${glyph[caret_alt]}$col[none]"
  zstyle ':kronuz:editor:keymap:overwrite' format " $col[overwrite]\${glyph[overwrite]}$col[none]"

  # Seed the keymap arrow so there's always a prompt char, even where ZLE is off
  # (e.g. Emacs `M-x shell`) and zle-line-init never fires to set it.
  local REPLY
  zstyle -s ':kronuz:editor:keymap:primary' format 'REPLY'
  editor_info[keymap]="$REPLY"

  _prompt_kronuz_git=''
  _prompt_kronuz_pwd=''

  # Session context, fixed for the shell's life: SSH session and/or container.
  typeset -g _kronuz_is_ssh='' _kronuz_is_container=''
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && _kronuz_is_ssh=1
  [[ -f /.dockerenv || -f /run/.containerenv || -n "$container" ]] && _kronuz_is_container=1

  # OS glyph: apple on macOS, Tux on Linux (Nerd Font), hidden in plain mode
  # (PROMPT_KRONUZ_NERD_FONT=0). Override via PROMPT_KRONUZ_GLYPH_OS, or the legacy
  # `_kronuz_os` in local.zsh (e.g. `_kronuz_os=$'\uf31a'`, or `''` to hide it).
  DEFAULT_PROMPT_KRONUZ_OS="\${glyph[os]:+\"$col[host]\${glyph[os]}$col[none] \"}"
  DEFAULT_PROMPT_KRONUZ_CONTEXT="\${_kronuz_is_container:+\" $col[container]\${glyph[container]}$col[none]\"}\${_kronuz_is_ssh:+\" $col[ssh]\${glyph[ssh]}$col[none]\"}"

  DEFAULT_PROMPT_KRONUZ_ERR="%(?.$col[status_ok]\${glyph[dot]}$col[none].$col[status_err]\${glyph[dot]}$col[none])"
  DEFAULT_PROMPT_KRONUZ_ERROR="%(?.. $col[status_err]\${glyph[return]} %?$col[none])"
  DEFAULT_PROMPT_KRONUZ_VIM="\${VIM:+\" $col[vim]\${glyph[vim]}$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_EMACS="\${INSIDE_EMACS:+\" $col[emacs]\${glyph[emacs]}$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_ETCTL="\${ETCTL_SESSION:+\" $col[info]etctl$col[none]:$col[etctl]\${ETCTL_SESSION}$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_JOBS="%(1j. $col[jobs]\${glyph[jobs]}\${glyph_pad[jobs]}%j$col[none].)"
  DEFAULT_PROMPT_KRONUZ_DURATION="\${_prompt_kronuz_duration:+\" $col[duration]\${glyph[duration]}\${glyph_pad[duration]}\${_prompt_kronuz_duration}$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_USER="%n"
  DEFAULT_PROMPT_KRONUZ_IP="\${_prompt_kronuz_ip}"
  DEFAULT_PROMPT_KRONUZ_GIT="\${_prompt_kronuz_git:+\${(e)_prompt_kronuz_git}}"
  DEFAULT_PROMPT_KRONUZ_VENV="\${(e)python_info[virtualenv]}"
  DEFAULT_PROMPT_KRONUZ_OVERWRITE="\${(e)editor_info[overwrite]}"
  DEFAULT_PROMPT_KRONUZ_PROMPT="\${(e)editor_info[keymap]}"
  DEFAULT_PROMPT_KRONUZ_TIME="[%*]"
  DEFAULT_PROMPT_KRONUZ_PWD="\${_prompt_kronuz_pwd:+\${(e)_prompt_kronuz_pwd}}"

  # Compose the prompt segments into $kronuz. The plain ones share one shape: a user
  # override ($PROMPT_KRONUZ_<SEG>) or the built-in default, both (e)-evaluated at render.
  unset kronuz
  typeset -gA kronuz
  kronuz[nl]=$'%E\n'
  local seg
  for seg in os err error vim emacs etctl context jobs duration git venv overwrite prompt; do
    kronuz[$seg]="\${(e)PROMPT_KRONUZ_${seg:u}:-\$DEFAULT_PROMPT_KRONUZ_${seg:u}}"
  done
  # The rest wrap a segment in its own colour, or compose other segments.
  kronuz[user]="$col[user]\${(e)PROMPT_KRONUZ_USER:-\$DEFAULT_PROMPT_KRONUZ_USER}$col[none]"
  kronuz[time]="$col[time]\${(e)PROMPT_KRONUZ_TIME:-\$DEFAULT_PROMPT_KRONUZ_TIME}$col[none]"
  kronuz[pwd]="$col[pwd]\${(e)PROMPT_KRONUZ_PWD:-\$DEFAULT_PROMPT_KRONUZ_PWD}$col[none]"
  kronuz[host]="$kronuz[os]$col[host]%M$col[none] $col[ip](\${(e)PROMPT_KRONUZ_IP:-\$DEFAULT_PROMPT_KRONUZ_IP})$col[none]"
  kronuz[info]="$kronuz[user] at $kronuz[host]"

  SPROMPT='zsh: correct $col[red]%R%f to $col[green]%r%f [nyae]? '
  RPROMPT="$kronuz[overwrite]$kronuz[vim]$kronuz[emacs]"
  PROMPT="$kronuz[err] $kronuz[info]$kronuz[context]$kronuz[etctl]$kronuz[git]$kronuz[venv]$kronuz[jobs]$kronuz[error]$kronuz[duration]$kronuz[nl]$kronuz[time] $kronuz[pwd] $kronuz[prompt] \${_kronuz_osc_b}"

  # Transient prompt: the caret left in scrollback for already-run commands.
  # Override the look with PROMPT_KRONUZ_TRANSIENT, or set it to '' to disable.
  # (Built with an if/else, not `${VAR-default}`: the default's `${glyph[caret]}`
  # braces would be mis-matched by the outer parameter expansion.)
  if (( ${+PROMPT_KRONUZ_TRANSIENT} )); then
    _kronuz_transient_prompt="$PROMPT_KRONUZ_TRANSIENT"
  else
    _kronuz_transient_prompt="$col[transient]\${glyph[caret]}$col[none] "
  fi
  zle -N _kronuz_transient_accept
  bindkey '^M' _kronuz_transient_accept
  bindkey '^J' _kronuz_transient_accept
  add-zsh-hook precmd _kronuz_transient_restore
  # Mute/dim styles restyle region_highlight for the accepted line; fast-syntax-
  # highlighting rebuilds it on its own zle-line-finish. Rather than hook
  # zle-line-finish (which recurses badly once fsh re-wraps the add-zle-hook-widget
  # dispatcher), wrap _zsh_highlight once: let it build the fresh colours, then
  # re-apply our style on top while `_kronuz_muting` is set. The line-finish rebuild
  # is unconditional in fsh, so this also covers a buffer fsh skipped (e.g. a paste).
  # Covers fast-syntax-highlighting and zsh-syntax-highlighting (same function name).
  if (( ${+functions[_zsh_highlight]} )) && (( ! ${+functions[_kronuz_zsh_highlight_orig]} )); then
    functions[_kronuz_zsh_highlight_orig]=$functions[_zsh_highlight]
    function _zsh_highlight {
      _kronuz_zsh_highlight_orig "$@"
      local ret=$?
      (( ${_kronuz_muting:-0} )) && _kronuz_transient_style
      return ret
    }
  fi
  # `dim` needs the terminal's real ANSI palette; query it once now (skipped for the
  # other styles, which don't recolour by RGB).
  [[ "${PROMPT_KRONUZ_TRANSIENT_STYLE:-dim}" != (keep|none|off|mute|grey|gray) ]] && _kronuz_query_palette
}
