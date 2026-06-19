# The Prompt

A reference for everything the kronuzsh prompt shows and every knob that changes
it. It's a single self-contained theme in [`prompt.zsh`](prompt.zsh), no framework.
For the internals (how the deferred strings render, how to add a segment), see the
"prompt" section of [`AGENTS.md`](AGENTS.md); this file is the user-facing manual.

Every option is an environment variable you set in `local.zsh` (git-ignored). All
of them are optional: out of the box the prompt auto-detects your terminal, font,
OS, and session and does the right thing.

## What you see

A typical prompt, after a command that failed and took a while (shown with the
plain-Unicode glyphs so it renders anywhere; with a Nerd Font the `⎇`, `venv`, and
time marks become polished icons). The exit code and duration sit on their own line
on top, then the info line, then the line you type on:

```
⏎ 1  3.2s
● gmendezb at host.example.com (10.0.0.5)  ⎇ main ⇡1 ✛2 ✴3  venv myproj
[16:26:02] ~/Development/kronuzsh ❯❯❯
```

Read top to bottom:

```
⏎ 1          exit code    the nonzero exit status (only when the last command failed)
3.2s         duration     how long it ran (only past a threshold); shares the top line
●            status dot   green if the last command succeeded, red if it failed
gmendezb     user         %n
at host…     host         OS logo (Nerd Font) + hostname + cached LAN IP
⎇ main …     git          branch/tag/commit, ahead/behind, staged/modified/…
venv myproj  venv         the active Python virtualenv ($VIRTUAL_ENV)
```

The **top line is conditional**: it shows only when the last command failed or was
slow, and is absent entirely on a quick, clean command (so a normal prompt is just
the info line and the input line). Bottom line: `[time]`, the working directory, and
the caret (`❯❯❯`) you type at. On the **right** (RPROMPT): the vi/emacs keymap
indicator and an overwrite-mode mark. Segments that have nothing to show (no git
repo, no venv) simply don't render, so the prompt stays as short as the moment allows.

Other segments that appear when relevant: a background-jobs count, an SSH or
container badge, and an `etctl:<name>` tag inside an Eternal Terminal session.


## Quick start

The tweaks people reach for first, all in `local.zsh`:

```zsh
# No Nerd Font installed? Flip the whole prompt to plain-Unicode glyphs:
export PROMPT_KRONUZ_NERD_FONT=0

# Show a command's duration sooner (default: only when it ran 3s+):
export PROMPT_KRONUZ_CMD_DURATION_MIN=1

# Past commands collapse to a faded caret. Make the faded command grey instead
# of dimmed, or turn the whole transient behavior off:
export PROMPT_KRONUZ_TRANSIENT_STYLE=mute
export PROMPT_KRONUZ_TRANSIENT=''

# Recolor a segment (any name from the color table below):
export PROMPT_KRONUZ_COLOR_HOST='$col[chartreuse]'

# Swap or hide a single glyph:
export PROMPT_KRONUZ_GLYPH_MODIFIED='*'
export PROMPT_KRONUZ_GLYPH_OS=''
```

## Glyphs

The prompt ships two full glyph sets and picks one automatically:

- **Nerd Font** (default): the polished icon set. Needs a [Nerd Font](https://www.nerdfonts.com/)
  installed and selected in your terminal (see [README](README.md#fonts-nerd-font)
  and [NerdFonts.md](NerdFonts.md)).
- **Plain Unicode**: BMP symbols that render in any normal font. Switch to it with
  `PROMPT_KRONUZ_NERD_FONT=0` (also accepts `no`, `off`, `false`). It's also forced
  automatically on a `dumb`/unknown terminal, where Nerd Font glyphs would be tofu.

Override any single glyph in either set with `PROMPT_KRONUZ_GLYPH_<NAME>`: set it to
a character of your choice, or to `''` to hide it. The name is the uppercased key
from this table. The **Plain** column shows the literal fallback glyph; the **Nerd
Font** column gives the icon's Nerd Font name and codepoint (it renders as an icon
only in a Nerd Font, so it's named here rather than shown):

| Name         | Plain | Nerd Font                       | Meaning                          |
|--------------|:-----:|---------------------------------|----------------------------------|
| `os`         | (none) | `nf-fa-apple` / `nf-fa-linux` (by OS) | OS logo by the hostname    |
| `branch`     |  ⎇    | `nf-pl-branch` U+E0A0           | local branch                     |
| `tag`        |  ⚑    | `nf-oct-tag` U+F412             | tag ref                          |
| `commit`     |  @    | `nf-oct-git_commit` U+F417      | detached HEAD                    |
| `remote`     |  ⇅    | `nf-oct-git_compare` U+F47F     | upstream / remote tracking       |
| `action`     |  ⚙    | `nf-oct-git_merge` U+F419       | in-progress op (rebase/merge)    |
| `clean`      |  ✔    | ✔ U+2714 (same)                 | worktree clean                   |
| `dirty`      |  ✗    | ✗ U+2717 (same)                 | worktree dirty                   |
| `stashed`    |  ≡    | `nf-fa-archive` U+F187          | stash entries                    |
| `ahead`      |  ⇡    | ⇡ U+21E1 (same)                 | commits ahead of upstream        |
| `behind`     |  ⇣    | ⇣ U+21E3 (same)                 | commits behind upstream          |
| `staged`     |  ✛    | `nf-oct-diff_added` U+F457      | staged changes                   |
| `modified`   |  ✴    | `nf-fa-pencil` U+F040           | unstaged changes                 |
| `conflicted` |  ❖    | `nf-fa-exclamation_tri` U+F071  | merge conflicts                  |
| `untracked`  |  ⊖    | `nf-fa-question` U+F128         | untracked files                  |
| `venv`       |  venv | `nf-seti-python` U+E606         | active Python virtualenv         |
| `vim`        |  V    | `nf-dev-vim` U+E7C5             | inside vim                       |
| `emacs`      |  E    | `nf-dev-emacs` U+E7CF           | inside emacs                     |
| `jobs`       |  &    | `nf-oct-stack` U+F51E           | backgrounded jobs                |
| `duration`   | (none) | `nf-fa-clock_o` U+F017          | last command duration            |
| `ssh`        |  ssh  | `nf-cod-remote` U+EB3A          | inside an SSH session            |
| `container`  |  box  | `nf-oct-container` U+F4B7       | inside a container               |
| `dot`        |  ●    | ● U+25CF (same)                 | command status dot               |
| `return`     |  ⏎    | ⏎ U+23CE (same)                 | nonzero-exit marker              |
| `overwrite`  |  ♺    | ♺ U+267A (same)                 | overwrite (replace) editing mode |
| `caret`      |  ❯    | ❯ U+276F (same)                 | prompt caret (insert keymap)     |
| `caret_alt`  |  ❮    | ❮ U+276E (same)                 | prompt caret (vicmd keymap)      |

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
export PROMPT_KRONUZ_COLOR_HOST='$col[chartreuse]'   # by palette name
export PROMPT_KRONUZ_COLOR_TIME='%F{45}'             # by raw zsh color
export PROMPT_KRONUZ_COLOR_BRANCH='%B$col[white]'    # %B = bold
```

The semantic names and their defaults:

| Name(s)                                   | Default            | Used for                          |
|-------------------------------------------|--------------------|-----------------------------------|
| `host`                                    | blue               | hostname                          |
| `ip`                                      | dark grey          | LAN IP next to the host           |
| `user`                                    | bold white         | username                          |
| `pwd`                                     | aqua               | working directory                 |
| `time`                                    | dark grey          | `[clock]`                         |
| `info`, `sep`                             | dark grey          | the "at" / separators             |
| `status_ok` / `status_err`               | green / red        | the status dot and exit code      |
| `branch`, `remote`, `commit`, `position`  | white              | git ref names                     |
| `clean` / `dirty`                         | forest green / brown | worktree state icon             |
| `ahead` / `behind`                        | chartreuse / deep pink | upstream distance             |
| `added`/`indexed`/`renamed`/`action`      | dark orange        | staged-side git counts            |
| `modified`/`deleted`/`unindexed`/`unmerged` | red              | unstaged-side git counts          |
| `untracked`                               | dark grey          | untracked count                   |
| `stashed`                                 | light steel blue   | stash count                       |
| `venv`                                    | white              | virtualenv name                   |
| `jobs`                                    | gold               | background-jobs count             |
| `duration`                                | goldenrod          | command duration                  |
| `ssh` / `container`                       | medium purple / deep sky blue | session badge          |
| `etctl`                                   | bold magenta       | the `etctl:<name>` tag            |
| `vim` / `emacs`                           | bold green         | editor keymap indicators          |
| `overwrite`                               | red                | overwrite-mode mark               |
| `insert` / `completing`                   | dark grey / black  | caret keymap states               |
| `transient`                               | dark grey          | the collapsed transient caret     |
| `primary1/2/3`                            | red/yellow/green   | the three carets of `❯❯❯`         |

(`primary1/2/3` are also swapped to all-red when running as root, via a `%(!..)`
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
command that line is absent entirely. When you submit the next command, that line
stays behind in scrollback (dimmed, per your transient style), so your history reads
as a quiet log of what failed or dragged. See [Transient prompt](#transient-prompt).

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

## Transient prompt

When you press Enter, the prompt for the command you just ran collapses to a single
short caret, so your scrollback is a clean column of carets and commands instead of
a wall of repeated full prompts. The live prompt above the cursor is always the
full one; only the past ones shrink. A command that **failed or was slow** also
leaves its outcome line (the `⏎<code>` / duration) behind, dimmed, so scrollback
stays a quiet log of what happened; quiet commands collapse to a bare caret.

```
❯ cd src
❯ make
⏎ 2          ← make failed; its outcome line stays, dimmed
❯ ./run --watch
3.4s         ← slow; the dimmed duration stays
● gmendezb at host (10.0.0.5)  ⎇ main ❯❯❯        ← the live prompt, full color
```

Three variables control it:

| Variable                       | Default            | Effect                                            |
|--------------------------------|--------------------|---------------------------------------------------|
| `PROMPT_KRONUZ_TRANSIENT`      | a faded `❯`        | The collapsed prompt string. Set to `''` to disable transience entirely (past prompts stay full). |
| `PROMPT_KRONUZ_TRANSIENT_STYLE`| `dim`              | How the just-run **command and the kept outcome line** are restyled in the collapsed line: `dim`, `mute`, or `keep`. |
| `PROMPT_KRONUZ_TRANSIENT_DIM`  | `0.7`              | For `dim`: darkness factor, `0` = black, `1` = unchanged. Lower is darker. |
| `PROMPT_KRONUZ_TRANSIENT_HL`   | `fg=8`             | For `mute`: the `region_highlight` spec to paint the command with (default = grey). |

The three styles:

- **`dim`** keeps the command's own syntax colors but darkens them, so the line
  reads as faded history without losing its shape. The default factor (`0.7`) is a
  moderate fade; go lower (`0.4` to `0.5`) for darker, higher (`0.85`+) for subtler.
  To darken the
  right hue, the prompt queries your terminal's real 16 ANSI colors once at startup
  (via an OSC 4 query), falling back to the xterm defaults if the terminal doesn't
  answer.
- **`mute`** repaints the whole command in one flat color (grey by default; change
  it with `PROMPT_KRONUZ_TRANSIENT_HL`).
- **`keep`** leaves the syntax colors untouched.

### The exit code lives above the caret, not in it

A natural wish is to color the caret of a failed command red. The caret itself
can't be: it's drawn the moment you press Enter, before the command runs, so at
caret-draw time its own result doesn't exist yet. Instead the result shows on the
**line above** the caret. The live prompt puts the `⏎<code>` / duration on its own
line, and when you submit the next command that line stays behind (dimmed) in
scrollback, so past failures and slow commands are still visible at a glance. The
terminal also gets the machine-readable version via the OSC 133 `D;<exitcode>` mark
the prompt emits per command, which terminals like iTerm2 use to flag failed
commands in the gutter.

## Terminal integration

On a capable terminal (skipped on `dumb`/unknown), the prompt emits standard
shell-integration escape sequences so the terminal can do more for you:

- **OSC 7** (current directory): new tabs and splits open in the same `$PWD`.
- **OSC 133** (prompt/command marks `A`/`B`/`C`/`D;exit`): jump between prompts,
  show per-command success/failure, select command output. The `D;<exitcode>` mark
  carries the real `$?`, so the terminal knows which commands failed.
- **OSC 1337** (iTerm2 only): also reports host and directory to iTerm2's own
  integration, on top of the cross-terminal OSC 133 marks.

There's nothing to configure; it activates wherever the terminal understands it.

## Replacing a whole segment

Beyond colors and glyphs, you can override a segment's entire content with
`PROMPT_KRONUZ_<SEGMENT>`. The value is a prompt string (zsh `%`-escapes and
`$col[...]` / `$glyph[...]` references work). Available segments: `OS`, `ERR`,
`USER`, `IP`, `HOST` (composed), `TIME`, `PWD`, `GIT`, `VENV`, `JOBS`,
`CONTEXT`, `ETCTL`, `VIM`, `EMACS`, `OVERWRITE`, `PROMPT`. (The exit code and
duration are no longer their own overridable segments; they're built into the
status line on top, formatted by `_kronuz_status_segment`.)

```zsh
# A 24-hour clock with seconds instead of the default [%*]:
export PROMPT_KRONUZ_TIME='[%D{%H:%M:%S}]'

# Just the basename of the cwd, not the full ~-path:
export PROMPT_KRONUZ_PWD='%1~'
```

For deeper changes (adding a brand-new segment, reordering the line), edit
`prompt.zsh` directly; the [`AGENTS.md`](AGENTS.md) "Add a segment" recipe walks
through it.

## Full option reference

| Variable | Default | What it does |
|----------|---------|--------------|
| `PROMPT_KRONUZ_NERD_FONT` | `1` | `0`/`no`/`off`/`false` switches to the plain-Unicode glyph set. |
| `PROMPT_KRONUZ_GLYPH_<NAME>` | (per glyph) | Override one glyph; `''` hides it. Names in the glyph table. |
| `PROMPT_KRONUZ_COLOR_<NAME>` | (per color) | Override one semantic color. Names in the color table. |
| `PROMPT_KRONUZ_<SEGMENT>` | (built-in) | Replace a segment's whole content. Names in "Replacing a whole segment". |
| `PROMPT_KRONUZ_CMD_DURATION_MIN` | `3` | Seconds a command must run before its duration is shown. `0` = always. |
| `PROMPT_KRONUZ_TRANSIENT` | faded `❯` | The collapsed past-prompt string; `''` disables transience. |
| `PROMPT_KRONUZ_TRANSIENT_STYLE` | `dim` | Restyle of the past command: `dim`, `mute`, or `keep`. |
| `PROMPT_KRONUZ_TRANSIENT_DIM` | `0.7` | `dim` darkness factor (`0` black .. `1` unchanged). |
| `PROMPT_KRONUZ_TRANSIENT_HL` | `fg=8` | `mute` color, as a `region_highlight` spec. |
| `NO_COLOR` | (unset) | Standard env var; when set, renders with no color escapes. |

Anything not set falls back to the built-in default, and every variable is read
live, so editing `local.zsh` and starting a new shell is all it takes.
