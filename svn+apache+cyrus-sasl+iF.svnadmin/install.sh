#安装apr
# deps
yum -y install gcc gcc-c++ libtool openssl openssl-devel ncurses ncurses-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel sqlite sqlite-devel zlib zlib-devel libpng-devel gd-devel freetype-devel perl perl-devel perl-ExtUtils-Embed

#apr
tar jxvf apr-1.5.2.tar.bz2  && cd apr-1.5.2
sed -i '/$RM "$cfgfile"/ s/^/#/' configure
./configure --prefix=/usr/local/apr
 make && make install

#安装apr-util
tar jxvf apr-util-1.5.4.tar.bz2 && cd  apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#安装pcre
tar jxvf pcre-8.37.tar.bz2 && cd pcre-8.37
./configure --prefix=/usr/local/pcre
make && make install

#升级openssl
tar zxvf openssl-1.0.2a.tar.gz
cd openssl-1.0.2a
./config shared zlib
make && make install
mv /usr/bin/openssl /usr/bin/openssl.OFF
mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl

#安装apache
tar jxvf httpd-2.4.12.tar.bz2 && cd httpd-2.4.12
./configure --prefix=/usr/local/apache-2.4.12 --sysconfdir=/etc/httpd --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr-util/bin/apu-1-config  --with-pcre=/usr/local/pcre/ --enable-so --enable-mods-shared=most --enable-rewirte  --enable-ssl=shared --with-ssl=/usr/local/ssl
make && make install

#re2c (for php)
tar zxvf re2c-0.14.3.tar.gz && cd re2c-0.14.3
./configure && make &&  make install

# libiconv (for php)
tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14
./configure --prefix=/usr && make && make install

# php (for iF.SVNADMIN)
tar jxvf php-5.3.29.tar.bz2 && cd php-5.3.29
 ./configure --prefix=/Data/app/php-5.3.29  --with-config-file-path=/Data/app/php-5.3.29/etc --with-apxs2=/Data/app/apache-2.4.12/bin/apxs --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir --with-zlib --with-gd  --with-freetype-dir  --enable-gd-native-ttf  --with-readline --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear  --enable-mbstring --enable-soap --enable-xml --enable-zip --enable-bcmath
make ZEND_EXTRA_LIBS='-liconv' && make install

#安装sqlite
#http://www.sqlite.org/download.html
tar zxvf sqlite-autoconf-3081002.tar.gz  && cd   sqlite-autoconf-3081002
./configure --prefix=/usr/local/sqlite
make && make install

#cyrus-sasl
#注销旧的cyrus-sasl
mv /usr/lib64/sasl2/ /usr/lib64/sasl2.OFF
tar zxvf cyrus-sasl-2.1.26.tar.gz && cd cyrus-sasl-2.1.26
./configure --disable-sample --disable-saslauthd --disable-pwcheck --disable-krb4 --disable-gssapi --disable-anon --enable-plain --enable-login --enable-cram --enable-digest --with-saslauthd=/var/run/saslauthd
make && make install
ln -s /usr/local/lib/sasl2/ /usr/lib64/sasl2
echo "/usr/local/lib/sasl2/lib" >> /etc/ld.so.conf
ldconfig

#安装subversion
tar  jxvf subversion-1.8.13.tar.bz2 && cd  subversion-1.8.13
./configure --prefix=/usr/local/subversion --with-apxs=/usr/local/apache2/bin/apxs --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-sqlite=/usr/local/sqlite/ --with-sasl=/usr/lib64/sasl2
make && make install
#在安装目录下生成svn-tools目录，里边有一些扩展工具，比如svnauthz-validate
make install-tools

#########svnserve --version################
##Cyrus SASL authentication is available.##
###########################################

# $PATH
cat >> ~/.bashrc << EOF
APACHE_HOME=/Data/app/apache-2.4.12
SUBVERSION_HOME=/Data/app/subversion
PATH=$PATH:${APACHE_HOME}/bin:${SUBVERSION_HOME}/bin
export APACHE_HOME SUBVERSIOIN_HOME PATH
EOF

#为apache添加模块
cd $prefix
cp   libexec/mod_authz_svn.so  /usr/local/apache2/modules/
cp   libexec/mod_dav_svn.so  /usr/local/apache2/modules/

#向httpd.conf添加：
LoadModule dav_module modules/mod_dav.so
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so

#去掉Include /etc/httpd/extra/httpd-vhosts.conf行前注释使之生效

#在httpd-vhosts.conf添加虚拟主机：
<VirtualHost *:80>
    ServerName svn.happigo.com
    <Location /svn>                         #这里的/svn要区别于Alias目录别名
        DAV svn
        SVNParentPath /data/svn      #svn版本库根目录,根目录下有多个版本库使用SVNParentPath,单个版本库可使用SVNPath
        AuthType Basic
        AuthName "Subversion repository"    #验证页面提示信息
        AuthUserFile /data/svn/passwd          #用户名密码
        Require valid-user                              # 只允许通过验证的用户访问
        AuthzSVNAccessFile /data/svn/authz  #版本库权限控制
    </Location>
</VirtualHost>
# 创建passwd及authz文件

# 创建认证文件

# 用户名密码文件：
htpasswd -c  /data/svn/passwd  user1  #首次添加用户，再添加用户使用-m参数即可

# 版本库权限认证文件

vi  /data/svn/authz  #按照svn版本库下的authz文件格式编辑权限即可

#  创建版本库

svnadmin  create /data/svn/test1

# 访问
http://svn.xx.com/svn/test1


# 配置apache  https

# 服务器要安装了openssl,上边的步骤中已经安装过

# apache要加载ssl模块或者安装apache的时候已经使用enable-ssl静态包含了ssl

#httpd.conf中去掉如下行的注释，使之生效
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
Include /etc/httpd/extra/httpd-ssl.conf

#编辑httpd-ssl.conf文件

<VirtualHost _default_:443>
ServerName svn.xx.com:443
<Location /svn>
        DAV svn
        SVNParentPath /data/svn
        AuthType Basic
        AuthName "Subversion repository"
        AuthUserFile /data/svn/passwd
        Require valid-user
        AuthzSVNAccessFile /data/svn/authz
</Location>
SSLEngine on
SSLCertificateFile "/etc/httpd/server.crt"     
SSLCertificateKeyFile "/etc/httpd/server.key"
</VirtualHost >

# 生成ssl证书
openssl genrsa  -des3 -out  server.key 1024 #des3 给私钥添加密码，提升安全性

openssl req -new   -key server.key  -out server.csr # 与私钥匹配的公钥，连接建立后该公钥传输给客户端

openssl req -x509 -days 365 -signkey server.key -in server.csr  -out  server.crt #给公钥签名，生成证书

cp server.key server.key.with_pass

openssl rsa -in server.key.with_pass -out server.key # 生成一个无密码的私钥，专门给apache或nginx使用的，因为传输过程中要使用私钥对客户端使用的公钥进行验证，匹配才允许传输

#将生成的三个文件放到/et/httpd目录下（/etc/httpd目录是上一步httpd-ssl.conf中指定的）

# 重启apache服务

#访问

https://svn.xx.com/svn/test1

#注意在这种模式下（svn服务并不启动，通过http或https来管理svn），向svn提交数据的时候要保证用来运行apache的用户对svn版本库目录有读写权限，不然会遇到“db/txn-current-lock': Permission denied” 的错误
