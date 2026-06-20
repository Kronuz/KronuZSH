# integrations/setup.sh — install-time setup for the external-tool integrations, one
# file per tool (integrations/<tool>/setup.sh). install.sh sources this; it's also
# safe to run on its own (`sh integrations/setup.sh`) to re-apply just the tool config
# without re-linking the runcoms. Each tool's step is guarded on its tool and
# idempotent.
#
# Plain POSIX sh (not zsh) so install.sh (bash) can source it; each setup.sh
# self-locates its own dir to find bundled themes.
_kronuz_setup_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
for _kronuz_s in "$_kronuz_setup_dir"/*/setup.sh; do
  [ -r "$_kronuz_s" ] && . "$_kronuz_s"
done
unset _kronuz_s _kronuz_setup_dir
