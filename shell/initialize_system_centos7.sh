#!/bin/bash

if [ $(id -u) != 0 ];then
echo "Must be root can do this."
exit 9
fi

#selinux
if [ `sed -n '/^SELINUX=/p' /etc/selinux/config  | cut -d= -f2` != disabled ];then
    sed -i '/^SELINUX=/ s/^/#/;/#SELINUX=/a\SELINUX=disabled' /etc/selinux/config
fi

#stop firewalld
systemctl stop firewalld && systemctl disable firewalld

#install iptables service
yum install iptables-services -y

#install killall
yum install psmisc -y

# install atd
yum install at -y

#修改ssh端口为
port=5122
sed  -i "/^#Port/ {s/^#//;s/22/$port/}" /etc/ssh/sshd_config

# set privileges
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

# Turn off unnecessary services
service=($(ls /usr/lib/systemd/system))
for i in ${service[@]} ;do
case $i in
sshd.service|rsyslog.service|iptables.service|crond.service|atd.service)
systemctl enable $i;;
*)
systemctl disable $i;;
esac
done

#set ulimit
sed  -i '$ i\*             soft    nofile          65535 \
*               hard    nofile          65535 \
*               soft    core            unlimited \
*               hard    core            unlimited' /etc/security/limits.conf

# set sysctl
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

#####for  lvs ######
#net.ipv4.conf.all.rp_filter = 0
#net.ipv4.conf.default.rp_filter = 0
#net.ipv4.conf.lo.arp_ignore = 1
#net.ipv4.conf.lo.arp_announce = 2
#net.ipv4.conf.all.arp_ignore = 1
#net.ipv4.conf.all.arp_announce = 2
#################################################

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
# next 单个共享内存段的大小（单位：字节）限制，计算公式64G*1024*1024*1024(字节)
kernel.shmmax = 4294967296
#next 所有内存大小（单位：页，1页 = 4Kb），计算公式16G*1024*1024*1024/4KB(页)
kernel.shmall = 2097152
kernel.shmmni = 4096
#coredump
kernel.core_pattern=/Data/corefiles/core-%e-%s-%u-%g-%p-%t
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.core.wmem_default = 8388608
net.core.wmem_max = 16777216
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216


net.core.somaxconn = 8192            # 每个监听socket的TCP全连接队列长度
net.ipv4.tcp_max_syn_backlog = 4096  # 每个监听socket的TCP半连接队列长度
net.ipv4.tcp_synack_retries = 2      # 内核发送syn+ack的重试次数
net.ipv4.tcp_tw_reuse = 1            # TIME_WAIT重用(只对客户端生效)
net.ipv4.tcp_fin_timeout = 30        # 缩短FIN_WAIT_2状态的超时时间
net.ipv4.ip_local_port_range = 1024 65000  # 扩大本地端口范围
net.core.netdev_max_backlog = 16384  # 数据包backlog 队列长度（packet 个数）

# 放弃回应一个（未建立连接的）TCP 连接请求前﹐需要进行N次重试,default:3；
net.ipv4.tcp_retries1 = 3
#在丢弃激活(已建立通讯状况)的TCP连接之前﹐需要进行N次重试,default:15；
net.ipv4.tcp_retries2 = 5

#系统所能处理的不属于任何进程的TCP sockets最大数量，不能过分依靠它或者人为地减小这个值，更应该增加这个值(如果增加了内存之后) 每个孤儿套接字最多能够吃掉64K不可交换的内存
net.ipv4.tcp_max_orphans = 3276800

net.ipv4.tcp_syncookies = 1

# 对于一个新建连接，内核要发送多少个 SYN 连接请求才决定放弃(出站)
net.ipv4.tcp_syn_retries = 2

# 对于远端的连接请求SYN，内核在放弃连接之前所送出的 SYN+ACK 数目
net.ipv4.tcp_synack_retries = 2


################# 以下选项谨慎开启!!! ########################
################# 很可能会导致处在NAT环境中的客户端与该服务器的连接出现不可预知的问题  ##########################################
# tcp时间戳
net.ipv4.tcp_timestamps = 1

# TIME_WAIT重用,须开启tcp时间戳方能生效
# 这个参数对客户端有意义，在主动发起连接的时候会在调用的inet_hash_connect()中会检查是否可以重用TIME_WAIT状态的套接字。
# 在服务器段设置这个参数的话，则没有什么作用，因为服务器端ESTABLISHED状态的套接字和监听套接字的本地IP、端口号是相同的，没有重用的概念
net.ipv4.tcp_tw_reuse = 1
############################################################################################

#系统同时保持TIME_WAIT套接字的最大数量
net.ipv4.tcp_max_tw_buckets = 5000

#减少处于FIN-WAIT-2连接状态的时间，使系统可以处理更多的连接
net.ipv4.tcp_fin_timeout = 30

#减少TCP KeepAlive连接侦测的时间，使系统可以处理更多的连接
# 以下设置为5分钟断开 30 + 30*9 = 300
net.ipv4.tcp_keepalive_time = 30
# 重试间隔
net.ipv4.tcp_keepalive_intvl = 30
# 重试次数
net.ipv4.tcp_keepalive_probes = 9

#对iptables的优化
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 7200
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120


##bridge 需加载bridge模块之后方可生效
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

net.ipv4.tcp_mem =  3145728 8388608 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.ip_local_port_range = 1024 65535
vm.swappiness = 0
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10

EOF

#修改ssh端口为
port=5122
sed  -i "/^#Port/ {s/^#//;s/22/$port/}" /etc/ssh/sshd_config

# ssh密码错误3次账号锁定5分钟(不锁定root)
#sed -i '/#%PAM/ a\auth required pam_tally2.so deny=3 unlock_time=300' even_deny_root root_unlock_time=120 /etc/pam.d/sshd
sed -i '/#%PAM/ a\auth required pam_tally2.so deny=3 unlock_time=300' /etc/pam.d/sshd
sed -i '/-auth/ a\account     required    pam_tally2.so' /etc/pam.d/sshd

#history
sed -i '/^HISTSIZE/ a \export HISTFILESIZE=10000000\
export PROMPT_COMMAND="history -a"\
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S `whoami` "\
export HISTIGNORE="pwd:ls:ll:ls -al:"\
export HISTCONTROL="ignoredups"' /etc/profile


#仅wheel组成员可以使用su,防止其他成员直接使用su - 切换root身份，，该限制不会影响sudo命令，只限制su 命令
sed -i '/required/ s/^#//' /etc/pam.d/su
echo "SU_WHEEL_ONLY  yes" >> /etc/login.defs

source /etc/profile

# time
yum install ntp -y
echo "*/180 * * * * ( /usr/sbin/ntpdate tick.ucla.edu tock.gpsclock.com ntp.nasa.gov timekeeper.isi.edu ;)> /dev/null 2>&1" >>/var/spool/cron/root

# vim + solarized

yum install vim git -y

cd
git clone https://github.com/seebi/dircolors-solarized.git
cd dircolors-solarized
cp dircolors.256dark ~/.dircolors
sed -i '$a\eval `dircolors ~/.dircolors`\
export TERM=xterm-256color' ~/.bashrc
sed -i "/mv/ a\alias vi='vim'" ~/.bashrc
source ~/.bashrc

cd
git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized/
#./set_dark.sh

mkdir -p ~/.vim/{autoload,bundle}
cd ~/.vim/autoload
if [ ! $(rpm -qa | grep wget) ];then
    yum install wget -y
fi
wget https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cd ~/.vim/bundle
git clone https://github.com/altercation/vim-colors-solarized.git

if [ $? != 0 ];then
    echo "solarized not succeed!"
    exit 3
else
    echo "solarized succeed,then install NERDTree and vim-nerdtree-tabs"
    sleep 2
fi

cat > ~/.vimrc << EOF
set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
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
" vundel

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Lokaltog/vim-powerline'
Plugin 'Yggdroot/indentLine'
Plugin 'w0rp/ale'
call vundle#end()
filetype plugin indent on


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

"一个tab键对应4个空格
set ts=4
"自动缩进时缩进4个空格
set sw=4
set expandtab
"一次退格键删除4个空格
set softtabstop=4
" 继承前一行的缩进方式，特别适用于多行注释
" set autoindent
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
\set autoindent
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
#单IP最大并发ssh连接限制
$IPTABLES -A INPUT -p tcp --dport $port -m connlimit  --connlimit-above 3 -j DROP
#

#单IP每分钟限制10个新ssh连接
$IPTABLES -A INPUT -p tcp --dport $port  -m state --state NEW -m recent --name SSHPOOL --rcheck --seconds 60 --hitcount 5 -j LOG --log-prefix "DROP_SSH" --log-ip-options --log-tcp-options
$IPTABLES -A INPUT -p tcp --dport $port  -m state --state NEW -m recent --name SSHPOOL --rcheck --seconds 60 --hitcount 5 -j DROP
$IPTABLES -A INPUT -p tcp --dport $port  -m state --state NEW -m recent --name SSHPOOL --set -j ACCEPT
#
$IPTABLES -A INPUT -p tcp -m tcp --dport $port -m state --state NEW -j ACCEPT
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
$IPTABLES -P INPUT DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m udp --dport 123 -m conntrack --ctstate NEW -j ACCEPT
# traceroute
$IPTABLES -A OUTPUT -p udp --dport 33434:33524 -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

# save to /etc/sysconfig/iptables
/usr/libexec/iptables/iptables.init save

#MODULES AUTO LOAD ON BOOT
# bridge
cat > /etc/sysconfig/modules/bridge.modules << EOF
#! /bin/bash
/sbin/modprobe bridge
EOF

#nf_conntrack
cat > /etc/sysconfig/modules/nf_conntrack.modules << EOF
#! /bin/bash
/sbin/modprobe nf_conntrack
EOF

#nf_conntrack_ipv4
cat > /etc/sysconfig/modules/nf_conntrack_ipv4.modules << EOF
#! /bin/bash
/sbin/modprobe nf_conntrack_ipv4
EOF

chmod +x /etc/sysconfig/modules/*

#kerneldump file_pattern
mkdir -p /Data/corefiles && chmod 777 /Data/corefiles

# reboot system
echo -e "reboot system right now?[Y/n]"
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
