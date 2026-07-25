# Framework prompt survey

Snapshot taken 2026-07-24. This complements `prompt-survey.md`, which started with
standalone prompt projects.

| Collection | Pinned revision | Bundled prompt inventory |
| --- | --- | ---: |
| Oh My Zsh | `b37dd49ca5bf` | 143 themes |
| Prezto | `cff2d0187142` | 16 prompt implementations |
| Zsh 5.9.2 `promptinit` | release 5.9.2 | 18 themes (including off/restore) |
| Zim framework gallery | site/repositories below | 11 featured themes |
| grml | `a175434e64a0` | one highly configurable prompt system |

Oh My Zsh itself describes its bundle as 150 themes; the checked-out revision contains
143 `themes/*.zsh-theme` files. Prezto includes Agnoster, Cloud, Damoekri, Giddie,
Kylewest, Minimal, Nicoulaj, Paradox, Peepcode, Powerlevel10k, Powerline, Pure, Skwp,
Smiley, Sorin, and Steeef. Zsh ships Adam1/2, Bart, Bigfade, Clint, Elite/Elite2,
Fade, Fire, Oliver, Pws, Redhat, Suse, Walters, and Zefram plus control themes.
Zim features Agnoster, Asciiship, Bira, Eriner, Gitster, Hometown, Magicmace, Minimal,
S1ck94, Sorin, and Steeef.

## Implemented in this pass

Sixteen additional declarative skins were selected to cover distinct visual families,
not merely variations in hue:

- Oh My Zsh: AF-Magic, Bira, Cloud, DST, Fino, Itchy, Kiwi, Lukerandall, Pygmalion,
  Steeef, Sunaku, and Ys.
- Zsh `promptinit`: Redhat, Suse, Walters, and Zefram.

Several overlap across frameworks: Prezto carries Cloud and Steeef; Zim carries Bira
and Steeef. One compatibility skin therefore covers multiple framework origins.

## Engine gaps found and filled

Framework prompts repeatedly needed the same state that had previously been trapped
inside the built-in renderer. The engine now exposes:

- `git.repo`, `git.clean`, `git.detached`, and `git.action` flags/state;
- exact `git.tag` and short `git.commit`;
- normalized `venv.name` and `duration`.

These are populated once by the existing gitstatus/fallback and precmd paths. No skin
adds a hook, function, subprocess, or theme-specific engine branch.

Remaining common gaps are repository-relative path formatting, commit age, Mercurial/
Subversion state, language/runtime versions, and arbitrary width-aware segment joining.
Those need separate design work; they were not papered over with executable skin code.
