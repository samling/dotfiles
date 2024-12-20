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
let mapleader=' '
"let mapleader=','
"let mapleader="\<Space>"

"""
"""
" Source .vimrc.local if present
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

""" map/remap some characters
"""
"""
" Previous buffer
"map <Leader>[ :bp<CR>
" Next buffer
"map <Leader>] :bn<CR> 
" Close buffer
"map <Leader>w :bd<CR>
" New tab
"map <leader>t :tabnew<CR>

" Toggle paste mode for pasting in external text
"map . :set paste!<CR>

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
" Unbind 'find next character'
noremap f <NOP>
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
" Remap Enter to insert a new line without entering Insert mode
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>
" Remapping shift+q, aka Ex mode
noremap Q @q
" Alias for <Escape>
""" See vim-easyescape plugin below
" inoremap jj <esc>
" vnoremap jk <esc>
" inoremap <Leader><Leader> <esc>
"
" Underline the current line with various symbols (such that the number of
" underline matches line length and indendation)
"nnoremap <Leader>= yypv$r=
"nnoremap <Leader>- yypv$r-
"nnoremap <Leader># yypv$r#
"nnoremap <Leader>" yypv$r"

""" Display Settings
"""
"""
set nowrap		    " don't wrap lines
"set wrap            " enable line wrapping
set linebreak       " wrap words but don't break line unless hitting enter
set nolist          " list disables linebreak
" don't show matching bracket
"set noshowmatch	" show matching bracket (briefly jump)
set noshowmatch		
let loaded_matchparen=0
set matchtime=2		" show matching bracket for 0.2 seconds
"set guifont=Menlo\ Regular\ for\ Powerline\ 12
"set guifont=Menlo_Regular_for_Powerline:h12
set guifont=Fira\ Code:12
set guifont=Fira_Code:h12
set laststatus=2	" use 2 lines for the status bar
set matchpairs+=<:>	" specifically for html

""" Editor Settings
"""
"""
set incsearch		" highlight options as you type expression (emacs style)
set ignorecase		" ignore case for entirely lowercase searches
set smartcase		" respect case when capitals are included
set number		    " enable line numbers
"set relativenumber	" relative row numbers when exiting Insert mode
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
set updatetime=100  " Update file every 100ms (default: 4000ms) to process gitgutter etc. changes
set nohlsearch

""" File Type Settings
"""
"""
filetype off		" required
filetype plugin on	" required
filetype plugin indent on " required
autocmd FileType make setlocal noexpandtab  " avoid expandtab when editing make files (as this may break them)
autocmd BufNewFile,BufRead *.less setf less " Set .less files to have the correct filetype

""" GoLang settings
"""
"""
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

""" Python Settings
"""
"""
let python_highlight_all = 1

""" Color settings
"""
"""
set background=dark
set t_Co=256
if &t_Co > 2 || has("gui_running")
	syntax on		" language syntax
	" set hlsearch		" highlight search
	set incsearch		" search incrementally (search while typing)
	"colorscheme nord
    colorscheme sublimemonokai
    " Remove the background color from the theme to match the terminal bg
    " color
	let g:molokai_original = 1 
	let g:airline_powerline_fonts = 1
	let g:Powerline_symbols = 'fancy'
	" let g:airline_theme='wombat'
	" let g:rehash256 = 1
endif

""" Theme Settings
"""
"""
hi Normal guibg=NONE ctermbg=NONE
hi vertsplit ctermfg=238 ctermbg=NONE
hi LineNr ctermfg=242 ctermbg=None
hi StatusLine ctermfg=242 ctermbg=None
hi StatusLineNC ctermfg=242 ctermbg=None
hi Search ctermbg=58 ctermfg=15
hi Default ctermfg=1
hi clear SignColumn
hi SignColumn ctermbg=NONE
hi GitGutterAdd ctermbg=NONE ctermfg=245
hi GitGutterChange ctermbg=NONE ctermfg=245
hi GitGutterDelete ctermbg=NONE ctermfg=245
hi GitGutterChangeDelete ctermbg=NONE ctermfg=245
hi EndOfBuffer ctermfg=245 ctermbg=NONE
set statusline=%F\ %m%=%P\ %c,%l/%L
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set noshowmode
" Change the cursor according to mode (formatted for tmux)
"let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
"let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

""" System Settings
set confirm		" get dialog when :q, :w, or :wq fails
set nobackup		" no backup~ files
set viminfo='20,\"500	" remember copy registers after quitting in the .viminfo
set hidden		" remember undo after quitting
set history=50		" keep 50 lines of command history
set backupskip=/tmp/*,/private/tmp/*    " Allow vim to edit crontab
let g:python3_host_prog = '/usr/local/bin/python3' " Required for nvim to recognize that python3 is there
" set mouse=v		" use mouse in visual mode (not normal, insert,
			" command, help modes)

""" vim-plug
""" ---------------------------------------------------
call plug#begin('~/.vim/plugged')
Plug 'fsharp/vim-fsharp', {
    \ 'for': 'fsharp',
    \ 'do':  'make fsautocomplete',
    \ }
call plug#end()


""" Vundle
""" ---------------------------------------------------

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" Let Vundle manage itself
" Required
Plugin 'VundleVim/Vundle.vim'

" Call plugins here
" Run :PluginInstall (case-sensitive) to install
"Plugin 'scrooloose/nerdtree'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'godlygeek/csapprox'
"Plugin 'vim-scripts/Better-CSS-Syntax-for-Vim'
"Plugin 'scrooloose/syntastic'
Plugin 'Yggdroot/indentLine'
Plugin 'tpope/vim-fugitive'
"Plugin 'easymotion/vim-easymotion'
"Plugin 'zhou13/vim-easyescape'
"Plugin 'fatih/vim-go'
"Plugin 'bling/vim-bufferline'
"Plugin 'majutsushi/tagbar'
Plugin 'aperezdc/vim-template'
"Plugin 'valloric/youcompleteme'
"Plugin 'ervandew/supertab'
Plugin 'samling/previewcolors.vim'
Plugin 'airblade/vim-gitgutter'
"Plugin 'mhinz/vim-signify'
"Plugin 'crusoexia/vim-monokai'
"Plugin 'vim-python/python-syntax'
"Plugin 'sheerun/vim-polyglot'
"Plugin 'liuchengxu/vim-which-key'

call vundle#end()

" Bundle-specific settings

""" Vim-EasyEscape
let g:easyescape_chars = { "j": 1, "k": 1 }
let g:easyescape_timeout = 100
cnoremap jk <ESC>
cnoremap kj <ESC>

" fzf
set rtp+=~/.fzf
let $FZF_DEFAULT_COMMAND = 'rg --files --no-ignore-vcs --hidden'

""" WhichVim
"let g:which_key_map = {
"            \ }
"let g:which_key_map.b = {
"            \ 'name' : '+buffer' ,
"            \ 't' : ['tab-new'   , 'new-buffer']      ,
"            \ 'd' : ['bd'        , 'delete-buffer']   ,
"            \ ']' : ['bnext'     , 'next-buffer']     ,
"            \ '[' : ['bprevious' , 'previous-buffer'] ,
"            \ }
""let g:which_key_map.f = {
""           \ 'name' : 'EasyMotion',
""           \ 'f' : ['<Plug>(easymotion-overwin-f)', 'search'] ,
""           \ }
"let g:which_key_map['c'] = ['TagbarToggle' , '+tagbar-toggle']
"let g:which_key_map.h = {
"            \ 'name' : 'Gitter',
"            \ 'p' : ['<Plug>GitGutterPreviewHunk', 'preview-hunk'],
"            \ 's' : ['<Plug>GitGutterStageHunk',   'stage-hunk'],
"            \ 'u' : ['<Plug>GitGutterUndoHunk',    'undo-hunk'],
"            \ 'w' : ['pc', 'close-preview'],
"            \ }
"call which_key#register(',', "g:which_key_map")
"nnoremap <silent> <leader> :WhichKey ','<CR>
"set timeoutlen=0

""" polyglot
let g:polyglot_disabled = ['graphql']

""" Powerline
"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup

""" youcompleteme
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_python_binary_path = '/usr/local/bin/python'

""" vim-go
nnoremap gj :cnext<CR>
nnoremap gk :cprevious<CR>
nnoremap gx :cclose<CR>

""" TagBar
"nmap <F8> :TagbarToggle<CR>
nmap <leader>c :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }

""" SuperTab
let g:SuperTabDefaultCompletionType = "<c-n>"

""" airline
let g:airline#extensions#tabline#enabled = 1

""" easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_leader_key='f'
nmap f <Plug>(easymotion-overwin-f)

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
""" python-syntax
let g:python_highlight_all = 1

" Vundle shortcuts
" :BundleList		- List configured bundles
" :BundleInstall(!)	- Install (update) bundles
" :BundleSearch(!) foo 	- Search (or refresh cache first) for foo
" :BundleClean(!)	- Confirm (or auto-approve) removal of unused bundles
" For additional help: 	:h vundle

