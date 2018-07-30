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

" vim-plug plugin manager
call plug#begin('~/.vim/plugged')

Plug 'pearofducks/ansible-vim'
Plug 'steffanc/cscopemaps.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
Plug 'mfukar/robotframework-vim'
Plug 'vim-scripts/taglist.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-smooth-scroll'
Plug 'nvie/vim-togglemouse'

" Initialize plugin system
call plug#end()

" Save and load view automatically (folding...). Uncomment only if needed
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview

" Spellcheck, uncomment needed
"set spell spelllang=en_us
"set spellfile=~/.vim/spell/en.utf-8.add
"set nospell
" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
  execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
  execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if count(s:opam_available_tools, tool) > 0
    call s:opam_configuration[tool]()
  endif
endfor
" ## end of OPAM user-setup addition for vim / base ## keep this line
