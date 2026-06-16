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
col[olive]='%F{100}'
col[darkkhaki]='%F{101}'
col[gray]='%F{102}'
col[lavender]='%F{103}'
col[mediumpurple]='%F{104}'
col[mediumslateblue]='%F{105}'
col[darkolivegreen]='%F{107}'
col[darkseagreen]='%F{108}'
col[powderblue]='%F{109}'
col[lightyellow]='%F{11}'
col[skyblue]='%F{110}'
col[cornflowerblue]='%F{111}'
col[lawngreen]='%F{112}'
col[palegreen]='%F{114}'
col[mediumaquamarine]='%F{115}'
col[cadetblue]='%F{116}'
col[lightskyblue]='%F{117}'
col[chartreuse]='%F{118}'
col[limegreen]='%F{119}'
col[lightblue]='%F{12}'
col[aquamarine]='%F{121}'
col[darkred]='%F{124}'
col[mediumvioletred]='%F{125}'
col[darkmagenta]='%F{126}'
col[purple]='%F{127}'
col[darkviolet]='%F{128}'
col[fuchsia]='%F{129}'
col[lightmagenta]='%F{13}'
col[chocolate]='%F{130}'
col[lightcoral]='%F{131}'
col[palevioletred]='%F{132}'
col[orchid]='%F{133}'
col[mediumorchid]='%F{134}'
col[darkorchid]='%F{135}'
col[darkgoldenrod]='%F{136}'
col[burlywood]='%F{137}'
col[rosybrown]='%F{138}'
col[plum]='%F{139}'
col[lightcyan]='%F{14}'
col[violet]='%F{140}'
col[khaki]='%F{143}'
col[palegoldenrod]='%F{144}'
col[darkgray]='%F{145}'
col[slategray]='%F{146}'
col[lightsteelblue]='%F{147}'
col[yellowgreen]='%F{149}'
col[lightgrey]='%F{15}'
col[honeydew]='%F{151}'
col[paleturquoise]='%F{152}'
col[greenyellow]='%F{155}'
col[dimgray]='%F{16}'
col[tomato]='%F{160}'
col[deeppink]='%F{161}'
col[darkorange]='%F{166}'
col[indianred]='%F{167}'
col[hotpink]='%F{168}'
col[navy]='%F{17}'
col[goldenrod]='%F{172}'
col[lightsalmon]='%F{173}'
col[lightpink]='%F{175}'
col[gold]='%F{178}'
col[sandybrown]='%F{179}'
col[darkblue]='%F{18}'
col[tan]='%F{180}'
col[mistyrose]='%F{181}'
col[thistle]='%F{182}'
col[lemonchiffon]='%F{187}'
col[whitesmoke]='%F{188}'
col[ghostwhite]='%F{189}'
col[mediumblue]='%F{19}'
col[azure]='%F{195}'
col[orangered]='%F{196}'
col[crimson]='%F{197}'
col[green]='%F{2}'
col[salmon]='%F{203}'
col[orange]='%F{208}'
col[coral]='%F{209}'
col[peru]='%F{215}'
col[darksalmon]='%F{216}'
col[pink]='%F{218}'
col[darkgreen]='%F{22}'
col[navajowhite]='%F{223}'
col[peachpuff]='%F{224}'
col[teal]='%F{23}'
col[lightgoldenrodyellow]='%F{230}'
col[white]='%F{231}'
col[darkcyan]='%F{24}'
col[deepskyblue]='%F{25}'
col[silver]='%F{250}'
col[lightgray]='%F{251}'
col[gainsboro]='%F{252}'
col[dodgerblue]='%F{26}'
col[yellow]='%F{3}'
col[darkturquoise]='%F{31}'
col[mediumspringgreen]='%F{35}'
col[aqua]='%F{39}'
col[blue]='%F{4}'
col[lime]='%F{40}'
col[springgreen]='%F{41}'
col[magenta]='%F{5}'
col[maroon]='%F{52}'
col[indigo]='%F{54}'
col[cyan]='%F{6}'
col[lightslategray]='%F{60}'
col[darkslateblue]='%F{61}'
col[slateblue]='%F{62}'
col[darkslategray]='%F{66}'
col[steelblue]='%F{68}'
col[royalblue]='%F{69}'
col[grey]='%F{7}'
col[mediumseagreen]='%F{78}'
col[darkgrey]='%F{8}'
col[mediumturquoise]='%F{80}'
col[forestgreen]='%F{83}'
col[turquoise]='%F{86}'
col[lightred]='%F{9}'
col[blueviolet]='%F{93}'
col[brown]='%F{94}'


function prompt_kronuz_colors {
  # Use extended color pallete if available.
  if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
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
  else
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
    DEFAULT_PROMPT_KRONUZ_COLOR_ACTION='$col[yellow]'
    DEFAULT_PROMPT_KRONUZ_COLOR_ADDED='$col[yellow]'
    DEFAULT_PROMPT_KRONUZ_COLOR_AHEAD='$col[green]'
    DEFAULT_PROMPT_KRONUZ_COLOR_BEHIND='$col[magenta]'
    DEFAULT_PROMPT_KRONUZ_COLOR_DIRTY='$col[yellow]'
    DEFAULT_PROMPT_KRONUZ_COLOR_CLEAN='$col[green]'
    DEFAULT_PROMPT_KRONUZ_COLOR_BRANCH='%B$col[white]'
    DEFAULT_PROMPT_KRONUZ_COLOR_REMOTE='$col[white]'
    DEFAULT_PROMPT_KRONUZ_COLOR_COMMIT='$col[white]'
    DEFAULT_PROMPT_KRONUZ_COLOR_DELETED='$col[red]'
    DEFAULT_PROMPT_KRONUZ_COLOR_MODIFIED='$col[red]'
    DEFAULT_PROMPT_KRONUZ_COLOR_POSITION='$col[white]'
    DEFAULT_PROMPT_KRONUZ_COLOR_RENAMED='$col[yellow]'
    DEFAULT_PROMPT_KRONUZ_COLOR_STASHED='$col[cyan]'
    DEFAULT_PROMPT_KRONUZ_COLOR_UNMERGED='$col[red]'
    DEFAULT_PROMPT_KRONUZ_COLOR_INDEXED='$col[yellow]'
    DEFAULT_PROMPT_KRONUZ_COLOR_UNINDEXED='$col[red]'
    DEFAULT_PROMPT_KRONUZ_COLOR_UNTRACKED='$col[darkgrey]'
    DEFAULT_PROMPT_KRONUZ_COLOR_INFO='$col[darkgrey]'
    DEFAULT_PROMPT_KRONUZ_COLOR_SEP='$col[darkgrey]'
    DEFAULT_PROMPT_KRONUZ_COLOR_IP='$col[darkgrey]'
    DEFAULT_PROMPT_KRONUZ_COLOR_TIME='$col[darkgrey]'
    DEFAULT_PROMPT_KRONUZ_COLOR_HOST='$col[blue]'
    DEFAULT_PROMPT_KRONUZ_COLOR_PWD='%(!.$col[red].$col[cyan])'
    DEFAULT_PROMPT_KRONUZ_COLOR_USER='%(!.%B$col[red].%B$col[white])'
  fi
  DEFAULT_PROMPT_KRONUZ_COLOR_NONE='%b%u%s%f%k'
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
  local sep="${(e)col[sep]}" none="${(e)col[none]}"
  local s="${sep}:${(e)col[branch]}${branch}${none}"
  local remote
  remote="$(command git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)"
  [[ -n "$remote" ]] && s+="${sep}:${(e)col[remote]}${remote}${none}"
  local staged='' unstaged='' untracked='' icons=''
  command git diff --cached --quiet --ignore-submodules 2>/dev/null || staged=1
  command git diff --quiet --ignore-submodules 2>/dev/null || unstaged=1
  [[ -n "$(command git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]] && untracked=1
  if [[ -n "$staged$unstaged$untracked" ]]; then
    icons+="${(e)col[dirty]}✗${none}"
    [[ -n "$staged" ]]    && icons+="${(e)col[added]}✛${none}"
    [[ -n "$unstaged" ]]  && icons+="${(e)col[modified]}✴${none}"
    [[ -n "$untracked" ]] && icons+=" ${(e)col[untracked]}⊖${none}"
  else
    icons="${(e)col[clean]}✔${none}"
  fi
  _prompt_kronuz_git=" ${(e)col[info]}git${none}${s}${sep}(${none}${icons}${sep})${none}"
}

function _kronuz_git_segment {
  _prompt_kronuz_git=''
  if ! { (( ${+functions[gitstatus_query]} )) && gitstatus_query KRONUZ 2>/dev/null && [[ "$VCS_STATUS_RESULT" == ok-sync ]] }; then
    _kronuz_git_fallback
    return
  fi

  local sep="${(e)col[sep]}" none="${(e)col[none]}" s=''
  if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    s+="${sep}:${(e)col[branch]}${VCS_STATUS_LOCAL_BRANCH}${none}"
  elif [[ -n "$VCS_STATUS_TAG" ]]; then
    s+="${sep}:${(e)col[branch]}${VCS_STATUS_TAG}${none}"
  else
    s+="${sep}:${(e)col[commit]}${VCS_STATUS_COMMIT[1,7]}${none}"
  fi
  [[ -n "$VCS_STATUS_REMOTE_NAME" ]] && \
    s+="${sep}:${(e)col[remote]}${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}${none}"
  [[ -n "$VCS_STATUS_ACTION" ]] && s+="${sep}:${(e)col[action]}${VCS_STATUS_ACTION}${none}"

  local icons=''
  (( VCS_STATUS_STASHES )) && icons+="${(e)col[stashed]}⼐${none}"
  if (( VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED + VCS_STATUS_NUM_CONFLICTED )); then
    icons+="${(e)col[dirty]}✗${none}"
  else
    icons+="${(e)col[clean]}✔${none}"
  fi
  (( VCS_STATUS_COMMITS_AHEAD ))  && icons+="${(e)col[ahead]}⇡${none}"
  (( VCS_STATUS_COMMITS_BEHIND )) && icons+="${(e)col[behind]}⇣${none}"
  (( VCS_STATUS_NUM_STAGED ))     && icons+="${(e)col[added]}✛${none}"
  (( VCS_STATUS_NUM_UNSTAGED ))   && icons+="${(e)col[modified]}✴${none}"
  (( VCS_STATUS_NUM_CONFLICTED )) && icons+="${(e)col[unmerged]}❖${none}"
  (( VCS_STATUS_NUM_UNTRACKED ))  && icons+=" ${(e)col[untracked]}⊖${none}"

  _prompt_kronuz_git=" ${(e)col[info]}git${none}${s}${sep}(${none}${icons}${sep})${none}"
}

# ---- venv segment (replaces prezto python-info) ----
typeset -gA python_info
function _kronuz_venv_segment {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    python_info[virtualenv]=" ${(e)col[info]}venv${(e)col[none]}:${(e)col[venv]}${VIRTUAL_ENV:t}${(e)col[none]}"
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
  zle reset-prompt 2>/dev/null
}
function zle-keymap-select { _kronuz_editor_info }
function zle-line-init { _kronuz_editor_info }

# ---- precmd ----
function prompt_kronuz_precmd {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_kronuz_colors
  _prompt_kronuz_pwd="${${(%):-%~}//\%/%%}"
  _kronuz_venv_segment
  _kronuz_git_segment
}

# ---- setup ----
function prompt_kronuz_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent sp subst)

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd prompt_kronuz_precmd
  zle -N zle-keymap-select
  zle -N zle-line-init

  local -a COLORS
  COLORS=(action added ahead behind branch clean commit completing deleted
    dirty host indexed info insert ip modified none overwrite position primary1
    primary2 primary3 pwd remote renamed sep stashed status_err status_ok time
    unindexed unmerged untracked user venv vim emacs etctl)

  typeset -A fcol
  local color C
  for color in "${COLORS[@]}" ; do
    C="\${(e)PROMPT_KRONUZ_COLOR_${color:u}:-\$DEFAULT_PROMPT_KRONUZ_COLOR_${color:u}}"
    col[$color]="$C"
    fcol[$color]="\${$C//\%/%%}"
  done

  zstyle ':kronuz:editor:keymap:primary' format "$col[primary1]❯$col[none]$col[primary2]❯$col[none]$col[primary3]❯$col[none]"
  zstyle ':kronuz:editor:keymap:alternate' format "$col[primary3]❮$col[none]$col[primary2]❮$col[none]$col[primary1]❮$col[none]"
  zstyle ':kronuz:editor:keymap:overwrite' format " $col[overwrite]♺$col[none]"

  _prompt_kronuz_git=''
  _prompt_kronuz_pwd=''

  # OS glyph (Nerd Font): apple on macOS, Tux on Linux. Override in local.zsh,
  # e.g. `_kronuz_os=$'\uf31a'` (the other Tux) or `_kronuz_os=''` to hide it.
  typeset -g _kronuz_os=''
  case "$OSTYPE" in
    darwin*) _kronuz_os=$'\uf179' ;;
    linux*)  _kronuz_os=$'\uf17c' ;;
  esac
  DEFAULT_PROMPT_KRONUZ_OS="\${_kronuz_os:+\"$col[host]\${_kronuz_os}$col[none] \"}"

  DEFAULT_PROMPT_KRONUZ_ERR="%(?.$col[status_ok]●$col[none].$col[status_err]●$col[none])"
  DEFAULT_PROMPT_KRONUZ_ERROR="%(?.. $col[status_err]⏎ %?$col[none])"
  DEFAULT_PROMPT_KRONUZ_VIM="\${VIM:+\" $col[vim]V$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_EMACS="\${INSIDE_EMACS:+\" $col[emacs]E$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_ETCTL="\${ETCTL_SESSION:+\" $col[info]etctl$col[none]:$col[etctl]\${ETCTL_SESSION}$col[none]\"}"
  DEFAULT_PROMPT_KRONUZ_USER="%n"
  DEFAULT_PROMPT_KRONUZ_IP="\$(ifconfig 2>/dev/null | grep \"inet \" | grep -v \"127.0.0.1\" | head -1 | awk \"{print \\\$2;}\")"
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
  PROMPT="$kronuz[err]$kronuz[info]$kronuz[etctl]$kronuz[git]$kronuz[venv]$kronuz[error]$kronuz[nl]$kronuz[time] $kronuz[pwd] $kronuz[prompt] "
}
