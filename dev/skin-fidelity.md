# Skin fidelity

Named compatibility skins are tested as visual targets. “Looks inspired by” is not
enough for the featured gallery.

## Reference versions

| Skin | Upstream | Audited revision |
| --- | --- | --- |
| `agnoster.zsh` | `agnoster/agnoster-zsh-theme` | `6bba672c7812` |
| `pure.zsh` | `sindresorhus/pure` | `89c9e30a38d3` |
| `robbyrussell.zsh` | `ohmyzsh/ohmyzsh` | `b37dd49ca5bf` |

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
| Agnoster | 98% | gitstatus replaces `vcs_info`; same visible default states |
| Pure | 93% | no Node/Nix/custom hook fields; Git state comes from gitstatus |
| robbyrussell | 100% | gitstatus replaces Oh My Zsh's Git helper |

Powerlevel10k, Spaceship, and Starship were evaluated but rejected as compatibility
skins: their default environment/tool module range cannot reach 90% with KronuZSH's
current normalized state. Native skins remain free to be original designs.
