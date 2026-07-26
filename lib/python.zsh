# Automatically activate the nearest .venv while moving through a Python project.
#
# Ownership matters: a virtualenv activated manually (or by another tool) is never
# replaced or deactivated. Only the environment recorded in _kz_managed_venv belongs
# to this hook.

typeset -g _kz_managed_venv=${_kz_managed_venv:-}

function _kz_python_venv_update {
  emulate -L zsh

  local dir=${PWD:A} target='' active=${VIRTUAL_ENV:-}

  while true; do
    if [[ -r "$dir/.venv/bin/activate" ]]; then
      target="${dir}/.venv"
      target=${target:A}
      break
    fi
    [[ "$dir" == / ]] && break
    dir=${dir:h}
  done

  [[ -n "$active" ]] && active=${active:A}

  # The user replaced or manually deactivated our environment. Relinquish ownership
  # without touching the new shell state.
  if [[ -n "$_kz_managed_venv" && "$active" != "$_kz_managed_venv" ]]; then
    _kz_managed_venv=''
  fi

  # Keep our environment while anywhere below its project root. When the nearest
  # .venv changes (including disappearing entirely), restore the shell first.
  if [[ -n "$_kz_managed_venv" ]]; then
    [[ "$target" == "$_kz_managed_venv" ]] && return 0
    if (( ! $+functions[deactivate] )); then
      _kz_managed_venv=''
      return 0
    fi
    deactivate
    _kz_managed_venv=''
    active=''
  fi

  # A manually managed environment wins. Otherwise activate the nearest .venv.
  [[ -n "$active" || -z "$target" ]] && return 0
  builtin source "$target/bin/activate" || return 0

  active=${VIRTUAL_ENV:-}
  [[ -n "$active" ]] && active=${active:A}
  if [[ "$active" == "$target" ]]; then
    _kz_managed_venv=$target
  fi

  return 0
}

function _kz_python_venv_setup {
  emulate -L zsh

  autoload -Uz add-zsh-hook
  if [[ "${(L)KZ_AUTO_VENV:-1}" == (0|no|off|false) ]]; then
    add-zsh-hook -d chpwd _kz_python_venv_update 2>/dev/null
    local active=${VIRTUAL_ENV:-}
    [[ -n "$active" ]] && active=${active:A}
    if [[ -n "$_kz_managed_venv" && "$active" == "$_kz_managed_venv" \
      && $+functions[deactivate] -ne 0 ]]; then
      deactivate
    fi
    _kz_managed_venv=''
    return 0
  fi

  add-zsh-hook chpwd _kz_python_venv_update
  _kz_python_venv_update
}
