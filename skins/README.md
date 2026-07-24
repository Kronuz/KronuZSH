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
venv jobs nl time pwd prompt overwrite vim emacs` — plus any `$col[...]` / `$glyph[...]`
or normal zsh prompt escapes (`%~`, `%n`, `%m`, `%c`, `%F{...}`, `%K{...}`). `$kronuz[]`
is the palette (the composed segments); PS1/RPS1 are the layout that arranges them.

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

## Gallery

| Skin            | Look                                                        |
| --------------- | ---------------------------------------------------------- |
| `minimal.zsh`   | a single spare line: path, git, a lone magenta caret       |
| `classic.zsh`   | the plain bash look: `user@host:dir$`                      |
| `retro.zsh`     | a green-CRT DOS memory: `C:\dir\>`                          |
