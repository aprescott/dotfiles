" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set selection=exclusive
set clipboard^=unnamed

set virtualedit=onemore
set scrolloff=5

" set termguicolors
set cursorline
highlight CursorLine cterm=NONE guibg=#22262e

highlight ExtraWhitespace ctermbg=red guibg=#5f2930
match ExtraWhitespace /\s\+$/

set colorcolumn=80

if has("vms")
  " do not keep a backup file, use versions instead
  set nobackup
else
  " keep a backup file
  set backup
endif

" keep 50 lines of command line history
set history=100

" show the cursor position all the time
set ruler

" display incomplete commands
set showcmd

" do incremental searching
set incsearch

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=80

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else
endif " has("autocmd")

set autoindent		" always set autoindenting on

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set tabstop=2
set shiftwidth=2
set expandtab
set number

set timeoutlen=100
set ttimeoutlen=50

set ignorecase
set smartcase

nnoremap <F2> :set nonumber! number?<CR>

nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
nnoremap 0 g0
nnoremap $ g$
nnoremap ^ g^
nnoremap <End> g$
nnoremap <Home> g^

inoremap <C-a> <C-o>g^
cnoremap <C-a> <Home>
inoremap <C-e> <C-o>g$
cnoremap <C-e> <End>
inoremap <C-w> <C-g>u<C-w>

vnoremap j gj
vnoremap k gk
vnoremap <Down> gj
vnoremap <Up> gk
vnoremap 0 g0
vnoremap $ g$
vnoremap ^ g^
vnoremap <End> g$
vnoremap <Home> g^

vnoremap < <gv
vnoremap > >gv

set foldmethod=indent
set foldnestmax=0
set nofoldenable
set foldlevel=1

" Better numbered list handling for gq wrapping.
set formatoptions+=n

" Prevent modelines as a security measure.
set modelines=0
set nomodeline

set directory=~/.vim/swapfiles//
set backupdir=~/.vim/backups//

set background=dark
