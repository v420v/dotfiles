
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

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin()

call plug#end()


