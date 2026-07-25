# direnv: load and unload project-specific environment variables as directories
# change. direnv requires explicit approval for each new or changed .envrc.
# install: brew install direnv · apt/dnf install direnv
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
