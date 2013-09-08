""" Settings
""" ---------------------------------------------------
""" reset.vim
if &compatible
	set nocompatible
	" Treats a wrapped line as two separate lines when scrolling
endif
nnoremap j gj
nnoremap k gk
map < :bp<CR>
map > :bn<CR> 
map " :bd<CR>
map ' :tabnew<CR>
" Experimental -- disabling cursor keys to better learn and get used to hjkl
inoremap <Up> 	<NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
noremap  <Up>	<NOP>
noremap	 <Down>	<NOP>
noremap	 <Left>	<NOP>
noremap  <Right> <NOP>

""" Display Settings
" set nowrap		" don't wrap lines
set showmatch		" show matching bracket (briefly jump)
set matchtime=2		" show matching bracket for 0.2 seconds
set guifont=Inconsolata-dz\ for\ Powerline\ Medium\ 12
set laststatus=2	" use 2 lines for the status bar
set matchpairs+=<:>	" specifically for html

""" Editor Settings
set incsearch		" highlight options as you type expression (emacs style)
set ignorecase		" ignore case for entirely lowercase searches
set smartcase		" respect case when capitals are included
" set number		" enable line numbers
set relativenumber	" relative row numbers when exiting Insert mode
" set ambiwidth=double	" make ambiguously-sized characters double the width
set backspace=2		" make backspace behave normally
set backspace=indent,eol,start	" see above; allow backspacing over everything in insert mode
set smarttab		" smart tab handling for indenting
set magic		" change the way backslashes are used in search patterns

""" File Type Settings
filetype off		" required
filetype plugin on	" required
filetype plugin indent on " required

""" Color settings
if &t_Co > 2 || has("gui_running")
	syntax on		" language syntax
	" set hlsearch		" highlight search
	set incsearch		" search incrementally (search while typing)
	colorscheme molokai 
	let g:molokai_original = 1 
	let g:airline_powerline_fonts = 1
	let g:Powerline_symbols = 'fancy'
	" let g:airline_theme='wombat'
	" let g:rehash256 = 1
endif

""" System Settings
set confirm		" get dialog when :q, :w, or :wq fails
set nobackup		" no backup~ files
set viminfo='20,\"500	" remember copy registers after quitting in the .viminfo
set hidden		" remember undo after quitting
set history=50		" keep 50 lines of command history
" set mouse=v		" use mouse in visual mode (not normal, insert,
			" command, help modes)

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
" Bundle 'Valloric/MatchTagAlways'

" Bundle-specific settings
""" airline
let g:airline#extensions#tabline#enabled = 1
""" easymotion
let g:EasyMotion_leader_key=','
""" NERDtree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1
""" gundo
nnoremap - :GundoToggle<CR>
let g:gundo_close_on_revert=1
""" Ctrl-P
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
nmap ; :CtrlPBuffer<CR>
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_working_path_mode = 'ra'
""" MatchTagAlways
let g:mta_filetypes = {
	\ 'html' : 1,
	\ 'xhtml' : 1,
	\ 'xml' : 1,
	\ 'jinja' : 1,
	\ 'php' : 1,
	\}

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

