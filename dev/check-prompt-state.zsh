#!/usr/bin/env zsh
# Guard the normalized state exposed to declarative skins.
emulate -L zsh
setopt err_return

typeset -g KRONUZSH=$PWD
typeset -g KZ_PROMPT_TERMINAL_INTEGRATION=0
source runcoms/zshenv 2>/dev/null
source dev/fake-gitstatus.zsh
source lib/prompt.zsh
kz_prompt_setup
kz_prompt_colors
_kz_git_render

local key
for key in git.repo git.branch git.commit git.dirty git.staged git.unstaged \
  git.untracked git.stashed git.ahead; do
  [[ -n "${kz[$key]}" ]] || {
    print -u2 -r -- "$key: expected normalized fake-repository state"
    return 1
  }
done
[[ -z "${kz[git.clean]}" ]] || {
  print -u2 -r -- "git.clean: dirty repository reported clean"
  return 1
}

VCS_STATUS_NUM_STAGED=0
VCS_STATUS_NUM_UNSTAGED=0
VCS_STATUS_NUM_UNTRACKED=0
VCS_STATUS_NUM_CONFLICTED=0
VCS_STATUS_STASHES=0
VCS_STATUS_COMMITS_AHEAD=0
_kz_git_render
[[ -n "${kz[git.clean]}" && -z "${kz[git.dirty]}" ]] || {
  print -u2 -r -- "clean/dirty flags did not invert for a clean repository"
  return 1
}

VCS_STATUS_LOCAL_BRANCH=''
VCS_STATUS_TAG=''
VCS_STATUS_ACTION='rebase'
_kz_git_render
[[ -n "${kz[git.detached]}" && "${kz[git.action]}" == rebase ]] || {
  print -u2 -r -- "detached/action state was not exposed"
  return 1
}

VIRTUAL_ENV=/tmp/example-venv
_kz_venv_segment
[[ "${kz[venv.name]}" == example-venv ]] || {
  print -u2 -r -- "venv.name was not exposed"
  return 1
}

_kz_cmd_start=$(( EPOCHREALTIME - 4 ))
_kz_duration_segment
[[ -n "${kz[duration]}" ]] || {
  print -u2 -r -- "duration was not exposed"
  return 1
}

_kz_git_reset_state
for key in ${(k)kz[(I)git.*]}; do
  [[ -z "${kz[$key]}" ]] || {
    print -u2 -r -- "$key: state leaked outside a repository"
    return 1
  }
done
