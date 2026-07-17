# aliases.zsh: the genuinely useful ones. Add your own freely, right here.

# ls: color + group dirs first + classify, GNU or BSD/macOS.
if ls --version &>/dev/null; then
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
alias b='${(z)BROWSER}'                 # `b URL` opens $BROWSER
alias p='${(z)PAGER}'                   # explicit pager, normally less

# Open a file or URL in the desktop environment.
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif (( $+commands[xdg-open] )); then
  alias o='xdg-open'
elif (( $+commands[termux-open] )); then
  alias o='termux-open'
fi

alias df='df -kh'                       # human-readable filesystem usage
alias du='du -kh'                       # human-readable directory usage
alias diffu='diff --unified'
alias http-serve='python3 -m http.server'
alias po='popd'
alias pu='pushd'

# AUTO_PUSHD keeps this stack populated: `d` shows it, and 1..9 jump to an
# entry by the number printed at its left.
alias d='dirs -v'
alias -- -='cd -'   # toggle back to the previous directory
for _index ({1..9}) alias "$_index"="cd +$_index"
unset _index

# Interactive-safe variants, opt-in (they do NOT shadow rm/mv/cp).
alias rmi='rm -i'
alias mvi='mv -i'
alias cpi='cp -i'
alias lni='ln -i'
