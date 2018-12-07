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

" Line at 80 characters
set colorcolumn=81

" Search for visually-selected text with //
vnoremap // y/<C-R>"<CR>

" Highlight search results
set hlsearch
highlight Search ctermbg=Red ctermfg=Yellow

" Don't use Ex mode, use Q for formatting
map Q gq

" Open / close NERDTree
map <C-e> :NERDTreeToggle<CR>

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

" Ctags-related stuff
" Search tags file
" https://stackoverflow.com/questions/16636173/how-can-i-run-ctags-in-a-large-code-base
set tags=./tags;/,tags;/
nnoremap <silent> <F8> :TlistToggle<CR>

" vim-plug plugin manager, see https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

Plug 'pearofducks/ansible-vim'
Plug 'steffanc/cscopemaps.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
Plug 'mfukar/robotframework-vim'
Plug 'vim-scripts/taglist.vim'
Plug 'bazelbuild/vim-bazel'
Plug 'tpope/vim-fugitive'
Plug 'terryma/vim-expand-region'
Plug 'airblade/vim-gitgutter'
Plug 'google/vim-maktaba'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-smooth-scroll'
Plug 'nvie/vim-togglemouse'

" Initialize plugin system
call plug#end()
