#vim 版本大于7.3.584

# 先安装python3,安装vim时开启对python3的支持
wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz
tar zxvf Python-3.6.4.tgz && cd Python-3.6.4
./configure --prefix=/usr/local/python3 --enable-shared --enable-optimizations && make && make install

# add python3 to $PATH
PATH=$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin:$SUBVERSION_HOME/bin:$PYTHON3_HOME/bin
export PATH

#升级vim
yum install ncurses-devel perl-ExtUtils-Embed python-devel

git clone https://github.com/vim/vim.git && cd vim/src

./configure --with-features=huge  --enable-pythoninterp=yes --enable-python3interp=yes --with-python-config-dir=/usr/lib64/python2.7/config/ --with-python3-config-dir=/usr/local/python3/lib/python3.6/config-3.6m-x86_64-linux-gnu/ --enable-perlinterp=yes --enable-rubyinterp=yes --enable-rubyinterp=yes --enable-multibyte --enable-cscope --enable-luainterp --prefix=/usr

make -j4 && make install

#==============================================================================================

#升级gcc

# 依赖
yum install gcc gcc-c++ gibc-static cloog-ppl gmp-devel

# isl
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2
tar jxvf isl-0.12.2.tar.bz2 && cd isl-0.12.2
./configure
make
make install

#获取最新gcc源码
#svn checkout svn://gcc.gnu.org/svn/gcc/trunk  localdir
cd localdir/gcc
mkdir build

#下载gmp，mpfr，mpc源码，gcc-4.10.tgz里已经包含下载完的三个源码包，不必再次下载
./contrib/download_prerequisites 

cd build
../configure --prefix=/usr --enable-languages=c,c++ --disable-multilib

make -j4 
#make -j选项，与cpu个数及线程数有关

make install

#===================================================================================================


# 安装vundel，vim插件管理器
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# 使用vundel安装YouCompleteMe

# 在.vimrc中添加如下内容：

""""""""""""""""""""""""""""""  
" Vunble  
""""""""""""""""""""""""""""""  
filetype off  "required!
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' "required!
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/vim-powerline'
Plugin 'Yggdroot/indentLine'
Plugin 'w0rp/ale'
call vundle#end()
filetype plugin indent on "required
  
# 执行命令 vim +BundleInstall +qall来安装YouCompleteMe

#安装 YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe 
git submodule update --init --recursive
yum install cmake -y
./install.py --clang-completer
