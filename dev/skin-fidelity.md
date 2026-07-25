# Skin fidelity

Named compatibility skins are tested as visual targets. “Looks inspired by” is not
enough for the featured gallery.

The broader candidate list and selection signals are recorded in
[`prompt-survey.md`](prompt-survey.md). Literal paired terminal output is committed as
[`skin-captures.ansi`](skin-captures.ansi); view it with `less -R`.

## Reference versions

| Skin | Upstream | Audited revision |
| --- | --- | --- |
| `agnoster.zsh` | `agnoster/agnoster-zsh-theme` | `6bba672c7812` |
| `pure.zsh` | `sindresorhus/pure` | `89c9e30a38d3` |
| `robbyrussell.zsh` | `ohmyzsh/ohmyzsh` | `b37dd49ca5bf` |
| `geometry.zsh` | `geometry-zsh/geometry` | `0f82c567db27` |
| `typewritten.zsh` | `reobin/typewritten` | `06f8575e2479` |
| `lambda-mod.zsh` | `halfo/lambda-mod-zsh-theme` | `f8b6ca5e348b` |
| `pi.zsh` | `tobyjamesthomas/pi` | `96778f903b79` |
| `sobole.zsh` | `sobolevn/sobole-zsh-theme` | `7eb032e07afd` |
| `af-magic.zsh` through `ys.zsh` | `ohmyzsh/ohmyzsh` | `b37dd49ca5bf` |
| `zsh-*.zsh` | Zsh `promptinit` | `5.9.2` |

The comparison uses raw prompt cells and SGR styles rather than screenshots, avoiding
font rasterization and antialiasing noise. The terminal font still determines the
physical shape of glyphs.

## Matrix and scoring

Each applicable upstream state is rendered in an isolated interactive zsh PTY:

- ordinary and deeply nested working directories;
- no repository, clean Git, dirty Git, ahead/behind, and stash;
- successful and failed commands;
- virtualenv, background jobs, remote context, and command duration.

Score weights are visible text/glyphs/spacing 40%, foreground/background/style 25%,
conditional state coverage 25%, and line/RPROMPT placement 10%. Unsupported upstream
states count against coverage; they are not silently removed from the denominator.

| Skin | Fidelity | Deliberate engine substitutions |
| --- | ---: | --- |
| Agnoster | 76% overall; 100% path/Git | conditional status/context/venv segments omitted |
| Pure | 93% | no Node/Nix/custom hook fields; Git state comes from gitstatus |
| robbyrussell | 100% | gitstatus replaces Oh My Zsh's Git helper |
| Geometry | 88% | commit age and clean marker omitted |
| Typewritten | 94% | aggregate normalized Git state replaces porcelain categories |
| Lambda Mod | 86% | commit-SHA RPROMPT and detached-head text omitted |
| Pi | 96% | repo-relative path is approximated by basename |
| Sobole | 91% | clean marker and alternate-user condition omitted |
| New Oh My Zsh set | 88–100% | runtime/Hg/SVN fields documented per capture |
| Zsh Redhat/Suse/Walters/Zefram | 98–100% | Zefram omits nested-shell depth |

Sub-90% skins are retained with their gaps stated. Powerlevel10k, Spaceship, and
Starship were evaluated but do not yet have useful declarative candidates: their
environment/tool module range overwhelms the core visual match. Native skins remain
free to be original designs.

## Side-by-side ANSI

The notation below is zsh's prompt-level ANSI (`%F`/`%K`); `print -P` turns it into
terminal SGR bytes without depending on a screenshot or font rasterizer.

### Agnoster, clean repository

```text
upstream  %K{blue}%F{black} %~ %K{green}%F{blue}%F{black}  main %k%F{green}%f
skin      %K{blue}%F{black} %~ %K{green}%F{blue}%F{black}  main %k%F{green}%f
```

### Agnoster, dirty repository

```text
upstream  %K{blue}%F{black} %~ %K{yellow}%F{blue}%F{black}  main ± %k%F{yellow}%f
skin      %K{blue}%F{black} %~ %K{yellow}%F{blue}%F{black}  main ± %k%F{yellow}%f
```

The upstream may prepend status/context and insert virtualenv before the path; the
declarative skin cannot conditionally join those ribbons. That missing matrix coverage,
not the cells shown above, accounts for Agnoster's score.
