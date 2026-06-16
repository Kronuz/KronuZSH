# AGENTS.md: working on kronuzsh

A thin, prezto-free zsh setup. Read `README.md` for what it is and how to install
it; this file is how to **extend** it without breaking the prompt.

## Design

Own the whole thing, no framework. Everything kept is either mine (the prompt) or
a standalone plugin. The prompt was ported off a prezto theme; its prezto
dependencies were replaced with small native pieces:

| prezto gave | replaced by |
| --- | --- |
| `git-info` + `async` worker | gitstatus (gitstatusd) + a direct-`git` fallback |
| `python-info` (venv) | `_kronuz_venv_segment` ($VIRTUAL_ENV) |
| `editor-info` (keymap) | `_kronuz_editor_info` (zle hooks) |
| `prompt-pwd` | `${(%):-%~}` in precmd |
| `spectrum` ($col) | the `col` palette is defined inline in `prompt.zsh` |

Dropped from the prezto version: the `async` worker (gitstatusd is the async
engine), `pmodload`/`vcs_info`, and a stray debug `echo >> /tmp/prompt_kronuz` that
ran on every precmd.

## Load order (`init.zsh`)

`env → options → history → completion → keybindings → aliases → terminal →
plugins → prompt → prompt_kronuz_setup`, then `local.zsh` and `~/.zshrc.local`.
`$KRONUZSH` is the repo dir. `env.zsh` is also meant to be sourced by `~/.zshenv`
(env for all shells); `init.zsh` self-sources it so a `.zshrc`-only install works.

The bar for adding anything: keep only the **genuinely useful** part, lean and in
an obviously-named file, and prefer zsh-native over a vendored module (that's why
there's no `safe-paste` module, no `spectrum`, no `terminal` module — the useful
bit of each is a few native lines). Don't re-import prezto's breadth wholesale.

In `plugins.zsh` the order matters: **gitstatus first**, autosuggestions and
history-substring-search next, **fast-syntax-highlighting LAST** (it wraps ZLE
widgets, so anything that defines widgets must come before it).

## The prompt, and how it renders (read before editing `prompt.zsh`)

The prompt is built from deferred strings that are evaluated at every render. Two
things make it work; keep both intact:

1. **`prompt_opts=(cr percent sp subst)`** sets `PROMPT_SUBST`, so the `${(e)...}`
   inside `$PROMPT` are parameter-expanded on each display.
2. **`${(e)...}` recurses**: one `${(e)}` pass resolves a value that itself
   contains further `$`-expansions, down through the color layers.

### Colors (two layers)

- **Base palette**: `col[red]='%F{1}'`, `col[darkorange]='%F{208}'`, ... (name to a
  zsh `%F{N}` escape). Defined inline near the top of `prompt.zsh`.
- **Semantic layer**: `prompt_kronuz_colors` sets
  `DEFAULT_PROMPT_KRONUZ_COLOR_<NAME>='$col[...]'` (e.g. `..._BRANCH='%B$col[white]'`),
  in both the 256-color and 8-color branches. A loop in `prompt_kronuz_setup` then
  builds `col[<name>]="${(e)PROMPT_KRONUZ_COLOR_<NAME>:-$DEFAULT_PROMPT_KRONUZ_COLOR_<NAME>}"`.

So `${(e)col[branch]}` yields the final `%F{N}`, and any semantic color is
overridable by exporting `PROMPT_KRONUZ_COLOR_<NAME>` (e.g. in `local.zsh`). The
**host** color is special: green when `$ET_VERSION` is set (inside an Eternal
Terminal session), yellow otherwise.

### Segments

Each segment is a deferred string `kronuz[x]="${(e)PROMPT_KRONUZ_X:-$DEFAULT_PROMPT_KRONUZ_X}"`,
and `PROMPT`/`RPROMPT` splice the `$kronuz[...]` together. Dynamic data is computed
in `prompt_kronuz_precmd` (pwd, venv, git) into vars the deferred strings read
(`_prompt_kronuz_pwd`, `python_info[virtualenv]`, `_prompt_kronuz_git`).

Current layout:
`PROMPT = err info etctl git venv error \n time pwd prompt`,
`RPROMPT = overwrite vim emacs`.

### Add a segment

1. (if it needs a new color) add the name to the `COLORS` list and set
   `DEFAULT_PROMPT_KRONUZ_COLOR_<NAME>` in **both** branches of `prompt_kronuz_colors`.
2. Define `DEFAULT_PROMPT_KRONUZ_<NAME>` (its content; reference `$col[...]` and any
   dynamic var). Use `\${...}` to keep `$` deferred, matching the surrounding code.
3. Define `kronuz[<name>]="\${(e)PROMPT_KRONUZ_<NAME>:-\$DEFAULT_PROMPT_KRONUZ_<NAME>}"`.
4. Splice `$kronuz[<name>]` into `PROMPT` or `RPROMPT`.
5. If dynamic, compute its value in `prompt_kronuz_precmd`.

The **etctl** segment (driven by `$ETCTL_SESSION`) and **venv** segment are the
two cleanest examples to copy.

### git segment

`_kronuz_git_segment` queries the `KRONUZ` gitstatusd instance and maps
`VCS_STATUS_*` to the branch/icons. If gitstatusd isn't up (no tty, not installed,
download blocked) it calls `_kronuz_git_fallback`, a lean direct-`git` version, so
the prompt always shows git info. gitstatus only distinguishes counts
(staged/unstaged/untracked/conflicted), not added-vs-deleted-vs-renamed, so the
icon set is a small simplification of the old prezto one.

## Add a plugin

```bash
git submodule add https://github.com/owner/name plugins/name
```
Then `source "$KRONUZSH/plugins/name/name.plugin.zsh"` in `plugins.zsh`, respecting
the load order (fast-syntax-highlighting stays last). Bind keys after sourcing.

## Testing (no real terminal needed for most of it)

- **Syntax**: `zsh -n <file>`.
- **Sandbox** (doesn't touch the real shell):
  `ZDOTDIR=. HISTFILE=/tmp/kz-hist zsh -i`.
- **Render the prompt the real way — in a pty.** The reliable test is an actual
  interactive shell: a fresh `etctl open` to a host where kronuzsh is installed
  shows the live prompt (and starts `gitstatusd`, which needs a tty), or a local
  pty (`script -q /dev/null zsh -i`, or a Python `pty.fork`).
- **Beware the false positive.** `prompt_kronuz_precmd; print -rP -- "${(e)PROMPT}"`
  expands the segments manually with `${(e)}`, which **bypasses `PROMPT_SUBST`** — it
  renders fine even when the live prompt is broken. (This masked two real bugs: a
  missing `setopt PROMPT_SUBST`, and that the prompt is dead without it.) Use it
  only as a quick structural check, never as proof it works.
- **gitstatusd needs a tty** (job control). In a no-tty `zsh -ic` it won't start and
  the fallback runs; test the real daemon in a terminal (or an etctl VM pty).
- The **vi/emacs keymap arrow** (`❯`) is set by a `zle-line-init` hook, so it only
  shows in a live ZLE. To preview it: set `editor_info[keymap]` from the
  `:kronuz:editor:keymap:primary` zstyle and re-render.

## gitstatusd deployment

Downloaded, not compiled: the plugin fetches a prebuilt binary for the platform
into `~/.cache/gitstatus/` on first start (GitHub releases). Nothing is committed.
On a locked-down host where the download is blocked, build once
(`plugins/gitstatus/build -w`, needs cmake + a C++ compiler) or scp the cached
binary over. The prompt's fallback covers the gap meanwhile.

## Commits

- Author as **Germán Méndez Bravo \<german.mb@gmail.com\>** (the public identity).
- No `Co-authored-by: Copilot` trailer. If signing prompts, `git -c commit.gpgsign=false commit`.
