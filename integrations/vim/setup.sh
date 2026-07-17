# shellcheck shell=bash
# vim / neovim: (1) link the bundled Kronuz colorscheme (./colors/kronuz.vim) into the
# dir each looks in, and (2) offer to turn it on in your rc. We never silently rewrite
# your config: if the rc already loads kronuz we leave it; otherwise, on a real terminal
# we ask (kz_confirm), and only on "yes" append a clearly-marked, removable block (backing
# the rc up first). Force the answer with KRONUZ_VIM_AUTORC=1 / KRONUZ_VIM_NOAUTORC=1, or
# the global KRONUZ_YES / KRONUZ_NO. Sourced by ../setup.sh at install time; idempotent.
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

# wire the colorscheme into an rc, asking first unless overridden. $1 = rc, $2 = vim|lua,
# $3 = editor label (vim/neovim)
_kronuz_vim_wire() {
  _kronuz_rc="$1"; _kronuz_lang="$2"; _kronuz_ed="$3"
  # already loads kronuz? leave it untouched (idempotent)
  if [ -f "$_kronuz_rc" ] && grep -qi kronuz "$_kronuz_rc" 2>/dev/null; then
    kz_ok "$_kronuz_ed" "already enabled in $(kz_tilde "$_kronuz_rc")"
    return 0
  fi
  _kronuz_yes=0
  if [ -n "${KRONUZ_VIM_NOAUTORC:-}" ]; then
    _kronuz_yes=0
  elif [ -n "${KRONUZ_VIM_AUTORC:-}" ]; then
    _kronuz_yes=1
  elif kz_confirm "Enable the Kronuz colorscheme in $(kz_tilde "$_kronuz_rc")"; then
    _kronuz_yes=1
  fi
  if [ "$_kronuz_yes" = 0 ]; then
    kz_skip "$_kronuz_ed" "colorscheme linked, not enabled"
    kz_info "enable later: add 'silent! colorscheme kronuz' to $(kz_tilde "$_kronuz_rc")"
    return 0
  fi
  mkdir -p "$(dirname "$_kronuz_rc")"
  if [ -f "$_kronuz_rc" ]; then
    _kronuz_vbak="$(kz_backup "$_kronuz_rc")"
    kz_info "backed up $(kz_tilde "$_kronuz_rc") -> $(kz_tilde "$_kronuz_vbak")"
  fi
  _kronuz_vim_block "$_kronuz_lang" >> "$_kronuz_rc"
  kz_ok "$_kronuz_ed" "colorscheme enabled in $(kz_tilde "$_kronuz_rc")"
}

if command -v vim >/dev/null 2>&1; then
  mkdir -p "$HOME/.vim/colors"
  ln -sf "$_kronuz_vim_src" "$HOME/.vim/colors/kronuz.vim"
  _kronuz_vim_wire "$HOME/.vimrc" vim vim
fi

if command -v nvim >/dev/null 2>&1; then
  _kronuz_nvim="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  mkdir -p "$_kronuz_nvim/colors"
  ln -sf "$_kronuz_vim_src" "$_kronuz_nvim/colors/kronuz.vim"
  # nvim loads init.lua OR init.vim (both at once is an error) — wire whichever is in play
  if [ -f "$_kronuz_nvim/init.lua" ]; then
    _kronuz_vim_wire "$_kronuz_nvim/init.lua" lua neovim
  else
    _kronuz_vim_wire "$_kronuz_nvim/init.vim" vim neovim
  fi
  unset _kronuz_nvim
fi

unset -f _kronuz_vim_block _kronuz_vim_wire 2>/dev/null
unset _kronuz_vim_dir _kronuz_vim_src _kronuz_rc _kronuz_lang _kronuz_ed _kronuz_vbak _kronuz_yes 2>/dev/null
