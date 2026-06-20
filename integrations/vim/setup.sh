# vim / neovim: make the bundled Kronuz colorscheme (./colors/kronuz.vim) discoverable
# by linking it into the dir each looks in for colorschemes. Opt-in like btop/yazi: we
# place the file but never force it — turn it on with `colorscheme kronuz` in your
# vimrc/init.vim (and `set termguicolors` for truecolor). Dropping a colorscheme into
# colors/ doesn't touch your config, so unlike btop/yazi we can do the linking for you.
# Guarded on vim/nvim presence, idempotent (re-linking the same path). POSIX sh,
# sourced by ../setup.sh at install time.
_kronuz_vim_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_kronuz_vim_src="$_kronuz_vim_dir/colors/kronuz.vim"
if command -v vim >/dev/null 2>&1; then
  mkdir -p "$HOME/.vim/colors"
  ln -sf "$_kronuz_vim_src" "$HOME/.vim/colors/kronuz.vim"
  echo "linked Kronuz colorscheme into ~/.vim/colors (turn it on with: colorscheme kronuz)"
fi
if command -v nvim >/dev/null 2>&1; then
  _kronuz_nvim_colors="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/colors"
  mkdir -p "$_kronuz_nvim_colors"
  ln -sf "$_kronuz_vim_src" "$_kronuz_nvim_colors/kronuz.vim"
  echo "linked Kronuz colorscheme into nvim colors (turn it on with: colorscheme kronuz)"
  unset _kronuz_nvim_colors
fi
unset _kronuz_vim_dir _kronuz_vim_src
