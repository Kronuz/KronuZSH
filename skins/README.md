# Skins

A **skin** reshapes the KronuZSH prompt without touching the engine. The whole visible
layout is deferred, so a bundled skin contains only declarative `KZ_*` assignments
(plus comments and blank lines), set *after* the prompt loads from `~/.zshrc.local`.
No functions, hooks, commands, or other executable prompt code belong in a skin.
The change takes effect at the next render, no rebuild.

## Using one

Source a skin from your `~/.zshrc.local` (which `runcoms/zshrc` loads last):

```zsh
source "$KRONUZSH/skins/minimal.zsh"
```

Or copy the two or three lines you like straight into `~/.zshrc.local` and tweak them.

When switching between bundled skins, reset the previous layout first so an option that
the new skin does not set cannot leak through:

```zsh
kz_skin "$KRONUZSH/skins/spaceship.zsh"
```

Skin names are resolved from the bundled gallery, so the shorter forms work too:

```zsh
kz_skin spaceship
```

Use the comment-only `reset` skin to return to the built-in prompt:

```zsh
kz_skin reset
```

`kz_skin <TAB>` completes every bundled skin name.

The `.zsh` suffix is optional. A readable path is also accepted when importing or
developing a skin outside the gallery.

`kz_skin` clears every `KZ_PROMPT_*` setting before sourcing the selected skin. Put
machine-specific prompt overrides after `kz_skin` in `~/.zshrc.local` when you want
them to survive a skin change. Direct `source` remains useful when deliberately
layering a small override on top of an existing skin.

## Writing one

Four knobs, each a deferred `${...}` string re-evaluated every render:

| Variable                         | What it is                                            |
| -------------------------------- | ----------------------------------------------------- |
| `KZ_PROMPT_PREPROMPT`        | the preprompt, printed above the prompt (default `$kz[status]`; `''` prints nothing) |
| `KZ_PROMPT_PROMPT`           | the live left prompt (one line, or two via `$kz[NL]`)                              |
| `KZ_PROMPT_RPROMPT`          | the right prompt                                                                   |
| `KZ_PROMPT_TRANSIENT_PROMPT` | the collapsed scrollback prompt (`''` disables it)                                 |

Compose them from the unified `$kz` array:

- **UPPERCASE keys are presentation**: `$kz[FG.red]`, `$kz[BG.blue]`, `$kz[BOLD]`,
  `$kz[UNDERLINE]`, `$kz[STANDOUT]`, `$kz[RESET]`, `$kz[NL]`, and glyphs like
  `$kz[GLYPH.caret]`.
- **lowercase keys are content**: segment handles like `$kz[git]`, `$kz[pwd]`,
  `$kz[caret]`, `$kz[caret_past]`, plus live git state like `$kz[git.branch]` and
  `$kz[git.dirty]`, the failed-exit / slow-command status `$kz[status]` and raw
  `$kz[status.exit]` / `$kz[status.duration]`, and session flags
  `$kz[context.ssh]` / `$kz[context.container]`.

Normal zsh prompt escapes (`%~`, `%n`, `%m`, `%c`) still work. PROMPT/RPROMPT are the
layout that arranges these pieces.

Custom RGB colors go through the palette so they stay `NO_COLOR`-safe:

```zsh
KZ_PROMPT_PALETTE_OCEAN='#3a7bd5'
KZ_PROMPT_PROMPT='${kz[FG.ocean]}${kz[pwd]}${kz[RESET]} ${kz[caret]}'
```

That creates `$kz[FG.ocean]` and `$kz[BG.ocean]`. Prefer those over raw `%F{#...}` /
`%K{#...}` escapes; raw braces can also break inside `${var:+...}` conditionals.

Single `$kz[<name>]` segments resolve because the doubled `${(e)${(e)...}}` in
`PROMPT` runs two expansion passes: first the layout, then the segments it names. You can
also override an individual segment (`KZ_PROMPT_GIT`, `KZ_PROMPT_PWD`, ...) to
reshape just that piece.

## Verify it

The OSC 133 / iTerm 1337 shell-integration marks stay wrapped around whatever a skin
renders, but a malformed layout can still drop them. Always check:

```zsh
dev/preview-skin.py skins/minimal.zsh   # prints a preview and asserts the marks survive
```

## Reformatting git

Most skins just place `$kz[git]` (the engine's own git segment) in the layout. To
render git *differently* (robbyrussell's `git:(branch)` or an emoji),
override `KZ_PROMPT_GIT` and compose it from the git-state keys the engine
computes every prompt (from gitstatusd, or the direct-git fallback):

| Variable                                                                               | Value                                      |
| -------------------------------------------------------------------------------------- | ------------------------------------------ |
| `$kz[git.repo]` / `$kz[git.clean]` / `$kz[git.dirty]`                                  | state flags, `1` when true                  |
| `$kz[git.branch]`                                                                      | branch / tag / short commit, `''` off-repo |
| `$kz[git.tag]` / `$kz[git.commit]` / `$kz[git.detached]`                               | exact ref details and detached-state flag   |
| `$kz[git.action]`                                                                      | rebase/merge/etc., `''` when inactive       |
| `$kz[git.staged]` / `$kz[git.unstaged]` / `$kz[git.untracked]` / `$kz[git.conflicted]` | count, `''` when zero                      |
| `$kz[git.ahead]` / `$kz[git.behind]` / `$kz[git.stashed]`                              | count, `''` when zero                      |
| `$kz[git.remote]`                                                                      | `remote/branch`, `''` when none            |

Other normalized state useful to skins includes `$kz[status]` (the inline styled
failed-exit / slow-command line, empty on a clean fast command),
`$kz[status.exit]`, `$kz[status.duration]`, `$kz[venv.name]`, `$kz[context.ssh]`, and
`$kz[context.container]`. They are empty when inactive, except `status.exit`, which
contains `0` after a successful command; both context flags can be set when an SSH
session runs inside a container.
Bundled skins must consume these public keys rather than private `$_kz_*` engine
state; `dev/check-skins.zsh` enforces that boundary.

Each is empty when absent, so a plain `${var:+...}` tests it — no hook, no arithmetic,
and it works under both gitstatusd and the fallback:

```zsh
KZ_PROMPT_GIT='${kz[git.branch]:+ ${kz[FG.blue]}git:(${kz[FG.red]}${kz[git.branch]}${kz[FG.blue]})${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.yellow]}✗${kz[RESET]}}}'
```

**Use `${kz[FG.name]}` for colour inside a `${var:+...}` conditional, not a literal
`%F{...}`.** A bare `}` (from `%F{blue}`) ends the conditional early and truncates the
segment; `${kz[FG.blue]}` is a balanced `${...}` and survives. Use `${kz[BG.name]}`
for powerline-style backgrounds. `robbyrussell.zsh`, `pure.zsh`, and `emoji.zsh`
all follow the balanced foreground form.

## The preprompt, and moving the status line

`KZ_PROMPT_PREPROMPT` is the **preprompt** — a fourth layout knob (with `KZ_PROMPT_PROMPT`,
`KZ_PROMPT_RPROMPT`, and `KZ_PROMPT_TRANSIENT_PROMPT`) whose value is printed as output on
its own row *above* the prompt, once per command. It is composed from `$kz[...]` like the
others. Its default is the status line:

```zsh
KZ_PROMPT_PREPROMPT='$kz[status]'   # the built-in default: exit code / duration above the prompt
KZ_PROMPT_PREPROMPT=''              # print nothing above the prompt
KZ_PROMPT_PREPROMPT='${kz[status]} $(date +%H:%M)'   # or inject anything else
```

Since it is output (not part of the prompt), it stays in scrollback as the prompt
collapses, never acquires a terminal mark, and survives a screen clear like iTerm2's Cmd-K
without reappearing.

To move the status *elsewhere*, empty the preprompt and place `$kz[status]` where you want
it — for example right-aligned on the caret line via `KZ_PROMPT_RPROMPT`:

```zsh
KZ_PROMPT_PREPROMPT=''
KZ_PROMPT_RPROMPT='${kz[status]:+$kz[status] }$kz[mode_overwrite]$kz[vim]$kz[emacs]'
```

Because the right prompt is redrawn each prompt and dropped when the line collapses, a
status placed there is compact and live-only: it shows while you decide the next command
and vanishes when it runs, never entering scrollback. See `skins/status-right.zsh`.
`$kz[status.duration]` (the raw duration string) is available too for a custom split.

### Preprompt recipes

A few one-liners, each a `KZ_PROMPT_PREPROMPT=...` you can drop in `~/.zshrc.local`.
`${(pl:$COLUMNS::─:)}` is a full-width rule (pure parameter expansion, no subshell);
`$kz[NL]` is a newline for a multi-line preprompt.

```zsh
# A full-width rule above every command: muted normally, red when the last one failed.
# Separates commands in scrollback and makes failures easy to spot. (skins/preprompt-rule.zsh)
KZ_PROMPT_PREPROMPT='${${kz[status]:+${kz[FG.red]}}:-${kz[FG.muted]}}${(pl:$COLUMNS::─:)}${kz[RESET]}'

# A red rule ONLY when a command failed (nothing otherwise) — minimal failure marker.
KZ_PROMPT_PREPROMPT='${kz[status]:+${kz[FG.red]}${(pl:$COLUMNS::─:)}${kz[RESET]}}'

# The full path on its own line above, so the prompt line stays short in deep trees.
KZ_PROMPT_PREPROMPT='${kz[FG.gray]}%~${kz[RESET]}'

# A blank line above each prompt, for breathing room.
KZ_PROMPT_PREPROMPT=' '

# Keep the status, and add a muted rule under it.
KZ_PROMPT_PREPROMPT='${kz[status]:+$kz[status]${kz[NL]}}${kz[FG.muted]}${(pl:$COLUMNS::─:)}${kz[RESET]}'
```

Anything a prompt string can hold works, including `$(...)` command substitution (run each
prompt, so keep it cheap) — e.g. `KZ_PROMPT_PREPROMPT='${kz[status]} $(date +%H:%M)'`.

## Compatibility skins

Names borrowed from another prompt are compatibility targets, not loose inspiration.
Their defaults are compared against pinned upstream versions over clean and dirty
repositories, success and failure, nested paths, virtualenvs, jobs, and duration where
the upstream supports them. The score records how much is faithfully reproducible; a
sub-90% candidate stays available with its missing states documented so it can be
judged from the side-by-side ANSI captures rather than discarded automatically. See
[`dev/skin-fidelity.md`](../dev/skin-fidelity.md) for the scope and score.

Broad environment dashboards such as Powerlevel10k, Spaceship, and Starship remain
reference candidates. KronuZSH can reproduce their core layouts, but declarative
configuration cannot yet cover all language, cloud, package, battery, and tool state.

## Gallery

| Skin               | Look                                                           |
| ------------------ | -------------------------------------------------------------- |
| `kronuz.zsh`       | the built-in prompt, written out and annotated to copy + tweak |
| `minimal.zsh`      | a single spare line: path, git, a lone magenta caret           |
| `classic.zsh`      | the plain bash look: `user@host:dir$`                          |
| `retro.zsh`        | a green-CRT DOS memory: `C:\dir\>`                             |
| `pure.zsh`         | Pure-compatible two-line path/Git/context/status prompt         |
| `robbyrussell.zsh` | Oh My Zsh's default: `➜ dir git:(branch) ✗`                     |
| `emoji.zsh`        | playful all-emoji: `📁 dir 🌿 branch ⚡`                          |
| `agnoster.zsh`     | Agnoster's path/Git ribbon; optional segments documented         |
| `eriner.zsh`       | Zim Eriner's cyan/yellow powerline variant                       |
| `asciiship.zsh`    | Zim's readable two-line branch/status prompt                     |
| `gitster.zsh`      | Zim Gitster's compact arrow and Git verdict                      |
| `zim-minimal.zsh`  | Zim Minimal's lambda with right-aligned path/Git                 |
| `s1ck94.zsh`       | Zim S1ck94's arrow with right-aligned repository state            |
| `sorin.zsh`        | Zim/Prezto Sorin's blue path and Git RPROMPT                     |
| `magicmace.zsh`    | Zim Magicmace's bracketed path and long rule                     |
| `hometown.zsh`     | Zim Hometown's timestamped multiline layout                      |
| `powerlevel10k.zsh`| Powerlevel10k's compact two-line classic                       |
| `spaceship.zsh`    | Spaceship's directory/context/Git layout                         |
| `starship.zsh`     | Starship's broadly portable two-line shape                       |
| `liquidprompt.zsh` | Liquid Prompt's adaptive directory/VCS core                      |
| `geometry.zsh`     | Geometry's sparse left prompt and Git RPROMPT                     |
| `typewritten.zsh`  | Typewritten's prompt-left, context-right layout                   |
| `lambda-mod.zsh`   | Lambda Mod's two-line lambda/Git prompt                           |
| `pi.zsh`           | compact `π: project branch ❯`                                     |
| `sobole.zsh`       | Sobole's spacious two-line path/Git prompt                        |
| `af-magic.zsh`     | full-width dashed header, path/Git and context RPROMPT             |
| `bira.zsh`         | rounded two-line user/path/Git prompt                              |
| `cloud.zsh`        | compact cyan cloud prompt                                           |
| `dst.zsh`          | failure banner, user/path and clock RPROMPT                         |
| `fino.zsh`         | elegant two-line prose prompt                                       |
| `itchy.zsh`        | user/path over a happy-or-sad face                                  |
| `kiwi.zsh`         | framed `kiwish` two-line prompt                                     |
| `lukerandall.zsh`  | bold user/path and punctuation Git state                            |
| `pygmalion.zsh`    | high-voltage user@host:path prompt                                  |
| `steeef.zsh`       | prose-like user at host in path                                     |
| `sunaku.zsh`       | Git-first status stream                                             |
| `ys.zsh`           | explanatory two-line context/Git/time prompt                        |
| `zsh-redhat.zsh`   | Zsh's bundled Red Hat prompt                                        |
| `zsh-suse.zsh`     | Zsh's bundled SUSE prompt                                           |
| `zsh-walters.zsh`  | Zsh's bundled Walters prompt                                        |
| `zsh-zefram.zsh`   | Zsh version/user/host/path prompt                                   |
