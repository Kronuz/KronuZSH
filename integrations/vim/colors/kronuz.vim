" kronuz.vim — Kronuz colorscheme, a railscasts-family dark theme matching the
" kronuzsh palette (the same hexes bat, delta, fzf and eza use). Truecolor (gui)
" with nearest xterm-256 fallbacks for non-truecolor terminals.
"
" Activate it with `colorscheme kronuz` in your vimrc/init.vim (kronuzsh installs
" this file into ~/.vim/colors/ and ~/.config/nvim/colors/, it does not force it).
" For truecolor, also `set termguicolors` (Neovim, or Vim 8 in a truecolor term).

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "kronuz"


" editor / UI
hi Normal                 guifg=#c8c6c5 guibg=#383838 ctermfg=251 ctermbg=237 gui=NONE cterm=NONE
hi Cursor                 guifg=#383838 guibg=#d08040 ctermfg=237 ctermbg=173 gui=NONE cterm=NONE
hi lCursor                guifg=#383838 guibg=#d08040 ctermfg=237 ctermbg=173 gui=NONE cterm=NONE
hi CursorLine             guifg=NONE guibg=#303030 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi CursorColumn           guifg=NONE guibg=#303030 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi ColorColumn            guifg=NONE guibg=#303030 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi CursorLineNr           guifg=#e8bf6a guibg=#303030 ctermfg=179 ctermbg=236 gui=bold cterm=bold
hi LineNr                 guifg=#7a7775 guibg=#383838 ctermfg=243 ctermbg=237 gui=NONE cterm=NONE
hi SignColumn             guifg=NONE guibg=#383838 ctermfg=NONE ctermbg=237 gui=NONE cterm=NONE
hi FoldColumn             guifg=#7a7775 guibg=#383838 ctermfg=243 ctermbg=237 gui=NONE cterm=NONE
hi Folded                 guifg=#95815e guibg=#303030 ctermfg=101 ctermbg=236 gui=italic cterm=italic
hi VertSplit              guifg=#4a4a4a guibg=#383838 ctermfg=239 ctermbg=237 gui=NONE cterm=NONE
hi WinSeparator           guifg=#4a4a4a guibg=#383838 ctermfg=239 ctermbg=237 gui=NONE cterm=NONE
hi StatusLine             guifg=#c8c6c5 guibg=#4a4a4a ctermfg=251 ctermbg=239 gui=NONE cterm=NONE
hi StatusLineNC           guifg=#7a7775 guibg=#303030 ctermfg=243 ctermbg=236 gui=NONE cterm=NONE
hi TabLine                guifg=#95815e guibg=#303030 ctermfg=101 ctermbg=236 gui=NONE cterm=NONE
hi TabLineFill            guifg=NONE guibg=#303030 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi TabLineSel             guifg=#e8bf6a guibg=#383838 ctermfg=179 ctermbg=237 gui=NONE cterm=NONE
hi Pmenu                  guifg=#c8c6c5 guibg=#303030 ctermfg=251 ctermbg=236 gui=NONE cterm=NONE
hi PmenuSel               guifg=#383838 guibg=#6089b4 ctermfg=237 ctermbg=67 gui=bold cterm=bold
hi PmenuSbar              guifg=NONE guibg=#303030 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi PmenuThumb             guifg=NONE guibg=#7a7775 ctermfg=NONE ctermbg=243 gui=NONE cterm=NONE
hi Visual                 guifg=NONE guibg=#5a647e ctermfg=NONE ctermbg=60 gui=NONE cterm=NONE
hi VisualNOS              guifg=NONE guibg=#5a647e ctermfg=NONE ctermbg=60 gui=NONE cterm=NONE
hi Search                 guifg=#383838 guibg=#e8bf6a ctermfg=237 ctermbg=179 gui=NONE cterm=NONE
hi IncSearch              guifg=#383838 guibg=#fd971f ctermfg=237 ctermbg=208 gui=NONE cterm=NONE
hi CurSearch              guifg=#383838 guibg=#fd971f ctermfg=237 ctermbg=208 gui=NONE cterm=NONE
hi WildMenu               guifg=#383838 guibg=#e8bf6a ctermfg=237 ctermbg=179 gui=NONE cterm=NONE
hi MatchParen             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold,underline cterm=bold,underline
hi Directory              guifg=#6089b4 guibg=NONE ctermfg=67 ctermbg=NONE gui=NONE cterm=NONE
hi Title                  guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi ErrorMsg               guifg=#ff0b00 guibg=NONE ctermfg=196 ctermbg=NONE gui=bold cterm=bold
hi WarningMsg             guifg=#da4939 guibg=NONE ctermfg=167 ctermbg=NONE gui=NONE cterm=NONE
hi ModeMsg                guifg=#a5c261 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi MoreMsg                guifg=#a5c261 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi Question               guifg=#a5c261 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi NonText                guifg=#5a544a guibg=NONE ctermfg=239 ctermbg=NONE gui=NONE cterm=NONE
hi SpecialKey             guifg=#5a544a guibg=NONE ctermfg=239 ctermbg=NONE gui=NONE cterm=NONE
hi Whitespace             guifg=#5a544a guibg=NONE ctermfg=239 ctermbg=NONE gui=NONE cterm=NONE
hi Conceal                guifg=#7a7775 guibg=NONE ctermfg=243 ctermbg=NONE gui=NONE cterm=NONE
hi EndOfBuffer            guifg=#5a544a guibg=NONE ctermfg=239 ctermbg=NONE gui=NONE cterm=NONE

" syntax
hi Comment                guifg=#95815e guibg=NONE ctermfg=101 ctermbg=NONE gui=italic cterm=italic
hi SpecialComment         guifg=#95815e guibg=NONE ctermfg=101 ctermbg=NONE gui=bold cterm=bold
hi Constant               guifg=#6e9cbe guibg=NONE ctermfg=73 ctermbg=NONE gui=NONE cterm=NONE
hi String                 guifg=#a5c261 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi Character              guifg=#a5c261 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi Number                 guifg=#a5c260 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi Float                  guifg=#a5c260 guibg=NONE ctermfg=143 ctermbg=NONE gui=NONE cterm=NONE
hi Boolean                guifg=#6e9cbe guibg=NONE ctermfg=73 ctermbg=NONE gui=NONE cterm=NONE
hi Identifier             guifg=#e8e6e5 guibg=NONE ctermfg=254 ctermbg=NONE gui=NONE cterm=NONE
hi Function               guifg=#e8bf6a guibg=NONE ctermfg=179 ctermbg=NONE gui=NONE cterm=NONE
hi Statement              guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Conditional            guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Repeat                 guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Label                  guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Operator               guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Keyword                guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Exception              guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi PreProc                guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Include                guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Define                 guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Macro                  guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi PreCondit              guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Type                   guifg=#da4939 guibg=NONE ctermfg=167 ctermbg=NONE gui=NONE cterm=NONE
hi StorageClass           guifg=#cc7833 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Structure              guifg=#da4939 guibg=NONE ctermfg=167 ctermbg=NONE gui=NONE cterm=NONE
hi Typedef                guifg=#da4939 guibg=NONE ctermfg=167 ctermbg=NONE gui=NONE cterm=NONE
hi Special                guifg=#d08442 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi SpecialChar            guifg=#d08442 guibg=NONE ctermfg=173 ctermbg=NONE gui=NONE cterm=NONE
hi Tag                    guifg=#caa473 guibg=NONE ctermfg=179 ctermbg=NONE gui=NONE cterm=NONE
hi Delimiter              guifg=#c8c6c5 guibg=NONE ctermfg=251 ctermbg=NONE gui=NONE cterm=NONE
hi Debug                  guifg=#da4939 guibg=NONE ctermfg=167 ctermbg=NONE gui=NONE cterm=NONE
hi Underlined             guifg=#6089b4 guibg=NONE ctermfg=67 ctermbg=NONE gui=underline cterm=underline
hi Ignore                 guifg=#7a7775 guibg=NONE ctermfg=243 ctermbg=NONE gui=NONE cterm=NONE
hi Error                  guifg=#e8e6e5 guibg=#da4939 ctermfg=254 ctermbg=167 gui=NONE cterm=NONE
hi Todo                   guifg=#383838 guibg=#e8bf6a ctermfg=237 ctermbg=179 gui=bold cterm=bold

" diff
hi DiffAdd                guifg=NONE guibg=#26331a ctermfg=NONE ctermbg=235 gui=NONE cterm=NONE
hi DiffDelete             guifg=#7a7775 guibg=#3a1d1d ctermfg=243 ctermbg=235 gui=NONE cterm=NONE
hi DiffChange             guifg=NONE guibg=#332f1a ctermfg=NONE ctermbg=235 gui=NONE cterm=NONE
hi DiffText               guifg=NONE guibg=#4d3a17 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE
hi diffAdded              guifg=#219186 guibg=NONE ctermfg=30 ctermbg=NONE gui=NONE cterm=NONE
hi diffRemoved            guifg=#dc322f guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE
hi diffChanged            guifg=#cb4b16 guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE
hi diffLine               guifg=#6089b4 guibg=NONE ctermfg=67 ctermbg=NONE gui=NONE cterm=NONE
hi diffFile               guifg=#e8bf6a guibg=NONE ctermfg=179 ctermbg=NONE gui=NONE cterm=NONE
hi diffIndexLine          guifg=#95815e guibg=NONE ctermfg=101 ctermbg=NONE gui=NONE cterm=NONE

" git signs (gitgutter / signify)
hi GitGutterAdd           guifg=#219186 guibg=NONE ctermfg=30 ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterChange        guifg=#cb4b16 guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE
hi GitGutterDelete        guifg=#dc322f guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE
hi SignifySignAdd         guifg=#219186 guibg=NONE ctermfg=30 ctermbg=NONE gui=NONE cterm=NONE
hi SignifySignChange      guifg=#cb4b16 guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE
hi SignifySignDelete      guifg=#dc322f guibg=NONE ctermfg=166 ctermbg=NONE gui=NONE cterm=NONE

" spell
hi SpellBad               guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE gui=undercurl cterm=underline guisp=#da4939
hi SpellCap               guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE gui=undercurl cterm=underline guisp=#6089b4
hi SpellRare              guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE gui=undercurl cterm=underline guisp=#d687bf
hi SpellLocal             guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE gui=undercurl cterm=underline guisp=#219186

" markup (markdown)
hi markdownH1             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownH2             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownH3             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownH4             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownH5             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownH6             guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownHeadingDelimiter guifg=#fd971f guibg=NONE ctermfg=208 ctermbg=NONE gui=bold cterm=bold
hi markdownBold           guifg=#437cb9 guibg=NONE ctermfg=67 ctermbg=NONE gui=bold cterm=bold
hi markdownItalic         guifg=#7ea4cc guibg=NONE ctermfg=110 ctermbg=NONE gui=italic cterm=italic
hi markdownCode           guifg=#d687bf guibg=NONE ctermfg=175 ctermbg=NONE gui=NONE cterm=NONE
hi markdownCodeBlock      guifg=#d687bf guibg=NONE ctermfg=175 ctermbg=NONE gui=NONE cterm=NONE
hi markdownUrl            guifg=#6089b4 guibg=NONE ctermfg=67 ctermbg=NONE gui=underline cterm=underline
hi markdownLinkText       guifg=#6089b4 guibg=NONE ctermfg=67 ctermbg=NONE gui=NONE cterm=NONE
hi markdownListMarker     guifg=#9aa83a guibg=NONE ctermfg=107 ctermbg=NONE gui=NONE cterm=NONE
hi markdownBlockquote     guifg=#caa473 guibg=NONE ctermfg=179 ctermbg=NONE gui=italic cterm=italic

" :terminal ANSI palette (Kronuz)
if has("nvim")
  let g:terminal_color_0 = "#383838"
  let g:terminal_color_1 = "#da4939"
  let g:terminal_color_2 = "#a5c261"
  let g:terminal_color_3 = "#e8bf6a"
  let g:terminal_color_4 = "#6089b4"
  let g:terminal_color_5 = "#d687bf"
  let g:terminal_color_6 = "#219186"
  let g:terminal_color_7 = "#c8c6c5"
  let g:terminal_color_8 = "#7a7775"
  let g:terminal_color_9 = "#dc322f"
  let g:terminal_color_10 = "#9aa83a"
  let g:terminal_color_11 = "#fd971f"
  let g:terminal_color_12 = "#6e9cbe"
  let g:terminal_color_13 = "#caa473"
  let g:terminal_color_14 = "#437cb9"
  let g:terminal_color_15 = "#e8e6e5"
elseif exists("*term_setansicolors") || has("terminal")
  let g:terminal_ansi_colors = ["#383838", "#da4939", "#a5c261", "#e8bf6a", "#6089b4", "#d687bf", "#219186", "#c8c6c5", "#7a7775", "#dc322f", "#9aa83a", "#fd971f", "#6e9cbe", "#caa473", "#437cb9", "#e8e6e5"]
endif

