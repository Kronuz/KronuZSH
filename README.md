# kronuzsh

A thin, prezto-free zsh setup: my prompt, three plugins, and a small amount of
config, with no framework underneath. It replaces a 7-years-behind prezto fork
with something I own end to end.

It is deliberately small. The prompt is one file. Everything prezto used to give
me that I actually use is either mine or a standalone plugin:

- **prompt** (`prompt.zsh`) the Kronuz prompt, ported off prezto. Git status comes
  from [gitstatus](https://github.com/romkatv/gitstatus); the venv, vi/emacs keymap
  indicator, and pwd are tiny native replacements for prezto's python-info,
  editor-info, and prompt-pwd.
- **plugins** (git submodules under `plugins/`):
  [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting),
  [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions),
  [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search),
  and [gitstatus](https://github.com/romkatv/gitstatus).
- **config**: `env.zsh`, `options.zsh`, `history.zsh`, `completion.zsh`,
  `keybindings.zsh`, `aliases.zsh`, `terminal.zsh` — one named file per concern.

The guiding rule: keep only the **genuinely useful** parts, lean and easy to find,
and prefer zsh-native over a vendored module (e.g. bracketed paste is built in, so
there's no `safe-paste`). No cryptic framework magic; if you want to change
something, the file it lives in is obvious.

## Install

```bash
git clone --recursive https://github.com/Kronuz/kronuzsh.git ~/.config/kronuzsh
# back up your current rc files, then point zsh at this one:
cp ~/.zshrc ~/.zshrc.bak 2>/dev/null
cp ~/.zshenv ~/.zshenv.bak 2>/dev/null
echo 'source ~/.config/kronuzsh/env.zsh'  > ~/.zshenv   # env for all shells
echo 'source ~/.config/kronuzsh/init.zsh' > ~/.zshrc    # interactive layer
exec zsh
```

(`init.zsh` also sources `env.zsh`, so the `~/.zshenv` line is optional, just
recommended so non-interactive shells get `$EDITOR` etc. too.)

If you already cloned without `--recursive`:
`git submodule update --init --recursive`.

## Machine-local config

Anything machine-specific or corp-internal (tool hooks, private URLs, PATH
tweaks) stays out of the repo. Copy the template and edit it; the real file is
git-ignored:

```bash
cp ~/.config/kronuzsh/local.zsh.example ~/.config/kronuzsh/local.zsh
```

`init.zsh` also sources `~/.zshrc.local` if present.

## gitstatusd (the git prompt engine)

gitstatus needs a small daemon, `gitstatusd`. **It is downloaded, not compiled.**
On the first new shell, the plugin fetches a prebuilt binary for your platform
into `~/.cache/gitstatus/` (from GitHub releases). Nothing is committed here.

- **macOS / a machine with open network**: just works, no action needed.
- **A locked-down host (e.g. behind a corp proxy) where the download is blocked**:
  build it once locally (needs `cmake` + a C++ compiler), or copy the cached
  binary from a machine that could download it:

  ```bash
  ~/.config/kronuzsh/plugins/gitstatus/build -w   # compile gitstatusd locally
  # or: scp host:~/.cache/gitstatus/gitstatusd-linux-x86_64 ~/.cache/gitstatus/
  ```

- **Either way the prompt still works**: if `gitstatusd` isn't up, the git
  segment falls back to a direct `git` call (a little slower on huge repos).

## Layout

```
env.zsh            environment, for all shells (your ~/.zshenv sources this)
init.zsh           interactive entry point (your ~/.zshrc sources this)
options.zsh        shell options
history.zsh        history (HISTSIZE 10M)
completion.zsh     completion (cached compinit)
keybindings.zsh    key bindings (emacs)
aliases.zsh        the useful aliases (ls colors, ll, mkdir -p, ...)
terminal.zsh       window/tab title
plugins.zsh        plugin loader
prompt.zsh         the Kronuz prompt
local.zsh.example  machine-local template (real local.zsh is git-ignored)
plugins/           vendored plugins (git submodules)
```
