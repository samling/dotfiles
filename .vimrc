set nocompatible
filetype off		" Required
syntax on		" Language syntax
set backspace=2		" Make backspace behave normally
set backspace=indent,eol,start " See above

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

" Bundle-specific settings
""" vim-easymotion
let g:EasyMotion_leader_key = ','


filetype plugin indent on " Required

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

