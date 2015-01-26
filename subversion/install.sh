#��װapr
tar jxvf apr-1.5.1.tar.bz2  && cd apr-1.5.1

sed -i '/$RM "$cfgfile"/ s/^/#/' configure

./configure --prefix=/usr/local/apr

 make && make install

#��װapr-util
tar jxvf apr-util-1.5.4.tar.bz2 && cd  apr-util-1.5.4

./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config

make && make install

#��װsqlite
tar zxvf sqlite-autoconf-3080801.tar  && cd   sqlite-autoconf-3080801

./configure --prefix=/usr/local/sqlite

make && make install

#��װsvn
tar  jxvf subversion-1.8.11.tar.bz2 && cd  subversion-1.8.11

./configure --prefix=/usr/local/subversion  --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-sqlite=/usr/local/sqlite/

make && make install

make install-tools  #�ڰ�װĿ¼binĿ¼������svn-toolsĿ¼�������һЩ��չ���ߣ�����svnauthz-validate