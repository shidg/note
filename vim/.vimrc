set nocompatible" Use Vim defaults (much better!)
set bs=indent,eol,start" allow backspacing over everything in insert mode
set viminfo='20,\"50" read/write a .viminfo file, don't store more
" than 50 lines of registers

" Only do this part when compiled with support for autocommands
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

"if has('mouse')
"  set mouse=a
"endif

filetype plugin on

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

"不生成.swp文件
set nobackup

"语法高亮
syntax on

"配色方案
execute pathogen#infect()
"set background=dark
"colorscheme solarized
 
"显示行数标示
set number
 
"打开状态栏的坐标信息
set ruler
 
"取消底部状态栏显示。1为关闭，2为开启。
set laststatus=2
 
"将输入的命令显示出来，便于查看当前输入的信息
set showcmd
 
"设置魔术匹配控制，可以通过:h magic查看更详细的帮助信息
set magic
 
"设置vim存储的历史命令记录的条数
set history=100
 
"下划线高亮显示光标所在行
set cursorline
 
"插入右括号时会短暂地跳转到匹配的左括号
"set showmatch
 
"搜索时忽略大小写
set ignorecase
 
"在执行宏命令时，不进行显示重绘；在宏命令执行完成后，一次性重绘，以便提高性能。
set lazyredraw
 
"设置一个tab对应4个空格
set tabstop=4
 
"在按退格键时，如果前面有4个空格，则会统一清除
set softtabstop=4
 
 
"最基本的自动缩进
"set autoindent shiftwidth=4
 
"比autoindent稍智能的自动缩进
"set smartindent shiftwidth=4

"字符编码
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fileencoding=utf-8
set termencoding=utf-8

"将新增的tab转换为空格。不会对已有的tab进行转换
set expandtab
 
"高亮显示搜索匹配到的字符串
set hlsearch

"高亮显示匹配字符串时的颜色
highlight Search term=standout ctermfg=10 ctermbg=7
 
"在搜索模式下，随着搜索字符的逐个输入，实时进行字符串匹配，并对首个匹配到的字符串高亮显示
set incsearch

"tab标签配色
highlight TabLine term=reverse cterm=reverse ctermfg=12 ctermbg=0
highlight TabLineSel term=reverse,bold cterm=reverse,bold ctermbg=7 ctermfg=4

"Mapping jj to Esc
imap jj <Esc><Right>
 
"设置自定义快捷键的前导键
let mapleader=","
 
"匹配那些末尾有空格或TAB的行。（es：Endspace Show）
map es :/.*\s\+$<CR>
 
"删除行末尾的空格或TAB（ed：Endspace Delete）
map ed :s#\s\+0#<CR>
 
"如果所选行的行首没有#，则给所选行行首加上注释符#（#a：# add）
map #a :s/^\([^#]\s*\)/#\1/<CR>
 
"如果所选行行首有#，则将所选行行首所有的#都去掉（#d：# delete）
map #d :s/^#\+\(\s*\)/\1/<CR>
 
"如果所选行的行首没有//，则给所选行行首加上注释符//（/a：/ add）
map /a :s/^\([^\/\/]\s*\)/\/\/\1/<CR>
 
"如果所选行行首有//，则将所选行行首的//都去掉（/d：/ delete）
map /d :s/^\/\/\(\s*\)/\1/<CR>

