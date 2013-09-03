""" Settings
""" ---------------------------------------------------
set nocompatible
filetype off		" Required
filetype plugin on
syntax on		" Language syntax
set backspace=2		" Make backspace behave normally
set backspace=indent,eol,start " See above
set laststatus=2
"set ambiwidth=double
set number
set guifont=Inconsolata-dz\ for\ Powerline\ Medium\ 12
set incsearch		" highlight options as you type expression (emacs style)
set ignorecase		" ignore case for entirely lowercase searches
set smartcase		" respect case when capitals are included

""" Remap defaults
""" ---------------------------------------------------
nmap j gj
nmap k gk

""" Colorscheme/theme
""" ---------------------------------------------------
colorscheme molokai
let g:molokai_original = 1
let g:airline_powerline_fonts = 1
let g:Powerline_symbols = 'fancy'
" let g:airline_theme='wombat'
" let g:rehash256 = 1

""" Vundle
""" ---------------------------------------------------
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Let Vundle manage itself
" Required
Bundle 'gmarik/vundle'

" Call bundles here
" e.g.:
" Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'scrooloose/nerdtree'
" Bundle 'msanders/snipmate.vim'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-surround'
Bundle 'sjl/gundo.vim'
Bundle 'tpope/vim-commentary'
" Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'bling/vim-airline'
Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'

" Bundle-specific settings
""" easymotion
let g:EasyMotion_leader_key=','
""" NERDtree
map <C-n> :NERDTreeToggle<CR>
""" gundo
nnoremap - :GundoToggle<CR>
let g:gundo_close_on_revert=1
""" Ctrl-P
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

filetype plugin indent on " Required

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

