
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
set mouse=a
syntax on


colorscheme GruberDarker


" Bootstrap plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
   silent exec "!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
   if v:shell_error
     echom "❌ Error downloading vim-plug. Please install it manually."
   else
     echom "🚀 vim-plug has been installed."
     autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
   endif
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
Plug 'jiangmiao/auto-pairs'
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
let g:gitgutter_preview_win_floating = 1
let g:gitgutter_close_preview_on_escape=1
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap hu <Plug>(GitGutterUndoHunk)
nmap hp <Plug>(GitGutterPreviewHunk)


" fzf.vim
nnoremap <C-p> :Files<Cr>
nnoremap <C-f> :Rg<Cr>


