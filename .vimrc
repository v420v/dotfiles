
set number
set nowritebackup
set nobackup
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu
set incsearch
set hlsearch
set noerrorbells
set showcmd
set display=lastline
set history=10000
set noswapfile
set clipboard=unnamed,autoselect
syntax on


colorscheme GruberDarker


" Bootstrap plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


" Print a error if required package is not installed
function! CheckDependency(plugin_name, dependency) abort
  if executable(a:dependency) == 0
    echohl ErrorMsg
    echomsg "🤔 Plugin '".a:plugin_name."' requires '".a:dependency."' (not found in \$PATH)"
    echohl None
  endif
endfunction

call CheckDependency('wfxr/minimap.vim', 'code-minimap')


" Plugins
call plug#begin()
Plug 'wfxr/minimap.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()


" wfxr/minimap config
let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1


" vim-airline/vim-airline config
let g:airline_theme='minimalist'


