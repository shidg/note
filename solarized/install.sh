##ubuntu
sudo apt-get install git-core

#dircolors
cd

git clone git://github.com/seebi/dircolors-solarized.git

cd dircolors-solarized
cp dircolors.256dark ~/.dircolors

vi ~/.bashrc, add:
eval `dircolors ~/.dircolors`
export TERM=xterm-256color

source ~.bashrc

#terminal-colors
cd 
git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git

cd gnome-terminal-colors-solarized/

./set_dark.sh


# vim solarized

mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/bundle

cd ~/.vim/autoload
wget https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

cd ~/.vim/bundle
git clone git://github.com/altercation/vim-colors-solarized.git

# .vimrc
syntax on
execute pathogen#infect()
set background=dark
colorscheme solarized


#securecrt
# C:\Users\shidg\AppData\Roaming\VanDyke_SCRT\Config\Global.ini(具体路径以实际安装位置为准)
# 找到B:”ANSI Color RGB”这一行， 修改这一行开始的3行为以下内容：

B:"ANSI Color RGB"=00000040
00 2b 38 00 dc 32 2f 00 85 99 00 00 b5 89 00 00 26 8b d2 00 d3 36 82 00 2a a1 98 00 ee e8 d5 00
07 36 42 00 cb 4b 16 00 58 6e 75 00 65 7b 83 00 83 94 96 00 6c 71 c4 00 93 a1 a1 00 fd f6 e3 00

# 启动secureCRT， 工具栏options->global options->Terminal->Appearance->Advanced中找到color scheme选项， 在下拉菜单中选中traditional这个选项

# 之后步骤与ubuntu中相同
