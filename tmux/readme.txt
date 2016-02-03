# get source
wget http://sourceforge.net/projects/tmux/files/tmux/tmux-1.9/tmux-1.9a.tar.gz


##git获取较新版本##
git clone https://github.com/tmux/tmux.git tmux
cd tmux
sh autogen.sh
#若执行autogen.sh的时候提示"aclocal: command not found"则yum install libtool即可。

#安装依赖,libevent和ncurses
tar zxvf libevent-2.0.22-stable.tar.gz && cd libevent-2.0.22-stable && ./configure --prefix=/usr && make && make install
ldconfig

yum install ncurses-devel -y

# install tmux
./configure (--prefix=/usr) && make && make install

#############################################################
###By default, `make install' will install all the files in##
###'/usr/local/bin', '/usr/local/lib' etc.                 ##
#############################################################


