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

## Fonts (Nerd Font)

The prompt uses a few [Nerd Font](https://www.nerdfonts.com/) glyphs (the OS logo
by the hostname). Install any Nerd Font and point your terminal at it — e.g.
[MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts):

- macOS: `brew install --cask font-meslo-lg-nerd-font`, then set it as your
  terminal font.
- **iTerm2 gotcha**: also set it (or uncheck) under *Settings → Profiles → Text →
  "Use a different font for non-ASCII text"* — otherwise the glyphs show as boxes
  even with the right main font.

Without a Nerd Font the prompt still works; the OS logo just shows as tofu (□) —
set `_kronuz_os=''` in `local.zsh` to hide it.

For a longer, opinionated (and surely incomplete) rundown of good coding fonts,
see [NerdFonts.md](NerdFonts.md).

## Install

```bash
git clone --recursive https://github.com/Kronuz/kronuzsh.git ~/.config/kronuzsh
cd ~/.config/kronuzsh && ./install.sh
exec zsh
```

`install.sh` symlinks the runcoms (`~/.zshenv`, `~/.zshrc`, `~/.zprofile`,
`~/.zlogin`, `~/.zlogout`) at this repo's `runcoms/`, backing up anything it
replaces, and inits the plugin submodules. It's idempotent; `./install.sh
--uninstall` restores the backups. Symlinks mean editing `~/.zshrc` edits the
tracked `runcoms/zshrc` directly, and `$KRONUZSH` self-resolves through them.

## Machine-local config

Two tiers, by language:

- **`~/.profile`** — cross-shell env (PATH, exports) in POSIX **sh**, shared by
  bash, sh, and zsh; `runcoms/zprofile` sources it for zsh login shells.
- **`local.zsh`** — zsh-only machine tweaks (zstyles, the `PROMPT_KRONUZ_COLOR_HOST`
  override, the `_kronuz_os` glyph, tool hooks like `direnv`). Copy the template;
  it's git-ignored:

  ```bash
  cp ~/.config/kronuzsh/local.zsh.example ~/.config/kronuzsh/local.zsh
  ```

`~/.zshrc.local` is also sourced if present. `/etc/profile` is left to the system.

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

## External tools

A handful of modern CLI tools get wired in automatically **when they're
installed**, and are silently skipped when they aren't (so the same config works
on a fresh box or the server). Install the ones you want, e.g. on macOS:

```bash
brew install ripgrep fd fzf zoxide bat git-delta
```

What each gets you, all guarded on the command being present (`integrations.zsh`,
except delta which lives in git config):

- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder. The modern
  `fzf --zsh` integration binds **Ctrl-T** (insert a file path), **Ctrl-R**
  (search history; this takes over from the plain incremental search), and
  **Alt-C** (cd into a chosen directory).
- **[fd](https://github.com/sharkdp/fd)** — a friendlier `find`, and the engine
  behind fzf's file/dir pickers (hidden files, follows symlinks, skips `.git`).
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — a `cd` that learns your
  most-used dirs. Adds `z` (jump) and `zi` (interactive); the real `cd` is left
  alone.
- **[bat](https://github.com/sharkdp/bat)** — a syntax-highlighting pager, used
  as the **man pager** and fzf's file preview. It does **not** shadow `cat`.
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`) — a fast `grep`;
  nothing to wire, it just works. Point `$RIPGREP_CONFIG_PATH` at a config in
  `local.zsh` for defaults.
- **[git-delta](https://github.com/dandavison/delta)** — a syntax-highlighting
  pager for git diffs. `install.sh` sets it in your **global gitconfig** (so you
  get `navigate`, line numbers, and `git add -p` highlighting, not just paging),
  guarded with `command -v delta` so it falls back to `less`/`cat` where delta
  isn't installed. To set it up without re-running the installer:

  ```bash
  git config --global core.pager \
    'if command -v delta >/dev/null 2>&1; then delta; else less; fi'
  git config --global interactive.diffFilter \
    'if command -v delta >/dev/null 2>&1; then delta --color-only; else cat; fi'
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  ```

## Layout

```
install.sh         idempotent symlink installer (--uninstall restores backups)
runcoms/
  zshenv           environment, all shells   (~/.zshenv)
  zprofile         login: sources ~/.profile (~/.zprofile)
  zshrc            interactive entry point   (~/.zshrc)
  zlogin           login: bg-compiles the completion dump
  zlogout          logout (stub)
options.zsh        shell options
history.zsh        history (HISTSIZE 10M)
completion.zsh     completion (cached compinit)
keybindings.zsh    key bindings (emacs; word nav, Ctrl-W to last slash)
aliases.zsh        the useful aliases (ls colors, ll, mkdir -p, ...)
terminal.zsh       window/tab title
integrations.zsh   optional external tools (fzf, fd, zoxide, bat), each guarded
prompt.zsh         the Kronuz prompt (OS glyph, gitstatus, ...)
plugins.zsh        plugin loader
local.zsh.example  machine-local template (real local.zsh is git-ignored)
plugins/           vendored plugins (git submodules)
```
