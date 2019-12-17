#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-12-17 18:02:57

# 直接下载二进制包
# https://github.com/BurntSushi/ripgrep/releases

# 在线安装
brew install ripgrep

yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo && yum install ripgrep


# 使用rust安装
curl https://sh.rustup.rs -sSf | sh

git clone https://github.com/BurntSushi/ripgrep
cd ripgrep
cargo build --release
cp ./target/release/rg /usr/local/bin/
