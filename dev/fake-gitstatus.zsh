# Fake gitstatus for dev/preview-skin.py.
#
# The real gitstatusd is an async daemon: a throwaway preview shell would spend most
# of its life waiting for the first query to land, and the result would vary with the
# demo repo's state. This stubs the gitstatus_* entry points prompt.zsh calls
# (gitstatus_check / gitstatus_query / gitstatus_start) and backs them with a fixed,
# representative VCS_STATUS_* snapshot, so the git segment renders through the real
# _kronuz_git_render path -- synchronously, identically, and with no repo on disk.
#
# Edit the snapshot below to preview a different repo state.

typeset -g VCS_STATUS_RESULT=ok-sync
typeset -g VCS_STATUS_WORKDIR="$PWD"
typeset -g VCS_STATUS_LOCAL_BRANCH=main
typeset -g VCS_STATUS_REMOTE_NAME=origin
typeset -g VCS_STATUS_REMOTE_BRANCH=main
typeset -g VCS_STATUS_REMOTE_URL='git@github.com:you/project.git'
typeset -g VCS_STATUS_PUSH_REMOTE_NAME=''
typeset -g VCS_STATUS_PUSH_REMOTE_URL=''
typeset -g VCS_STATUS_TAG=''
typeset -g VCS_STATUS_ACTION=''
typeset -g VCS_STATUS_COMMIT=0123456789abcdef0123456789abcdef01234567
typeset -g VCS_STATUS_COMMITS_AHEAD=1
typeset -g VCS_STATUS_COMMITS_BEHIND=0
typeset -g VCS_STATUS_PUSH_COMMITS_AHEAD=0
typeset -g VCS_STATUS_PUSH_COMMITS_BEHIND=0
typeset -g VCS_STATUS_STASHES=1
typeset -g VCS_STATUS_NUM_STAGED=2
typeset -g VCS_STATUS_NUM_UNSTAGED=1
typeset -g VCS_STATUS_NUM_UNTRACKED=1
typeset -g VCS_STATUS_NUM_CONFLICTED=0
typeset -g VCS_STATUS_NUM_STAGED_NEW=1
typeset -g VCS_STATUS_NUM_STAGED_DELETED=0
typeset -g VCS_STATUS_NUM_UNSTAGED_DELETED=0
typeset -g VCS_STATUS_HAS_STAGED=1
typeset -g VCS_STATUS_HAS_UNSTAGED=1
typeset -g VCS_STATUS_HAS_UNTRACKED=1
typeset -g VCS_STATUS_HAS_CONFLICTED=0

function gitstatus_start { : }
function gitstatus_stop  { : }
function gitstatus_check { return 0 }               # the daemon is always "up"
function gitstatus_query { VCS_STATUS_RESULT=ok-sync; return 0 }   # answered, in budget
