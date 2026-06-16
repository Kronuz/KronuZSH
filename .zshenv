# Used when this repo is the ZDOTDIR (sandbox: `ZDOTDIR=. zsh`), and as the target
# for your real ~/.zshenv. Environment for ALL shells (interactive or not).
# init.zsh also sources env.zsh, so a .zshrc-only install still gets it.
source "${0:A:h}/env.zsh"
