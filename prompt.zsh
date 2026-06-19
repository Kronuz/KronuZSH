#
# Kronuz prompt, ported off prezto to a thin raw-zsh setup.
#
# Authors:
#   German M. Bravo (Kronuz) <german.mb@gmail.com>
#
# Git status comes from gitstatus (gitstatusd); venv/keymap/pwd are tiny native
# replacements for the prezto python-info/editor-info/prompt-pwd modules.
#

unset col
typeset -gA col
col[black]='%F{0}'
col[red]='%F{1}'
col[lightgreen]='%F{10}'
col[olive]='%F{#878700}'
col[darkkhaki]='%F{#87875f}'
col[gray]='%F{#878787}'
col[lavender]='%F{#8787af}'
col[mediumpurple]='%F{#8787d7}'
col[mediumslateblue]='%F{#8787ff}'
col[darkolivegreen]='%F{#87af5f}'
col[darkseagreen]='%F{#87af87}'
col[powderblue]='%F{#87afaf}'
col[lightyellow]='%F{11}'
col[skyblue]='%F{#87afd7}'
col[cornflowerblue]='%F{#87afff}'
col[lawngreen]='%F{#87d700}'
col[palegreen]='%F{#87d787}'
col[mediumaquamarine]='%F{#87d7af}'
col[cadetblue]='%F{#87d7d7}'
col[lightskyblue]='%F{#87d7ff}'
col[chartreuse]='%F{#87ff00}'
col[limegreen]='%F{#87ff5f}'
col[lightblue]='%F{12}'
col[aquamarine]='%F{#87ffaf}'
col[darkred]='%F{#af0000}'
col[mediumvioletred]='%F{#af005f}'
col[darkmagenta]='%F{#af0087}'
col[purple]='%F{#af00af}'
col[darkviolet]='%F{#af00d7}'
col[fuchsia]='%F{#af00ff}'
col[lightmagenta]='%F{13}'
col[chocolate]='%F{#af5f00}'
col[lightcoral]='%F{#af5f5f}'
col[palevioletred]='%F{#af5f87}'
col[orchid]='%F{#af5faf}'
col[mediumorchid]='%F{#af5fd7}'
col[darkorchid]='%F{#af5fff}'
col[darkgoldenrod]='%F{#af8700}'
col[burlywood]='%F{#af875f}'
col[rosybrown]='%F{#af8787}'
col[plum]='%F{#af87af}'
col[lightcyan]='%F{14}'
col[violet]='%F{#af87d7}'
col[khaki]='%F{#afaf5f}'
col[palegoldenrod]='%F{#afaf87}'
col[darkgray]='%F{#afafaf}'
col[slategray]='%F{#afafd7}'
col[lightsteelblue]='%F{#afafff}'
col[yellowgreen]='%F{#afd75f}'
col[lightgrey]='%F{15}'
col[honeydew]='%F{#afd7af}'
col[paleturquoise]='%F{#afd7d7}'
col[greenyellow]='%F{#afff5f}'
col[dimgray]='%F{#000000}'
col[tomato]='%F{#d70000}'
col[deeppink]='%F{#d7005f}'
col[darkorange]='%F{#d75f00}'
col[indianred]='%F{#d75f5f}'
col[hotpink]='%F{#d75f87}'
col[navy]='%F{#00005f}'
col[goldenrod]='%F{#d78700}'
col[lightsalmon]='%F{#d7875f}'
col[lightpink]='%F{#d787af}'
col[gold]='%F{#d7af00}'
col[sandybrown]='%F{#d7af5f}'
col[darkblue]='%F{#000087}'
col[tan]='%F{#d7af87}'
col[mistyrose]='%F{#d7afaf}'
col[thistle]='%F{#d7afd7}'
col[lemonchiffon]='%F{#d7d7af}'
col[whitesmoke]='%F{#d7d7d7}'
col[ghostwhite]='%F{#d7d7ff}'
col[mediumblue]='%F{#0000af}'
col[azure]='%F{#d7ffff}'
col[orangered]='%F{#ff0000}'
col[crimson]='%F{#ff005f}'
col[green]='%F{2}'
col[salmon]='%F{#ff5f5f}'
col[orange]='%F{#ff8700}'
col[coral]='%F{#ff875f}'
col[peru]='%F{#ffaf5f}'
col[darksalmon]='%F{#ffaf87}'
col[pink]='%F{#ffafd7}'
col[darkgreen]='%F{#005f00}'
col[navajowhite]='%F{#ffd7af}'
col[peachpuff]='%F{#ffd7d7}'
col[teal]='%F{#005f5f}'
col[lightgoldenrodyellow]='%F{#ffffd7}'
col[white]='%F{#ffffff}'
col[darkcyan]='%F{#005f87}'
col[deepskyblue]='%F{#005faf}'
col[silver]='%F{#bcbcbc}'
col[lightgray]='%F{#c6c6c6}'
col[gainsboro]='%F{#d0d0d0}'
col[dodgerblue]='%F{#005fd7}'
col[yellow]='%F{3}'
col[darkturquoise]='%F{#0087af}'
col[mediumspringgreen]='%F{#00af5f}'
col[aqua]='%F{#00afff}'
col[blue]='%F{4}'
col[lime]='%F{#00d700}'
col[springgreen]='%F{#00d75f}'
col[magenta]='%F{5}'
col[maroon]='%F{#5f0000}'
col[indigo]='%F{#5f0087}'
col[cyan]='%F{6}'
col[lightslategray]='%F{#5f5f87}'
col[darkslateblue]='%F{#5f5faf}'
col[slateblue]='%F{#5f5fd7}'
col[darkslategray]='%F{#5f8787}'
col[steelblue]='%F{#5f87d7}'
col[royalblue]='%F{#5f87ff}'
col[grey]='%F{7}'
col[mediumseagreen]='%F{#5fd787}'
col[darkgrey]='%F{8}'
col[mediumturquoise]='%F{#5fd7d7}'
col[forestgreen]='%F{#5fff5f}'
col[turquoise]='%F{#5fffd7}'
col[lightred]='%F{9}'
col[blueviolet]='%F{#8700ff}'
col[brown]='%F{#875f00}'


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
      local -F factor=${PROMPT_KRONUZ_TRANSIENT_DIM:-0.99}
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
    _kronuz_muting=1
    _kronuz_transient_style
    zle .reset-prompt
    zle .accept-line
    return
  fi
  zle accept-line
}
# Runs as a zle-line-finish hook (registered after fast-syntax-highlighting's, so it
# wins the final paint): re-apply our styling to the buffer fsh just re-coloured.
function _kronuz_transient_linefinish {
  (( ${_kronuz_muting:-0} )) || return
  _kronuz_muting=0
  _kronuz_transient_style
}
function _kronuz_transient_restore {
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

  unset kronuz
  typeset -gA kronuz
  kronuz[nl]=$'%E\n'
  kronuz[os]="\${(e)PROMPT_KRONUZ_OS:-\$DEFAULT_PROMPT_KRONUZ_OS}"
  kronuz[err]="\${(e)PROMPT_KRONUZ_ERR:-\$DEFAULT_PROMPT_KRONUZ_ERR}"
  kronuz[error]="\${(e)PROMPT_KRONUZ_ERROR:-\$DEFAULT_PROMPT_KRONUZ_ERROR}"
  kronuz[vim]="\${(e)PROMPT_KRONUZ_VIM:-\$DEFAULT_PROMPT_KRONUZ_VIM}"
  kronuz[emacs]="\${(e)PROMPT_KRONUZ_EMACS:-\$DEFAULT_PROMPT_KRONUZ_EMACS}"
  kronuz[etctl]="\${(e)PROMPT_KRONUZ_ETCTL:-\$DEFAULT_PROMPT_KRONUZ_ETCTL}"
  kronuz[context]="\${(e)PROMPT_KRONUZ_CONTEXT:-\$DEFAULT_PROMPT_KRONUZ_CONTEXT}"
  kronuz[jobs]="\${(e)PROMPT_KRONUZ_JOBS:-\$DEFAULT_PROMPT_KRONUZ_JOBS}"
  kronuz[duration]="\${(e)PROMPT_KRONUZ_DURATION:-\$DEFAULT_PROMPT_KRONUZ_DURATION}"
  kronuz[user]="$col[user]\${(e)PROMPT_KRONUZ_USER:-\$DEFAULT_PROMPT_KRONUZ_USER}$col[none]"
  kronuz[git]="\${(e)PROMPT_KRONUZ_GIT:-\$DEFAULT_PROMPT_KRONUZ_GIT}"
  kronuz[venv]="\${(e)PROMPT_KRONUZ_VENV:-\$DEFAULT_PROMPT_KRONUZ_VENV}"
  kronuz[overwrite]="\${(e)PROMPT_KRONUZ_OVERWRITE:-\$DEFAULT_PROMPT_KRONUZ_OVERWRITE}"
  kronuz[prompt]="\${(e)PROMPT_KRONUZ_PROMPT:-\$DEFAULT_PROMPT_KRONUZ_PROMPT}"
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
  # Register after plugins load (e.g. fast-syntax-highlighting) so our line-finish
  # hook runs last and gets the final say on the muted buffer highlight.
  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget zle-line-finish _kronuz_transient_linefinish 2>/dev/null
}
