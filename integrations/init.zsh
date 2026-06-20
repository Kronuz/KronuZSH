# integrations/init.zsh — wire up optional external CLI tools. Each tool's runtime
# config is its own integrations/<tool>/init.zsh, guarded internally on the command
# existing. This loader just sources every one of them, so adding a tool is dropping
# in its dir and removing one is deleting it — nothing to edit here. The install-time
# half, integrations/setup.sh, discovers its <tool>/setup.sh the same way.
#
# Order is alphabetical and deliberately doesn't matter: every tool only touches its
# own env/aliases/functions, or layers a keybinding no other integration here also
# claims. (If you ever add a tool that must bind a key another tool here also binds —
# the classic case is two history widgets fighting over Ctrl-R — that's when you'd
# switch back to explicit, ordered `source` lines instead of this glob.)
#
# Sourced by runcoms/zshrc after lib/keybindings + lib/plugins, so the widgets layer
# over the plugins. PATH timing: a tool's bin dir must be on PATH before .zshrc runs —
# put that in ~/.profile, not ~/.zshrc.local (integrations.md).
#
# Tools that need no shell wiring (lazygit, hyperfine, jq/yq, dust, duf, btop, procs,
# tokei, sd, tldr, xh) aren't here — see integrations.md for the full catalog.
for _kronuz_i in "$KRONUZSH"/integrations/*/init.zsh(N); do
  [[ -r $_kronuz_i ]] && source "$_kronuz_i"
done
unset _kronuz_i
