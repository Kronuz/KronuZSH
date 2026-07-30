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

At that point, the safe state was the restored baseline. It had one known placement
problem but did not contain any of the additional duplicate-mark regressions above.

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

## Successful post-OSC-7 retest

Retested on 2026-07-29 after the OSC 7 suppression had shipped. The test restored
`A`/`B` around the full live prompt while retaining fresh `A`/`B` around the collapsed
transient redraw. This time the independent OSC 7 mark producer was absent.

For `false`, the observed result was:

1. The command stopped counting immediately after completion.
2. Its marker was red and reported a running time of 0:00.036.
3. The new waiting prompt had one blue triangle.
4. The `⏎ 1` status line had no additional triangle.

This is the intended result. The live `A` is also required semantically because iTerm2
does not fully finalize `D;<status>` until the following `A`.

## Remote regression, and the positional fix that replaced OSC 7 suppression

On 2026-07-30 the duplicate mark returned, but only over a remote connection
(iTerm2 -> Eternal Terminal -> dev VM). A raw sniff of the remote prompt showed OSC 7
present, OSC 1337 absent, and the generic `\e]133;C\a` (not iTerm's `C;\r`): on the
remote `_kz_is_iterm` was 0. The cause is the transport, not the shell — `et` (7.0.0)
forwards no environment, so `LC_TERMINAL`/`TERM_PROGRAM` never reach the remote and
`_kz_osc_detect_iterm` cannot recognise the far-end iTerm2. The OSC 7 suppression above
was keyed entirely on that detection, so it never triggered remotely and OSC 7 flowed to
the real iTerm2 again.

Rather than widen the (inherently fragile) detection, the fix removes the dependency on it
by acting on the *position* of OSC 7 instead of suppressing it. OSC 7 had been emitted from
`precmd`, before the visible status row printed, so its cursor sat on the status line and
that is where iTerm2's mark landed. It now rides inside `_kz_osc_a`, immediately after the
`133;A` byte, so it is emitted only once the status row has already printed and the cursor
is on the `A` line. Whatever iTerm2 version does with OSC 7 — create a mark at the cursor
(3.7.0beta7) or nothing at all (the mark producer is absent from the current source, whose
OSC 7 path only tracks the directory) — the result is the same single prompt mark on the
`A` line, because a mark on the `A` line and the `A` mark are the same line. OSC 7 is
therefore emitted unconditionally (it is near-universal, only Alacritty ignores it, and a
local terminal ignores a remote `file://HOST/PATH`), and OSC 7 covers cwd for terminals
that do not read iTerm2's OSC 1337 `CurrentDir`.

The same "emit, don't detect" principle then applies to the OSC 1337 handshake itself.
iTerm2's own integration script (`iterm2.com/shell_integration/zsh`) gates *only* the
`133;C;\r` on `TERM_PROGRAM=iTerm.app`; it sends `ShellIntegrationVersion`, `RemoteHost`,
and `CurrentDir` to every terminal, because a non-iTerm terminal simply ignores the
proprietary OSC 1337. KronuZSH now does the same: those three are emitted unconditionally,
which restores full iTerm2 fidelity *over ssh/et* (per-host history/dirs, profile
switching, scp, and remote cwd — iTerm2 ignores an OSC 7 path whose host is not local, so
`CurrentDir` is what carries the remote directory) without any detection. `%n@%M` resolves
to the same `user@FQDN` iTerm2's own `$USER@$(hostname -f)` would, on the remote host too,
so the recorded host is correct across the connection. The `_kz_is_iterm` variable is
removed entirely; the sole remaining terminal gate is an inline
`TERM_PROGRAM==iTerm.app || LC_TERMINAL==iTerm2` check in `_kz_osc_preexec` for the
CR-terminated command form (`LC_TERMINAL` kept because it survives ssh forwarding).

For consistency the whole per-prompt context — `RemoteHost`, `CurrentDir`, `133;A`, OSC 7 —
now rides in one zero-width bundle inside `_kz_osc_a`, on the mark's own line, rather than
splitting OSC 1337 into precmd and OSC 7 into the boundary. Only `ShellIntegrationVersion`
stays a once-per-shell precmd announcement.

Byte-level verification (raw sniff, remote `false`, iTerm2 undetectable over the
transport): the completion stream is now `133;D;1`, then the status row, then
`1337;RemoteHost` + `1337;CurrentDir` + `133;A` + `\e]7;file://HOST/path`, then `133;B` —
the full host/cwd handshake and both prompt-mark boundaries co-located on the `A` line,
nothing before the status row, and `ShellIntegrationVersion` fired once earlier in the
shell. The real-iTerm-UI confirmation (one blue triangle on the waiting prompt, none on
`⏎ 1`) is the remaining check per the test plan, and can be done locally:
the change now sends OSC 7 to local iTerm2 as well, so a single triangle locally proves the
positional collapse holds. If it does not, revert this one change and fall back to the
detection-based suppression above.
