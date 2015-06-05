#安装apr
tar jxvf apr-1.5.2.tar.bz2  && cd apr-1.5.2

sed -i '/$RM "$cfgfile"/ s/^/#/' configure

./configure --prefix=/usr/local/apr

 make && make install

#安装apr-util
tar jxvf apr-util-1.5.4.tar.bz2 && cd  apr-util-1.5.4

./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config

make && make install

#安装sqlite
#http://www.sqlite.org/download.html
tar zxvf sqlite-autoconf-3081002.tar.gz  && cd   sqlite-autoconf-3081002

./configure --prefix=/usr/local/sqlite

make && make install

#安装svn
tar  jxvf subversion-1.8.13.tar.bz2 && cd  subversion-1.8.13
./configure --prefix=/usr/local/subversion  --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-sqlite=/usr/local/sqlite/

make && make install

make install-tools  #在安装目录bin目录下生成svn-tools目录，里边有一些扩展工具，比如svnauthz-validate
