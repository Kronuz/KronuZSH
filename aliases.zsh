# aliases.zsh: the genuinely useful ones. Add your own freely, right here.

# ls: color + group dirs first + classify, GNU or BSD/macOS.
if ls --color=auto -d . &>/dev/null; then
  alias ls='ls --color=auto --group-directories-first -F'   # GNU coreutils
else
  alias ls='ls -GF'                                         # BSD / macOS
fi
alias l='ls -1A'      # one per line, including hidden
alias ll='ls -lh'     # long, human-readable sizes
alias la='ls -lhA'    # long, including hidden
alias lr='ll -R'      # long, recursive

alias grep='grep --color=auto'
alias mkdir='mkdir -p'        # make parents as needed
alias _='sudo'
alias e='${(z)VISUAL:-${(z)EDITOR}}'   # `e file` opens $EDITOR
alias po='popd'
alias pu='pushd'

# Interactive-safe variants, opt-in (they do NOT shadow rm/mv/cp).
alias rmi='rm -i'
alias mvi='mv -i'
alias cpi='cp -i'
