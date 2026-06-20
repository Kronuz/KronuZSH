# kronuzsh

A thin, prezto-free zsh setup: my prompt, three plugins, and a small amount of
config, with no framework underneath. It replaces a 7-years-behind prezto fork
with something I own end to end.

It is deliberately small. The prompt is one file. Everything prezto used to give
me that I actually use is either mine or a standalone plugin:

- **prompt** (`lib/prompt.zsh`) the Kronuz prompt, ported off prezto. Git status comes
  from [gitstatus](https://github.com/romkatv/gitstatus); the venv, vi/emacs keymap
  indicator, and pwd are tiny native replacements for prezto's python-info,
  editor-info, and prompt-pwd.
- **plugins** (git submodules under `plugins/`):
  [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting),
  [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions),
  [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search),
  and [gitstatus](https://github.com/romkatv/gitstatus).
- **config** (in `lib/`): `options.zsh`, `history.zsh`, `completion.zsh`,
  `keybindings.zsh`, `aliases.zsh`, `terminal.zsh` — one named file per concern.

The guiding rule: keep only the **genuinely useful** parts, lean and easy to find,
and prefer zsh-native over a vendored module (e.g. bracketed paste is built in, so
there's no `safe-paste`). No cryptic framework magic; if you want to change
something, the file it lives in is obvious.

## Fonts (Nerd Font)

The prompt uses [Nerd Font](https://www.nerdfonts.com/) glyphs: the OS logo by the
hostname, the git segment (branch/tag/commit, stash, ahead/behind, staged/modified/
conflicted/untracked), the venv segment, and the vi/emacs indicators. Install any
Nerd Font and point your terminal at it — e.g.
[MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts):

- macOS: `brew install --cask font-meslo-lg-nerd-font`, then set it as your
  terminal font.
- **iTerm2 gotcha**: also set it (or uncheck) under *Settings → Profiles → Text →
  "Use a different font for non-ASCII text"* — otherwise the glyphs show as boxes
  even with the right main font.

Without a Nerd Font, flip the whole prompt to plain-Unicode glyphs that render in
a normal font: set `PROMPT_KRONUZ_NERD_FONT=0` (also accepts `no`/`off`/`false`) in
`~/.zshrc.local`. You can also retune individual glyphs (in either mode) via
`PROMPT_KRONUZ_GLYPH_<NAME>` — set one to a character of your choice, or to `''` to
hide it (e.g. `PROMPT_KRONUZ_GLYPH_MODIFIED='*'`). See the glyph table in
[prompt.md](prompt.md#glyphs) for the full list of names and both default sets.

Color is handled automatically: a `dumb`/unknown terminal (Emacs `M-x shell`,
some CI) or `NO_COLOR=1` ([no-color.org](https://no-color.org)) renders the full
layout with **no color escapes** (and `dumb` also forces the plain glyphs). It's
re-checked every prompt, so `export TERM=dumb` / `NO_COLOR=1` (and back) take
effect live.

For a longer, opinionated (and surely incomplete) rundown of good coding fonts,
see [nerd_fonts.md](nerd_fonts.md).

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
  bash, sh, and zsh; `runcoms/zprofile` sources it for zsh login shells. Put anything
  that puts a tool on PATH (cargo, `~/.local/bin`, ...) here, so it's set before
  `.zshrc` runs and `integrations/init.zsh` can detect the tool.
- **`~/.zshrc.local`** — zsh-only interactive machine tweaks (the
  `PROMPT_KRONUZ_COLOR_HOST` and other `PROMPT_KRONUZ_*` overrides, zstyles, tool
  hooks like `direnv`). Sourced last, if present. Copy the template and edit:

  ```bash
  cp ~/.config/kronuzsh/zshrc.local.example ~/.zshrc.local
  ```

`/etc/profile` is left to the system.

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

kronuzsh wires in a set of modern CLI tools **when they're installed**, and
silently skips them when they aren't, so the same config works on your laptop, a
fresh box, or a server with none of them. The wired set (fzf, fd, zoxide, bat,
ripgrep, git-delta, eza, yazi) gets key bindings, aliases, env, or git
config; a longer list of "just run them" tools (lazygit, jq, dust, btop, ...) is
worth having too.

**See [integrations.md](integrations.md) for the full catalog** — what each tool
does, the classic command it replaces, the per-platform install matrix, and the
shared Kronuz theming. The quick install:

```bash
# macOS
brew install fd bat fzf zoxide ripgrep git-delta eza yazi

# Debian / Ubuntu  (fd installs as `fdfind`, bat as `batcat`; init.zsh detects both)
sudo apt install fd-find bat fzf zoxide ripgrep git-delta

# Fedora
sudo dnf install fd-find bat fzf zoxide ripgrep git-delta
```

On a minimal or locked-down distro that lacks them (e.g. the CBL-Mariner dev VM,
which only ships `ripgrep`), install via Rust (`cargo install --locked fd-find
bat zoxide git-delta eza`) and grab fzf's prebuilt Go binary; the exact commands
are in [integrations.md](integrations.md#installing-them).

The colored tools (eza, bat, delta, fzf) share one **Kronuz** look from
[Kronuz-Theme](https://github.com/Kronuz/Kronuz-Theme), bundled under
`integrations/` (`eza/theme.yml`, `bat/themes/Kronuz.tmTheme`, and fzf's
`--color`). The wiring is in `integrations/init.zsh` (per-shell) and
`integrations/setup.sh` (one-time: bat's theme cache + delta's gitconfig).


## Layout

```
install.sh         idempotent symlink installer (--uninstall restores backups)
runcoms/
  zshenv           environment, all shells   (~/.zshenv)
  zprofile         login: sources ~/.profile (~/.zprofile)
  zshrc            interactive entry point   (~/.zshrc)
  zlogin           login: bg-compiles the completion dump
  zlogout          logout (stub)
lib/               modules sourced by zshrc, one per concern
  options.zsh        shell options
  history.zsh        history (HISTSIZE 10M)
  completion.zsh     completion (cached compinit)
  keybindings.zsh    key bindings (emacs; word nav, Ctrl-W to last slash)
  aliases.zsh        the useful aliases (ls colors, ll, mkdir -p, ...)
  terminal.zsh       window/tab title
  plugins.zsh        plugin loader
  prompt.zsh         the Kronuz prompt (OS glyph, gitstatus, ...; see prompt.md)
integrations/      optional external tools, one self-contained dir per tool (see integrations.md)
  init.zsh           loader: sources each <tool>/init.zsh at shell start
  setup.sh           loader: sources each <tool>/setup.sh at install time
  <tool>/init.zsh    per-shell wiring (fd, bat, fzf, zoxide, eza, yazi, ...)
  bat/setup.sh       builds bat's theme cache; bat/themes/ holds Kronuz.tmTheme
  delta/setup.sh     wires git-delta into the global gitconfig
  eza/theme.yml      Kronuz color theme for eza (loaded via $EZA_CONFIG_DIR)
  vim/colors/        Kronuz vim/nvim colorscheme (linked into ~/.vim/colors by setup.sh)
zshrc.local.example  machine-local template (copy to ~/.zshrc.local)
plugins/           vendored plugins (git submodules)
```

Topic docs: **[prompt.md](prompt.md)** (the full prompt manual: every segment and
option), **[integrations.md](integrations.md)** (the external-tool catalog) and
**[nerd_fonts.md](nerd_fonts.md)** (font rankings + setup).
