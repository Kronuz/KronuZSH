# zsh-autoenv example

Enter this directory and approve its `.autoenv.zsh` at the inline prompt:

```zsh
cd dev/autoenv-example
# Review the displayed file, then type: yes
print -r -- "$KRONUZSH_AUTOENV_EXAMPLE"
# loaded from autoenv-example
```

The prompt shows `env:autoenv-example` while the environment is loaded. The example
also makes the hostname green and the working directory green (tomato as root).

The `autostash` calls preserve the previous values and parameter attributes. Leaving
the directory restores both the previous environment and prompt without a separate
leave file:

```zsh
cd ..
print -r -- "${KRONUZSH_AUTOENV_EXAMPLE:-unset}"
# unset
```

After changing `.autoenv.zsh`, zsh-autoenv displays the new content and asks for
authorization again as part of the next directory entry.
