# agnoster — a visual compatibility skin for Agnoster's default segment order.
# It reproduces the conditional status/context/venv/path/git ribbon, including the
# original Powerline separators. A Nerd Font (or another Powerline-patched font) is
# required. Unlike Agnoster, gitstatus supplies the Git state asynchronously.

function _kz_skin_agnoster_prompt {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS

  local -a backgrounds foregrounds contents
  local symbols='' user_name="${USER:-%n}"

  (( ${_kz_prompt_last_exit:-0} != 0 )) && symbols+="${kz[FG.red]}✘"
  (( UID == 0 )) && symbols+="${kz[FG.yellow]}⚡"
  [[ -n "$(jobs -p 2>/dev/null)" ]] && symbols+="${kz[FG.cyan]}⚙"
  if [[ -n "$symbols" ]]; then
    backgrounds+=(black) foregrounds+=(default)
    contents+=(" $symbols ")
  fi

  if [[ "$user_name" != "${DEFAULT_USER-}" || -n "${SSH_CONNECTION-}" ]]; then
    backgrounds+=(black) foregrounds+=(default)
    if (( UID == 0 )); then
      contents+=(" ${kz[FG.yellow]}$user_name@%m ")
    else
      contents+=(" $user_name@%m ")
    fi
  fi

  if [[ -n "${VIRTUAL_ENV-}" ]]; then
    backgrounds+=(cyan) foregrounds+=(black)
    contents+=(" ${VIRTUAL_ENV:t} ")
  fi

  backgrounds+=(blue) foregrounds+=(black) contents+=(' %~ ')

  if [[ -n "${kz[git.branch]}" ]]; then
    backgrounds+=("${${kz[git.dirty]:+yellow}:-green}")
    foregrounds+=(black)
    contents+=("  ${kz[git.branch]}${kz[git.dirty]:+ ±} ")
  fi

  local out='' current='NONE' bg fg text bg_key fg_key current_fg_key
  local i
  for (( i = 1; i <= ${#backgrounds}; ++i )); do
    bg=$backgrounds[i] fg=$foregrounds[i] text=$contents[i]
    bg_key="BG.$bg" fg_key="FG.$fg" current_fg_key="FG.$current"
    if [[ "$current" != NONE && "$bg" != "$current" ]]; then
      out+="${kz[$bg_key]}${kz[$current_fg_key]}${kz[$fg_key]}"
    else
      out+="${kz[$bg_key]}${kz[$fg_key]}"
    fi
    out+=$text
    current=$bg
  done

  current_fg_key="FG.$current"
  out+="%k${kz[$current_fg_key]}%f "
  print -nr -- "$out"
}

KZ_PROMPT_STATUS=0
KZ_PROMPT_PROMPT='$(_kz_skin_agnoster_prompt)'
KZ_PROMPT_RPROMPT=''
KZ_PROMPT_TRANSIENT_PROMPT=''
