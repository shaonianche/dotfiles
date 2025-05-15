" -----------------------------------------------------------------------------
" Initialize Config
" -----------------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
exec 'set rtp+='.s:home
set rtp+=~/.vim

" -----------------------------------------------------------------------------
" General Settings
" -----------------------------------------------------------------------------
set nocompatible
set bs=eol,start,indent

set encoding=utf-8
set number
set ruler
set relativenumber 
set wildmenu
set lazyredraw
set showcmd

filetype plugin indent on
syntax enable
set nowrap
set autoindent
set cindent
set ffs=unix,dos,mac

if has('autocmd')
	filetype plugin indent on
endif

" -----------------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------------
set hlsearch
set incsearch
set ignorecase
set smartcase 

" -----------------------------------------------------------------------------
" Backup
" -----------------------------------------------------------------------------
set backup
set writebackup
set backupdir=~/.vim/tmp
set backupext=.bak
set noswapfile
set noundofile
silent! call mkdir(expand('~/.vim/tmp'), "p", 0755)
