# Prompt survey

There is no recognized shell-prompt awards program or canonical “top 100.” This
shortlist combines GitHub adoption (checked 2026-07-24), inclusion in the maintained
Awesome Zsh and Oh My Zsh galleries, recent maintenance, community recommendations,
and visual distinctness. Stars select candidates; they do not decide fidelity.

The follow-up inventory of the 143-theme Oh My Zsh bundle, Prezto, Zim, Zsh's native
themes, and grml is in [`framework-survey.md`](framework-survey.md).

| Candidate | GitHub stars | Archetype | Declarative skin |
| --- | ---: | --- | --- |
| Starship | 59,057 | cross-shell module engine | surveyed |
| Powerlevel10k | 54,787 | Zsh dashboard/powerline | surveyed |
| Oh My Posh | 23,151 | cross-shell theme engine | surveyed |
| Spaceship | 20,546 | two-line environment dashboard | surveyed |
| Pure | 14,362 | minimal two-line | `pure.zsh` |
| powerline-shell | 6,291 | classic segmented ribbon | surveyed |
| Liquidprompt | 4,665 | adaptive information prompt | surveyed |
| Agnoster | 4,226 | conditional powerline ribbon | `agnoster.zsh` |
| oh-my-git | 3,714 | dense Git state | surveyed |
| powerline-go | 2,889 | cross-shell powerline | surveyed |
| Bullet Train | 2,839 | developer powerline dashboard | surveyed |
| Geometry | 994 | minimal left, Git right | `geometry.zsh` |
| Typewritten | 950 | prompt left, project/Git right | `typewritten.zsh` |
| promptline.vim | 627 | Vim-airline-generated powerline | surveyed |
| Jovial | 562 | responsive developer prompt | surveyed |
| Silver | 503 | cross-shell icon powerline | surveyed |
| Lambda Mod | 470 | two-line lambda/Git | `lambda-mod.zsh` |
| Passion | 358 | colorful Oh My Zsh prompt | surveyed |
| Agkozak | 352 | portable asynchronous ASCII | surveyed |
| Alien | 349 | asynchronous powerline | surveyed |
| Polyglot | 194 | portable ASCII Git prompt | surveyed |
| Aphrodite | 177 | minimal cross-shell | surveyed |
| Sobole | 165 | spacious two-line prompt | `sobole.zsh` |
| Ultima | 132 | modern structured multiline | surveyed |
| Pi | 111 | compact π/Git prompt | `pi.zsh` |
| Roundy | 58 | rounded powerline blocks | surveyed |

“Surveyed” means retained for capture and design analysis, not rejected. A skin is
added when its distinguishing layout can be expressed with comments and `KZ_*`
assignments only. Full paired ANSI captures live in `dev/skin-captures.ansi` and are
regenerated with:

```sh
python3 dev/generate-skin-captures.py > dev/skin-captures.ansi
```
