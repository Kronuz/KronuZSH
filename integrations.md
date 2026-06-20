# External Tools

A catalog of the modern CLI tools kronuzsh knows how to use. They fall into two
groups: **modern replacements** for classic Unix commands (faster, friendlier,
colored) and **new capabilities** that never had a classic equivalent.

Everything here is **optional and guarded**: each tool is wired in only when its
binary is actually present (`(( $+commands[tool] ))`), and silently skipped when
it isn't. The same config works on your laptop, a fresh box, or a locked-down
server with none of them installed. Each tool is self-contained in its own
`integrations/<tool>/` directory — the shell wiring in `init.zsh`, the install-time
setup (bat's theme cache, git-delta's gitconfig) in `setup.sh`, theme data
alongside. Two thin loaders tie them together:
[`integrations/init.zsh`](integrations/init.zsh) sources every `<tool>/init.zsh` and
[`integrations/setup.sh`](integrations/setup.sh) sources every `<tool>/setup.sh`,
both by globbing the directory — order doesn't matter, since each tool only touches
its own env/aliases/functions. To add or drop a tool, just create or delete its
directory; there's no list to edit.

## The short version

```
classic     →  modern            what you get
──────────────────────────────────────────────────────────────
ls          →  eza               colors, icons, git, tree
cat         →  bat               syntax highlighting, line numbers, git gutter
find        →  fd                simpler syntax, respects .gitignore, fast
grep        →  rg (ripgrep)      recursive + gitignore-aware by default, fast
git diff    →  delta             side-by-side, syntax-highlighted diffs
cd          →  zoxide (z)        jumps to your most-used dirs
du          →  dust              readable disk-usage tree
df          →  duf               readable mounts/free space
top         →  btop              prettier, mouse-driven process monitor
ps          →  procs             colored, searchable process list
sed         →  sd                find/replace without the regex pain
(history)   →  fzf               fuzzy Ctrl-R search through your shell history
(none)      →  yazi              full-screen terminal file manager
```

## Wired in

These get real shell integration in `integrations/init.zsh` (key bindings,
aliases, env, or git config). Install any and it activates on the next shell.

### [fzf](https://github.com/junegunn/fzf) — fuzzy finder

The one with no classic equivalent and the highest payoff. The modern
`fzf --zsh` integration binds **Ctrl-T** (insert a file path), **Ctrl-R**
(fuzzy-search history, replacing the plain incremental search), and **Alt-C**
(cd into a chosen directory). It also powers `**<Tab>` completion. Colored from
the Kronuz palette; previews files with bat when bat is present.

### [fd](https://github.com/sharkdp/fd) — a friendlier `find`

Simpler syntax, respects `.gitignore`, follows symlinks, skips `.git`, and is
fast. Doubles as the engine behind fzf's file/dir pickers. Debian/Ubuntu ship the
binary as `fdfind` (a name clash); init.zsh accepts either name.

### [zoxide](https://github.com/ajeetdsouza/zoxide) — a `cd` that learns

Tracks your most-visited directories so `z proj` jumps straight there; `zi` picks
interactively. The real `cd` and `AUTO_CD` are left untouched.

### [bat](https://github.com/sharkdp/bat) — a `cat` with syntax highlighting

Line numbers, a git change gutter, and language detection. kronuzsh uses it where
it clearly helps (as the **man pager** and fzf's file preview) without shadowing
`cat`. Themed with Kronuz: `setup.sh` builds bat's cache with the bundled theme
([`integrations/bat/themes/Kronuz.tmTheme`](integrations/bat/themes/Kronuz.tmTheme))
and init.zsh sets `BAT_THEME=Kronuz`. Debian ships it as `batcat`; init.zsh
accepts either name.

### [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) — a fast `grep`

Recursive and `.gitignore`-aware by default, and very fast on big trees. Nothing
to wire in, it just works; point `$RIPGREP_CONFIG_PATH` at a config file in
`~/.zshrc.local` if you want defaults.

### [git-delta](https://github.com/dandavison/delta) — a pager for git diffs

Side-by-side, syntax-highlighted diffs with line numbers and `n`/`N` navigation.
`setup.sh` sets it in your **global gitconfig** (so you get the highlighting in
`git add -p` too, not just paging), guarded with `command -v delta` so a box
without delta falls back to `less`/`cat`. It reads the same bat cache, so it uses
the Kronuz syntax theme too.

### [eza](https://github.com/eza-community/eza) — a modern `ls`

Colors, icons, a git status column, and a tree mode. When present it takes over
the `ls`/`l`/`ll`/`la`/`lt` aliases (plus `llg`/`lag` for the slower git column,
left off the defaults because it walks git status per entry). Uses the bundled
Kronuz UI theme
([`integrations/eza/theme.yml`](integrations/eza/theme.yml)); override with
`EZA_CONFIG_DIR` in `~/.zshrc.local`.

> Note: theme.yml controls eza's **columns** (perms, size, owner, dates, git).
> Per-file **name** colors (by extension) come from `$LS_COLORS` / `$EZA_COLORS`
> and eza's built-in defaults, which override theme.yml's `extensions:` map. To
> recolor filenames, set `EZA_COLORS` (highest precedence).

### [yazi](https://github.com/sxyazi/yazi) — a terminal file manager

A fast, full-screen file browser with previews and bulk operations. `y` opens it
and cd's to wherever you quit (yazi's official wrapper); plain `yazi` still works
without the cd.

## Worth adding (just commands)

These need no shell wiring (they're plain commands you run directly), so they
aren't in init.zsh; install any and it works. Roughly ranked by daily payoff:

1. **[lazygit](https://github.com/jesseduffield/lazygit)** — a terminal git UI
   for staging, rebasing, and stashing; uses your delta config.
2. **[hyperfine](https://github.com/sharkdp/hyperfine)** — command-line
   benchmarking with statistics and warmup (same author as fd/bat).
3. **[jq](https://github.com/jqlang/jq)** / **[yq](https://github.com/mikefarah/yq)**
   — slice and reshape JSON / YAML on the command line.
4. **[dust](https://github.com/bootandy/dust)** (`du`) and
   **[duf](https://github.com/muesli/duf)** (`df`) — readable disk usage and
   mounts at a glance.
5. **[btop](https://github.com/aristocratos/btop)** (`top`) and
   **[procs](https://github.com/dalance/procs)** (`ps`) — nicer process views.
6. **[sd](https://github.com/chmln/sd)** — `sed`-style find/replace with sane
   syntax (literal strings or real regex, no escaping minefield).
7. **[tealdeer](https://github.com/tealdeer-rs/tealdeer)** (`tldr`) —
   example-first man pages; what you actually wanted from `man`.
8. **[tokei](https://github.com/XAMPPRocky/tokei)** — count lines of code per
   language, fast.
9. **[glow](https://github.com/charmbracelet/glow)** — render Markdown in the
   terminal, nicely.
10. **[xh](https://github.com/ducaale/xh)** — a fast HTTPie/`curl` for poking at
    HTTP APIs.

## Installing them

Package names differ across platforms, which bites on minimal distros.

```bash
# macOS
brew install fd bat fzf zoxide ripgrep git-delta eza yazi \
             lazygit hyperfine jq yq dust duf btop procs sd tealdeer tokei glow xh

# Debian / Ubuntu  (fd installs as `fdfind`, bat as `batcat` — init.zsh
# detects both)
sudo apt install fd-find bat fzf zoxide ripgrep git-delta

# Fedora
sudo dnf install fd-find bat fzf zoxide ripgrep git-delta
```

On a **minimal or locked-down distro** whose repos don't carry them (e.g. the
CBL-Mariner dev VM, which only ships `ripgrep`), install from source with Rust,
and grab fzf's prebuilt binary (it's Go, not Rust):

```bash
cargo install --locked fd-find bat zoxide git-delta eza    # -> ~/.cargo/bin
ver=$(curl -sSL https://api.github.com/repos/junegunn/fzf/releases/latest \
      | grep -m1 tag_name | sed -E 's/.*"v?([^"]+)".*/\1/')
curl -sSL "https://github.com/junegunn/fzf/releases/download/v$ver/fzf-$ver-linux_amd64.tar.gz" \
      | tar xz -C ~/.local/bin fzf                          # -> ~/.local/bin
```

Most of the "worth adding" tools are Rust too, so `cargo install <crate>` works
anywhere Rust does (crate names: `du-dust`, `procs`, `tokei`, `sd`, ...). lazygit,
yq, duf, glow, and xh are Go; grab their prebuilt release binaries. Both
`~/.cargo/bin` and `~/.local/bin` need to be on `$PATH` **before `.zshrc` runs**, so
`integrations/init.zsh` can detect what's there: put them in `~/.profile` (sourced at
login, before `.zshrc`), not in `~/.zshrc.local` (sourced after):

```sh
# ~/.profile
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH"; export PATH ;; esac
```

## Theming

The colored tools share one **Kronuz** look (from
[Kronuz-Theme](https://github.com/Kronuz/Kronuz-Theme)):

- **eza** — `integrations/eza/theme.yml` (column colors), loaded via
  `$EZA_CONFIG_DIR`.
- **bat** and **delta** — the same `integrations/bat/themes/Kronuz.tmTheme`,
  registered into bat's cache by `setup.sh` and read by both
  (`BAT_THEME=Kronuz`, `delta.syntax-theme = Kronuz`).
- **fzf** — its `--color` flags in `FZF_DEFAULT_OPTS` (set in `fzf/init.zsh`).
- **fast-syntax-highlighting** — `integrations/fast-syntax-highlighting/Kronuz.ini`
  maps shell syntax to the bat palette (commands gold, strings green, builtins
  orange, comments grey, ...); `setup.sh` applies it with `fast-theme`.
- **zsh-autosuggestions** / **zsh-history-substring-search** — their highlight
  colors are set in `lib/plugins.zsh` (a dim grey ghost; green/red diff-tinted
  match), since each is a single variable rather than a theme file.
- **ripgrep** — `integrations/ripgrep/config` (`--colors`: path green, match
  orange-bold), wired via `$RIPGREP_CONFIG_PATH`.
- **fd** (and GNU `ls`) — a Kronuz `LS_COLORS` set in `fd/init.zsh` (dir blue, link
  green, exec orange, archives red, images gold).
- **glow** — `integrations/glow/kronuz.json` glamour style, wired via
  `$GLAMOUR_STYLE`.

Each of these is set only as a default (`${VAR:-...}`), so your own value in
`~/.zshrc.local` wins.

Two TUIs pick their theme from their *own* config file (no env to override), so
kronuzsh ships the theme but can't auto-apply it without clobbering your config —
opt in by symlinking it into place (see the header in each file):

- **btop** — `integrations/btop/Kronuz.theme` → `~/.config/btop/themes/`, then set
  `color_theme` in btop.
- **yazi** — `integrations/yazi/theme.toml` → `~/.config/yazi/theme.toml`.

**vim / neovim** get a real colorscheme,
[`integrations/vim/colors/kronuz.vim`](integrations/vim/colors/kronuz.vim) — a
railscasts-family theme on the same palette (functions gold, keywords orange, strings
green, types red, comments grey), truecolor with xterm-256 fallbacks. `setup.sh` links
the file into `~/.vim/colors/` and `~/.config/nvim/colors/` (guarded on vim/nvim), then
**offers to turn it on**: on a terminal it asks before adding a small, clearly-marked,
removable block to your `~/.vimrc` (or nvim's `init.vim`/`init.lua`) that runs `syntax
on` / `set termguicolors` / `colorscheme kronuz`; off a terminal it just prints the
snippet. It backs the rc up first, and skips an rc that already loads kronuz, so it's
safe to re-run. Force the choice with `KRONUZ_VIM_AUTORC=1` (always add) or
`KRONUZ_VIM_NOAUTORC=1` (never).
