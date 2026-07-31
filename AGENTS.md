# AGENTS.md: working on KronuZSH

A thin, prezto-free zsh setup. Read `README.md` for what it is and how to install
it; this file is how to **extend** it without breaking the prompt.

## Design

Own the whole thing, no framework. Everything kept is either mine (the prompt) or
a standalone plugin. The prompt was ported off a prezto theme; its prezto
dependencies were replaced with small native pieces:

| prezto gave                 | replaced by                                                                                      |
| --------------------------- | ------------------------------------------------------------------------------------------------ |
| `git-info` + `async` worker | gitstatus (gitstatusd) + a direct-`git` fallback                                                 |
| `python-info` (venv)        | `_kz_venv_segment` (`$VIRTUAL_ENV`) and `lib/python.zsh`                                         |
| `editor-info` (keymap)      | `_kz_keymap_update` (zle hooks)                                                                 |
| `prompt-pwd`                | `_kz_pwd_segment` (`${(%):-%~}`, with `KZ_PROMPT_PWD_STYLE` full/short/base/absolute)             |
| `spectrum` (prompt colors)  | `$kz[FG.*]` / `$kz[BG.*]` / `$kz[HL.*]` expose the private palette in prompt/ZLE forms          |

Dropped from the prezto version: the `async` worker (gitstatusd is the async
engine), `pmodload`/`vcs_info`, and a stray debug `echo >> /tmp/prompt_kronuz` that
ran on every precmd.

## Layout & load order

Entry points are in `runcoms/` (names match their `~/.*` symlink targets);
implementation modules live in `lib/`. `install.sh` symlinks
`~/.{zshenv,zprofile,zshrc,zlogin,zlogout}` -> `runcoms/*`, and `$KRONUZSH`
self-resolves from `runcoms/zshrc` via `${(%):-%x}:A:h:h`.
The installer preserves its logical invocation directory in those symlink
targets, so invoking `~/.local/share/KronuZSH/install.sh` through a symlinked
checkout keeps `~/.local/share/KronuZSH/runcoms/*` as the public target path.

The installer has default install plus `--dry-run`, `--force`, `--uninstall`,
and `--help`. Dry-run must not change user files, global Git configuration,
caches, or submodules. Backups mirror their original paths under
`${XDG_STATE_HOME:-$HOME/.local/state}/kronuzsh/backups/<timestamp>/`; do not
put inactive backups beside live configuration because plugin and skill
discovery can mistake them for active content.

- `runcoms/zshenv` (all shells): env. `runcoms/zprofile` (login): sources
  `~/.profile` for cross-shell env. `runcoms/zshrc` (interactive): the entry that
  sources the `lib/` modules below. `runcoms/zlogin`: bg-compiles the compdump.
- `runcoms/zshrc` order: `zshenv → lib/options → lib/history → lib/colors →
  lib/completion → lib/keybindings → lib/aliases → lib/functions → lib/python →
  lib/terminal → lib/plugins → integrations/init → lib/prompt → kz_prompt_setup →
  ~/.zshrc.local → _kz_python_venv_setup`. (`lib/options` globally enables the
  prompt options before setup;
  `lib/colors` sets `$LS_COLORS` before `lib/completion` so the completion menu
  picks it up, plus `$GREP_COLORS`,
  `$LESS_TERMCAP`, and BSD `$LSCOLORS` — see "File colours" below.)

`lib/python.zsh` owns automatic `.venv` activation. Its `chpwd` hook searches upward
for the nearest `.venv/bin/activate` and records only environments it activates in
`$_kz_managed_venv`. Never remove that ownership check: manually activated
environments must not be replaced or deactivated. It defaults
`VIRTUAL_ENV_DISABLE_PROMPT=1` so activate scripts do not duplicate the native venv
segment; an explicitly empty value restores the stock prefix. Setup runs after
`~/.zshrc.local` so `KZ_AUTO_VENV=0` can disable both the hook and initial scan.

The bar for adding anything: keep only the **genuinely useful** part, lean and in
an obviously-named file, and prefer zsh-native over a vendored module (that's why
there's no `safe-paste` module, no `spectrum`, no `terminal` module — the useful
bit of each is a few native lines). Don't re-import prezto's breadth wholesale.

`help` normally shows a shell function's source. If an integration adds a transparent
function wrapper around an external command but users should still see the native
manual, register it as `_kz_help_native[wrapper]=command`. Do this only for hybrid
compatibility wrappers such as `cat`; genuine helpers such as `y` should document their
function implementation.

In `lib/plugins.zsh` the order matters: **gitstatus first**, autosuggestions and
history-substring-search next, **fast-syntax-highlighting LAST** (it wraps ZLE
widgets, so anything that defines widgets must come before it). Autosuggestions uses
`ZSH_AUTOSUGGEST_MANUAL_REBIND`: its first precmd runs after that complete stack is
loaded, binds once, then removes its own precmd hook. Do not move the binding earlier.

## File colours (ls / eza / fd / completion): the vivid pipeline

`lib/colors.zsh` owns the **system-tool** colours (not the per-integration ones, which
live with their tool). It sets `$LS_COLORS` (GNU `ls`, `fd`, `eza`, the completion menu),
`$LSCOLORS`/`$CLICOLOR` (BSD/macOS `ls`), `$GREP_COLORS` (GNU grep), and `$LESS_TERMCAP`
+ `$GROFF_NO_SGR` (man pages). All guarded `${VAR:-...}` so a user export wins, and
cross-platform (each tool reads the var it knows, ignores the rest). It loads **before**
`lib/completion` so the menu's `list-colors` (a lazy `zstyle -e`) picks `$LS_COLORS` up.

`$LS_COLORS` is **not hand-written** — it's a rich, truecolor, 677-entry set (500+ file
types) generated by [**vivid**](https://github.com/sharkdp/vivid) from a Kronuz theme:

```
integrations/vivid/kronuz.yml   the Kronuz vivid theme (palette + category→colour)
        │   vivid generate kronuz
        ▼
integrations/vivid/ls_colors    the generated string, COMMITTED (runtime needs no vivid)
        │   lib/colors.zsh:  export LS_COLORS="${LS_COLORS:-$(< .../ls_colors)}"
        ▼
ls · fd · eza · completion menu
```

Same "generate from a canonical source, commit the output" idea as the editor themes
(`KronuzTheme`). vivid is only needed to **re-generate**; `integrations/vivid/setup.sh`
symlinks the theme into vivid's config dir (when vivid is installed) so you can.

### Editing a colour

1. Edit `integrations/vivid/kronuz.yml` (vivid colours a *category*, e.g. `programming.source`,
   `media.image`, `archives`; a few individual languages are overridden for the source-code
   groups). The `colors:` block maps Kronuz names to hex.
2. **If you touched a `core:` filekind** (directory, symlink, executable, …) also change
   the matching key in `integrations/eza/theme.yml`. They MUST stay in lock-step: eza reads
   `$LS_COLORS` and it **overrides** eza's own `theme.yml` filekinds (precedence
   `$EZA_COLORS > $LS_COLORS > theme.yml > built-in`), so a mismatch makes eza disagree
   with `ls`/`fd`/the menu. (This bit us already: `symlink`, and `multi_link_file` vs `mh`.)
3. Regenerate and commit the result:
   ```sh
   cp integrations/vivid/kronuz.yml ~/.config/vivid/themes/kronuz.yml   # (no-op if setup.sh symlinked it)
   vivid generate kronuz > integrations/vivid/ls_colors
   ```

### The colour scheme (the rules behind it)

- **Filekinds match eza** and are the structural layer. Their ANSI slots let the terminal
  own the final RGB while preserving distinct kinds. The RGB column records the future
  iTerm palette target; until that palette is updated, the terminal's current colors win:

  | Slot | Target RGB | Filekind / prompt use |
  | --- | --- | --- |
  | red (1) | `#da4939` | broken links, prompt errors |
  | green (2) | `#a5c261` | executables, prompt success |
  | blue (4) | `#6e9cbe` | directories, mount points, local host and pwd |
  | cyan (6) | `#70c2ba` | symlinks |
  | gray / ANSI white (7) | `#c8c6c5` | ordinary files |
  | dark gray (8) | `#7a7775` | pipes, sockets, subdued prompt text |
  | light yellow (11) | `#cc7833` | block and character devices |
  | light cyan (14) | `#4fa8b0` | hard links (`mh`; eza's link-count column) |
- **Content categories avoid the filekind hues**, so a file's kind is never ambiguous.
  Source code is split into a few groups (general/systems **gold**, scripting **purple**,
  functional **teal**); markup pink, config amber, the three media types distinct, office
  lime, archives red, junk/backup muted gray.
- **vivid matches the most-specific pattern**, so a whole filename beats an extension:
  `README.md`/`CHANGELOG`/`TODO` (vivid's `text.special`/`text.todo`) render orange-bold
  as repo landmarks, `LICENSE`/`COPYING` (`text.licenses`) muted gray, and any *other*
  `.md` falls through to markup pink. Three `.md` files can legitimately be three colours.
- Same-colour overlaps are deliberate and semantically correct: executable extensions
  (`.dll`, `.bat`) share the exec green; build/junk (`.bak`, `.cache`) share the muted gray.



The prompt is built from deferred strings that are evaluated at every render. Two
things make it work; keep both intact:

1. **`setopt PROMPT_SUBST`** (set globally in `lib/options.zsh`, not inside the
   locally scoped prompt setup function) makes the `${(e)...}` inside `$PROMPT`
   parameter-expand on each display. The same Prompt section also sets
   `PROMPT_PERCENT PROMPT_CR PROMPT_SP`. (These used to ride on prezto's
   `$prompt_opts`, which only `promptinit`'s `prompt` command reads — we call
   `kz_prompt_setup` directly, so they are set explicitly in `lib/options.zsh`.)
2. **`${(e)...}` resolves the `$kz` refs**: each segment embeds presentation keys
   such as `${kz[FG.red]}` and `${kz[GLYPH.caret]}`, plus content keys such as
   `${kz[git.branch]}`, and one `${(e)}` pass at render expands them to the final
   escape / icon / value (a value that itself holds prompt `%`-escapes, left for
   `print -P`).

### Colors

`kz_prompt_colors` builds two internal palettes, then exposes the public
presentation keys in `$kz`:

- **Base hue palette (`$_kz_col_base`)**: private bare zsh colour codes such as
  `red='1'` and `darkorange='#d75f00'` (no `%F` / `%K`). The ANSI 0..15 colors stay indexes so they
  track the terminal's theme; the 16..255 colors are **hex** `#RRGGBB` so they render at
  full 24-bit on a truecolor terminal. `KZ_PROMPT_PALETTE_<NAME>` defines or
  overrides any non-retired hue, not just the 16 ANSI basics, and feeds both display and `dimmed`'s RGB
  (see the transient section). The engine publishes each hue as `$kz[FG.<name>]` and
  `$kz[BG.<name>]` for prompt text, plus `$kz[HL.<name>]` as zsh's native
  `region_highlight` foreground spec for ZLE buffers; the mutable raw-code palette is
  function-local and never exposed.
  Theme-relative neutral colors use conventional ANSI names: `gray` (7), `darkgray` (8),
  and `white` (15). `lightgray` remains the fixed `#c6c6c6`; no `grey` or `dimgray`
  aliases are published.
- **Semantic palette (`$_kz_sem`)**: a local defaults table maps each role to a full style
  expression (`branch '%B$kz[FG.white]'`, with `host` and `pwd` selected from the
  public session-context keys), then one loop
  applies any `KZ_PROMPT_COLOR_<ROLE>` override and writes the **resolved** style
  (`${(e)}` expands the `$kz[FG.*]` refs) into `$_kz_sem[<role>]`. Recomputed every precmd.

So `$_kz_sem[branch]` holds the final style for branch text, segments embed it deferredly
as `\${_kz_sem[branch]}` (or read it at runtime via `${(e)_kz_sem[branch]}`), and any
semantic role is overridable by setting `KZ_PROMPT_COLOR_<ROLE>` (e.g. in
`~/.zshrc.local`). Semantic roles are not hues; `branch` lives in `$_kz_sem`, not in a
public foreground key. An explicit semantic override colours even in no-colour mode,
matching glyph overrides.

**Background keys (`$kz[BG.*]`).** Backgrounds wrap the same private neutral hue codes as
foregrounds: the public `$kz[FG.blue]` and `$kz[BG.blue]` hold complete `%F{...}` /
`%K{...}` expressions. No string replacement is involved. A powerline/agnoster-style skin sets segment backgrounds
with `${kz[BG.blue]}` etc. The default prompt uses no backgrounds; semantic roles stay
in `$_kz_sem` and are not exposed as background hues.

**Truecolor / degradation.** `kz_prompt_setup` checks `$COLORTERM`
(`24bit`/`truecolor`) and `$terminfo[colors]`; on a non-truecolor terminal it
`zmodload zsh/nearcolor`, which transparently maps the hex codes to the nearest
256-color (and to the default foreground on 8/16-color terminals, so no broken
escapes). One hex palette therefore covers every tier: truecolor → 256 → 16/8.

**No-color mode.** `kz_prompt_precmd` sets two flags each prompt (so they
react live to `export TERM=dumb` / `NO_COLOR=1` and back): `_kz_dumb`
(`$TERM` empty/`dumb`/`unknown`) and `_kz_nocolor` (dumb **or** `$NO_COLOR`,
the [no-color.org](https://no-color.org) standard). When `_kz_nocolor`,
`kz_prompt_colors` blanks the public presentation keys (`kz[FG.green]`,
`kz[BG.green]`, `kz[HL.green]`, ...) and the semantic defaults in `$_kz_sem`, so the
**full layout renders with zero escapes** and both prompt text and transient ZLE styling
react live. A skin built on `${kz[FG.*]}` / `${kz[BG.*]}` is no-colour-safe for free.
An explicit
`KZ_PROMPT_COLOR_*` override still colours. When `_kz_dumb`,
`kz_prompt_glyphs` forces the plain glyph
set (PUA would be tofu). The keymap arrow is seeded in setup so a prompt char shows
even where ZLE is off (Emacs `M-x shell`), where `zle-line-init` never fires.

The **host** and **pwd** colors encode the fixed session context: blue locally,
green/mediumspringgreen over SSH, and purple/violet in a
container (which wins when both flags are set); root keeps the pwd tomato. The Eternal
Terminal cue is the separate **etctl** segment (`$ETCTL_SESSION`), not a host-color
change. (The old
prezto theme tinted the host by `$ET_VERSION`; that wasn't ported.)

### Glyphs (Nerd Font, with a plain fallback)

`kz_prompt_glyphs` fills `$kz[GLYPH.<name>]`, recomputed every
`precmd` (like the colors) so `~/.zshrc.local` overrides take effect. It holds two
default tables — a Nerd Font set and a plain-Unicode set — picked by
`KZ_PROMPT_NERD_FONT` (default on; `0`/`no`/`off`/`false` selects the plain
set, which renders in any font via normal fallback). On top of the chosen table,
each glyph is overridable via `KZ_PROMPT_GLYPH_<NAME>` (name upper-cased): set
it to any character, or to `''` to hide it (an empty override is honored, via the
`__KRONUZ_GLYPH_UNSET__` sentinel, not coerced back to the default).

Names: `os branch tag commit remote host_github host_gitlab host_bitbucket action fallback
clean dirty stashed ahead behind push_ahead push_behind staged modified added changed deleted
conflicted untracked unknown loading venv vim emacs jobs duration ssh container status_dot
exit mode_overwrite caret caret_alternate`. The git/venv/keymap/status segments and the OS segment
all read `$kz[GLYPH.*]` rather than hard-coding icons. A separate `_kz_glyph_pad[<name>]`
holds a trailing space for glyphs wide enough to collide with following text (a
single Private-Use-Area Nerd Font char); plain BMP / character glyphs get none, so
counts/jobs/duration only space out the wide glyphs. The OS glyph is OS-dependent
(apple/Tux by `$OSTYPE`, empty in plain mode); the legacy `_kz_os` still works
as a highest-priority override (applied after the loop). Each default codepoint is
in the inline `g=( ... )` tables, with the `nf-*` name or the literal
char in a comment.

### Segments

Each segment is a deferred string `kz[x]="${(e)KZ_PROMPT_X:-$DEFAULT_KZ_PROMPT_X}"`,
and `PROMPT`/`RPROMPT` splice the `$kz[...]` together. Dynamic data is computed
in `kz_prompt_precmd` into private vars for pwd/venv (`_kz_prompt_pwd`,
`_kz_prompt_venv`) and into `$kz[git.*]` for git state.

Current layout:
`PROMPT = status_dot identity context etctl git venv jobs NL time pwd caret`
(plus OSC 133 `A`/`B` marks around the editable prompt). Above `PROMPT` sits the
**preprompt** (`KZ_PROMPT_PREPROMPT`), a fourth deferred layout knob (alongside
`PROMPT`/`RPROMPT`/`TRANSIENT_PROMPT`) that is printed as ordinary output above the prompt,
once per command in precmd (`_kz_preprompt_print`, last in `kz_prompt_precmd`). Its default
is `$kz[status]` (the exit code + duration line); `KZ_PROMPT_PREPROMPT=''` prints nothing, and
a skin/user can inject anything. Because it is output — not part of `PROMPT` — a reset-prompt
redraw and the transient collapse never touch it. With transience on, the live
prompt is marked so the `A` immediately following `D;<status>` finalizes the previous
command's status and running time; accepting a command or blank line collapses the prompt
to its time/pwd/caret and emits fresh `A`/`B` around it. The already-printed preprompt stays
in scrollback on its own (not re-emitted and not erased). With
transience off, one-shot `A`/`B` markers permanently bracket only the editable final
prompt: the preprompt is shown above it by default (and empty when
`KZ_PROMPT_PREPROMPT=''`), adjacent `D;<status>` / `A` follow the preprompt and
precede the context row, and `B` ends the editable final line. `zle-line-init` clears
all three before its same-layout repaint and later keymap redraws. This avoids
extra/misplaced marks.
`RPROMPT = mode_overwrite vim emacs`. The **status** segment (`_kz_status_segment`) computes the
last command's exit code (`⏎<code>` when nonzero) and duration (when slow) into the public
`$kz[status]` content key (empty on a quick, clean command), with raw state in
`$kz[status.exit]` and `$kz[status.duration]`; the preprompt prints it above the identity
row by default. Because the preprompt is emitted as output rather than a
line of `PROMPT`, ZLE's prompt line count excludes it, so iTerm2's Clear Buffer (Cmd-K) —
which erases everything above the prompt mark, including the status row — cannot desync the
next redraw or resurrect the status when the following command runs. Its exit code comes from
`_kz_prompt_last_exit`, captured first thing in `_kz_osc_precmd` (which runs first
among the precmd hooks). `status_dot` is the always-on `●` success/failure dot.

`kz_prompt_setup` composes the defaults and final prompt strings. Keep side effects
out of that composition: `_kz_setup_lifecycle` owns hook/widget registration, and
`_kz_setup_transient_widgets` owns the accept-line bindings plus syntax-highlighter
bridge. Transient colour math belongs with the transient lifecycle (`_kz_dim_rgb` /
`_kz_dim_string`), not inside an individual segment renderer.

Before changing OSC 133 placement around the transient prompt, read
`iterm-transient-prompt-experiments.md`. It records the marker arrangements already
tested in the real iTerm UI, including several byte-correct sequences that still
produced duplicate blue triangles. Continue with the controlled raw-stream and ZLE
matrix in `iterm-transient-prompt-test-plan.md`, not ad hoc prompt edits.

For prompt lifecycle refactors, run `dev/check-prompt-streams.zsh <reference-tree>`.
It drives fresh interactive ZLE sessions through failure, success, blank Enter, and
exit in six modes: transient/static/disabled integration across iTerm and generic
terminal paths. It normalizes only fixed machine/time/root values, then compares every
remaining visible and control byte with `cmp`.

Beyond the deferred segments, a few features hook the line lifecycle:
**command duration** (`preexec` stamps `$EPOCHREALTIME`, precmd formats the delta
into `_kz_prompt_duration` when it tops `KZ_PROMPT_CMD_DURATION_MIN`),
**terminal integration** (universal OSC 7 cwd + cross-terminal OSC 133
marks from
`_kz_osc_precmd` / `_kz_osc_preexec`, with the OSC precmd ordered first in
`precmd_functions` so the `D` mark carries the real `$?`; a separate
`$_kz_osc_command_active` flag ensures a blank Enter emits a fresh prompt mark but
not a spurious `D;0` command completion (and a companion `$_kz_osc_line_submitted`
flag lets a line zsh rejects at parse time still get its `D` — see **Parse-reject
marks** below); the per-prompt host/cwd reports — `RemoteHost`, `CurrentDir`, OSC 7 (cwd) —
ride a dedicated zero-width `_kz_osc_ctx`, spliced immediately before the `133;A` mark
(`_kz_osc_a`), so the byte order is `RemoteHost`, `CurrentDir`, OSC 7, `133;A`. Both vars are
set in precmd and cleared in `zle-line-init` (with `_kz_osc_d`/`_kz_osc_b`), so each fires
once per prompt and never on keymap redraws — essential because OSC 7 and `133;A` are prompt-
mark producers in iTerm2, and re-emitting them on a `reset-prompt` would drop duplicate
triangles (this is also why they are *not* baked into `PROMPT`, which re-renders on every
redraw). Positioning the reports after the status row keeps OSC 7's directory mark on the
`133;A` line where it collapses into the single prompt mark instead of dropping a second
triangle on the status row, and keeps `RemoteHost`/`CurrentDir` adjacent to (and before) the
mark exactly as iTerm2's own script emits them, so the mark binds to the new cwd.
The OSC 1337 reports plus the `ShellIntegrationVersion` handshake (announced once from
precmd) are sent to *every* terminal, exactly as iTerm2's own integration script does:
iTerm2 acts on them (per-host history/dirs, profile switching, scp, and remote cwd, since
it ignores an OSC 7 path whose host is not local), and every other terminal ignores the
proprietary OSC 1337. That is deliberate — it means the integration keeps working across
ssh/et, where the transport strips `LC_TERMINAL`/`TERM_PROGRAM` and iTerm2 cannot be
detected at all (`%n@%M` still resolves to the remote `user@FQDN` iTerm2 expects). OSC 7 is
near-universal (only Alacritty ignores it) and covers cwd for terminals that do not read
1337 `CurrentDir`. The only byte still gated on the terminal is the CR-terminated
`133;C;\r` command form — an inline `TERM_PROGRAM==iTerm.app || LC_TERMINAL==iTerm2` check
in `_kz_osc_preexec` (a bare CR is a real control byte other terminals should not get;
`LC_TERMINAL` is kept because it survives ssh forwarding), degrading to plain `133;C`
elsewhere. All protocols are gated by
`KZ_PROMPT_TERMINAL_INTEGRATION`, and the announcement happens once on the
first enabled precmd so `~/.zshrc.local` can opt out), and the **transient prompt** (an accept-line
widget on `^M`/`^J` that swaps `$PROMPT` to the resolved
`${(e)KZ_PROMPT_TRANSIENT_PROMPT-$DEFAULT_KZ_PROMPT_TRANSIENT_PROMPT}` and `reset-prompt`s,
wrapping the collapsed redraw in fresh OSC 133 `A`/`B` boundaries so iTerm2 keeps the
command mark and its eventual `D;<status>` attached to the relocated prompt,
restored in precmd; configured symmetrically to the live prompt — `KZ_PROMPT_TRANSIENT_PROMPT`
is the whole string like `PROMPT`, `KZ_PROMPT_CARET_PAST` is just the caret piece
like `KZ_PROMPT_CARET`, both deferred `${...}` strings re-evaluated per accept. By
default it leaves the **submission time + pwd + caret** in scrollback so history shows
when and where each command ran — reusing `$kz[time]` and `$_kz_prompt_pwd` so it honors
`KZ_PROMPT_TIME` and `KZ_PROMPT_PWD_STYLE`, in the live
`pwd` colour (so it matches the prompt and honours `KZ_PROMPT_COLOR_PWD`); the caret
piece defaults to `caret_past`. `''` disables transience. The whole resolved line — pwd,
caret, and a custom `KZ_PROMPT_TRANSIENT_PROMPT` alike — is restyled by `_kz_dim_string`
(the general string dimmer; `_kz_dim_col` is a thin by-name wrapper) along with the
just-run command, per `KZ_PROMPT_TRANSIENT_STYLE` — `dimmed` (darken each fg to truecolor
hex, since zsh
`region_highlight` has no faint attribute; the 16 ANSI colours' RGB are loaded into
`$_kz_pal` by `_kz_load_palette`, run once from the **first precmd** (not setup,
so `~/.zshrc.local` can configure it): an on-disk cache
(`$XDG_CACHE_HOME/kronuzsh/palette-<term>`, kept `$KZ_PROMPT_PALETTE_TTL`s, per
terminal) else an OSC 4 query `_kz_query_palette` (budget
`$KZ_PROMPT_PALETTE_TIMEOUT`, default 0.6s, so a remote/slow link still answers; a
complete 16-colour result is cached), then per-colour `$KZ_PROMPT_PALETTE_<NAME>`
overrides win on top (never cached; if all 16 are set the query is skipped) — falling
back to xterm defaults. The same overrides feed the private live palette and the
`$kz[FG.*]` / `$kz[BG.*]` / `$kz[HL.*]` forms in `kz_prompt_colors`, so prompt display,
flat ZLE styling, and dim stay in sync),
any palette hue as a flat style (`darkgray`/ANSI 8, `gray`/ANSI 7, `pink`, or a custom
name), or `original` (the default). Unknown values are reported once and fall back to
`original`.
Flat styles consume the same
live palette through `$kz[FG.<name>]` for the prompt and zsh-native
`$kz[HL.<name>]` (`fg=<code>`) for the submitted command, so palette overrides and
`NO_COLOR` affect both together. To win the
final paint over fast-syntax-highlighting it wraps fsh's `_zsh_highlight` once (not a
`zle-line-finish` hook — `add-zle-hook-widget zle-line-finish` recurses once fsh
re-wraps the dispatcher): the wrapper runs fsh, then re-applies our style while the
`_kz_muting` flag is set (set at accept, cleared in precmd). fsh rebuilds
`region_highlight` unconditionally on line-finish, so this also covers a buffer fsh
skipped, e.g. a paste). The preprompt (status by default) is printed as output above the
prompt when the command finishes, and simply stays in scrollback as the prompt collapses
(never re-emitted). It stays before the next `A`, so iTerm
keeps the gutter triangle on the pwd/caret row; consequently, iTerm's “Select Output of
Last Command” includes the status line because it bounds output by the next prompt mark
rather than by `D`. Blank Enter emits a fresh `A`/`B`
prompt boundary, but no `C`/`D`, so command navigation remains distinct.
`KZ_PROMPT_PREPROMPT=''` prints nothing above the prompt (the way to hide the default status
line); there is no separate live-only sub-mode, since emitting the preprompt as output
means shown and kept are the same thing. The **jobs** segment is
prompt-native (`%(1j...)`); the
**context** (SSH/container) badge is detected once at setup. All of these are gated
off on dumb terminals.

**Parse-reject marks.** `preexec` fires only for a command that actually runs, so a
line zsh rejects while *parsing* (structurally complete but invalid) would otherwise
emit no `D` — a consumer that tracks command boundaries over OSC 133 (a terminal's
command navigation, or an agent driving the shell) sees the failed line silently
swallowed. The accept-line widget records that a non-empty line was submitted
(`$_kz_osc_line_submitted`); when `_kz_osc_precmd` then runs with no `C` opened
(`$_kz_osc_command_active == 0`) and it was not a Ctrl-C abort (`$? != 130`), it
emits the closing `D;<status>` itself:

```zsh
% done      # complete token, invalid here → zsh: parse error near `done'
#           → still emits OSC 133 D;1 (a boundary + exit status for the failed line)
```

It deliberately leaves two cases unmarked: a **blank Enter** (no buffer, so no flag) and
a **Ctrl-C on an unfinished line** (`(( 1 +` then `^C` → `$? == 130`, which ran nothing).
An *incomplete* line (unbalanced quote / paren / heredoc) parks at a continuation prompt
and correctly has no `D` until it is finished or aborted. Note this closes the mark for a
human fat-fingering syntax; a wrapper that always submits a valid outer command (e.g.
`eval "$(cat <<'EOF' … EOF)"`) already gets a clean `C`/`D;<status>` because its body's
parse error happens at *runtime* inside the valid `eval`.

### Add a segment

1. (if it needs a new semantic style) add a `<role> '$kz[FG.<hue>]'` entry to the
   defaults table in `kz_prompt_colors`. The loop writes `$_kz_sem[<role>]` and
   wires the `KZ_PROMPT_COLOR_<ROLE>` override automatically; the no-color path
   blanks the default, so nothing terminal-specific is needed.
2. Define `DEFAULT_KZ_PROMPT_<NAME>` (its content; reference `\${_kz_sem[<role>]}`,
   `\${kz[GLYPH.<name>]}`, and any dynamic var). Use `\${...}` to keep `$` deferred,
   matching the surrounding code.
3. Define `kz[<name>]="\${(e)KZ_PROMPT_<NAME>:-\$DEFAULT_KZ_PROMPT_<NAME>}"`.
4. Splice `$kz[<name>]` into `PROMPT` or `RPROMPT`.
5. If dynamic, compute its value in `kz_prompt_precmd`.

The **etctl** segment (driven by `$ETCTL_SESSION`) and **venv** segment are the
two cleanest examples to copy.

### git segment

`_kz_git_segment` queries the `KRONUZ` gitstatusd instance and maps
`VCS_STATUS_*` to the branch/icons. If gitstatusd isn't up (no tty, not installed,
download blocked) it calls `_kz_git_fallback`, a lean direct-`git` version, so
the prompt always shows git info. That path renders `$kz[GLYPH.fallback]` with
`$_kz_sem[fallback]`, making synchronous fallback visible without warning in the healthy
daemon path. gitstatus only distinguishes counts
(staged/unstaged/untracked/conflicted), not added-vs-deleted-vs-renamed, so the
icon set is a small simplification of the old prezto one.

The fallback's git binary is overridable via `KZ_PROMPT_GIT_CMD` (default
`command git`); point it at a wrapper, or a fake for previews/tests (`dev/fake-git`).

**Git state for skins.** Both render paths also populate a normalized set of
`$kz[git.*]` keys (`$kz[git.repo]`, `$kz[git.branch]`, `$kz[git.tag]`,
`$kz[git.commit]`, `$kz[git.detached]`, `$kz[git.action]`, `$kz[git.clean]`,
`$kz[git.dirty]`, `$kz[git.staged]`,
`$kz[git.unstaged]`, `$kz[git.untracked]`, `$kz[git.conflicted]`, `$kz[git.stashed]`,
`$kz[git.ahead]`, `$kz[git.behind]`, `$kz[git.remote]`) — each a string, empty when
absent/zero. `_kz_git_reset_state` clears them, and they're reset in the no-repo
path. A `KZ_PROMPT_GIT` override composes them declaratively
(`${kz[git.branch]:+...}`), so a skin reshapes git with no hook of its own and it works
under gitstatusd and the fallback alike. Inside a `${var:+...}` conditional, colour with
`${kz[FG.name]}`, never a literal `%F{...}` (a bare `}` ends the conditional early).
Other normalized content state includes `$kz[status]` (the inline styled failed-exit /
slow-command line, empty on a clean fast command; it is the preprompt's default content —
`KZ_PROMPT_PREPROMPT='$kz[status]'` — and a skin can drop it elsewhere, e.g. into
`KZ_PROMPT_RPROMPT` with `KZ_PROMPT_PREPROMPT=''` so it is not also printed above; see
`skins/status-right.zsh`), `$kz[status.exit]`, `$kz[status.duration]`,
`$kz[venv.name]`,
`$kz[context.ssh]`, and `$kz[context.container]`. The context keys are fixed at
setup; both may be `1` for an SSH session inside a container.
Skins must consume these public keys rather than private `$_kz_*` engine state;
`dev/check-skins.zsh` enforces that boundary.

### Skins

The whole visible layout is deferred and overridable end to end, so a skin reshapes the
prompt with no rebuild. Four knobs, each a `${...}` string re-evaluated every render:

- `KZ_PROMPT_PREPROMPT` — ordinary output above the prompt (default `$kz[status]`).
- `KZ_PROMPT_PROMPT` — the live left prompt (one line, or two via `$kz[NL]`).
- `KZ_PROMPT_RPROMPT` — the right prompt.
- `KZ_PROMPT_TRANSIENT_PROMPT` — the collapsed scrollback prompt (`''` disables transience).

`DEFAULT_KZ_PROMPT_PROMPT`/`RPROMPT`/`TRANSIENT_PROMPT` hold the built-in layout; a skin sets the
non-`DEFAULT_` ones from `~/.zshrc.local` (sourced after `kz_prompt_setup`, so it
takes effect at the next render). It composes the unified `$kz` array:

- **UPPERCASE keys are presentation**: `$kz[FG.red]`, `$kz[BG.blue]`,
  `$kz[HL.gray]` (native ZLE `region_highlight` syntax), `$kz[BOLD]`,
  `$kz[UNDERLINE]`, `$kz[STANDOUT]`, `$kz[RESET]`, `$kz[NL]`, and glyphs like
  `$kz[GLYPH.caret]`.
- **lowercase keys are content**: bare segment handles such as `$kz[git]`, `$kz[pwd]`,
  `$kz[caret]`, `$kz[caret_past]`, plus live state such as `$kz[git.branch]` and
  `$kz[status.exit]`.

Normal prompt escapes still work. PROMPT/RPROMPT are the layout that arranges the pieces.
For custom RGB, define `KZ_PROMPT_PALETTE_OCEAN='#3a7bd5'` and use
`${kz[FG.ocean]}` / `${kz[BG.ocean]}`. The engine blanks those keys in `NO_COLOR`; raw
`%F{#...}` / `%K{#...}` does not, and raw braces break inside `${var:+...}` conditionals.

Why it resolves: `PROMPT` wraps the chosen layout in a doubled `${(e)${(e)...}}` so one
PROMPT_SUBST pass evaluates both levels — first the layout string, then the
`$kz[...]` segments it names (a single `(e)` would leave the segments literal). The
OSC 133 `A`/`B`/`D` marks and the status line stay wrapped around whatever the skin
renders, so terminal integration survives any skin.

Bundled skins live in `skins/` (see `skins/README.md`). **Verify every skin** with
`dev/preview-skin.py` (below) — a broken layout can silently drop the integration marks.
For a change that reshapes the engine or palette but should leave rendering untouched (a
rename, a refactor), run the **byte-identical oracle** `dev/skin-oracle.sh` before and
after: the digest must match and all 9 layouts must stay `OSC ... PASS` (see dev/ below).

## Add a plugin

```bash
git submodule add https://github.com/owner/name plugins/name
```
Then `source "$KRONUZSH/plugins/name/name.plugin.zsh"` in `lib/plugins.zsh`, respecting
the load order (fast-syntax-highlighting stays last). Bind keys after sourcing.

## Backing up user files

Integration setup uses the small managed-file API in `install.lib.sh`. A descriptor
keeps its human label and paths together; expand it quoted when calling a helper:

```bash
local -a theme=("yazi theme" "$source" "$destination")
kz_managed_link_active "${theme[@]}"
kz_manage_link "${theme[@]}"

local -a config=("yazi config" "$config_path")
kz_commit_file "${config[@]}" "$replacement"
kz_manage_file "${config[@]}"   # on a later run when already active
```

`kz_manage_link` is the ownership boundary for symlinks: it is idempotent, backs up a
conflict, installs the link, and registers the destination. Do not call `ln` directly.
For config rewrites, prepare a complete temporary replacement and pass it to
`kz_commit_file`: it creates the parent directory, backs up the old file, atomically
installs the replacement, and registers the result. Do not move a replacement into a
user path directly. A setup step that writes through an external tool (for example
`git config` or a cache builder) MUST call `kz_manage_file <label> <path>` after
confirming the result exists. Use `kz_script_dir "${BASH_SOURCE[0]:-$0}"` rather than
repeating the physical-directory resolution expression.

The registry is deliberately ephemeral: every active integration rebuilds it on every
run, and `integrations/setup.sh` renders it once for `--files`, together with all sibling
`<file>.YYYYMMDDhhmmss.kronuzsh.bak` recovery points. Never invent a backup filename or
call `kz_backup` from an integration. The shared `--no-backup` policy belongs solely to
the managed helpers.

Wrap each sourced setup script in one `_kz_setup_<tool>` function, use descriptive
`local` variables and arrays inside it, then call and `unset -f` the function. This keeps
one integration's temporary state from leaking into the next.

## Testing (no real terminal needed for most of it)

- **Syntax**: `zsh -n <file>`.
- **Sandbox** (doesn't touch the real shell):
  `ZDOTDIR=. HISTFILE=/tmp/kz-hist zsh -i`.
- **Render the prompt the real way — in a pty.** The reliable test is an actual
  interactive shell: a fresh `etctl open` to a host where KronuZSH is installed
  shows the live prompt (and starts `gitstatusd`, which needs a tty), or a local
  pty (`script -q /dev/null zsh -i`, or a Python `pty.fork`).
- **Beware the false positive.** `kz_prompt_precmd; print -rP -- "${(e)PROMPT}"`
  expands the segments manually with `${(e)}`, which **bypasses `PROMPT_SUBST`** — it
  renders fine even when the live prompt is broken. (This masked two real bugs: a
  missing `setopt PROMPT_SUBST`, and that the prompt is dead without it.) Use it
  only as a quick structural check, never as proof it works.
- **gitstatusd needs a tty** (job control). In a no-tty `zsh -ic` it won't start and
  the fallback runs; test the real daemon in a terminal (or an etctl VM pty).
- The **vi/emacs keymap arrow** (`❯`) is updated by a `zle-line-init` hook in live
  ZLE. To preview it without ZLE, resolve `KZ_PROMPT_CARET_PRIMARY` (or its
  `DEFAULT_` counterpart) into `_kz_prompt_caret` and re-render.

### dev/ (contributor tooling)

Not shipped to users — harnesses for working on the prompt, kept in `dev/`. All run
headlessly (a pty or `expect`), so none needs a real terminal. Reach for these before
hand-rolling a new capture script:

- **`dev/preview-skin.py [SKIN...]`** — render a skin (or the built-in layout, with no
  arg) in a throwaway, fully isolated shell and print its PROMPT / RPROMPT / transient as a
  readable, ANSI-stripped preview (`--raw` also dumps the raw bytes). It then asserts the
  OSC 133 `A`/`B`/`C`/`D` shell-integration marks and iTerm's OSC 1337 survive the skin,
  **exiting non-zero if a skin breaks integration**. Loads only the prompt engine (fast,
  no `compinit`), announces iTerm so the iTerm path is exercised, and drives the shell
  event-driven (waiting on the ZLE-ready and OSC marks, not fixed sleeps) so it's quick.
  It sources `dev/fake-gitstatus.zsh` so the git segment renders synchronously from a
  fixed snapshot (deterministic, no daemon); `--fallback` instead exercises the
  direct-git fallback with `dev/fake-git`. Run it on any skin or prompt-rendering change.
- **`dev/skin-oracle.sh`** — the **byte-identical oracle**. Renders the default layout
  plus every skin in `--raw`, keeps the raw-escape and OSC lines, and normalises the wall
  clock to `[TIME]`, producing a stable digest of exactly what each of the 9 layouts paints
  (colours, attributes, glyphs, segment structure) and each one's OSC 133 A/B/C/D + iTerm
  1337 verdict. **Run it around any change to `lib/prompt.zsh` or the skins that is meant
  to _preserve_ rendering** — a palette/array rename or refactor (this is how the `$kz`
  unification was proven), a colour/glyph reshuffle, a segment tweak:
  ```bash
  dev/skin-oracle.sh > /tmp/before.txt      # baseline first
  # ... make the change ...
  dev/skin-oracle.sh > /tmp/after.txt
  diff /tmp/before.txt /tmp/after.txt && echo "byte-identical"
  ```
  A pure refactor MUST leave the digest byte-identical (same sha, printed to stderr with the
  OSC tally); every layout must report `PASS`, and the script exits non-zero if any doesn't.
  A behavioural change shows up as a precise, inspectable diff. It pairs with
  `dev/check-prompt-streams.zsh` (below): the oracle covers *what every skin paints*,
  check-prompt-streams covers *the lifecycle/OSC protocol across modes*.
- **`dev/fake-gitstatus.zsh`** — a fake gitstatus (stubs `gitstatus_check` / `_query` /
  `_start` over a fixed `VCS_STATUS_*` snapshot) so a preview shell renders the git
  segment through the real daemon-path render, instantly and identically, with no daemon
  or repo. Edit the snapshot to preview other repo states.
- **`dev/fake-git`** — a fake `git` answering only the queries the direct-git fallback
  makes, with a fixed dirty-repo state; used via `KZ_PROMPT_GIT_CMD` (see
  `preview-skin.py --fallback`) to preview/test the fallback path with no repo on disk.
- **`dev/check-prompt-streams.zsh <reference-tree>`** — golden regression. Drives fresh
  ZLE sessions through failure / success / blank-Enter / exit in six modes
  (transient/static/disabled × iTerm/generic) for both a reference tree and this
  checkout, then `cmp`s every byte that isn't time/host/root. Run it for any
  prompt-lifecycle or OSC refactor. Uses the two helpers below.
- **`dev/capture-prompt-stream.exp OUTPUT SCENARIO [ROOT]`** — the `expect` harness that
  captures one real interactive scenario's raw byte stream (one fresh shell per case so
  OSC state cannot leak between them).
- **`dev/normalize-prompt-stream.zsh IN OUT [ROOT]`** — replaces only the values that
  must vary between runs (wall-clock time, host, repo root) while preserving every
  control byte, so a protocol or cursor-motion change still fails the golden compare.
- **`dev/check-integrations.sh`** — sanity-checks the external-tool integration wiring
  (also referenced from `CONTRIBUTING.md`).
- **`dev/check-auto-venv.zsh`** — exercises nearest-parent discovery, nested
  environment switching, shell restoration, manual-environment ownership, and opt-out.
- **`dev/check-prompt-namespace.zsh`** — guards the prompt's public/private variable
  boundary, including cleanup of the old `$col` palette on re-source. CI runs it on
  macOS and Linux.

## gitstatusd deployment

Downloaded, not compiled: the plugin fetches a prebuilt binary for the platform
into `~/.cache/gitstatus/` on first start (GitHub releases). Nothing is committed.
On a locked-down host where the download is blocked, build once
(`plugins/gitstatus/build -w`, needs cmake + a C++ compiler) or scp the cached
binary over. The prompt's fallback covers the gap meanwhile.

## Commits

- Author as **Germán Méndez Bravo \<german.mb@gmail.com\>** (the public identity).
- No `Co-authored-by: Copilot` trailer. If signing prompts, `git -c commit.gpgsign=false commit`.
