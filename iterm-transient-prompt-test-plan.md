# iTerm2 transient-prompt test plan

This plan turns the transient-prompt marker problem into a reproducible matrix. Read
`iterm-transient-prompt-experiments.md` first. That file records arrangements already
tested and their observed failures.

Before running the OSC 133 matrix, test the source-driven OSC 7 hypothesis recorded at
the end of that file. iTerm2's OSC 7 handler itself creates a prompt mark, so a matrix
that includes OSC 7 would confound every OSC 133 case in the same way.

## Question to answer

For a command that exits 1, find a stream that produces exactly:

1. one red mark beside the collapsed command line;
2. one blue mark beside the next live prompt's `●` row;
3. no mark beside the temporary `⏎ 1` row;
4. correct **Select Output of Last Command** behavior.

Marker position, marker color, command selection, output selection, and the mark's Info
panel are separate results. Record all of them. A visually correct pair of triangles is
not sufficient if iTerm assigns the wrong command or output range.

## What assigning `PROMPT` does

This assignment alone sends nothing to the terminal:

```zsh
PROMPT="$new_prompt"
```

It only changes the string Zsh will expand on a later prompt draw. In KronuZSH's
accept-line widget, the observable work begins here:

```zsh
zle .reset-prompt
```

ZLE then redraws the editing display. For the current two-line live prompt becoming a
one-line transient prompt, that stream includes cursor movement, carriage returns,
line erasure, SGR styling, the expanded replacement `PROMPT`, and the already typed
buffer. Any OSC 133 bytes embedded in the replacement prompt are emitted during this
redraw. The subsequent:

```zsh
zle .accept-line
```

finishes the editing display and hands the command to Zsh. The `preexec` hook then emits
`C`, the command emits its output, and `precmd` handles `D;<status>` and prepares the
next prompt.

So there are three different objects to test:

- the logical OSC 133 order;
- the synthetic screen rewrite used by a raw fixture;
- ZLE's real, terminal-dependent redraw stream.

A protocol-only `cat` fixture tests the first object. It does not prove the third.

## Isolation rule

Do not run a fixture by typing `cat fixture.ansi` inside a KronuZSH-integrated prompt.
That outer command contributes its own `A/B/C/D` and contaminates the result.

For raw fixtures, create a fresh iTerm profile whose command is `/bin/cat` plus the
absolute fixture path, or open a fresh profile running `/bin/zsh -f` with no shell
integration and make the fixture the first emitted stream. Use a new tab/session for
every case. OSC 133 state can survive until a later `A`, so cases must never share a
session.

Before each batch, record:

- iTerm version and build;
- profile name and terminal dimensions;
- whether **Show mark indicators** is enabled;
- whether automatic shell integration is disabled for the clean profile;
- fixture SHA-256.

## Layer 1: raw protocol fixtures

Create `scripts/iterm-mark-lab.zsh` with these operations:

```text
--list                     list stable case IDs and parameters
--emit CASE                write one raw stream to stdout
--build DIRECTORY          write one .ansi file per case plus manifest.tsv
--explain CASE             print the escaped, human-readable stream
```

The `.ansi` files must contain real ESC and BEL bytes. The manifest must contain the
escaped representation and SHA-256 so a capture can always be tied to its source.

Use fixed visible text:

```text
~ ❯ sh -c 'printf "nope\n"; exit 1'
nope
⏎ 1
● kronuz at test-host
~ ❯
```

Do not put explanatory labels inside the raw stream. Labels change rows and may become
part of iTerm's command or output ranges.

### Axes

Generate the full valid cross-product of these axes. Reject combinations that contain
an unterminated OSC or `B` without an active `A`.

| Axis | Values |
| --- | --- |
| live prompt region | none, `A … B` |
| redraw action | none, cursor erase only, parameterless `D` then erase |
| collapsed region | none, `A … B` |
| completion placement | before status, after status, both |
| next prompt region | none, `A … B` |
| boundary identity | anonymous, one shared `aid`, new `aid` for next prompt |
| `C` form | `C`, `C;\r` |

Keep status text either entirely outside OSC sequences or reject the case. In
particular, never generate this unterminated form:

```text
\e]133;D;1⏎ 1
\e]133;A\a
```

### Start with discriminating cases

Run these before the full cross-product:

1. iTerm's ordinary official sequence without a redraw. This is the positive control.
2. The restored KronuZSH baseline.
3. Baseline with `D;1` moved after the status and directly beside `A`.
4. A marked live prompt with erase only and no second `A`.
5. An unmarked live prompt with `A/B` only after the erase.
6. Parameterless abort before erase, with fresh collapsed `A/B`.
7. Duplicate `D;1`, before and after status.

Cases 2 through 7 have already appeared in the real prompt experiments. Repeating them
as raw fixtures is useful only as a comparison between the protocol-only and ZLE-backed
results, not as another proposed fix.

## Layer 2: exact ZLE redraw capture

Build a minimal interactive Zsh harness that does not source KronuZSH. It should:

1. define a fixed two-line `PROMPT` and fixed one-line transient prompt;
2. install only `precmd`, `preexec`, and one custom `accept-line` widget;
3. accept the same fixed failure command;
4. write the pty byte stream with `script`;
5. produce a second escaped transcript where ESC, BEL, CR, LF, CSI, OSC, and visible
   text are tokenized without changing their order.

The harness must parameterize the same marker axes as Layer 1. This isolates ZLE from
KronuZSH's syntax highlighting, async prompt work, title changes, OSC 7, and OSC 1337.

Then add features back in this order:

1. two-line-to-one-line `reset-prompt` only;
2. typed-buffer syntax highlighting;
3. KronuZSH's transient dimming;
4. title OSCs;
5. OSC 7 and OSC 1337 metadata;
6. the full KronuZSH prompt.

Stop at the first layer where UI results diverge. That identifies the interaction
instead of merely producing another long trace.

## Layer 3: results ledger

Add `iterm-transient-prompt-results.tsv` with one row per fresh iTerm session:

```text
date	iterm_build	layer	case	fixture_sha256	command_mark	status_mark	live_mark	command_color	select_output	info_status	notes
```

Use controlled values for marker columns: `none`, `blue`, `red`, `other`. Describe a
position as a row name, not "first" or "second": `collapsed-command`, `status`,
`live-dot`.

Screenshots may accompany a row, but the TSV is authoritative because it remains
searchable and comparable.

## Decision process

1. Verify the official no-redraw positive control. If it fails, the clean profile is
   contaminated or the iTerm build has a broader regression.
2. Compare each raw fixture with its minimal-ZLE counterpart.
3. If raw succeeds and ZLE fails, investigate redraw coordinates rather than OSC order.
4. If both fail identically, reduce the protocol case further.
5. If one case meets all four success conditions, reproduce it three times in fresh
   sessions before changing KronuZSH.
6. Port only that exact lifecycle into `lib/prompt.zsh`.
7. Recheck failure, success, blank Enter, Ctrl-C, multiline input, and consecutive
   commands.
8. Only then update `prompt.md` and the blog article.

## If the matrix finds no valid case

Prepare a minimal iTerm2 issue using the smallest Layer-2 harness, its escaped pty
capture, the corresponding raw fixture, and the results ledger. Ask specifically how a
shell should relocate a marked prompt during a ZLE in-place redraw without creating an
additional visible mark. Reference the existing `D` finalization report, but keep the
new reproduction focused on transient prompt relocation.
