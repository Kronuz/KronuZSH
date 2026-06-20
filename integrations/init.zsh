# integrations/init.zsh — wire up optional external CLI tools, one dir per tool
# (integrations/<tool>/init.zsh), each guarded on its command existing so a machine
# missing a tool just skips it. To drop a tool, delete its integrations/<tool>/.
# Sourced by runcoms/zshrc after lib/keybindings + lib/plugins, so fzf's Ctrl-R wins
# and the tool widgets layer cleanly over the plugins.
#
# Order: most tools are order-independent, but a few care (atuin must bind Ctrl-R
# after fzf), so source those in a set order, then any other tool dir alphabetically
# — a new drop-in tool needs no edit here.
#
# PATH timing: this runs at .zshrc start, so a tool's bin dir (~/.cargo/bin,
# ~/.local/bin, ...) must be on PATH already. Put that in ~/.profile (sourced at
# login, before .zshrc), NOT in ~/.zshrc.local (sourced after this). The install-time
# half is each tool's setup.sh (run by ./setup.sh; see Integrations.md).
#
# Tools that need no shell wiring (lazygit, hyperfine, jq/yq, dust, duf, btop, procs,
# tokei, sd, tldr, glow, xh) aren't here — see Integrations.md for the catalog.
_kronuz_int=( fd bat fzf zoxide atuin eza yazi "$KRONUZSH"/integrations/*(/N:t) )
for _kronuz_t in ${(u)_kronuz_int[@]}; do
  [[ -r "$KRONUZSH/integrations/$_kronuz_t/init.zsh" ]] && \
    source "$KRONUZSH/integrations/$_kronuz_t/init.zsh"
done
unset _kronuz_int _kronuz_t
