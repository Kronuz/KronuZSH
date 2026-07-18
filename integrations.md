# External Tools

A catalog of the modern CLI tools KronuZSH knows how to use. They fall into two
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
cat file    →  bat               syntax highlighting for interactive file viewing
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

## Integrated with KronuZSH

These receive either runtime shell wiring (`init.zsh`: key bindings, aliases, or
environment) or install-time configuration (`setup.sh`: themes, caches, or tool-owned
config). Runtime integrations activate in the next shell; setup integrations are
applied by `install.sh` or `bash integrations/setup.sh`. Both accept `--force` to
replace a conflicting tool theme without prompting, `--hints` to show optional usage
and maintenance notes, `--files` to list managed files and timestamped backups, and
`--no-backup` to suppress recovery copies (only advisable when your configuration is
already versioned).

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

Line numbers, a git change gutter, and language detection. When available,
KronuZSH uses it for `cat`, the **man pager**, local-function output from `help`,
and fzf's file preview; without it, the native tools stay untouched. Themed with
Kronuz: `setup.sh` builds bat's cache with the bundled theme
([`integrations/themes/Kronuz.tmTheme`](integrations/themes/Kronuz.tmTheme))
and init.zsh sets `BAT_THEME=Kronuz`. A compatibility wrapper uses bat only for a
plain `cat file` written directly to the terminal. Options such as `cat -v`, stdin,
pipelines, and redirections use the native `cat`, so shell and byte-stream behavior
remain intact. `help cat` likewise resolves to native cat's manual rather than showing
the compatibility wrapper. Debian ships it as `batcat`; init.zsh
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
without the cd. Its setup integration also installs the Kronuz UI and code-preview
themes.

### [tealdeer](https://github.com/tealdeer-rs/tealdeer) (`tldr`) — practical command examples

Example-first command documentation. Its setup integration seeds a missing config,
applies the Kronuz palette, and enables automatic cache updates. Existing configs are
backed up and changed only after confirmation; non-style preferences stay intact.

### [glow](https://github.com/charmbracelet/glow) — Markdown in the terminal

Renders Markdown with the bundled Kronuz glamour style. Its setup integration writes
the style path into glow's own config when the current style is still the default,
leaving an existing custom style alone.

### [btop](https://github.com/aristocratos/btop) — process monitor

A polished, mouse-capable replacement for `top`. Its opt-in setup links the bundled
Kronuz theme and selects it in `btop.conf`, with confirmation and backup protection.

## Worth adding (just commands)

These have no KronuZSH runtime or setup integration; install any and it works as a
plain command. Roughly ranked by daily payoff:

1. **[lazygit](https://github.com/jesseduffield/lazygit)** — a terminal git UI
   for staging, rebasing, and stashing; uses your delta config.
2. **[hyperfine](https://github.com/sharkdp/hyperfine)** — command-line
   benchmarking with statistics and warmup (same author as fd/bat).
3. **[jq](https://github.com/jqlang/jq)** / **[yq](https://github.com/mikefarah/yq)**
   — slice and reshape JSON / YAML on the command line.
4. **[dust](https://github.com/bootandy/dust)** (`du`) and
   **[duf](https://github.com/muesli/duf)** (`df`) — readable disk usage and
   mounts at a glance.
5. **[procs](https://github.com/dalance/procs)** — a colored, searchable `ps` replacement.
6. **[sd](https://github.com/chmln/sd)** — `sed`-style find/replace with sane
   syntax (literal strings or real regex, no escaping minefield).
7. **[tokei](https://github.com/XAMPPRocky/tokei)** — count lines of code per
   language, fast.
8. **[xh](https://github.com/ducaale/xh)** — a fast HTTPie/`curl` for poking at
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

The colored tools share one **Kronuz** look. The syntax-highlighting theme is the
canonical Kronuz theme, generated identically for VS Code, Sublime Text
([Kronuz-Theme](https://github.com/Kronuz/Kronuz-Theme)) and TextMate from one source
of truth ([kronuz-theme-vscode](https://github.com/Kronuz/kronuz-theme-vscode)); the
TextMate build lives in `integrations/themes/` (don't hand-edit it). The rest of the
palette wiring:

- **eza** — `integrations/eza/theme.yml` (column colors), loaded via
  `$EZA_CONFIG_DIR`.
- **bat** and **delta** — the same `integrations/themes/Kronuz.tmTheme`,
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
- **ls / fd / eza / the completion menu** — one rich truecolor `$LS_COLORS` (500+ file
  types) generated by **[vivid](https://github.com/sharkdp/vivid)** from
  `integrations/vivid/kronuz.yml` into the committed `integrations/vivid/ls_colors`,
  loaded by `lib/colors.zsh` (runtime needs no vivid). Source code is grouped (general
  gold, scripting purple, functional teal); docs, markup, config, the media types,
  archives and junk each get a distinct hue. eza reads `$LS_COLORS` and it overrides
  `theme.yml`'s filekinds, so the two are kept in sync.
- **grep / man / BSD `ls`** — `lib/colors.zsh` also sets `$GREP_COLORS`, `$LESS_TERMCAP`
  (man pages), and `$LSCOLORS`/`$CLICOLOR` (macOS/BSD `ls`) in Kronuz tones.
- **glow** — the bundled `integrations/glow/kronuz.json` glamour style, written into
  glow's own config (`style:`) by `setup.sh`, only when your style is still the default.
  glow the CLI never reads `$GLAMOUR_STYLE` (only the glamour *library* does) and themes
  nothing until its config or a `-s` flag names a style, so the env var alone does nothing
  — override with `glow -s <style>` or by editing `glow config`.
- **tealdeer / tldr** — `integrations/tldr/kronuz.toml` maps descriptions, command
  names, example prose, code, and variables to the Kronuz foreground, gold, tan, green,
  and blue. Its setup uses `tldr --seed-config` when needed, replaces only `[style.*]`
  tables, and enables tealdeer's built-in automatic cache updates.

Each of these is set only as a default (`${VAR:-...}`), so your own value in
`~/.zshrc.local` wins.

Four tools pick their theme from their *own* config file (no env to override), so
KronuZSH can't theme them through the environment. Instead `setup.sh` wires them up
non-destructively (backing up anything it replaces, idempotent). Existing configs are
changed only after a `[y/N]` prompt (default No, honoring `KRONUZ_YES` / `KRONUZ_NO`);
tealdeer can create and theme its standard seed config automatically when none exists:

- **btop** — links `integrations/btop/Kronuz.theme` into `~/.config/btop/themes/` and
  sets `color_theme = "Kronuz"` in `btop.conf`.
- **yazi** — links `integrations/yazi/theme.toml` into the yazi config dir, plus the
  shared `integrations/themes/Kronuz.tmTheme` so yazi's **code preview** highlights with
  the same Kronuz theme bat uses (`syntect_theme`).
- **tealdeer / tldr** — seeds a missing config automatically; for an existing config,
  asks before backing it up, replacing only its style tables, and setting
  `updates.auto_update = true`. Its interval, archive source, TLS backend, display,
  language, and directory settings remain untouched.

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
`KRONUZ_VIM_NOAUTORC=1` (never). For a transparent editor (inherit your terminal's
background instead of the theme's), set `let g:kronuz_transparent = 1` before
`colorscheme kronuz`.
