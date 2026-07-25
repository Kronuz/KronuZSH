# direnv example

Enter this directory, approve its `.envrc`, and inspect the exported value:

```zsh
cd dev/direnv-example
direnv allow
print -r -- "$KRONUZSH_DIRENV_EXAMPLE"
# loaded from direnv-example
```

The prompt shows `env:direnv-example` while this environment is detected. Leaving
the directory restores the previous environment:

```zsh
cd ..
print -r -- "${KRONUZSH_DIRENV_EXAMPLE:-unset}"
# unset
```

After changing `.envrc`, direnv blocks it again until you review the diff and run
`direnv allow`.
