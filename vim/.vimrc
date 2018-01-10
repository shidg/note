set nocompatible  "Use Vim defaults (much better!)
set bs=indent,eol,start  "allow backspacing over everything in insert mode
set viminfo='20,\"50 " read/write a .viminfo file, don't store more than 50 lines of registers

"Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif  != ""
      cs add 
   endif
   set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif


filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Yggdroot/indentLine'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline' "crt onwindowns,要安装powerline字体,并设置为crt的默认字体,https://github.com/powerline/fonts
Plugin 'vim-airline/vim-airline-themes'
Plugin 'majutsushi/tagbar' "yum install ctags https://sourceforge.net/projects/ctags/?source=typ_redirect
"Plugin 'w0rp/ale'
Plugin 'vim-scripts/indentpython.vim'
call vundle#end()
filetype plugin indent on

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

set nobackup
syntax on

"execute pathogen#infect()
"set background=dark
"colorscheme solarized
"
"一个tab键对应4个空格
set tabstop=4
"自动缩进时缩进4个空格
set shiftwidth=4
"使用space替代tab的输入
set expandtab
"一次退格键删除4个空格
set softtabstop=4
" 继承前一行的缩进方式，特别适用于多行注释
set autoindent
"显示行号
set number
"打开状态栏标尺
set ruler
"底部状态栏显示。1为关闭，2为开启
set laststatus=2
"状态栏显示目前所执行的指令
set showcmd
set history=100
set lazyredraw
"vim内部编码
set encoding=utf-8
"设置编码的自动识别
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
"打开已有文件，如果文件编码与vim内部编码不同，vim会将文件转码为fileencoding.新建文件也会保存为fileencoding指定的编码
set fileencoding=utf-8
"防止特殊符号无法正常显示
set ambiwidth=double
"超过79列时换行
set tw=79
"不在单词中间换行
set lbr
"高亮光标所在行
set cursorline
"set cursorcolumn
"高亮光标所在列
"set cursorline
"highlight CursorLine   cterm=NONE ctermbg=yellow ctermfg=red guibg=NONE guifg=NONE
"highlight CursorColumn cterm=NONE ctermbg=yellow ctermfg=red guibg=NONE guifg=NONE

"快捷键F12打开或关闭paste模式，防止粘贴文件时因为自动缩进出现格式混乱
set pastetoggle=<F12>
"自动折行
set wrap

set hlsearch
set incsearch
set ignorecase
highlight Search term=standout ctermfg=10 ctermbg=7
highlight TabLine term=reverse cterm=reverse ctermfg=12 ctermbg=0
highlight TabLineSel term=reverse,bold cterm=reverse,bold ctermbg=7 ctermfg=4

"Mapping jj to Esc
imap jj <Esc><Right>
let mapleader=","
"map es :/.*\s\+$<CR>
"map ed :s#\s\+0#<CR>
map #a :s/^\([^#]\s*\)/#\1/<CR>
map #d :s/^#\+\(\s*\)/\1/<CR>
map /a :s/^\([^\/\/]\s*\)/\/\/\1/<CR>
map /d :s/^\/\/\(\s*\)/\1/<CR>

" YCM
let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_complete_in_comments=1
let g:ycm_collect_identifiers_from_comments_and_strings = 0 
let g:ycm_complete_in_strings = 1 
autocmd InsertLeave * if pumvisible() == 0|pclose|endif


"NERDTree
"autocmd vimenter * NERDTree
map w :NERDTreeToggle<CR>
autocmd VimEnter * wincmd w
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeShowBookmarks=1 
let NERDTreeChDirMode=1
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']

"indentLine
let g:indentLine_char = '¦'
let g:indentLine_enabled = 1
let g:autopep8_disable_show_diff=1

"ale
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

"Ctrlp
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|pyc)$'

"tagbar
nmap <F8> :TagbarToggle<CR>

"airline
let g:airline_theme="molokai" 
"let g:airline_theme="solarized" 
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#whitespace#symbol = '!'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" Auto add head info
" .py file into add header
function HeaderPython()
    call setline(1, "#!/usr/bin/python")
    call append(1, "# -*- coding: utf-8 -*-#")
    normal G
    normal o
endf
autocmd BufNewFile *.py call HeaderPython()

autocmd BufNewFile,BufRead *.py
\set tabstop=4
\set softtabstop=4
\set shiftwidth=4
\set textwidth=79
\set expandtab
\set fileformat=unix


" Auto add head info
" .sh file into add header
function Headershell()
    call setline(1, "#! /bin/bash")
    call append(1, "# -*- coding: utf-8 -*-#")
    normal G
    normal o
endf
autocmd BufNewFile *.sh call Headershell()
