# integrations/setup.sh — install-time setup for the external-tool integrations, one
# file per tool (integrations/<tool>/setup.sh). install.sh sources this; it's also
# safe to run on its own (`bash integrations/setup.sh`) to re-apply just the tool
# config without re-linking the runcoms. Each tool's step is guarded on its tool and
# idempotent.
#
# Written for bash (install.sh is bash and sources it), avoiding zsh-isms; each
# setup.sh self-locates its own dir to find bundled themes.
_kronuz_setup_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
# Shared output/prompt helpers (kz_*); install.sh already sourced them, but pull them
# in when this file is run on its own (`bash integrations/setup.sh`).
if ! command -v kz_ok >/dev/null 2>&1; then
  # shellcheck source=../install.lib.sh
  source "$_kronuz_setup_dir/../install.lib.sh"
fi
kz_head "Tool integrations" "🎨"
for _kronuz_s in "$_kronuz_setup_dir"/*/setup.sh; do
  # shellcheck source=/dev/null
  [ -r "$_kronuz_s" ] && source "$_kronuz_s"
done
unset _kronuz_s _kronuz_setup_dir
