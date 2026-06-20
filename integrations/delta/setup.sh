# git-delta: use it as git's diff pager and `git add -p` highlighter, guarded with
# `command -v delta` so a box without delta falls back to less/cat. Set in the global
# gitconfig (the env can't carry interactive.diffFilter), idempotent: re-running just
# re-sets the same keys. POSIX sh, sourced by ../setup.sh at install time.
# install: brew install git-delta · cargo install git-delta
if command -v git >/dev/null 2>&1; then
  git config --global core.pager \
    'if command -v delta >/dev/null 2>&1; then delta; else less; fi'
  git config --global interactive.diffFilter \
    'if command -v delta >/dev/null 2>&1; then delta --color-only; else cat; fi'
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  # Kronuz diff colors: warm-tinted add/remove backgrounds to match the theme.
  git config --global delta.plus-style        'syntax #26331a'
  git config --global delta.minus-style       'syntax #3a1d1d'
  git config --global delta.plus-emph-style    'syntax #34471f'
  git config --global delta.minus-emph-style   'syntax #57231f'
  # Kronuz syntax highlighting in diffs, but only if bat built that theme.
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    git config --global delta.syntax-theme Kronuz
  fi
  echo "configured git to use delta when available (falls back to less)"
fi
