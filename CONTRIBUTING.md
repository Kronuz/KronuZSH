# Contributing to KronuZSH

KronuZSH is deliberately small and opinionated. Contributions are welcome when
they improve the complete setup without turning it into a general-purpose framework:
keep only broadly useful behavior, prefer native Zsh over another dependency, and put
each change in the file whose name describes it.

## Where changes belong

- `runcoms/` contains the shell entry points corresponding to `~/.*` files.
- `lib/` contains the core interactive-shell behavior, one concern per file.
- `integrations/<tool>/` contains optional runtime wiring, setup, and themes for one
  external tool.
- `plugins/` contains pinned upstream projects as Git submodules. Do not copy their
  source into KronuZSH.

Keep gitstatus first and fast-syntax-highlighting last in `lib/plugins.zsh`; the latter
wraps ZLE widgets and must load after anything that defines them. Prompt changes should
preserve the deferred expansion described in `prompt.md` and `AGENTS.md`.

## Checks

Run the same syntax checks as CI:

```sh
for file in runcoms/* lib/*.zsh integrations/*.zsh integrations/*/*.zsh zshrc.local.example; do
  zsh -n "$file" || exit
done
for file in install.sh install.lib.sh integrations/setup.sh integrations/*/setup.sh; do
  bash -n "$file" || exit
done
shellcheck --external-sources install.sh install.lib.sh integrations/setup.sh integrations/*/setup.sh
bash scripts/check-integrations.sh
```

For prompt behavior, also start a real interactive Zsh in a PTY. A manual
`${(e)PROMPT}` expansion is useful for inspection but does not prove that live
`PROMPT_SUBST` rendering works.

## Attribution

KronuZSH is MIT-licensed and includes code adapted from Prezto. Preserve existing
provenance comments and copyright notices. New third-party code must have a compatible
license and clear attribution.
