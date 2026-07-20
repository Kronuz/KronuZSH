# iTerm2 transient-prompt marker experiments

This is a record of failed experiments, not an implementation guide. It exists so the
same OSC 133 arrangements are not proposed and tested again without new evidence.

Last tested: 2026-07-19, in iTerm2 3.7.0beta7 with KronuZSH's transient prompt enabled
and **Show mark indicators** visible. The test command was:

```sh
sh -c 'printf "nope\n"; exit 1'
```

The desired result is one red triangle beside the collapsed failed command and one blue
triangle beside the next live prompt's `●`. There should be no triangle beside the
temporary `⏎ 1` status row.

## Protocol facts we verified

The four OSC 133 boundaries are:

```text
\e]133;A\a       prompt starts
\e]133;B\a       prompt ends, command line starts
\e]133;C;\r\a    command output starts, matching iTerm2's zsh form
\e]133;D;1\a     command finishes with exit status 1
```

All sequences shown here use `\e` for ESC and `\a` for BEL. Newlines are shown as
`\n` only when their position matters.

iTerm2 does not fully finalize `D` until it receives the following `A`. This is also
reported in [iTerm2 issue 12382](https://gitlab.com/gnachman/iterm2/-/issues/12382).
The version-14 integration shipped by iTerm uses the same `C;\r` and `D;<status>` forms
as KronuZSH. iTerm's [shell-integration documentation](https://iterm2.com/documentation-shell-integration.html)
describes blue prompt marks and red failed-command marks.

Raw interactive pty captures were useful for proving byte order and exit status. They
cannot prove gutter-marker placement or color. Every result below was checked in the
actual iTerm UI.

## Restored baseline

`lib/prompt.zsh` has been restored to the state from before these experiments.

With transience enabled, the live prompt is unmarked. Pressing Enter replaces it with a
collapsed prompt wrapped in `A` and `B`. `C` is emitted by `preexec`, and `D;<status>`
is emitted directly by the next `precmd`. The following full live prompt is unmarked.

Simplified failure trace:

```text
\e]133;A\a~ ❯ sh -c 'printf "nope\n"; exit 1'\e]133;B\a\n
\e]133;C;\r\anope\n
\e]133;D;1\a
⏎ 1\n
● kronuz at ...
```

Observed problem: a blue marker appears at the completion boundary before the status
row. In a following successful example, another blue marker appeared at the boundary
before the next `●` row. This baseline preserves transient-prompt behavior but does not
produce the intended marker placement.

## Failed experiment 1: mark both live and collapsed prompts

Change:

- Always put `A` and `B` around the full live prompt.
- On Enter, emit a parameterless `D` to abort that provisional region.
- Put fresh `A` and `B` around the collapsed redraw.
- Keep emitting `D;<status>` directly from `precmd`.

Relevant shape:

```text
\e]133;A\a[full live prompt]\e]133;B\a
\e]133;D\a
\e]133;A\a[collapsed prompt + command]\e]133;B\a\n
\e]133;C;\r\a[output]
\e]133;D;1\a
⏎ 1\n
\e]133;A\a● kronuz at ...\e]133;B\a
```

Observed result: two blue triangles, one beside `⏎ 1` and one beside `●`. The
parameterless abort did not disappear from the UI as expected.

## Failed experiment 2: add iTerm2 `aid` identifiers

Change:

- Give `A`, `B`, `C`, and `D` the same per-command `aid`.
- Reuse that `aid` for the collapsed redraw.
- Initially announce shell-integration version 14, then version 17 to match the script
  bundled with iTerm2 3.7.0beta7.

Example boundaries:

```text
\e]133;A;aid=123-1\a
\e]133;B;aid=123-1\a
\e]133;C;aid=123-1\r\a
\e]133;D;1;aid=123-1\a
```

Observed result with both version announcements: unchanged. Blue triangles still
appeared beside both `⏎ 1` and `●`. Do not retry `aid` merely by changing the announced
version.

## Failed experiment 3: reuse the live mark across `reset-prompt`

Change:

- Mark the full live prompt with `A` and `B`.
- Let ZLE's `reset-prompt` redraw it without emitting another `A` or `B`.
- Continue with `C` and `D;<status>`.

Observed result: worse. The blue triangles beside `⏎ 1` and `●` remained, and the
collapsed command line gained another blue triangle instead of a red one. A raw byte
trace looked linear, but iTerm's retained screen coordinates did not behave as assumed.

## Failed experiment 4: defer `D;<status>` until immediately before `A`

This fixed one part of the problem and is worth distinguishing from a complete fix.

Change:

- Store `D;1` during `precmd` instead of printing it immediately.
- Render the visible status first.
- Put `D;1` immediately beside the next prompt's `A`.
- Still abort the provisional live region and mark the collapsed redraw separately.

Relevant completion:

```text
⏎ 1\n
\e]133;D;1\a\e]133;A\a● kronuz at ...\e]133;B\a
```

Observed result: the collapsed command finally had the correct red triangle. However,
a blue triangle still appeared beside `⏎ 1`, and another appeared beside `●`. Deferring
`D` fixed status association but did not remove the extra aborted/live mark.

## Failed experiment 5: defer `D` and remove the abort

Change:

- Keep the successful deferred `D;1` ordering from experiment 4.
- Remove the parameterless abort `D`.
- Mark the first collapsed prompt, then try to reuse later live prompt regions across
  `reset-prompt` without emitting another `A`.

Observed result: unchanged from experiment 4. The command marker was red, but blue
triangles remained beside both `⏎ 1` and `●`.

## Failed experiment 6: send `D;<status>` twice

Tested sequence:

```text
\e]133;D;1\a
⏎ 1\n
\e]133;D;1\a\e]133;A\a● kronuz at ...
```

Observed result: it did not remove the extra marker.

An unterminated variation must not be retried:

```text
\e]133;D;1⏎ 1
\e]133;A\a
```

Without the first `\a`, the visible status and nested ESC sequence become part of one
OSC payload. The status will not render normally and the inner `A` is not a separate
boundary.

## What would count as new evidence

Do not make another sequence-only change unless it adds information unavailable in the
experiments above. Useful next steps could include:

- an iTerm2 debug log showing the semantic-prompt state transitions and mark identities;
- a minimal standalone reproducer, without KronuZSH or ZLE highlighting, that performs
  the same `reset-prompt` redraw;
- confirmation from iTerm2's implementation or maintainer about how OSC 133 marks are
  expected to survive a ZLE in-place redraw;
- an iTerm2 change that explicitly addresses `D` finalization or transient prompts.

Until then, the safe state is the restored baseline. It has one known placement problem
but does not contain any of the additional duplicate-mark regressions above.

## Source-level finding after these experiments

On 2026-07-19, iTerm2 source commit
`9272e49d03728e4f56dc18c93a7d2f20bcb3aa73` identified a second, independent mark
producer. OSC 7 is not merely a directory update in iTerm2. Its
`setWorkingDirectoryFromURLString` path calls `setPathFromURL`, which calls both
`insertNewlinesBeforeAddingPromptMarkAfterPrompt:` and `setPromptStartLine:`. The latter
creates or reuses a blue prompt mark at the cursor position where OSC 7 arrived.

KronuZSH emitted OSC 7 during `precmd`, before the visible status and prompt, while also
emitting OSC 133 prompt marks. That explains blue triangles which none of the OSC 133
reorderings removed. iTerm2's own source contains a nearby warning that adjacent prompt
marks can occur when a shell sends OSC 7 and also has shell integration installed.

The next source-driven experiment therefore does not rearrange OSC 133. It suppresses
OSC 7 only in iTerm2, where KronuZSH already emits `OSC 1337;CurrentDir` and
`OSC 1337;RemoteHost`. Other terminals continue receiving OSC 7.
