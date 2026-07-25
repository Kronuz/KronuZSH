# Shared Kronuz theme files

`Kronuz.tmTheme` (dark) and `Kronuz-Light.tmTheme` are the TextMate colour themes
shared by the tool integrations that highlight code with a TextMate/syntect engine:

- **bat** and **git-delta** — registered into bat's theme cache by
  [`../bat/setup.sh`](../bat/setup.sh) (`BAT_THEME=Kronuz`, `delta.syntax-theme = Kronuz`).
- **yazi** — its file preview (`syntect_theme`) points here, wired by
  [`../yazi/setup.sh`](../yazi/setup.sh).

The TextMate root foreground uses syntect's terminal-default sentinel (`#00000001`).
The fallback scope `source, text - text.plain` restores the canonical true-color
foreground for every highlighted grammar. Consequently plain/unknown text emits no
foreground ANSI, while highlighted files retain a coherent Kronuz palette without any
filename or language detection in the shell integration.

**These files are generated, do not edit them by hand.** They come from the canonical
Kronuz theme (the single source of truth) in
[`KronuzTheme`](https://github.com/Kronuz/KronuzTheme) via its
`build.mjs`, which emits the identical theme for VS Code, Sublime Text
([`kronuz-theme-sublime`](https://github.com/Kronuz/kronuz-theme-sublime)) and TextMate (here). The
light variant is derived mathematically from the dark one. To change a colour, edit the
canonical source and regenerate.
