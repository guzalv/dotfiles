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

" Highlight characters at column 81
2mat ErrorMsg '\%81v.'

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

" Yaml (https://dzone.com/articles/vim-settings-for-working-with-yaml-snippet)
" Yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab foldmethod=indent

" Folding
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf
autocmd BufEnter * normal zR

" ctrlp settings
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
let g:ctrlp_max_files = 100000

" codefmt settings
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer black
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
  autocmd BufWritePre,FileWritePre * FormatCode
augroup END

" Conceal by default (used by vim-markdown)
set conceallevel=2

" vim-plug plugin manager, see https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

Plug 'pearofducks/ansible-vim'
Plug 'steffanc/cscopemaps.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
Plug 'mfukar/robotframework-vim'
Plug 'tmhedberg/SimpylFold'
Plug 'vim-scripts/taglist.vim'
Plug 'bazelbuild/vim-bazel'
Plug 'google/vim-codefmt'
Plug 'tpope/vim-fugitive'
Plug 'bazelbuild/vim-ft-bzl'
Plug 'terryma/vim-expand-region'
Plug 'airblade/vim-gitgutter'
Plug 'google/vim-jsonnet'
Plug 'google/vim-maktaba'
Plug 'plasticboy/vim-markdown'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-repeat'
Plug 'terryma/vim-smooth-scroll'
Plug 'tpope/vim-surround'
Plug 'nvie/vim-togglemouse'
Plug 'stephpy/vim-yaml'

" Initialize plugin system
call plug#end()
