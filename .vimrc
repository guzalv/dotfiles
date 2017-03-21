set nocompatible
set backspace=2
syntax on

" 4 spaces indentation, no tabs
set tabstop=4
set shiftwidth=4
set expandtab

" Automatic indent
filetype indent on

" Color trailing whitespace and tabs
highlight ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\s\+$\|\t/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$\|\t/
au InsertLeave * match ExtraWhiteSpace /\s\+$\|\t/

" Search for visually-selected text with //
vnoremap // y/<C-R>"<CR>

" Highlight search results
set hlsearch
highlight Search ctermbg=Red ctermfg=Yellow

" Set colorscheme
colorscheme peachpuff

" Don't use Ex mode, use Q for formatting
map Q gq

" Toggle paste mode
set pastetoggle=<F2>

" Jump to the last position when reopening a file
if has("autocmd")
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Smooth-scroll-related settings
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 15, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>

" Faster updates, for vim-gitgutter
set updatetime=250

" Tab-related shortcuts
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap te  :tabedit<Space>
nnoremap tx  :tabclose<CR>

" vim-plug plugin manager
call plug#begin('~/.vim/plugged')

Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-smooth-scroll'
Plug 'nvie/vim-togglemouse'
Plug 'airblade/vim-gitgutter'
Plug 'pearofducks/ansible-vim'

" Initialize plugin system
call plug#end()

" Save and load view automatically (folding...). Uncomment only if needed
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview

" Spellcheck, uncomment needed
"set spell spelllang=en_us
"set spellfile=~/.vim/spell/en.utf-8.add
"set nospell
