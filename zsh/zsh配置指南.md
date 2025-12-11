### 安装zsh

```bash
# 安装
sudo apt update
sudo apt install zsh -y

# 查看版本
zsh --version
```

### 安装Oh-My-Zsh

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 安装Powerlevel10k主题

```bash
# 安装Powerlevel10k
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 修改主题为Powerlevel10
# 修改~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
```

### 安装Nerd Fonts字体

```bash
sudo wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip

# 用户级别安装
sudo mkdir  -p ~/.local/share/fonts
sudo unzip Meslo.zip -d  .local/share/fonts

# 系统级别安装
sudo unzip Meslo.zip -d /usr/local/share/fonts

# 更新字体缓存
sudo apt install fontconfig
sudo fc-cache -fv
```

### 配置Powerlevel10k主题

```bash
p10k configure
```

###  配置自动补全

```bash
# 安装zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 安装zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
```

### 语法高亮

```bash
# 安装
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 快速跳转常用目录

```bash
# 安装autojump
sudo apt install autojump
```

### 将配置写入.zshrc

```ini
# .zshrc
# 启用插件
plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    poetry
    history
    autojump
)

# 自动跳转常用目录
[[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh

# 其他常用配置

# 直接输入目录名就能进入
setopt auto_cd   

# 自动纠正拼写错误
setopt correct

# 历史命令去重
setopt HIST_IGNORE_DUPS

# 搜索历史命令去重
setopt HIST_FIND_NO_DUPS

# 历史记录设置
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# 高亮
ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/highlighters

```

### 用用配置

```bash
source ~/.zshrc
```

