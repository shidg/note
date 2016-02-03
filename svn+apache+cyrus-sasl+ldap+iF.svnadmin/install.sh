# deps
yum -y install gcc gcc-c++ libtool openssl openssl-devel ncurses ncurses-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel sqlite sqlite-devel zlib zlib-devel libpng-devel gd-devel freetype-devel perl perl-devel perl-ExtUtils-Embed openldap openldap-devel

APP_DIR=/usr/local/
SOURCE_DIR=/Data/software
[ "$PWD" != "${SOURCE_DIR}" ] && cd ${SOURCE_DIR}

#apr
tar jxvf apr-1.5.2.tar.bz2  && cd apr-1.5.2
sed -i '/$RM "$cfgfile"/ s/^/#/' configure
./configure --prefix=${APP_DIR}apr
make && make install
cd ..

#安装apr-util
tar jxvf apr-util-1.5.4.tar.bz2 && cd  apr-util-1.5.4
./configure --prefix=${APP_DIR}apr-util --with-apr=${APP_DIR}apr/bin/apr-1-config --with-ldap
make && make install
cd ..

#安装pcre
tar jxvf pcre-8.38.tar.bz2 && cd pcre-8.37
./configure --prefix=${APP_DIR}pcre
make && make install
cd ..

#升级openssl
tar zxvf openssl-1.0.2f.tar.gz
cd openssl-1.0.2f
./config shared zlib
make && make install
mv /usr/bin/openssl /usr/bin/openssl.OFF
mv /usr/include/openssl /usr/include/openssl.OFF
ln -s ${APP_DIR}ssl/bin/openssl /usr/bin/openssl
ln -s ${APP_DIR}ssl/include/openssl /usr/include/openssl
echo "${APP_DIR}ssl/lib" >> /etc/ld.so.conf
ldconfig
cd ..

#安装apache
tar jxvf httpd-2.4.17.tar.bz2 && cd httpd-2.4.17
./configure --prefix=${APP_DIR}apache-2.4.17 --sysconfdir=/etc/httpd --with-apr=${APP_DIR}apr/bin/apr-1-config --with-apr-util=${APP_DIR}apr-util/bin/apu-1-config  --with-pcre=${APP_DIR}pcre/ --enable-so --enable-mods-shared=all --enable-rewirte  --enable-ssl=shared --with-ssl=${APP_DIR}ssl --enable-ldap --enable-authnz-ldap
make && make install
cd ..

#re2c (for php)
tar zxvf re2c-0.14.3.tar.gz && cd re2c-0.14.3
./configure && make &&  make install
cd ..

# libiconv (for php)
tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14
#centos7 补丁
#cd ..
#gunzip libiconv-glibc-2.16.patch.gz
#cd libiconv-1.14/srclib
#patch -p1 < ../../libiconv-glibc-2.16.patch
#cd ..
./configure --prefix=/usr && make && make install
cd ..

# php (for iF.SVNADMIN)
tar jxvf php-5.3.29.tar.bz2 && cd php-5.3.29
./configure --prefix=${APP_DIR}php-5.3.29  --with-config-file-path=${APP_DIR}php-5.3.29/etc --with-apxs2=${APP_DIR}apache-2.4.12/bin/apxs --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir --with-zlib --with-gd  --with-freetype-dir  --enable-gd-native-ttf  --with-readline --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear  --enable-mbstring --enable-soap --enable-xml --enable-zip --enable-bcmath
make ZEND_EXTRA_LIBS='-liconv' && make install

#php添加ldap支持
cd ext/ldap
${APP_DIR}php-5.3.29/bin/phpize
./configure --with-ldap  --with-ldap-sasl --with-php-config=${APP_DIR}php-5.3.29/bin/php-config 
make && make install
mkdir ${APP_DIR}php-5.3.29/ext
cp ${APP_DIR}php-5.3.29/lib/php/extensions/no-debug-zts-20090626/ldap.so ${APP_DIR}php-5.3.29/ext
#echo "extension = ldap.so" >> php.ini

cd ../../

#安装sqlite
#http://www.sqlite.org/download.html
tar zxvf sqlite-autoconf-3090200.tar.gz  && cd  sqlite-autoconf-3090200/
./configure --prefix=${APP_DIR}sqlite
make && make install
cd ..

#cyrus-sasl
#注销旧的cyrus-sasl
mv /usr/lib64/sasl2/ /usr/lib64/sasl2.OFF
tar zxvf cyrus-sasl-2.1.26.tar.gz && cd cyrus-sasl-2.1.26
./configure --disable-sample --disable-saslauthd --disable-pwcheck --disable-krb4 --disable-gssapi --disable-anon --enable-plain --enable-login --enable-cram --enable-digest --with-saslauthd=/var/run/saslauthd
make && make install
ln -s ${APP_DIR}lib/sasl2/ /usr/lib64/sasl2
echo "${APP_DIR}lib/sasl2/lib" >> /etc/ld.so.conf
ldconfig
cd ..



### serf [让svn可以处理http/htps方式的版本库]
#scons# [http://sourceforge.net/projects/scons/files/scons/]
tar zxvf scons-2.4.0.tar.gz  && cd scons-2.4.0
python setup.py install 

# serf# [https://serf.apache.org/download]
tar jxvf serf-1.3.8.tar.bz2 && cd serf-1.3.8
scons PREFIX=/Data/app/serf APR=/Data/app/apr APU=/Data/app/apr-util/
scons install
scons -c




#安装subversion
tar  jxvf subversion-1.9.2.tar.bz2 && cd  subversion-1.9.2
./configure --prefix=${APP_DIR}subversion --with-apxs=${APP_DIR}apache-2.4.12/bin/apxs --with-apr=${APP_DIR}apr --with-apr-util=${APP_DIR}apr-util/ --with-sqlite=${APP_DIR}sqlite/ --with-serf=/Data/app/serf --with-sasl=/usr/lib64/sasl2
make && make install
#在安装目录下生成svn-tools目录，里边有一些扩展工具，比如svnauthz-validate
make install-tools
ln -s  /Data/app/serf/lib/libserf-1.so.1.3.0 /Data/app/subversion/lib/libserf-1.so.1 
cd ..

#########svnserve --version################
##Cyrus SASL authentication is available.##
###########################################

# $PATH
cat >> ~/.bashrc << EOF
APACHE_HOME=${APP_DIR}apache-2.4.12
SUBVERSION_HOME=${APP_DIR}subversion
PATH=$PATH:\${APACHE_HOME}/bin:\${SUBVERSION_HOME}/bin
export APACHE_HOME SUBVERSIOIN_HOME PATH
EOF
source ~/.bashrc

#为apache添加模块
cd ${SUBVERSOIN_HOME}
cp libexec/*svn.so  ${APACHE_HOME}/modules/

#确保apache开启了如下模块：
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule dav_module modules/mod_dav.so
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so
LoadModule authnz_ldap_module modules/mod_authnz_ldap.so
LoadModule ldap_module modules/mod_ldap.so


#配置saslauthd服务
cat > /etc/saslauthd.conf << EOF
ldap_servers: ldap://192.168.1.100
ldap_default_domain: selboo.com.cn
ldap_search_base: DC=selboo,DC=com,DC=cn
ldap_bind_dn: administrator@selboo.com.cn
ldap_bind_pw: 123456
ldap_deref: never
ldap_restart: yes
ldap_scope: sub
ldap_use_sasl: no
ldap_start_tls: no
ldap_version: 3
ldap_auth_method: bind
ldap_filter: sAMAccountName=%u
ldap_password_attr: userPassword
ldap_timeout: 10
ldap_cache_ttl: 30
ldap_cache_mem: 32768
EOF
sed -i '/^MECH/ s/pam/ldap/' /etc/sysconfig/saslauthd

#整合svn与sasl
#cat /etc/sasl2/svn.conf
pwcheck_method: saslauthd
auxprop_plugin: ldap
mech_list: PLAIN LOGIN
ldapdb_mech: PLAIN LOGIN

#启动saslauthd服务
service saslauthd start

#验证sasl
testsaslzuthd -u xxx -p xxx
##0: OK "Success."##

#svnadmin create /Data/svnroot/test1
# vi /Data/svnroot/test1/conf/svnserve.conf
[sasl]
use-sasl = true

#在httpd-vhosts.conf添加虚拟主机：
<VirtualHost *:80>
    ServerName svn.xxx.com
    <Location />
        DAV svn
        SVNParentPath /Data/svnroot
        AuthBasicProvider ldap
        AuthType Basic
        #AuthzLDAPAuthoritative on
        AuthName "My Subversion Server"
        AuthLDAPURL "ldap://10.10.xx.xx:389/DC=bj,DC=happigo,DC=com?sAMAccountName?sub?(objectClass=*)" NONE
        #AuthLDAPBindDN "CN=shidg,CN=Users,DC=bj,DC=happigo,DC=COM"
        AuthLDAPBindDN "shidg@bj.happigo.com"
        AuthLDAPBindPassword "xxxx"
        Require valid-user
        AuthzSVNAccessFile /Data/svnroot/authz
    </Location>
</VirtualHost>



##############################################最基本的htpasswd认证####################################################
#<VirtualHost *:80>
#    ServerName svn.happigo.com
#    <Location />                         #这里的/svn要区别于Alias目录别名
#        DAV svn
#        SVNParentPath /data/svn      #svn版本库根目录,根目录下有多个版本库使用SVNParentPath,单个版本库可使用SVNPath
#        AuthType Basic
#        AuthName "Subversion repository"    #验证页面提示信息
#        AuthUserFile /data/svn/passwd          #用户名密码
#        Require valid-user                              # 只允许通过验证的用户访问
#        AuthzSVNAccessFile /data/svn/authz  #版本库权限控制
#    </Location>
#</VirtualHost>
# 创建passwd及authz文件
# 创建认证文件
# 用户名密码文件：
#htpasswd -c  /data/svn/passwd  user1  #首次添加用户，再添加用户使用-m参数即可
# 版本库权限认证文件 authz
######################################################################################################################




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
<Location />
        DAV svn
        SVNParentPath /Data/svnroot
        AuthBasicProvider ldap
        AuthType Basic
        #AuthzLDAPAuthoritative on
        AuthName "My Subversion Server"
        AuthLDAPURL "ldap://10.10.xx.xx:389/DC=bj,DC=happigo,DC=com?sAMAccountName?sub?(objectClass=*)" NONE
        #AuthLDAPBindDN "CN=shidg,CN=Users,DC=bj,DC=happigo,DC=COM"
        AuthLDAPBindDN "shidg@bj.happigo.com"
        AuthLDAPBindPassword "xxxx"
        Require valid-user
        AuthzSVNAccessFile /Data/svnroot/authz
</Location>
SSLEngine on
SSLCertificateFile "/etc/httpd/server.crt"     
SSLCertificateKeyFile "/etc/httpd/server.key"
</VirtualHost >

# 生成ssl证书
openssl genrsa  -des3 -out  server.key 1024 #des3 给私钥添加密码，提升安全性

openssl req -new   -key server.key  -out server.csr # 与私钥匹配的公钥，连接建立后该公钥传输给客户端

openssl  x509 -days 365 -req -signkey server.key -in server.csr  -out  server.crt  #给公钥签名，生成证书

cp server.key server.key.with_pass

openssl rsa -in server.key.with_pass -out server.key # 生成一个无密码的私钥，专门给apache或nginx使用的，因为传输过程中要使用私钥对客户端使用的公钥进行验证，匹配才允许传输

#将生成的三个文件放到/et/httpd目录下（/etc/httpd目录是上一步httpd-ssl.conf中指定的）

# 重启apache服务

#访问

https://svn.xx.com/test1

#注意在这种模式下（svn服务并不启动，通过http或https来管理svn），向svn提交数据的时候要保证用来运行apache的用户对svn版本库目录有读写权限，不然会遇到“db/txn-current-lock': Permission denied” 的错误
