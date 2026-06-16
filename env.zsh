# env.zsh: environment, for ALL shells (sourced via ~/.zshenv).
# Keep this generic; machine-specific PATH/exports go in local.zsh.

export EDITOR=vim
export VISUAL=vim
export PAGER=less

# less: stay in the terminal, no wrap, case-insensitive search, keep colors.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Default locale only if the terminal didn't set one.
[[ -z "$LANG" ]] && export LANG='en_US.UTF-8'

# lesspipe: let `less` peek inside archives/binaries, if it's installed.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# Keep path-like arrays unique (no duplicate entries).
typeset -gU cdpath fpath mailpath path

# macOS: `open` is the browser.
[[ "$OSTYPE" == darwin* ]] && export BROWSER='open'
