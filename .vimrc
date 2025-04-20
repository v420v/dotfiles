
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
set smartindent
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2


augroup filetypeIndent
  autocmd!
  autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
  autocmd FileType php setlocal tabstop=4 softtabstop=4 shiftwidth=4
  autocmd FileType make setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  autocmd FileType sshconfig setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  autocmd FileType gitconfig setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  autocmd FileType ibu setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END


let mapleader = " "


" Tsoding
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
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
call plug#end()


" wfxr/minimap config
let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1


" vim-airline/vim-airline config
let g:airline_theme='minimalist'
let g:airline#extensions#branch#enabled = 1


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


" Auto Refresh
autocmd BufEnter NERD_tree_* | execute 'normal R'
autocmd FocusGained NERD_tree_* | execute 'normal R'


" Switching windows
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k


" source current file
nnoremap <leader>r :source %<CR>


" Automatically Quit Vim if Actual Files are Closed
" https://yous.be/2014/11/30/automatically-quit-vim-if-actual-files-are-closed
function! CheckLeftBuffers()
  if tabpagenr('$') == 1
    let i = 1
    while i <= winnr('$')
      if getbufvar(winbufnr(i), '&buftype') == 'help' ||
          \ getbufvar(winbufnr(i), '&buftype') == 'quickfix' ||
          \ exists('t:NERDTreeBufName') &&
          \ bufname(winbufnr(i)) == t:NERDTreeBufName ||
          \ bufname(winbufnr(i)) == '__Tag_List__' ||
          \ bufname(winbufnr(i)) == '-MINIMAP-'
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
      qall
    endif
    unlet i
  endif
endfunction
autocmd BufEnter * call CheckLeftBuffers()


augroup filetypeIndent
  autocmd!
  autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
  autocmd FileType php setlocal tabstop=4 softtabstop=4 shiftwidth=4
  autocmd FileType make setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  autocmd FileType sshconfig setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  autocmd FileType gitconfig setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
augroup END


" Auto dislay nerdtree on vim enter
autocmd VimEnter * NERDTree

