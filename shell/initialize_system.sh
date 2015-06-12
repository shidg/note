#!/bin/bash

#selinux
if [ `sed -n '/^SELINUX=/p' /etc/selinux/config  | cut -d= -f2` != disabled ];then
    sed -i '/^SELINUX=/ s/^/#/;/#SELINUX=/a\SELINUX=disabled' /etc/selinux/config
fi

#iptables
service iptables stop

if [ $(id -u) != 0 ];then
echo "Must be root can do this."
exit 9
fi
# set privileges
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

# Turn off unnecessary services
if [ ! -f /etc/init.d/snmpd ];then
    yum install net-snmp -y
fi
service=($(ls /etc/init.d/))
for i in ${service[@]}; do
case $i in
sshd|network|rsyslog|iptables|crond|snmpd)
chkconfig $i on;;
*)
chkconfig $i off;;
esac
done
#set ulimit
cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
* soft core   0
* hard core   0
EOF
# set sysctl

modprobe bridge

cat > /etc/sysctl.conf << EOF
#不充当路由器
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# 开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1


# 开启并记录欺骗，源路由和重定向包
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# 禁止修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0


kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmall = 2097152
kernel.shmmax = 4294967296
kernel.shmmni = 4096
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.rmem_default = 262144
net.core.rmem_max = 16777216

#网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 3000

# 系统中每一个端口最大的监听队列的长度
net.core.somaxconn = 2048

#统所能处理的不属于任何进程的TCP sockets最大数量
net.ipv4.tcp_max_orphans = 2000

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

# TIME-WAIT套接字重用功能，用于存在大量连接的服务器
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

#系统同时保持TIME_WAIT套接字的最大数量
net.ipv4.tcp_max_tw_buckets = 5000

#减少处于FIN-WAIT-2连接状态的时间，使系统可以处理更多的连接
net.ipv4.tcp_fin_timeout = 30

#减少TCP KeepAlive连接侦测的时间，使系统可以处理更多的连接
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3

#对iptables的优化
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 7200
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120

#以下是CentOS5的参数
#net.ipv4.ip_conntrack_max = 25000000
#net.ipv4.netfilter.ip_conntrack_max = 25000000
#net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 180
#net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait = 120
#net.ipv4.netfilter.ip_conntrack_tcp_timeout_close_wait = 60
#net.ipv4.netfilter.ip_conntrack_tcp_timeout_fin_wait = 120

##bridge 需加载bridge模块之后方可生效
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.ip_local_port_range = 1024 65535
vm.swappiness = 0
EOF

#修改ssh端口为
port=5122
sed  -i "/^#Port/ {s/^#//;s/22/$port/}" /etc/ssh/sshd_config


#history
sed -i '/^HISTSIZE/ a \export HISTFILESIZE=10000000\
export PROMPT_COMMAND="history -a"\
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S `whoami` "\
export HISTIGNORE="pwd:ls:ll:ls -al:"\
export HISTCONTROL="ignoredups"' /etc/profile

# 关闭不必要的tty,默认6个，修改为2个（centos6.x适用）
sed -i '/[1-2]/ s/6/2/' /etc/init/start-ttys.conf
sed -i '/tty/ s/6/2/' /etc/sysconfig/init 


#仅wheel组成员可以使用su,防止其他成员直接使用su - 切换root身份，，该限制不会影响sudo命令，只限制su 命令
sed -i '/required/ s/^#//' /etc/pam.d/su
echo "SU_WHEEL_ONLY  yes" >> /etc/login.defs

source /etc/profile
# time
echo "*/180 * * * * ( /usr/sbin/ntpdate tick.ucla.edu tock.gpsclock.com ntp.nasa.gov timekeeper.isi.edu ;)> /dev/null 2>&1" >>/var/spool/cron/root

# vim + solarized

yum install vim git -y

cd
git clone git://github.com/seebi/dircolors-solarized.git
cd dircolors-solarized
cp dircolors.256dark ~/.dircolors
sed -i '$a\eval `dircolors ~/.dircolors`\
export TERM=xterm-256color' ~/.bashrc
sed -i "/mv/ a\alias vi='vim'" ~/.bashrc
source ~/.bashrc

cd
git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized/
#./set_dark.sh

mkdir -p ~/.vim/{autoload,bundle}
cd ~/.vim/autoload
if [ ! $(rpm -qa | grep wget) ];then
    yum install wget -y
fi
wget https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cd ~/.vim/bundle
git clone git://github.com/altercation/vim-colors-solarized.git

if [ $? != 0 ];then
    echo "solarized not succeed!"
    exit 3
else
    echo "solarized succeed,then install NERDTree and vim-nerdtree-tabs"
    sleep 2
fi

#NERDTree and vim-nerdtree-tabs
#cd ~/.vim/bundle
#git clone https://github.com/scrooloose/nerdtree.git
#git clone https://github.com/jistr/vim-nerdtree-tabs.git

cat > ~/.vimrc << EOF
set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
"set ai			" always set autoindenting on
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
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
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
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

if &term=="xterm"
     set t_Co=8
     set t_Sb=[4%dm
     set t_Sf=[3%dm
endif

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
 
" 插入匹配括号
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap { {}<LEFT>

" 按退格键时判断当前光标前一个字符，如果是左括号，则删除对应的右括号以及括号中间的内容
function! RemovePairs()
    let l:line = getline(".")
    let l:previous_char = l:line[col(".")-1] " 取得当前光标前一个字符
 
    if index(["(", "[", "{"], l:previous_char) != -1
        let l:original_pos = getpos(".")
        execute "normal %"
        let l:new_pos = getpos(".")
 
        " 如果没有匹配的右括号
        if l:original_pos == l:new_pos
            execute "normal! a\<BS>"
            return
        end
 
        let l:line2 = getline(".")
        if len(l:line2) == col(".")
            " 如果右括号是当前行最后一个字符
            execute "normal! v%xa"
        else
            " 如果右括号不是当前行最后一个字符
            execute "normal! v%xi"
        end
 
    else
        execute "normal! a\<BS>"
    end
endfunction

" 用退格键删除一个左括号时同时删除对应的右括号
inoremap <BS> <ESC>:call RemovePairs()<CR>a

" 输入一个字符时，如果下一个字符也是括号，则删除它，避免出现重复字符
function! RemoveNextDoubleChar(char)
    let l:line = getline(".")
    let l:next_char = l:line[col(".")] " 取得当前光标后一个字符
 
    if a:char == l:next_char
        execute "normal! l"
    else
        execute "normal! i" . a:char . ""
    end
endfunction
inoremap ) <ESC>:call RemoveNextDoubleChar(')')<CR>a
inoremap ] <ESC>:call RemoveNextDoubleChar(']')<CR>a
inoremap } <ESC>:call RemoveNextDoubleChar('}')<CR>a
 
"在执行宏命令时，不进行显示重绘；在宏命令执行完成后，一次性重绘，以便提高性能。
set lazyredraw
 
"设置一个tab对应4个空格
set tabstop=4
 
"在按退格键时，如果前面有4个空格，则会统一清除
set softtabstop=4
 
"cindent对c语法的缩进更加智能灵活，
"而shiftwidth则是在使用&lt;和&gt;进行缩进调整时用来控制缩进量。
"换行自动缩进，是按照shiftwidth值来缩进的
set cindent shiftwidth=4
 
"最基本的自动缩进
"set autoindent shiftwidth=4
 
"比autoindent稍智能的自动缩进
set smartindent shiftwidth=4

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
map ed :s#\s\+$##<CR>
 
"如果所选行的行首没有#，则给所选行行首加上注释符#（#a：# add）
map #a :s/^\([^#]\s*\)/#\1/<CR>
 
"如果所选行行首有#，则将所选行行首所有的#都去掉（#d：# delete）
map #d :s/^#\+\(\s*\)/\1/<CR>
 
"如果所选行的行首没有//，则给所选行行首加上注释符//（/a：/ add）
map /a :s/^\([^\/\/]\s*\)/\/\/\1/<CR>
 
"如果所选行行首有//，则将所选行行首的//都去掉（/d：/ delete）
map /d :s/^\/\/\(\s*\)/\1/<CR>

"在同一vim窗口中打开man手册
source $VIMRUNTIME/ftplugin/man.vim

"NERDTree
"打开vim时自动运行NERDTree
"autocmd vimenter * NERDTree
"运行NERDTree后自动将光标定位在右侧窗口
"autocmd VimEnter * wincmd w
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"退出编辑区自动退出NERDTree
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
"默认显示bookmarks
"let NERDTreeShowBookmarks=1 
"打开/关闭NERDTree的快捷键
"map <C-n> :NERDTreeToggle<CR>

"vim-nerdtree-tabs
"let g:nerdtree_tabs_open_on_console_startup=1
EOF
echo "~/.vimrc has been created"
sleep 2

echo "the last, iptables and reboot"
#iptables
#定义变量
IPTABLES=/sbin/iptables

#清除filter表中INPUT OUTPUT FORWARD链中的所有规则，但不会修改默认规则。
$IPTABLES -F
#清除filter表中自定义链中的所有规则
#$IPTABLES -X
#$IPTABLES -Z
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp --dport $port --syn -m state --state NEW -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp --dport 80 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 10.10.38.238 --dport 161 -j ACCEPT
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
$IPTABLES -P INPUT DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m udp --dport 123 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP
service iptables save

# reboot system
echo -n "reboot system right now?[Y/n]"
read -n 1 answer
case $answer in
Y|y) echo 
for i in $(seq -w 10| tac)
do
        echo -ne "\aThe system will reboot after $i seconds...\r"
        sleep 1
done
echo
shutdown -r now  
;;
N|n)
echo
;;
esac
exit 0
