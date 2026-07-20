# KronuZSH

**KronuZSH** is a thin, prezto-free zsh setup: my prompt, four plugins, and a small
amount of config, with no framework underneath. It replaces a 7-years-behind prezto
fork with something I maintain end to end.

![KronuZSH prompt showing host, Git and virtualenv context above the time, working directory, and caret.](assets/kronuzsh-prompt.png)

KronuZSH is an opinionated, complete Zsh configuration—not a plugin intended to be
sourced into an existing framework. It installs the standard Zsh runcoms and owns the
shell options, history, completion, keybindings, plugins, and prompt they load.

It is deliberately small. The prompt is one file. Everything Prezto used to give
me that I actually use is now maintained here or supplied by a standalone plugin:

- **prompt** (`lib/prompt.zsh`) the Kronuz prompt, evolved from the theme I maintained
  in Prezto and incorporating ideas and code from Prezto prompt themes. Git status comes
  from [gitstatus](https://github.com/romkatv/gitstatus); the venv, vi/emacs keymap
  indicator, and pwd are tiny native replacements for prezto's python-info,
  editor-info, and prompt-pwd. Past prompts collapse to a compact, configurable
  `path ❯` line (the [transient prompt](prompt.md#transient-prompt)); a slow or
  failed command is immediately visible in the live prompt, while terminals with
  OSC 133 support retain its historical status and running time.
- **plugins** (git submodules under `plugins/`):
  [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting),
  [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions),
  [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search),
  and [gitstatus](https://github.com/romkatv/gitstatus).
- **config** (in `lib/`): `options.zsh`, `history.zsh`, `colors.zsh`,
  `completion.zsh`, `keybindings.zsh`, `aliases.zsh`, `functions.zsh`,
  `terminal.zsh` — one named file per concern.

The guiding rule: keep only the **genuinely useful** parts, lean and easy to find,
and prefer zsh-native over a vendored module (e.g. bracketed paste is built in, so
there's no `safe-paste`). No cryptic framework magic; if you want to change
something, the file it lives in is obvious.

For the story behind the move away from Prezto—and the small conveniences I only
noticed after removing it—read ["Molting Zsh: Down to the core"](https://kronuz.github.io/blog/molting/).

## Contents

- [Prompt and fonts](#fonts-nerd-font)
- [Install](#install)
- [Machine-local config](#machine-local-config)
- [Shell conveniences](#shell-conveniences)
- [Git prompt engine](#gitstatusd-the-git-prompt-engine)
- [External tools](#external-tools)
- [Repository layout](#layout)
- [License](#license)

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

### Requirements

- **Zsh 5.9** is tested in CI on macOS and Linux. Older Zsh 5.x releases may work,
  but are not currently guaranteed.
- **Git** is required to clone and initialize the four plugin submodules.
- **Bash** is used by `install.sh`; the installed interactive configuration is Zsh.
- A **Nerd Font is optional**. Plain-Unicode glyphs are available when one is not
  installed.
- The external tools described below are optional. In particular, the prompt falls
  back to direct `git` calls when `gitstatusd` cannot run.

```bash
git clone --recursive https://github.com/Kronuz/KronuZSH.git ~/.config/KronuZSH
cd ~/.config/KronuZSH && ./install.sh
exec zsh
```

`install.sh` symlinks the runcoms (`~/.zshenv`, `~/.zshrc`, `~/.zprofile`,
`~/.zlogin`, `~/.zlogout`) at this repo's `runcoms/`, backing up anything it
replaces, and inits the plugin submodules. It's idempotent; `./install.sh
--uninstall` restores the backups. Symlinks mean editing `~/.zshrc` edits the
tracked `runcoms/zshrc` directly, and `$KRONUZSH` self-resolves through them.

Use `./install.sh --force` to apply the Kronuz theme over conflicting tool
preferences without prompting, `--hints` for optional usage and maintenance notes, or
`--files` to list integration-managed files and their backups. `--no-backup` suppresses
recovery copies when replacing user files; use it only when those files are versioned.

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
  cp ~/.config/KronuZSH/zshrc.local.example ~/.zshrc.local
  ```

`/etc/profile` is left to the system.

## Shell conveniences

The small built-in command set stays deliberately conventional: `d` prints the
automatic directory stack, `1`–`9` jump through it, and `-` returns to the previous
directory. `mkdcd <directory>` creates one directory (including parents) and enters
it. `http-serve` starts Python 3's HTTP server when `python3` is installed.

`help <command>` is the normal help entry point: local shell functions show their
source (syntax-highlighted and paged by bat when available, otherwise through
`$PAGER`), while builtins, aliases, reserved words, and external commands go through
zsh's context-aware `run-help`. Transparent integration wrappers do the same, so
`help cat` opens the native `cat` manual even when interactive file viewing is powered
by bat. Native `run-help` remains available directly,
including its Git, `ip`, OpenSSL, and `sudo` helpers; minimal installations fall back
to `man`.

The completion menu matches case and `.`, `_`, or `-` boundaries flexibly, keeps
private functions out of normal results, and includes the directory stack for `cd`.

## gitstatusd (the git prompt engine)

gitstatus needs a small daemon, `gitstatusd`. **It is downloaded, not compiled.**
On the first new shell, the plugin fetches a prebuilt binary for your platform
into `~/.cache/gitstatus/` (from GitHub releases). Nothing is committed here.

- **macOS / a machine with open network**: just works, no action needed.
- **A locked-down host (e.g. behind a corp proxy) where the download is blocked**:
  build it once locally (needs `cmake` + a C++ compiler), or copy the cached
  binary from a machine that could download it:

  ```bash
  ~/.config/KronuZSH/plugins/gitstatus/build -w   # compile gitstatusd locally
  # or: scp host:~/.cache/gitstatus/gitstatusd-linux-x86_64 ~/.cache/gitstatus/
  ```

- **Either way the prompt still works**: if `gitstatusd` isn't up, the git
  segment falls back to direct `git` calls (slower on huge repos) and shows a warning
  icon before the branch until the daemon answers again.

## External tools

KronuZSH wires in a set of modern CLI tools **when they're installed**, and
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

On a minimal or locked-down distro that lacks them, install via Rust
(`cargo install --locked fd-find bat zoxide git-delta eza`) and grab fzf's prebuilt
Go binary; the exact commands are in [integrations.md](integrations.md#installing-them).

The colored tools (eza, bat, delta, fzf) share one **Kronuz** look, bundled under
`integrations/` (`eza/theme.yml`, `themes/Kronuz.tmTheme`, and fzf's
`--color`). The syntax theme is generated from one source of truth
([kronuz-theme-vscode](https://github.com/Kronuz/kronuz-theme-vscode)), identical to
the VS Code and Sublime ([Kronuz-Theme](https://github.com/Kronuz/Kronuz-Theme))
editions. The wiring is in `integrations/init.zsh` (per-shell) and
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
  colors.zsh         canonical $LS_COLORS (sourced before completion, which reads it)
  completion.zsh     cached, case-flexible completion (including the directory stack)
  keybindings.zsh    key bindings (emacs; word nav, Ctrl-W to last slash)
  aliases.zsh        the useful aliases (ls colors, ll, mkdir -p, ...)
  functions.zsh      small, generally useful shell functions
  terminal.zsh       window/tab title
  plugins.zsh        plugin loader
  prompt.zsh         the Kronuz prompt (OS glyph, gitstatus, ...; see prompt.md)
integrations/      optional external tools, one self-contained dir per tool (see integrations.md)
  init.zsh           loader: sources each <tool>/init.zsh at shell start
  setup.sh           loader: sources each <tool>/setup.sh at install time
  <tool>/init.zsh    per-shell wiring (fd, bat, fzf, zoxide, eza, yazi, ...)
  bat/setup.sh       builds bat's theme cache from themes/Kronuz.tmTheme
  themes/            shared Kronuz .tmTheme files (bat, delta, yazi); generated
  delta/setup.sh     wires git-delta into the global gitconfig
  eza/theme.yml      Kronuz color theme for eza (loaded via $EZA_CONFIG_DIR)
  vim/colors/        Kronuz vim/nvim colorscheme (linked into ~/.vim/colors by setup.sh)
zshrc.local.example  machine-local template (copy to ~/.zshrc.local)
plugins/           vendored plugins (git submodules)
```

Topic docs: **[prompt.md](prompt.md)** (the full prompt manual: every segment and
option), **[integrations.md](integrations.md)** (the external-tool catalog) and
**[nerd_fonts.md](nerd_fonts.md)** (font rankings + setup).

Contributions are welcome within the project's deliberately narrow scope; see
[CONTRIBUTING.md](CONTRIBUTING.md) for file placement, checks, and attribution notes.

## License

KronuZSH is released under the [MIT License](LICENSE). Portions adapted from
[Prezto](https://github.com/sorin-ionescu/prezto) retain its copyright notices.
The plugins under `plugins/` are git submodules and remain under their respective
upstream licenses.
