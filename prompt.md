# The Prompt

A reference for everything the KronuZSH prompt shows and every knob that changes
it. It's a single self-contained theme in [`lib/prompt.zsh`](lib/prompt.zsh), no framework.
For the internals (how the deferred strings render, how to add a segment), see the
"prompt" section of [`AGENTS.md`](AGENTS.md); this file is the user-facing manual.

Every option is an ordinary Zsh parameter that you set in `~/.zshrc.local` (in your
home directory, never committed). Do not `export` prompt options: they only affect the
current shell and its prompt. All of them are optional; out of the box the prompt
auto-detects your terminal, OS, and session. Nerd Font glyphs are enabled by default,
with a plain-Unicode set available for terminals using another font.

## What you see

A typical prompt, after a command that failed and took a while (shown with the
plain-Unicode glyphs so it renders anywhere; with a Nerd Font the `⎇`, `venv`, and
time marks become polished icons). The exit code and duration sit on their own line
on top, then the info line, then the line you type on:

```
⏎ 1  3.2s
● kronuz at host.example.com (10.0.0.5)  ⎇ main ⇡1 ✛2 ✴3  venv myproj
[16:26:02] ~/.config/KronuZSH ❯❯❯
```

Read top to bottom:

```
⏎ 1          exit code    the nonzero exit status (only when the last command failed)
3.2s         duration     how long it ran (only past a threshold); shares the top line
●            status dot   green if the last command succeeded, red if it failed
kronuz       user         %n
at host…     host         OS logo (Nerd Font) + hostname + cached LAN IP
⎇ main …     git          branch/tag/commit, ahead/behind, staged/modified/…
venv myproj  venv         the active Python virtualenv ($VIRTUAL_ENV)
```

The **top line is conditional**: it shows only when the last command failed or was
slow, and is absent entirely on a quick, clean command (so a normal prompt is just
the info line and the input line). Bottom line: `[time]`, the working directory, and
the caret (`❯❯❯`) you type at. On the **right** (RPROMPT), an overwrite-mode mark
appears while overwrite mode is active; Vim/Emacs indicators appear when the shell is
running inside either editor. Segments that have nothing to show (no git repo, no venv)
simply don't render, so the prompt stays as short as the moment allows.

Other segments that appear when relevant: a background-jobs count, an SSH or
container badge, and an `etctl:<name>` tag inside an Eternal Terminal session.


## Quick start

The tweaks people reach for first, all in `~/.zshrc.local`:

```zsh
# No Nerd Font installed? Flip the whole prompt to plain-Unicode glyphs:
PROMPT_KRONUZ_NERD_FONT=0

# Show a command's duration sooner (default: only when it ran 3s+):
PROMPT_KRONUZ_CMD_DURATION_MIN=1

# Past commands collapse to a faded caret. Make the faded command grey instead
# of dimmed, or turn the whole transient behavior off:
PROMPT_KRONUZ_TRANSIENT_STYLE=mute
PROMPT_KRONUZ_TRANSIENT=''

# Swap just the collapsed caret for an emoji (the pwd stays; symmetric to the live caret):
PROMPT_KRONUZ_TRANSIENT_CARET='🚀'

# Recolor a segment (any name from the color table below):
PROMPT_KRONUZ_COLOR_HOST='$col[chartreuse]'

# Swap or hide a single glyph:
PROMPT_KRONUZ_GLYPH_MODIFIED='*'
PROMPT_KRONUZ_GLYPH_OS=''
```

Start a new shell after editing the file. For a quick preview in the current shell,
run `source ~/.zshrc.local`; most display options take effect on the next prompt. The
terminal-palette query is the exception: it runs once per shell, on the first prompt,
so palette query, timeout, and cache changes require a new shell.

## Editing modes and carets

KronuZSH uses Zsh's Emacs editing map by default (`bindkey -e`), so ordinary command
entry is the **primary** mode and shows the right-pointing `❯❯❯` caret. Press the
`Insert` key to toggle **overwrite** mode; KronuZSH reads its terminal-specific sequence
from terminfo, as Prezto does, and binds it in both Emacs and vi-insert maps. In the
default Emacs map, Zsh's inherited `Ctrl-X Ctrl-O` sequence also works (hold Ctrl, press
X, then O). Typed characters now replace the ones under the cursor; use the same
shortcut again to return to inserting characters.

In overwrite mode the primary caret keeps the same three `❯` cells but turns entirely
red, so toggling modes does not move the command line. A separate red overwrite glyph
also appears at the right edge in `RPROMPT`.

The **alternate** `❮❮❮` caret is for vi command mode. It is relevant only if you opt
into vi keybindings with `bindkey -v` in `~/.zshrc.local`: press `Esc` to enter command
mode, then `i` (or another vi insertion command such as `a`) to return to primary
vi-insert mode.

The complete indicators can be replaced or hidden independently. Values are prompt
strings, so palette and glyph references remain deferred:

```zsh
PROMPT_KRONUZ_KEYMAP_PRIMARY='${col[caret1]}${glyph[caret]}${col[none]}'
PROMPT_KRONUZ_KEYMAP_ALTERNATE='${col[caret1]}${glyph[caret_alt]}${col[none]}'
PROMPT_KRONUZ_KEYMAP_OVERWRITE='${col[overwrite]}>>>${col[none]}' # overwrite caret
PROMPT_KRONUZ_OVERWRITE=''   # hide only the RPROMPT marker
```

Direct assignments take effect on the next prompt or keymap transition; no export is
required. Put persistent choices in `~/.zshrc.local`, then start a new shell or source
that file once to apply an edit to the current shell.

## Glyphs

The prompt ships two full glyph sets and picks one automatically:

- **Nerd Font** (default): the polished icon set. Needs a [Nerd Font](https://www.nerdfonts.com/)
  installed and selected in your terminal (see [README](README.md#fonts-nerd-font)
  and [nerd_fonts.md](nerd_fonts.md)).
- **Plain Unicode**: BMP symbols that render in any normal font. Switch to it with
  `PROMPT_KRONUZ_NERD_FONT=0` (also accepts `no`, `off`, `false`). It's also forced
  automatically on a `dumb`/unknown terminal, where Nerd Font glyphs would be tofu.

Override any single glyph in either set with `PROMPT_KRONUZ_GLYPH_<NAME>`: set it to
a character of your choice, or to `''` to hide it. The name is the uppercased key
from this table. The **Plain** column shows the literal fallback glyph; the **Nerd
Font** column gives the icon's Nerd Font name and codepoint (it renders as an icon
only in a Nerd Font, so it's named here rather than shown):

Each glyph also has a trailing **pad** (a right-hand space that keeps a wide Nerd Font
icon from colliding with an adjacent count). It's added automatically for wide glyphs
and omitted for normal ones; override it per glyph with `PROMPT_KRONUZ_GLYPH_PAD_<NAME>`.
Set it to `''` to hug tight, or to a space, a non-breaking space (`$'\u00a0'`), or any
string to tune the spacing for your font (e.g. `PROMPT_KRONUZ_GLYPH_PAD_UNTRACKED=''`).


| Name         | Plain  | Nerd Font                      | Meaning                           |
|--------------|:------:|--------------------------------|-----------------------------------|
| `os`         | (none) | `nf-fa-apple` / `nf-fa-linux`  | OS logo by the hostname           |
| `branch`     |  ⎇     | `nf-pl-branch` U+E0A0          | local branch                      |
| `tag`        |  ⚑     | `nf-oct-tag` U+F412            | tag ref                           |
| `commit`     |  @     | `nf-oct-git_commit` U+F417     | detached HEAD                     |
| `remote`     |  ⇅     | `nf-oct-git_compare` U+F47F    | upstream / remote tracking        |
| `host_github`    | (⇅) | `nf-fa-github` U+F09B      | remote host GitHub (nerd only; else `remote`)    |
| `host_gitlab`    | (⇅) | `nf-fa-gitlab` U+F296      | remote host GitLab (nerd only; else `remote`)    |
| `host_bitbucket` | (⇅) | `nf-fa-bitbucket` U+F171   | remote host Bitbucket (nerd only; else `remote`) |
| `action`     |  ⚙     | `nf-oct-git_merge` U+F419      | in-progress op (rebase/merge)     |
| `fallback`   |  ⚠     | `nf-fa-warning` U+F071         | direct-git fallback is active     |
| `clean`      |  ✔     | ✔ U+2714 (same)                | worktree clean                    |
| `dirty`      |  ✗     | ✗ U+2717 (same)                | worktree dirty                    |
| `stashed`    |  ≡     | `nf-fa-archive` U+F187         | stash entries                     |
| `ahead`      |  ⇡     | ⇡ U+21E1 (same)                | commits ahead of upstream         |
| `behind`     |  ⇣     | ⇣ U+21E3 (same)                | commits behind upstream           |
| `push_ahead`  | ⇧     | ⇧ U+21E7 (same)                | commits ahead of a distinct push remote  |
| `push_behind` | ⇩     | ⇩ U+21E9 (same)                | commits behind a distinct push remote    |
| `staged`     |  ✛     | `nf-oct-diff_added` U+F457     | staged changes                    |
| `modified`   |  ✴     | `nf-fa-pencil` U+F040          | unstaged changes                  |
| `conflicted` |  ❖     | `nf-fa-exclamation_tri` U+F071 | merge conflicts                   |
| `untracked`  |  ⊖     | ⊖ U+2296 (same)                | untracked files                   |
| `unknown`    |  ∞     | ∞ U+221E (same)                | dirty, count not scanned (-m cap) |
| `loading`    |  …     | `nf-fa-refresh` U+F021         | async git query in flight         |
| `venv`       |  venv  | `nf-seti-python` U+E606        | active Python virtualenv          |
| `vim`        |  V     | `nf-dev-vim` U+E7C5            | inside vim                        |
| `emacs`      |  E     | `nf-dev-emacs` U+E7CF          | inside emacs                      |
| `jobs`       |  &     | `nf-oct-stack` U+F51E          | backgrounded jobs                 |
| `duration`   | (none) | `nf-fa-clock_o` U+F017         | last command duration             |
| `ssh`        |  ssh   | `nf-cod-remote` U+EB3A         | inside an SSH session             |
| `container`  |  box   | `nf-oct-container` U+F4B7      | inside a container                |
| `dot`        |  ●     | ● U+25CF (same)                | command status dot                |
| `return`     |  ⏎     | ⏎ U+23CE (same)                | nonzero-exit marker               |
| `overwrite`  |  ♺     | ♺ U+267A (same)                | overwrite (replace) editing mode  |
| `caret`      |  ❯     | ❯ U+276F (same)                | prompt caret (insert keymap)      |
| `caret_alt`  |  ❮     | ❮ U+276E (same)                | prompt caret (vicmd keymap)       |

Rows marked "(same)" use the same BMP mark in both sets (they render in any font);
the rest are true Nerd Font icons in the default set and the Plain glyph otherwise.

### A note on glyph spacing

Some Nerd Font icons (the ones in the Private Use Area) render slightly wider than
one cell and can collide with the text right after them. The prompt detects those
per-glyph and inserts a single trailing space automatically; single-width symbols
and text labels get none. So a count next to a wide icon (` 12`) is spaced, but a
plain mark (`✴3`) isn't. You don't configure this; it just keeps columns honest.

## Colors

Color is fully automatic. There are two layers:

1. A **base palette** of named colors (`red`, `chartreuse`, `darkorange`, ...),
   each an `%F{...}` escape. ANSI 0..15 stay as `%F{0..15}` so they follow your
   terminal theme; 16..255 are exact hex (truecolor), downsampled by `zsh/nearcolor`
   on terminals that can't do truecolor.
2. A **semantic layer** that maps each part of the prompt to a base color.

Override any semantic color with `PROMPT_KRONUZ_COLOR_<NAME>`. The value is
evaluated, so you can reference a base-palette name or write a raw escape:

```zsh
PROMPT_KRONUZ_COLOR_HOST='$col[chartreuse]'   # by palette name
PROMPT_KRONUZ_COLOR_TIME='%F{45}'             # by raw zsh color
PROMPT_KRONUZ_COLOR_BRANCH='%B$col[white]'    # %B = bold
PROMPT_KRONUZ_COLOR_TRANSCARET='$col[cyan]'   # collapsed caret
PROMPT_KRONUZ_COLOR_TRANSMUTED='$col[grey]'   # mute-style prompt text
```

You can also override a **base** ANSI color with `PROMPT_KRONUZ_PALETTE_<NAME>` (a
`#RRGGBB` or a 0-255 index) — `RED`, `BLUE`, `LIGHTGREEN`, and the rest of the 16. This
pins that color across the whole prompt (everything built on it) and tells `dim` its
real RGB, which is the clean way to match a terminal whose palette can't be queried (see
[Transient prompt](#transient-prompt)):

```zsh
PROMPT_KRONUZ_PALETTE_RED='#ff5c57'   # fixed red, instead of the theme's %F{1}
```

The semantic names and their defaults:

| Name(s)                                   | Default            | Used for                          |
|-------------------------------------------|--------------------|-----------------------------------|
| `host`                                    | silver             | hostname (colour it per machine to tell boxes apart) |
| `ip`                                      | dark grey          | LAN IP next to the host           |
| `user`                                    | bold white         | username                          |
| `pwd`                                     | white (red as root) | working directory                |
| `time`                                    | dark grey          | `[clock]`                         |
| `info`, `sep`                             | dark grey          | the "at" / separators             |
| `status_ok` / `status_err`                | green / red        | the status dot and exit code      |
| `branch`, `remote`, `commit`              | white              | git ref names                     |
| `clean` / `dirty`                         | forest green / brown | worktree state icon             |
| `ahead` / `behind`                        | chartreuse / deep pink | upstream distance             |
| `added` / `action`                        | dark orange        | staged changes / in-progress operation |
| `fallback`                                | gold               | direct-git fallback warning      |
| `modified` / `unmerged`                   | red                | unstaged changes / conflicts      |
| `untracked`                               | dark grey          | untracked count                   |
| `loading`                                 | dark grey          | in-flight async git query mark    |
| `stashed`                                 | light steel blue   | stash count                       |
| `venv`                                    | white              | virtualenv name                   |
| `jobs`                                    | gold               | background-jobs count             |
| `duration`                                | goldenrod          | command duration                  |
| `ssh` / `container`                       | medium purple / deep sky blue | session badge          |
| `etctl`                                   | bold magenta       | the `etctl:<name>` tag            |
| `vim` / `emacs`                           | bold green         | shell-running-inside-editor indicators |
| `overwrite`                               | red                | overwrite-mode mark               |
| `transcaret`                              | bold white         | the collapsed transient caret     |
| `transmuted`                              | dark grey          | flat prompt color used by the `mute` transient style |
| `caret1/2/3`                              | red/yellow/green   | the three carets of `❯❯❯`         |

(`caret1/2/3` are also swapped to all-red when running as root, via a `%(!..)`
test, as are `pwd` and `user`.)

### No-color mode

A `dumb`/unknown terminal (Emacs `M-x shell`, some CI) or `NO_COLOR=1`
([no-color.org](https://no-color.org)) blanks every semantic color, so the full
layout still renders with zero escapes. It's re-evaluated every prompt, so
`export NO_COLOR=1` (and `unset`) take effect on the very next prompt.

## Behavior

### The status line (exit code + duration)

When the last command **failed or was slow**, the prompt shows a line on top, above
the info row, with its exit code (`⏎<code>`) and/or duration. On a quick, clean
command that line is absent entirely. With transient prompts enabled, submitting the
next command keeps the result line in scrollback above that command's collapsed prompt.
The line stays outside the prompt's OSC 133 `A`/`B` region, so it does not acquire a
terminal mark. Set `PROMPT_KRONUZ_STATUS=0` to retain the older live-only
behavior. With transience disabled, the option instead controls whether status/duration
are shown in the static prompt (shown by default, hidden when false).

### Command duration

After a command runs longer than `PROMPT_KRONUZ_CMD_DURATION_MIN` seconds
(default `3`), the status line above shows how long it took, formatted compactly:
`3.2s`, `1m05s`, `1h02m03s`. Set the threshold to `0` to always show it.

### Background jobs

When you have stopped or backgrounded jobs, the prompt shows the job glyph and the
count (`%j`). Nothing renders when there are none.

### Session context

Two badges are detected once at shell startup and stay for its life:

- **SSH**: shown when any of `$SSH_CONNECTION` / `$SSH_TTY` / `$SSH_CLIENT` is set.
- **Container**: shown when `/.dockerenv`, `/run/.containerenv`, or `$container`
  indicates you're inside one.

The Eternal Terminal session cue is the separate `etctl:<name>` tag (in magenta),
shown whenever `$ETCTL_SESSION` is set, so you can tell at a glance which managed
remote session a shell belongs to.

### Working directory

The path segment shows the full working directory with `$HOME` abbreviated to `~`
(`~/.config/KronuZSH/integrations/bat`). `PROMPT_KRONUZ_PWD_STYLE` shortens it:

| Value | Example | |
|-------|---------|--|
| `full` (default) | `~/.config/KronuZSH/integrations/bat` | the whole path, home as `~` |
| `short` | `~/.c/K/i/bat` | shortest-unique-prefix (like Powerlevel10k's `truncate_to_unique`): each parent shrunk only as far as it stays unambiguous among its siblings, the current directory in full |
| `base` | `bat` | just the current directory's name |
| `absolute` | `/home/kronuz/.config/KronuZSH/integrations/bat` | the whole path with `$HOME` expanded |

```zsh
PROMPT_KRONUZ_PWD_STYLE=short
```

For full control of the segment (a fixed prompt string, `%`-escapes), override
`PROMPT_KRONUZ_PWD` instead — see [Replacing a whole segment](#replacing-a-whole-segment).

## Transient prompt

When you press Enter, the prompt for the command you just ran collapses to a compact
line: the **directory it ran in**, then a short caret. So your scrollback reads as a
column of `path ❯ command` instead of a wall of repeated full prompts, and you can see
where each command was run. The live prompt above the cursor is always the full one;
only the past ones shrink. A command that **failed or was slow** leaves its outcome
line (the `⏎<code>` / duration) visible in the next live prompt. When you submit the
next command, that outcome line is discarded with the rest of the full prompt so it
does not create another terminal mark. In iTerm2, the command's mark still retains its
exit status and calculated running time for later inspection.

The collapsed path reuses your `PROMPT_KRONUZ_PWD_STYLE` (so `short`/`base` shorten it
there too) and uses the live `pwd` colour (so it matches the prompt and honours
`PROMPT_KRONUZ_COLOR_PWD`).

The collapsed line is built the same way as the live prompt, and is configured
symmetrically: `PROMPT_KRONUZ_TRANSIENT` is the whole string (like `PROMPT`) and
`PROMPT_KRONUZ_TRANSIENT_CARET` is just the caret piece (like `PROMPT_KRONUZ_PROMPT` is
the live caret), so you can swap the caret for an emoji without rebuilding the rest. Both
take deferred `${...}` segments and are re-evaluated on every Enter, and the whole
resolved line — pwd, caret, and your own `PROMPT_KRONUZ_TRANSIENT` if you set one — is
restyled together by `PROMPT_KRONUZ_TRANSIENT_STYLE`.

```
~/project ❯ cd src
~/project/src ❯ make
⏎ 2          ← make failed; visible in the current live prompt
● kronuz at host (10.0.0.5)  ⎇ main
[16:25:58] ~/project/src ❯❯❯ ./run --watch
~/project/src ❯ ./run --watch       ← after Enter, the old prompt collapses
3.4s         ← the completed command was slow; visible in the new live prompt
● kronuz at host (10.0.0.5)  ⎇ main
[16:26:02] ~/project/src ❯❯❯
```

These variables control it (the palette knobs `dim` relies on are described under the
styles below, and listed in full in the option reference):

| Variable                       | Default            | Effect                                            |
|--------------------------------|--------------------|---------------------------------------------------|
| `PROMPT_KRONUZ_TRANSIENT`      | `pwd ❯`            | The whole collapsed prompt string (by default the directory the command ran in, then a caret), built like `PROMPT` from deferred `${...}` segments. Set to `''` to disable transience entirely (past prompts stay full), or to any string for a custom collapsed prompt (which is itself restyled per `PROMPT_KRONUZ_TRANSIENT_STYLE`). |
| `PROMPT_KRONUZ_TRANSIENT_CARET`| `❯`                | Just the caret piece of the default collapsed line — symmetric to `PROMPT_KRONUZ_PROMPT` for the live prompt. Set to an emoji or any string to change the caret without touching the rest. Ignored if you override the whole `PROMPT_KRONUZ_TRANSIENT`. |
| `PROMPT_KRONUZ_STATUS`          | `1`                | Keep a failed exit status and/or slow-command duration in scrollback when the next command collapses, or show it in the static prompt when transience is disabled; `0`/`no`/`off`/`false` makes it live-only with transience and hides it without transience. |
| `PROMPT_KRONUZ_TRANSIENT_STYLE`| `dim`              | How the collapsed line — the pwd, caret, and the just-run **command** — is restyled: `dim`, `mute`, or `keep`. |
| `PROMPT_KRONUZ_TRANSIENT_DIM`  | `0.7`              | For `dim`: darkness factor, `0` = black, `1` = unchanged. Lower is darker. |
| `PROMPT_KRONUZ_TRANSIENT_HL`   | `fg=8`             | For `mute`: the `region_highlight` spec to paint the command with (default = grey). |

The three styles:

- **`dim`** keeps the command's own syntax colors but darkens them, so the line
  reads as faded history without losing its shape. The default factor (`0.7`) is a
  moderate fade; go lower (`0.4` to `0.5`) for darker, higher (`0.85`+) for subtler.
  To darken the right hue, the prompt needs your terminal's real 16 ANSI colors. It
  gets each from its `PROMPT_KRONUZ_PALETTE_<NAME>` override if you set one, else from
  an on-disk cache, else a one-time **OSC 4** query of the terminal (cached afterward
  for `PROMPT_KRONUZ_PALETTE_TTL`); if nothing answers it falls back to the xterm
  defaults. Over a remote shell (e.g. SSH or Eternal Terminal) the query round-trip is
  network-bound, so the cache and a generous `PROMPT_KRONUZ_PALETTE_TIMEOUT` matter; if
  your terminal still can't be queried, just pin the 16 base colors in `~/.zshrc.local`
  (which also fixes the displayed colors, and skips the query entirely):

  ```zsh
  # iTerm "Snazzy" — your terminal's 16 ANSI colors as #RRGGBB.
  PROMPT_KRONUZ_PALETTE_BLACK='#000000'    PROMPT_KRONUZ_PALETTE_DARKGREY='#686868'
  PROMPT_KRONUZ_PALETTE_RED='#ff5c57'      PROMPT_KRONUZ_PALETTE_LIGHTRED='#ff5c57'
  PROMPT_KRONUZ_PALETTE_GREEN='#5af78e'    PROMPT_KRONUZ_PALETTE_LIGHTGREEN='#5af78e'
  PROMPT_KRONUZ_PALETTE_YELLOW='#f3f99d'   PROMPT_KRONUZ_PALETTE_LIGHTYELLOW='#f3f99d'
  PROMPT_KRONUZ_PALETTE_BLUE='#57c7ff'     PROMPT_KRONUZ_PALETTE_LIGHTBLUE='#57c7ff'
  PROMPT_KRONUZ_PALETTE_MAGENTA='#ff6ac1'  PROMPT_KRONUZ_PALETTE_LIGHTMAGENTA='#ff6ac1'
  PROMPT_KRONUZ_PALETTE_CYAN='#9aedfe'     PROMPT_KRONUZ_PALETTE_LIGHTCYAN='#9aedfe'
  PROMPT_KRONUZ_PALETTE_GREY='#f1f1f0'     PROMPT_KRONUZ_PALETTE_LIGHTGREY='#eff0eb'
  ```
- **`mute`** repaints the whole command in one flat color (grey by default; change
  it with `PROMPT_KRONUZ_TRANSIENT_HL`).
- **`keep`** leaves the syntax colors untouched.

### The exit code is live; the terminal keeps the history

A natural wish is to color the caret of a failed command red. The caret itself
can't be: it's drawn the moment you press Enter, before the command runs, so at
caret-draw time its own result doesn't exist yet. Instead the result shows on a line
above the **next live prompt**, where it is useful while it is fresh. Submitting
another command discards that visual line during the transient collapse. The terminal
independently gets the machine-readable result via the OSC 133 `D;<exitcode>` mark
emitted for each command. iTerm2 uses it to flag failed commands in the gutter and
retains the command's status and calculated running time in the mark's Info panel, so
the information remains available without another line in scrollback.

## Terminal integration

On a capable terminal (skipped on `dumb`/unknown), the prompt emits standard
shell-integration escape sequences so the terminal can do more for you:

- **OSC 7** (current directory): on non-iTerm terminals, new tabs and splits open in
  the same `$PWD`. iTerm2 receives `OSC 1337;CurrentDir` instead because its OSC 7
  handler also creates a prompt mark, which would duplicate the OSC 133 mark.
- **OSC 133** (prompt/command marks `A`/`B`/`C`/`D;exit`): jump between prompts,
  show per-command success/failure, select command output. The `D;<exitcode>` mark
  carries the real `$?`, so the terminal knows which commands failed.
- **OSC 1337** (iTerm2 only): reports host and directory through iTerm2's native
  integration, on top of the cross-terminal OSC 133 marks.

### Why keep the iTerm2 integration enabled?

The metadata is invisible until iTerm2 uses it, and several small conveniences add up:

- **Jump between commands:** press **Command-Shift-Up** or **Command-Shift-Down** to
  move to the previous or next prompt mark instead of scrolling and hunting.
- **Spot failures:** with mark indicators visible, a failed command gets a red mark.
  Right-click its mark to inspect its exit status and running time.
- **Select clean output:** press **Command-Shift-A**, or choose **Edit → Select Output
  of Last Command**, to select only what the last command printed, without its prompt
  or command line.
- **Search one command's output:** click a past command, then Find and Filter operate on
  that command's output rather than the whole scrollback buffer.
- **Keep directory context:** new terminal tabs and splits can start in the current
  working directory, while iTerm2 also knows the current host and directory for features
  such as automatic profile switching.

iTerm2's [Shell Integration documentation](https://iterm2.com/documentation-shell-integration.html)
describes the complete feature set, including command history, recent directories,
alerts when long commands finish, automatic profile switching, and file transfer.

To verify command tracking, run `false`. The next prompt should show KronuZSH's
`⏎1` status, and—with **Show mark indicators** enabled—the mark beside that command
should turn red. Then run `printf 'hello\n'` and press **Command-Shift-A**; only
`hello` should be selected. If neither feature works, ensure
`PROMPT_KRONUZ_TERMINAL_INTEGRATION` is not disabled and test outside ordinary
`tmux`/`screen`, which can swallow shell-integration sequences.

### iTerm2 preferences

iTerm2 uses the OSC 133 command marks for a couple of UI behaviors that are useful but
can feel intrusive. You can disable either behavior without losing the rest of the
integration:

- Hide the blue/red gutter marks: turn off **Settings → Profiles → Terminal → Show
  mark indicators** for the profile.
- Stop a click on an old command from dimming everything else and restricting Find and
  Filter to that command's output: turn off **Settings → General → Selection → Clicking
  on a command selects it to restrict Find and Filter**.

To opt out of terminal integration entirely, add this to `~/.zshrc.local`:

```zsh
PROMPT_KRONUZ_TERMINAL_INTEGRATION=0
```

That disables all terminal metadata emitted by the prompt: OSC 7 current-directory
reporting on other terminals, OSC 133 prompt/command marks, and iTerm2's OSC 1337
host/directory updates.
Values `0`, `no`, `off`, and `false` disable it; the default is `1`.

## Replacing a whole segment

Beyond colors and glyphs, you can override a segment's entire content with
`PROMPT_KRONUZ_<SEGMENT>`. The value is a prompt string (zsh `%`-escapes and
`$col[...]` / `$glyph[...]` references work). Use single quotes in
`~/.zshrc.local` when the value contains `$col` or `$glyph`; that keeps the reference
deferred so it is resolved whenever the prompt is drawn.

| Segment option | Built-in content |
|----------------|------------------|
| `PROMPT_KRONUZ_OS` | OS glyph before the hostname |
| `PROMPT_KRONUZ_ERR` | green/red status dot for the previous command |
| `PROMPT_KRONUZ_ERROR` | nonzero exit-code item on the conditional outcome line |
| `PROMPT_KRONUZ_DURATION` | elapsed-time item on the conditional outcome line |
| `PROMPT_KRONUZ_USER` | username (`%n`) |
| `PROMPT_KRONUZ_HOST` | hostname (`%M`) |
| `PROMPT_KRONUZ_IP` | cached LAN address inside the hostname's parentheses |
| `PROMPT_KRONUZ_TIME` | current time (`[%*]`) |
| `PROMPT_KRONUZ_PWD` | working directory generated according to `PROMPT_KRONUZ_PWD_STYLE` |
| `PROMPT_KRONUZ_GIT` | generated git status |
| `PROMPT_KRONUZ_VENV` | active Python virtualenv |
| `PROMPT_KRONUZ_JOBS` | background-job glyph and count |
| `PROMPT_KRONUZ_CONTEXT` | container and SSH badges |
| `PROMPT_KRONUZ_ETCTL` | Eternal Terminal session label |
| `PROMPT_KRONUZ_VIM` | right-prompt Vim indicator |
| `PROMPT_KRONUZ_EMACS` | right-prompt Emacs indicator |
| `PROMPT_KRONUZ_OVERWRITE` | right-prompt overwrite indicator; `''` hides it |
| `PROMPT_KRONUZ_PROMPT` | complete live input caret; replacing it bypasses the primary/alternate keymap carets |

The host display composes `PROMPT_KRONUZ_OS`, `PROMPT_KRONUZ_HOST`, and
`PROMPT_KRONUZ_IP`; recolor the hostname with `PROMPT_KRONUZ_COLOR_HOST`. The outcome
line itself owns the conditional layout:
`PROMPT_KRONUZ_ERROR` is used only for a nonzero exit, and `PROMPT_KRONUZ_DURATION`
only after the duration threshold is reached. Their values control the contents of
those items; the status line supplies their default colors, spacing, newline, and
conditional layout. Set either to `''` to hide that item without disabling the other.

```zsh
# A 24-hour clock with seconds instead of the default [%*]:
PROMPT_KRONUZ_TIME='[%D{%H:%M:%S}]'

# Just the basename of the cwd (or simpler: PROMPT_KRONUZ_PWD_STYLE=base; for the
# shortest-unique-prefix ~/.c/K/i/bat, PROMPT_KRONUZ_PWD_STYLE=short):
PROMPT_KRONUZ_PWD='%1~'

# Add a label before the normal username:
PROMPT_KRONUZ_USER='dev:%n'

# Replace the status dot with literal text, colored by the result:
PROMPT_KRONUZ_ERR='%(?.${col[status_ok]}OK.${col[status_err]}ERR)${col[none]}'

# Spell out failures, or omit the duration glyph while keeping the formatted time:
PROMPT_KRONUZ_ERROR='exit ${_prompt_kronuz_last_exit}'
PROMPT_KRONUZ_DURATION='${_prompt_kronuz_duration}'

# Use one fixed caret and ignore editor-keymap changes:
PROMPT_KRONUZ_PROMPT='${col[caret3]}›${col[none]}'
```

For deeper changes (adding a brand-new segment, reordering the line), edit
`lib/prompt.zsh` directly; the [`AGENTS.md`](AGENTS.md) "Add a segment" recipe walks
through it.

## Full option reference

These are all of the public KronuZSH prompt parameters, followed by the standard
terminal environment signals the prompt reads. Names represented by `<NAME>` are
fully enumerated in the linked table or directly in the description.

| Variable | Default | What it does |
|----------|---------|--------------|
| `PROMPT_KRONUZ_NERD_FONT` | `1` | `0`/`no`/`off`/`false` switches to the plain-Unicode glyph set. |
| `PROMPT_KRONUZ_GLYPH_<NAME>` | per glyph | Override one glyph; `''` hides it. All names are in the [glyph table](#glyphs). |
| `PROMPT_KRONUZ_GLYPH_PAD_<NAME>` | per glyph | Override a glyph's trailing (right-hand) pad; `''` hugs tight, a space / `$'\u00a0'` / any string tunes it for your font. |
| `PROMPT_KRONUZ_GIT_SEP` | `' '` (space) | String inserted between the git detail indicators (stash / staged / modified / untracked / ahead-behind …). Set to `'·'`, `':'`, `$'\u00a0'`, or any string; `''` packs them with no separator. |
| `PROMPT_KRONUZ_COLOR_<NAME>` | per color | Override one semantic color. All public names are in the [color table](#colors). |
| `PROMPT_KRONUZ_PALETTE_<NAME>` | terminal palette | Override one ANSI base color with `#RRGGBB` or a 0–255 index. Names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `GREY`, `DARKGREY`, `LIGHTRED`, `LIGHTGREEN`, `LIGHTYELLOW`, `LIGHTBLUE`, `LIGHTMAGENTA`, `LIGHTCYAN`, `LIGHTGREY`. This changes display colors and the RGB used by `dim`. |
| `PROMPT_KRONUZ_<SEGMENT>` | built in | Replace one complete segment or outcome item. Names: `OS`, `ERR`, `ERROR`, `DURATION`, `USER`, `HOST`, `IP`, `TIME`, `PWD`, `GIT`, `VENV`, `JOBS`, `CONTEXT`, `ETCTL`, `VIM`, `EMACS`, `OVERWRITE`, `PROMPT`; see [Replacing a whole segment](#replacing-a-whole-segment). |
| `PROMPT_KRONUZ_PWD_STYLE` | `full` | Working-directory shortening: `full`, `short` (shortest unique prefix, `~/.c/K/i/bat`), `base` (current dir name), or `absolute` (`$HOME` expanded). |
| `PROMPT_KRONUZ_CMD_DURATION_MIN` | `3` | Seconds a command must run before its duration is shown. `0` = always. |
| `PROMPT_KRONUZ_IP_TTL` | `60` | Seconds the LAN-IP lookup is cached; lower it if prompt-time address changes must appear sooner. |
| `PROMPT_KRONUZ_TRANSIENT` | `pwd ❯` | The whole collapsed past-prompt string (default: the run directory + caret), built like `PROMPT`; `''` disables transience. |
| `PROMPT_KRONUZ_TRANSIENT_CARET` | `❯` | Just the caret piece of the default collapsed line (symmetric to `PROMPT_KRONUZ_PROMPT`); set to an emoji or any string. |
| `PROMPT_KRONUZ_STATUS` | `1` | Keep the previous failed status and/or duration above the next collapsed command, or show it in the static prompt when transience is disabled; false values make it live-only with transience and hide it without transience. |
| `PROMPT_KRONUZ_TRANSIENT_STYLE` | `dim` | Restyle of the collapsed line (pwd, caret, command): `dim`, `mute`, or `keep`. |
| `PROMPT_KRONUZ_TRANSIENT_DIM` | `0.7` | `dim` darkness factor (`0` black .. `1` unchanged). |
| `PROMPT_KRONUZ_TRANSIENT_HL` | `fg=8` | `mute` color, as a `region_highlight` spec. |
| `PROMPT_KRONUZ_PALETTE_TTL` | `86400` | Seconds the queried palette is cached on disk (per terminal); `0` disables the cache. |
| `PROMPT_KRONUZ_PALETTE_TIMEOUT` | `0.6` | Seconds to wait for the OSC 4 palette answer; bump it for a slow/remote terminal. |
| `PROMPT_KRONUZ_TERMINAL_INTEGRATION` | `1` | `0`/`no`/`off`/`false` disables OSC 7 cwd reporting, OSC 133 command marks, and iTerm2 OSC 1337 metadata. |
| `PROMPT_KRONUZ_KEYMAP_PRIMARY` | `❯❯❯` | The live caret in the primary keymap (emacs / vi-insert), as a prompt string. `''` hides it. |
| `PROMPT_KRONUZ_KEYMAP_ALTERNATE` | `❮❮❮` | The live caret in the vi-command keymap. `''` hides it. |
| `PROMPT_KRONUZ_KEYMAP_OVERWRITE` | red `❯❯❯` | The complete live caret used in overwrite mode. It stays three cells wide by default. |
| `COLORTERM` | (terminal) | `24bit`/`truecolor` keeps the hex palette at 24-bit; otherwise colors degrade to 256/16 via `zsh/nearcolor`. |
| `TERM` | (terminal) | `dumb`/`unknown`/empty forces the plain-glyph set and no color (see no-color mode). |
| `NO_COLOR` | (unset) | Standard env var; when set, renders with no color escapes. |

Anything not set falls back to its built-in default. These are shell parameters, not
environment settings, so they do not need `export`. Most are recomputed on each prompt
or keymap transition and can be previewed by assigning them directly. The palette used
to dim transient prompts is loaded only once, on a shell's first prompt; start a new
shell after changing `PROMPT_KRONUZ_PALETTE_*`, `PROMPT_KRONUZ_PALETTE_TTL`, or
`PROMPT_KRONUZ_PALETTE_TIMEOUT` when you need the dimmed colors to be recalculated.
