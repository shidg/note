#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-12-05 13:33:57


wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh

bash Miniconda3-latest-MacOSX-x86_64.sh

# 默认安装位置为$HOME/mimaconda3


# 添加清华镜像源(频道)
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/

## 官方channels 
conda config --add channels bioconda
conda config --add channels conda-forge

# 查看已有频道
conda config --get channels

# 创建环境
conda-env create -n python3.8 python=3.8

# 激活环境
conda activate python3.8

# 查看已有环境
conda -env list


# 查看环境中已安装软件
conda list

# 安装/删除软件
conda install/remove xxx
