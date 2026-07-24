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

| Variable                   | What it is                                            |
| -------------------------- | ----------------------------------------------------- |
| `PROMPT_KRONUZ_PS1`        | the live left prompt (one line, or two via `$kronuz[nl]`) |
| `PROMPT_KRONUZ_RPS1`       | the right prompt                                      |
| `PROMPT_KRONUZ_TRANSIENT`  | the collapsed scrollback prompt (`''` disables it)    |

Compose them from the segment palette `$kronuz[<name>]` — `os err info context etctl git
venv jobs nl time pwd caret transcaret overwrite vim emacs` — plus any `$fcol[...]` (foreground) /
`$bcol[...]` (background) / `$glyph[...]` or normal zsh prompt escapes (`%~`, `%n`, `%m`,
`%c`, `%F{...}`, `%K{...}`). `$kronuz[]` is the palette (the composed segments); PS1/RPS1
are the layout that arranges them.

Single `$kronuz[<name>]` segments resolve because the doubled `${(e)${(e)...}}` in
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

Most skins just place `$kronuz[git]` (the engine's own git segment) in the layout. To
render git *differently* (robbyrussell's `git:(branch)`, an emoji, a powerline segment),
override `PROMPT_KRONUZ_GIT` and compose it from the git-state variables the engine
computes every prompt (from gitstatusd, or the direct-git fallback):

| Variable                        | Value                                     |
| ------------------------------- | ----------------------------------------- |
| `_prompt_kronuz_git_branch`     | branch / tag / short commit, `''` off-repo |
| `_prompt_kronuz_git_dirty`      | non-empty when there are changes          |
| `_prompt_kronuz_git_staged` / `_unstaged` / `_untracked` / `_conflicted` | count, `''` when zero |
| `_prompt_kronuz_git_ahead` / `_behind` / `_stashed` | count, `''` when zero          |
| `_prompt_kronuz_git_remote`     | `remote/branch`, `''` when none           |

Each is empty when absent, so a plain `${var:+...}` tests it — no hook, no arithmetic,
and it works under both gitstatusd and the fallback:

```zsh
PROMPT_KRONUZ_GIT='${_prompt_kronuz_git_branch:+ ${fcol[blue]}git:(${fcol[red]}${_prompt_kronuz_git_branch}${fcol[blue]})${fcol[none]}${_prompt_kronuz_git_dirty:+ ${fcol[yellow]}✗${fcol[none]}}}'
```

**Use `${fcol[name]}` for colour inside a `${var:+...}` conditional, not a literal
`%F{...}`.** A bare `}` (from `%F{blue}`) ends the conditional early and truncates the
segment; `${fcol[blue]}` is a balanced `${...}` and survives. The palette has every named
colour (`blue`, `cyan`, `red`, ...); `$fcol` is the foreground, `$bcol` the matching
background (`${bcol[green]}`, for powerline-style segments). `robbyrussell.zsh`,
`pure.zsh`, `emoji.zsh`, and `powerline.zsh` all follow this.

## Gallery

| Skin               | Look                                                            |
| ------------------ | -------------------------------------------------------------- |
| `default.zsh`      | the built-in layout, written out and annotated to copy + tweak |
| `minimal.zsh`      | a single spare line: path, git, a lone magenta caret           |
| `classic.zsh`      | the plain bash look: `user@host:dir$`                          |
| `retro.zsh`        | a green-CRT DOS memory: `C:\dir\>`                              |
| `pure.zsh`         | two lines, Sindre Sorhus's Pure: blue path, grey branch, `❯`   |
| `robbyrussell.zsh` | oh-my-zsh's default: `➜ dir git:(branch) ✗`                    |
| `emoji.zsh`        | playful all-emoji: `📁 dir 🌿 branch ⚡`                       |
| `powerline.zsh`    | agnoster-style coloured segments with Nerd Font separators     |
