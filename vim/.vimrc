""" Settings
""" ---------------------------------------------------

""" reset.vim
"""
"""

if &compatible
	set nocompatible
endif

"""
" Leader key
let mapleader=','
"let mapleader="\<Space>"

"""
" Source .vimrc.local if present
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

""" move according to visual lines instead of line numbers (i.e. treat line
""" breaks as two separate lines)
"""
"""
" nnoremap j gj
" nnoremap k gk

""" map/remap some characters
"""
"""
" map { :bp<CR>
" map } :bn<CR> 
" map " :bd<CR>
" map ' :tabnew<CR>

" Toggle paste mode for pasting in external text
map \ :set paste!<CR>

""" Experimental -- disabling cursor keys to better learn and get used to hjkl
"""
"""
inoremap <Up> 	<NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
noremap  <Up>	<NOP>
noremap	 <Down>	<NOP>
noremap	 <Left>	<NOP>
noremap  <Right> <NOP>
" Mapping j and k to move vertically by visual rather than actual line
nnoremap j gj
nnoremap k gk
" Better beginning and end shortcuts
nnoremap B ^
nnoremap E $
"nnoremap $ <nop>
"nnoremap ^ <nop>
" Mapping the +/- keys to inc/dec
noremap - <C-x>
noremap = <C-a>
" Unmapping 's' to make way for vim-seek
noremap s <NOP>
noremap S <NOP>
vnoremap s <NOP>
vnoremap S <NOP>
" Disabling whatever shift+j/shift+k does
noremap <S-Up> <NOP>
noremap <S-Down> <NOP>
vnoremap <S-Up> <NOP>
vnoremap <S-Down> <NOP>
" Remapping shift+q, aka Ex mode
noremap Q @q
" Alias for <Escape>
inoremap jk <esc>
" vnoremap jk <esc>
" inoremap <Leader><Leader> <esc>
"
" Underline the current line with various symbols (such that the number of
" underline matches line length and indendation)
nnoremap <Leader>= yypv$r=
nnoremap <Leader>- yypv$r-
nnoremap <Leader># yypv$r#
nnoremap <Leader>" yypv$r"

""" Display Settings
"""
"""
"set nowrap		    " don't wrap lines
set wrap            " enable line wrapping
set linebreak       " wrap words but don't break line unless hitting enter
set nolist          " list disables linebreak
set showmatch		" show matching bracket (briefly jump)
set matchtime=2		" show matching bracket for 0.2 seconds
set guifont=Menlo\ Regular\ for\ Powerline\ 12
set guifont=Menlo_Regular_for_Powerline:h12
set laststatus=2	" use 2 lines for the status bar
set matchpairs+=<:>	" specifically for html

""" Editor Settings
"""
"""
set incsearch		" highlight options as you type expression (emacs style)
set ignorecase		" ignore case for entirely lowercase searches
set smartcase		" respect case when capitals are included
set number		    " enable line numbers
set relativenumber	" relative row numbers when exiting Insert mode
" set ambiwidth=double	" make ambiguously-sized characters double the width
set backspace=2		" make backspace behave normally
set backspace=indent,eol,start	" see above; allow backspacing over everything in insert mode
set smarttab		" smart tab handling for indenting
set magic   		" change the way backslashes are used in search patterns
set shiftwidth=4	" use 4 spaces as indent guide
set tabstop=4		" use 4 spaces as indent guide
set expandtab		" convert tabs to spaces
"set virtualedit=onemore " allow the cursor to move past the last character
set splitbelow      " vsplit new panes below current pane
set splitright      " vsplit new panes to the right of the current pane
set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P
"set synmaxcol=120   " stop vim from syntax highlighting after 120 columns to prevent long strings from making vim chug

""" File Type Settings
"""
"""
filetype off		" required
filetype plugin on	" required
filetype plugin indent on " required
autocmd FileType make setlocal noexpandtab  " avoid expandtab when editing make files (as this may break them)
autocmd BufNewFile,BufRead *.less setf less " Set .less files to have the correct filetype

""" Color settings
"""
"""
if &t_Co > 2 || has("gui_running")
	syntax on		" language syntax
	" set hlsearch		" highlight search
	set incsearch		" search incrementally (search while typing)
	colorscheme molokai-nobg
    " Remove the background color from the theme to match the terminal bg
    " color
    hi Normal ctermbg=NONE
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
set backupskip=/tmp/*,/private/tmp/*    " Allow vim to edit crontab
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
" Run :BundleInstall (case-sensitive) to install
" e.g.:
" Bundle 'tpope/vim-fugitive'
" Bundle 'Lokaltog/vim-easymotion'
Bundle 'scrooloose/nerdtree'
" Bundle 'msanders/snipmate.vim'
" Bundle 'tpope/vim-abolish'
" Bundle 'tpope/vim-surround'
" Bundle 'sjl/gundo.vim'
" Bundle 'tpope/vim-commentary'
" Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'bling/vim-airline'
" Bundle 'scrooloose/syntastic'
" Bundle 'kien/ctrlp.vim'
" Bundle 'Valloric/MatchTagAlways'
Bundle 'godlygeek/csapprox'
Bundle 'vim-scripts/Better-CSS-Syntax-for-Vim'
" Bundle 'matze/vim-move'
" Bundle 'goldfeld/vim-seek'
" Bundle 'flazz/vim-colorschemes'
" Bundle 'Raimondi/delimitMate'
" Bundle 'tpope/vim-fugitive'
Bundle 'Yggdroot/indentLine'
" Bundle 'tpope/vim-rails'
" Bundle 'justinmk/vim-sneak'
" Bundle 'rizzatti/funcoo.vim'
" Bundle 'rizzatti/dash.vim'
" Bundle 'groenewege/vim-less'

" Bundle-specific settings
""" airline
let g:airline#extensions#tabline#enabled = 1
""" easymotion
let g:EasyMotion_leader_key=','
""" vim-move
let g:move_key_modifier = 'S'
""" NERDtree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1
""" gundo
" nnoremap - :GundoToggle<CR>
let g:gundo_close_on_revert=1
""" Ctrl-P
" let g:ctrlp_map = '<c-p>'
" let g:ctrlp_cmd = 'CtrlP'
" nmap ; :CtrlPBuffer<CR>
" let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
" let g:ctrlp_working_path_mode = 'ra'
""" indentLine
let g:indentLine_color_term = 239
""" MatchTagAlways
let g:mta_filetypes = {
	\ 'html' : 1,
	\ 'xhtml' : 1,
	\ 'xml' : 1,
	\ 'jinja' : 1,
	\ 'php' : 1,
	\}
""" vim-sneak
let g:sneak#streak = 1

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

