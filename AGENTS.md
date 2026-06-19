# AGENTS.md: working on kronuzsh

A thin, prezto-free zsh setup. Read `README.md` for what it is and how to install
it; this file is how to **extend** it without breaking the prompt.

## Design

Own the whole thing, no framework. Everything kept is either mine (the prompt) or
a standalone plugin. The prompt was ported off a prezto theme; its prezto
dependencies were replaced with small native pieces:

| prezto gave | replaced by |
| --- | --- |
| `git-info` + `async` worker | gitstatus (gitstatusd) + a direct-`git` fallback |
| `python-info` (venv) | `_kronuz_venv_segment` ($VIRTUAL_ENV) |
| `editor-info` (keymap) | `_kronuz_keymap_update` (zle hooks) |
| `prompt-pwd` | `${(%):-%~}` in precmd |
| `spectrum` ($col) | the `col` palette is defined inline in `prompt.zsh` |

Dropped from the prezto version: the `async` worker (gitstatusd is the async
engine), `pmodload`/`vcs_info`, and a stray debug `echo >> /tmp/prompt_kronuz` that
ran on every precmd.

## Layout & load order

Entry points are in `runcoms/` (names match their `~/.*` symlink targets);
implementation modules live at the repo root. `install.sh` symlinks
`~/.{zshenv,zprofile,zshrc,zlogin,zlogout}` -> `runcoms/*`, and `$KRONUZSH`
self-resolves from `runcoms/zshrc` via `${(%):-%x}:A:h:h`.

- `runcoms/zshenv` (all shells): env. `runcoms/zprofile` (login): sources
  `~/.profile` for cross-shell env. `runcoms/zshrc` (interactive): the entry that
  sources the modules below. `runcoms/zlogin`: bg-compiles the compdump.
- `runcoms/zshrc` order: `zshenv → options → history → completion → keybindings →
  aliases → terminal → plugins → prompt → prompt_kronuz_setup`, then `setopt
  PROMPT_SUBST`, then `local.zsh` and `~/.zshrc.local`.

The bar for adding anything: keep only the **genuinely useful** part, lean and in
an obviously-named file, and prefer zsh-native over a vendored module (that's why
there's no `safe-paste` module, no `spectrum`, no `terminal` module — the useful
bit of each is a few native lines). Don't re-import prezto's breadth wholesale.

In `plugins.zsh` the order matters: **gitstatus first**, autosuggestions and
history-substring-search next, **fast-syntax-highlighting LAST** (it wraps ZLE
widgets, so anything that defines widgets must come before it).

## The prompt, and how it renders (read before editing `prompt.zsh`)

The prompt is built from deferred strings that are evaluated at every render. Two
things make it work; keep both intact:

1. **`setopt PROMPT_SUBST`** (set in `runcoms/zshrc`, not the prompt module) makes
   the `${(e)...}` inside `$PROMPT` parameter-expand on each display. zshrc also
   sets `PROMPT_PERCENT PROMPT_CR PROMPT_SP`. (These used to ride on prezto's
   `$prompt_opts`, which only `promptinit`'s `prompt` command reads — we call
   `prompt_kronuz_setup` directly, so it's set explicitly in zshrc instead.)
2. **`${(e)...}` resolves the array refs**: each segment embeds `${col[...]}` and
   `${glyph[...]}`, and one `${(e)}` pass at render expands them to the final escape /
   icon (a value that itself holds prompt `%`-escapes, left for `print -P`).

### Colors

- **Base palette**: `col[red]='%F{1}'`, `col[darkorange]='%F{#d75f00}'`, ... (name to
  a zsh color escape). A load-time literal near the top of `prompt.zsh`. The ANSI 0..15
  colors stay `%F{N}` so they track the terminal's theme; the 16..255 colors are
  **hex** `%F{#RRGGBB}` so they render at full 24-bit on a truecolor terminal. The 16
  ANSI names (`$_kronuz_basic`, name→index) are each overridable to a `#RRGGBB`/index via
  `PROMPT_KRONUZ_PALETTE_<NAME>`, applied to `col[]` at the top of `prompt_kronuz_colors`
  (and fed to `dim`'s RGB, see the transient section).
- **Semantic layer**: `prompt_kronuz_colors` works exactly like `prompt_kronuz_glyphs`
  (the two are intentionally symmetric): a local defaults table maps each name to a
  palette colour (`branch '%B$col[white]'`, `host '$col[blue]'`, ...), then one loop
  applies any `PROMPT_KRONUZ_COLOR_<NAME>` override and writes the **resolved** escape
  (`${(e)}` expands the `$col[...]` palette ref) into the same `col[]` array. Recomputed
  every precmd.

So `col[branch]` already holds the final escape; segments embed it deferredly as
`\${col[branch]}` (or read it at runtime via `${(e)col[branch]}`), and any semantic
colour is overridable by exporting `PROMPT_KRONUZ_COLOR_<NAME>` (e.g. in `local.zsh`).
An explicit override colours even in no-colour mode, matching the glyph overrides.

**Truecolor / degradation.** `prompt_kronuz_setup` checks `$COLORTERM`
(`24bit`/`truecolor`) and `$terminfo[colors]`; on a non-truecolor terminal it
`zmodload zsh/nearcolor`, which transparently maps the hex codes to the nearest
256-color (and to the default foreground on 8/16-color terminals, so no broken
escapes). One hex palette therefore covers every tier: truecolor → 256 → 16/8.

**No-color mode.** `prompt_kronuz_precmd` sets two flags each prompt (so they
react live to `export TERM=dumb` / `NO_COLOR=1` and back): `_kronuz_dumb`
(`$TERM` empty/`dumb`/`unknown`) and `_kronuz_nocolor` (dumb **or** `$NO_COLOR`,
the [no-color.org](https://no-color.org) standard). When `_kronuz_nocolor`,
`prompt_kronuz_colors` blanks each name's built-in default (so `col[*]` resolves to
the empty string), so the **full layout still renders with zero escapes**; an explicit
`PROMPT_KRONUZ_COLOR_*` override still colours. When `_kronuz_dumb`,
`prompt_kronuz_glyphs` forces the plain glyph
set (PUA would be tofu). The keymap arrow is seeded in setup so a prompt char shows
even where ZLE is off (Emacs `M-x shell`), where `zle-line-init` never fires.

The **host** color is the `host` semantic color (blue by default). The Eternal
Terminal cue is the separate **etctl** segment (`$ETCTL_SESSION`), not a host-color
change. (The old prezto theme tinted the host by `$ET_VERSION`; that wasn't ported.)

### Glyphs (Nerd Font, with a plain fallback)

`prompt_kronuz_glyphs` builds a global `glyph[<name>]` array, recomputed every
`precmd` (like the colors) so `local.zsh` overrides take effect. It holds two
default tables — a Nerd Font set and a plain-Unicode set — picked by
`PROMPT_KRONUZ_NERD_FONT` (default on; `0`/`no`/`off`/`false` selects the plain
set, which renders in any font via normal fallback). On top of the chosen table,
each glyph is overridable via `PROMPT_KRONUZ_GLYPH_<NAME>` (name upper-cased): set
it to any character, or to `''` to hide it (an empty override is honored, via the
`__KRONUZ_GLYPH_UNSET__` sentinel, not coerced back to the default).

Names: `os branch tag commit remote action clean dirty stashed ahead behind staged
modified conflicted untracked venv vim emacs jobs duration ssh container dot return
overwrite caret caret_alt`. The git/venv/keymap/error segments and the OS segment
all read `$glyph[...]` rather than hard-coding icons. A separate `glyph_pad[<name>]`
holds a trailing space for glyphs wide enough to collide with following text (a
single Private-Use-Area Nerd Font char); plain BMP / character glyphs get none, so
counts/jobs/duration only space out the wide glyphs. The OS glyph is OS-dependent
(apple/Tux by `$OSTYPE`, empty in plain mode); the legacy `_kronuz_os` still works
as a highest-priority override (applied after the loop). Each default codepoint is
in the inline `g=( ... )` tables, with the `nf-*` name or the literal
char in a comment.

### Segments

Each segment is a deferred string `kronuz[x]="${(e)PROMPT_KRONUZ_X:-$DEFAULT_PROMPT_KRONUZ_X}"`,
and `PROMPT`/`RPROMPT` splice the `$kronuz[...]` together. Dynamic data is computed
in `prompt_kronuz_precmd` (pwd, venv, git) into vars the deferred strings read
(`_prompt_kronuz_pwd`, `_kronuz_venv`, `_prompt_kronuz_git`).

Current layout:
`PROMPT = status err info context etctl git venv jobs \n time pwd prompt`
(plus a zero-width OSC 133 "B" mark at the end via `$_kronuz_osc_b`),
`RPROMPT = overwrite vim emacs`. The **status** segment (`_prompt_kronuz_status`,
built in `_kronuz_status_segment`) is the last command's exit code (`⏎<code>` when
nonzero) and duration (when slow) on their own line above the info row, and renders
nothing (no line) on a quick, clean command. Its exit code comes from
`_kronuz_last_exit`, captured first thing in `_kronuz_osc_precmd` (which runs first
among the precmd hooks). `err` is the always-on `●` success/failure dot.

Beyond the deferred segments, a few features hook the line lifecycle:
**command duration** (`preexec` stamps `$EPOCHREALTIME`, precmd formats the delta
into `_prompt_kronuz_duration` when it tops `PROMPT_KRONUZ_CMD_DURATION_MIN`),
**terminal integration** (cross-terminal OSC 7 cwd + OSC 133 marks from
`_kronuz_osc_precmd` / `_kronuz_osc_preexec`, with the OSC precmd ordered first in
`precmd_functions` so the `D` mark carries the real `$?`; in iTerm2,
`$_kronuz_is_iterm`, it also emits the proprietary OSC 1337 ShellIntegrationVersion
/ RemoteHost / CurrentDir), and the **transient prompt** (an accept-line
widget on `^M`/`^J` that swaps to `$_kronuz_transient_prompt` and `reset-prompt`s,
restored in precmd; it also restyles the just-run command per
`PROMPT_KRONUZ_TRANSIENT_STYLE` — `dim` (darken each fg to truecolor hex, since zsh
`region_highlight` has no faint attribute; the 16 ANSI colours' RGB are loaded into
`$_kronuz_pal` by `_kronuz_load_palette`, run once from the **first precmd** (not setup,
so `local.zsh` can configure it): an on-disk cache
(`$XDG_CACHE_HOME/kronuzsh/palette-<term>`, kept `$PROMPT_KRONUZ_PALETTE_TTL`s, per
terminal) else an OSC 4 query `_kronuz_query_palette` (budget
`$PROMPT_KRONUZ_PALETTE_TIMEOUT`, default 0.6s, so a remote/slow link still answers; a
complete 16-colour result is cached), then per-colour `$PROMPT_KRONUZ_PALETTE_<NAME>`
overrides win on top (never cached; if all 16 are set the query is skipped) — falling
back to xterm defaults. The same overrides also re-tint `$col` for those names in
`prompt_kronuz_colors`, so display and dim stay in sync),
`mute` (grey), or `keep`. To win the
final paint over fast-syntax-highlighting it wraps fsh's `_zsh_highlight` once (not a
`zle-line-finish` hook — `add-zle-hook-widget zle-line-finish` recurses once fsh
re-wraps the dispatcher): the wrapper runs fsh, then re-applies our style while the
`_kronuz_muting` flag is set (set at accept, cleared in precmd). fsh rebuilds
`region_highlight` unconditionally on line-finish, so this also covers a buffer fsh
skipped, e.g. a paste). On accept it also keeps a **dimmed copy of the status line**
(`_prompt_kronuz_status_dim`, dimmed per the same style via `_kronuz_dim_col`) above
the collapsed caret, so a failed or slow command leaves a one-line marker in
scrollback while quiet commands collapse to a bare caret. The **jobs** segment is
prompt-native (`%(1j...)`); the
**context** (SSH/container) badge is detected once at setup. All of these are gated
off on dumb terminals.

### Add a segment

1. (if it needs a new color) add a `<name> '$col[...]'` entry to the defaults table in
   `prompt_kronuz_colors`. The loop builds `col[<name>]` and the override automatically;
   the no-color path blanks the default, so nothing terminal-specific is needed.
2. Define `DEFAULT_PROMPT_KRONUZ_<NAME>` (its content; reference `\${col[...]}` and any
   dynamic var). Use `\${...}` to keep `$` deferred, matching the surrounding code.
3. Define `kronuz[<name>]="\${(e)PROMPT_KRONUZ_<NAME>:-\$DEFAULT_PROMPT_KRONUZ_<NAME>}"`.
4. Splice `$kronuz[<name>]` into `PROMPT` or `RPROMPT`.
5. If dynamic, compute its value in `prompt_kronuz_precmd`.

The **etctl** segment (driven by `$ETCTL_SESSION`) and **venv** segment are the
two cleanest examples to copy.

### git segment

`_kronuz_git_segment` queries the `KRONUZ` gitstatusd instance and maps
`VCS_STATUS_*` to the branch/icons. If gitstatusd isn't up (no tty, not installed,
download blocked) it calls `_kronuz_git_fallback`, a lean direct-`git` version, so
the prompt always shows git info. gitstatus only distinguishes counts
(staged/unstaged/untracked/conflicted), not added-vs-deleted-vs-renamed, so the
icon set is a small simplification of the old prezto one.

## Add a plugin

```bash
git submodule add https://github.com/owner/name plugins/name
```
Then `source "$KRONUZSH/plugins/name/name.plugin.zsh"` in `plugins.zsh`, respecting
the load order (fast-syntax-highlighting stays last). Bind keys after sourcing.

## Testing (no real terminal needed for most of it)

- **Syntax**: `zsh -n <file>`.
- **Sandbox** (doesn't touch the real shell):
  `ZDOTDIR=. HISTFILE=/tmp/kz-hist zsh -i`.
- **Render the prompt the real way — in a pty.** The reliable test is an actual
  interactive shell: a fresh `etctl open` to a host where kronuzsh is installed
  shows the live prompt (and starts `gitstatusd`, which needs a tty), or a local
  pty (`script -q /dev/null zsh -i`, or a Python `pty.fork`).
- **Beware the false positive.** `prompt_kronuz_precmd; print -rP -- "${(e)PROMPT}"`
  expands the segments manually with `${(e)}`, which **bypasses `PROMPT_SUBST`** — it
  renders fine even when the live prompt is broken. (This masked two real bugs: a
  missing `setopt PROMPT_SUBST`, and that the prompt is dead without it.) Use it
  only as a quick structural check, never as proof it works.
- **gitstatusd needs a tty** (job control). In a no-tty `zsh -ic` it won't start and
  the fallback runs; test the real daemon in a terminal (or an etctl VM pty).
- The **vi/emacs keymap arrow** (`❯`) is set by a `zle-line-init` hook, so it only
  shows in a live ZLE. To preview it: set `_kronuz_keymap` from the
  `:kronuz:editor:keymap:primary` zstyle and re-render.

## gitstatusd deployment

Downloaded, not compiled: the plugin fetches a prebuilt binary for the platform
into `~/.cache/gitstatus/` on first start (GitHub releases). Nothing is committed.
On a locked-down host where the download is blocked, build once
(`plugins/gitstatus/build -w`, needs cmake + a C++ compiler) or scp the cached
binary over. The prompt's fallback covers the gap meanwhile.

## Commits

- Author as **Germán Méndez Bravo \<german.mb@gmail.com\>** (the public identity).
- No `Co-authored-by: Copilot` trailer. If signing prompts, `git -c commit.gpgsign=false commit`.
