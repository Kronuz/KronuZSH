# Shared Kronuz theme files

`Kronuz.tmTheme` (dark) and `Kronuz-Light.tmTheme` are the TextMate colour themes
shared by the tool integrations that highlight code with a TextMate/syntect engine:

- **bat** and **git-delta** — registered into bat's theme cache by
  [`../bat/setup.sh`](../bat/setup.sh) (`BAT_THEME=Kronuz`, `delta.syntax-theme = Kronuz`).
- **yazi** — its file preview (`syntect_theme`) points here, wired by
  [`../yazi/setup.sh`](../yazi/setup.sh).

**These files are generated, do not edit them by hand.** They come from the canonical
Kronuz theme (the single source of truth) in
[`kronuz-theme-vscode`](https://github.com/Kronuz/kronuz-theme-vscode) via its
`build.mjs`, which emits the identical theme for VS Code, Sublime Text
([`Kronuz-Theme`](https://github.com/Kronuz/Kronuz-Theme)) and TextMate (here). The
light variant is derived mathematically from the dark one. To change a colour, edit the
canonical source and regenerate.
