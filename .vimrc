set nocompatible
filetype off		" Required
filetype plugin on
syntax on		" Language syntax
set backspace=2		" Make backspace behave normally
set backspace=indent,eol,start " See above
set laststatus=2
set ambiwidth=double
set number

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Colorscheme/theme
colorscheme molokai
let g:molokai_original = 1
let g:airline_powerline_fonts = 1
let g:Powerline_symbols = 'fancy'
" let g:rehash256 = 1

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
" Bundle 'bling/vim-airline'

" Bundle-specific settings
""" easymotion
let g:EasyMotion_leader_key=','
""" NERDtree
map <C-n> :NERDTreeToggle<CR>
""" gundo
nnoremap - :GundoToggle<CR>
let g:gundo_close_on_revert=1

filetype plugin indent on " Required

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

