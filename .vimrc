
set encoding=utf-8
set termencoding=utf-8
set number
set nowritebackup
set nobackup
set backspace=indent,eol,start
set ambiwidth=single
set wildmenu
set incsearch
set hlsearch
set noerrorbells
set showcmd
set display=lastline
set history=10000
set noswapfile
set clipboard=unnamed,autoselect
set updatetime=100
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
call CheckDependency('junegunn/fzf', 'fzf')
call CheckDependency('junegunn/fzf', 'rg')


" Plugins
call plug#begin()
Plug 'wfxr/minimap.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()


" wfxr/minimap config
let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1


" vim-airline/vim-airline config
let g:airline_theme='minimalist'


" airblade/vim-gitgutter
highlight GitGutterAdd guifg=#009900 ctermfg=Green
highlight GitGutterChange guifg=#bbbb00 ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222 ctermfg=Red
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0


" fzf.vim
nnoremap <C-p> :Files<Cr>
nnoremap <C-f> :Rg<Cr>


