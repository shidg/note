#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#pip的安装（新版本Python自带pip）
#https://pypi.org/project/pip/

# ModuleNotFoundError: No module named 'pip'
python -m ensurepip
python -m pip install --upgrade pip

# 使用pip,将从 Python Packaging Index（https://pypi.org） 安装一个模块的最新版本及其依赖项
python -m pip install SomePackage
python -m pip install SomePackage==1.0.4    # specific version
python -m pip install "SomePackage>=1.0.4"  # minimum version

# wheel格式的安装包
# 在https://pypi.python.org/pypi/redis#downloads，下载安装包
#　pip install redis-2.10.6-py2.py3-none-any.whl


# 源码安装
#下载tar.gz结尾的安装包
#解压这个压缩包
#在命令行里面运行 python setup.py install
 
