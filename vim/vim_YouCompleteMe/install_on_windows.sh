# install(支持python的)vim8.0 (vim --version)
# https://github.com/vim/vim-win32-installer/releases

# install vundle (vim插件管理器)
    # install git
cd %USERPROFILE%/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git

# edit %USERPROFILE%/.vim/_vimrc
set rtp+=C:\Users\shidegang\.vim\bundle\Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
call vundle#end()

# install python
# 在cmd中，测试命令"py"是否可用

# install cmake 
# https://cmake.org/download/

# install 7zip

# install Visual Studio 2017 Community版本,安装时选择"Desktop development with C++"
# https://www.visualstudio.com/zh-hans/downloads/

# install YouCompleteMe
    # edit %USERPROFILE%/.vim/_vimrc

filetype off
set rtp+=C:\Users\shidegang\.vim\bundle\Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()

vim ---> PluginInstall

# 在cmd中
cd %USERPROFILE%/.vim/bundle/YouCompleteMe
py install.py



#安装其他插件
filetype off
set rtp+=C:\Users\shidegang\.vim\bundle\Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'Yggdroot/indentLine'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()
