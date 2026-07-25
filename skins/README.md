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

## Writing one

Three knobs, each a deferred `${...}` string re-evaluated every render:

| Variable                         | What it is                                            |
| -------------------------------- | ----------------------------------------------------- |
| `KZ_PROMPT_PROMPT`           | the live left prompt (one line, or two via `$kz[nl]`) |
| `KZ_PROMPT_RPROMPT`          | the right prompt                                      |
| `KZ_PROMPT_TRANSIENT_PROMPT` | the collapsed scrollback prompt (`''` disables it)    |

Compose them from the unified `$kz` array:

- **UPPERCASE keys are presentation**: `$kz[FG.red]`, `$kz[BG.blue]`, `$kz[BOLD]`,
  `$kz[UNDERLINE]`, `$kz[STANDOUT]`, `$kz[RESET]`, and glyphs like `$kz[GLYPH.caret]`.
- **lowercase keys are content**: segment handles like `$kz[git]`, `$kz[pwd]`,
  `$kz[caret]`, `$kz[nl]`, plus live git state like `$kz[git.branch]` and
  `$kz[git.dirty]`.

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

Other normalized state useful to skins includes `$kz[venv.name]` and
`$kz[duration]`. They are empty when inactive.

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
| `kronuz.zsh`       | the built-in layout, written out and annotated to copy + tweak |
| `minimal.zsh`      | a single spare line: path, git, a lone magenta caret           |
| `classic.zsh`      | the plain bash look: `user@host:dir$`                          |
| `retro.zsh`        | a green-CRT DOS memory: `C:\dir\>`                             |
| `pure.zsh`         | Pure-compatible two-line path/Git/context/status prompt         |
| `robbyrussell.zsh` | Oh My Zsh's default: `➜ dir git:(branch) ✗`                     |
| `emoji.zsh`        | playful all-emoji: `📁 dir 🌿 branch ⚡`                          |
| `agnoster.zsh`     | Agnoster's path/Git ribbon; optional segments documented         |
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
