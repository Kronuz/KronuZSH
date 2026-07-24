# Skins

A **skin** reshapes the KronuZSH prompt without touching the engine. The whole visible
layout is deferred, so a skin is just a few variables you set *after* the prompt loads
(from `~/.zshrc.local`); the change takes effect at the next render, no rebuild.

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
| `PROMPT_KRONUZ_PROMPT`           | the live left prompt (one line, or two via `$kz[nl]`) |
| `PROMPT_KRONUZ_RPROMPT`          | the right prompt                                      |
| `PROMPT_KRONUZ_TRANSIENT_PROMPT` | the collapsed scrollback prompt (`''` disables it)    |

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
PROMPT_KRONUZ_PALETTE_OCEAN='#3a7bd5'
PROMPT_KRONUZ_PROMPT='${kz[FG.ocean]}${kz[pwd]}${kz[RESET]} ${kz[caret]}'
```

That creates `$kz[FG.ocean]` and `$kz[BG.ocean]`. Prefer those over raw `%F{#...}` /
`%K{#...}` escapes; raw braces can also break inside `${var:+...}` conditionals.

Single `$kz[<name>]` segments resolve because the doubled `${(e)${(e)...}}` in
`PROMPT` runs two expansion passes: first the layout, then the segments it names. You can
also override an individual segment (`PROMPT_KRONUZ_GIT`, `PROMPT_KRONUZ_PWD`, ...) to
reshape just that piece.

## Verify it

The OSC 133 / iTerm 1337 shell-integration marks stay wrapped around whatever a skin
renders, but a malformed layout can still drop them. Always check:

```zsh
dev/preview-skin.py skins/minimal.zsh   # prints a preview and asserts the marks survive
```

## Reformatting git

Most skins just place `$kz[git]` (the engine's own git segment) in the layout. To
render git *differently* (robbyrussell's `git:(branch)`, an emoji, a powerline segment),
override `PROMPT_KRONUZ_GIT` and compose it from the git-state keys the engine
computes every prompt (from gitstatusd, or the direct-git fallback):

| Variable                                                                               | Value                                      |
| -------------------------------------------------------------------------------------- | ------------------------------------------ |
| `$kz[git.branch]`                                                                      | branch / tag / short commit, `''` off-repo |
| `$kz[git.dirty]`                                                                       | non-empty when there are changes           |
| `$kz[git.staged]` / `$kz[git.unstaged]` / `$kz[git.untracked]` / `$kz[git.conflicted]` | count, `''` when zero                      |
| `$kz[git.ahead]` / `$kz[git.behind]` / `$kz[git.stashed]`                              | count, `''` when zero                      |
| `$kz[git.remote]`                                                                      | `remote/branch`, `''` when none            |

Each is empty when absent, so a plain `${var:+...}` tests it — no hook, no arithmetic,
and it works under both gitstatusd and the fallback:

```zsh
PROMPT_KRONUZ_GIT='${kz[git.branch]:+ ${kz[FG.blue]}git:(${kz[FG.red]}${kz[git.branch]}${kz[FG.blue]})${kz[RESET]}${kz[git.dirty]:+ ${kz[FG.yellow]}✗${kz[RESET]}}}'
```

**Use `${kz[FG.name]}` for colour inside a `${var:+...}` conditional, not a literal
`%F{...}`.** A bare `}` (from `%F{blue}`) ends the conditional early and truncates the
segment; `${kz[FG.blue]}` is a balanced `${...}` and survives. Use `${kz[BG.name]}` for
powerline-style backgrounds. `robbyrussell.zsh`, `pure.zsh`, `emoji.zsh`, and
`powerline.zsh` all follow this.

## Gallery

| Skin               | Look                                                           |
| ------------------ | -------------------------------------------------------------- |
| `kronuz.zsh`       | the built-in layout, written out and annotated to copy + tweak |
| `minimal.zsh`      | a single spare line: path, git, a lone magenta caret           |
| `classic.zsh`      | the plain bash look: `user@host:dir$`                          |
| `retro.zsh`        | a green-CRT DOS memory: `C:\dir\>`                             |
| `pure.zsh`         | two lines, Sindre Sorhus's Pure: blue path, grey branch, `❯`   |
| `robbyrussell.zsh` | oh-my-zsh's default: `➜ dir git:(branch) ✗`                    |
| `emoji.zsh`        | playful all-emoji: `📁 dir 🌿 branch ⚡`                          |
| `powerline.zsh`    | agnoster-style coloured segments with Nerd Font separators     |
