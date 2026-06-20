# vim / neovim: (1) link the bundled Kronuz colorscheme (./colors/kronuz.vim) into the
# dir each looks in, and (2) offer to turn it on in your rc. We never silently rewrite
# your config: if the rc already loads kronuz we leave it; otherwise, on a real terminal
# we ask, and only on "yes" append a clearly-marked, removable block (backing the rc up
# first); off a terminal we just print the snippet. Force the answer with
# KRONUZ_VIM_AUTORC=1 (always add) or KRONUZ_VIM_NOAUTORC=1 (never). POSIX sh, sourced by
# ../setup.sh at install time; idempotent.
_kronuz_vim_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_kronuz_vim_src="$_kronuz_vim_dir/colors/kronuz.vim"

# the marked block we append, in vimscript or lua (nvim init.lua)
_kronuz_vim_block() {  # $1 = vim|lua
  if [ "$1" = lua ]; then
    cat <<'RC'

-- >>> kronuzsh (Kronuz colorscheme) >>>
-- Added by kronuzsh integrations/vim/setup.sh; delete this block to opt out.
vim.opt.termguicolors = true
-- vim.g.kronuz_transparent = 1   -- uncomment to inherit your terminal background
pcall(vim.cmd, 'colorscheme kronuz')
-- <<< kronuzsh (Kronuz colorscheme) <<<
RC
  else
    cat <<'RC'

" >>> kronuzsh (Kronuz colorscheme) >>>
" Added by kronuzsh integrations/vim/setup.sh; delete this block to opt out.
syntax on
if has('termguicolors')
  set termguicolors
endif
" let g:kronuz_transparent = 1   " uncomment to inherit your terminal background
silent! colorscheme kronuz
" <<< kronuzsh (Kronuz colorscheme) <<<
RC
  fi
}

_kronuz_vim_hint() {  # $1 = rc path
  echo "kronuzsh: to enable it, add 'silent! colorscheme kronuz' (+ 'set termguicolors') to $1"
}

# wire the colorscheme into an rc, asking first unless overridden. $1 = rc, $2 = vim|lua
_kronuz_vim_wire() {
  _kronuz_rc="$1"; _kronuz_lang="$2"
  # already loads kronuz? leave it untouched (idempotent)
  if [ -f "$_kronuz_rc" ] && grep -qi kronuz "$_kronuz_rc" 2>/dev/null; then
    return 0
  fi
  if [ -n "$KRONUZ_VIM_NOAUTORC" ]; then
    _kronuz_vim_hint "$_kronuz_rc"; return 0
  elif [ -n "$KRONUZ_VIM_AUTORC" ]; then
    :
  elif [ -t 0 ] && [ -t 1 ]; then
    printf 'kronuzsh: turn on the Kronuz colorscheme in %s? [y/N] ' "$_kronuz_rc"
    read _kronuz_ans 2>/dev/null || _kronuz_ans=
    case "$_kronuz_ans" in
      [yY]|[yY][eE][sS]) ;;
      *) _kronuz_vim_hint "$_kronuz_rc"; return 0 ;;
    esac
  else
    _kronuz_vim_hint "$_kronuz_rc"; return 0
  fi
  mkdir -p "$(dirname "$_kronuz_rc")"
  [ -f "$_kronuz_rc" ] && cp -p "$_kronuz_rc" "$_kronuz_rc.kronuz.bak" && \
    echo "kronuzsh: backed up $_kronuz_rc -> $_kronuz_rc.kronuz.bak"
  _kronuz_vim_block "$_kronuz_lang" >> "$_kronuz_rc"
  echo "kronuzsh: enabled the Kronuz colorscheme in $_kronuz_rc"
}

if command -v vim >/dev/null 2>&1; then
  mkdir -p "$HOME/.vim/colors"
  ln -sf "$_kronuz_vim_src" "$HOME/.vim/colors/kronuz.vim"
  echo "kronuzsh: linked Kronuz colorscheme into ~/.vim/colors"
  _kronuz_vim_wire "$HOME/.vimrc" vim
fi

if command -v nvim >/dev/null 2>&1; then
  _kronuz_nvim="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  mkdir -p "$_kronuz_nvim/colors"
  ln -sf "$_kronuz_vim_src" "$_kronuz_nvim/colors/kronuz.vim"
  echo "kronuzsh: linked Kronuz colorscheme into $_kronuz_nvim/colors"
  # nvim loads init.lua OR init.vim (both at once is an error) — wire whichever is in play
  if [ -f "$_kronuz_nvim/init.lua" ]; then
    _kronuz_vim_wire "$_kronuz_nvim/init.lua" lua
  else
    _kronuz_vim_wire "$_kronuz_nvim/init.vim" vim
  fi
  unset _kronuz_nvim
fi

unset -f _kronuz_vim_block _kronuz_vim_hint _kronuz_vim_wire 2>/dev/null
unset _kronuz_vim_dir _kronuz_vim_src _kronuz_rc _kronuz_lang _kronuz_ans 2>/dev/null
