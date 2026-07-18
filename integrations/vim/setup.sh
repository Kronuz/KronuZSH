# shellcheck shell=bash
# Vim / Neovim: link the colorscheme into each editor's runtime and optionally append
# a marked, removable activation block to its config.

_kronuz_vim_block() {
  if [ "$1" = lua ]; then
    cat <<'RC'

-- >>> kronuzsh (Kronuz colorscheme) >>>
-- Added by kronuzsh integrations/vim/setup.sh; delete this block to opt out.
vim.opt.termguicolors = true
-- vim.g.kronuz_transparent = 1   -- uncomment to inherit your terminal background
pcall(vim.cmd, 'colorscheme kronuz')
vim.opt.mouse = 'a'
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
set mouse=a
" <<< kronuzsh (Kronuz colorscheme) <<<
RC
  fi
}

_kronuz_vim_wire() {
  local editor="$1" language="$2" path="$3" replacement enable=0
  local -a config=("$editor config" "$path")

  if [ -f "$path" ] && grep -qi kronuz "$path" 2>/dev/null; then
    kz_ok "$editor" "already enabled in $(kz_tilde "$path")"
    enable=1
  elif [ -n "$KRONUZ_FORCE" ] || [ -n "${KRONUZ_VIM_AUTORC:-}" ]; then
    enable=1
  elif [ -z "${KRONUZ_VIM_NOAUTORC:-}" ] \
    && kz_confirm "Enable the Kronuz colorscheme in $(kz_tilde "$path")"; then
    enable=1
  fi

  if [ "$enable" -eq 0 ]; then
    kz_skip "$editor" "colorscheme linked, not enabled"
    kz_info "enable later: add 'silent! colorscheme kronuz' to $(kz_tilde "$path")"
    return 0
  fi

  if ! grep -qi kronuz "$path" 2>/dev/null; then
    replacement="$(mktemp)"
    if [ -f "$path" ]; then
      cat "$path" > "$replacement"
    fi
    _kronuz_vim_block "$language" >> "$replacement"
    kz_commit_file "${config[@]}" "$replacement"
    kz_ok "$editor" "colorscheme enabled in $(kz_tilde "$path")"
  fi

  kz_manage_file "${config[@]}"
  kz_hint "transparent background: set kronuz_transparent before loading the colorscheme"
}

_kronuz_setup_vim() {
  local here source nvim_dir
  local -a vim_theme neovim_theme

  here="$(kz_script_dir "${BASH_SOURCE[0]:-$0}")"
  source="$here/colors/kronuz.vim"
  nvim_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

  vim_theme=("vim colorscheme" "$source" "$HOME/.vim/colors/kronuz.vim")
  neovim_theme=("neovim colorscheme" "$source" "$nvim_dir/colors/kronuz.vim")

  if command -v vim >/dev/null 2>&1; then
    kz_manage_link "${vim_theme[@]}"
    _kronuz_vim_wire vim vim "$HOME/.vimrc"
  fi

  if command -v nvim >/dev/null 2>&1; then
    kz_manage_link "${neovim_theme[@]}"

    # Neovim loads init.lua or init.vim, never both.
    if [ -f "$nvim_dir/init.lua" ]; then
      _kronuz_vim_wire neovim lua "$nvim_dir/init.lua"
    else
      _kronuz_vim_wire neovim vim "$nvim_dir/init.vim"
    fi
  fi
}

_kronuz_setup_vim
unset -f _kronuz_setup_vim _kronuz_vim_block _kronuz_vim_wire
