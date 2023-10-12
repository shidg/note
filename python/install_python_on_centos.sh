#!/bin/bash
# File Name: -- install_python_on_centos.sh --
# author: -- shidegang --
# Created Time: 2019-12-26 10:14:11


## python 3.x ###
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel gcc make automake autoconf libtool

# https://www.python.org/downloads/

./configure --prefix=/usr/local/python3 --enable-optimizations
make && make install


