#lnmp环境
#./configure --prefix=${app_dir}php-5.6.8  --with-config-file-path=${app_dir}php-5.6.8/etc --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir --with-zlib --with-gd --with-freetype-dir --with-mcrypt=/usr --with-mhash --enable-gd-native-ttf  --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear --enable-fpm --enable-mbstring --enable-soap --enable-xml --enable-pdo --enable-ftp  --enable-zip --enable-bcmath --enable-sockets --enable-opcache --with-gettext

#php Required
#php>=5.3.0 gd>=2.0 libxml2>=2.6.15
#PHP option memory_limit	128M
#PHP option post_max_size	16M
#PHP option upload_max_filesize	2M
#PHP option max_execution_time	300	
#PHP option max_input_time	300
#PHP mbstring.func_overload	off
#PHP always_populate_raw_post_data off  (php5.6中取消了该项设置，可设置为-1)
#mbstring bcmatch  gettext sockets
#putenv()


#java环境

#deps
yum install net-snmp-devel libxml2-devel curl curl-devel unixODBC unixODBC-devel

#install
tar zxvf zabbix-2.4.5.tar.gz
cd zabbix-2.4.5
./configure --prefix=/Data/app/zabiix-2.4.5 --enable-server --enable-proxy --enable-java --enable-agent --with-mysql=/Data/app/mysql/bin/mysql_config --with-net-snmp --with-libiconv=/usr/ --with-libcurl --with-unixodbc --with-ldap
make && make install

#MySQL
mysql -u root -p << EOF
create database zabbix;
use zabbix;
source /Data/software/zabbix-2.4.5/database/mysql/schema.sql;
#如果仅仅初始化proxy的数据库，那么够了。如果初始化server，那么接着导入下面两个sql
source /Data/software/zabbix-2.4.5/database/mysql/images.sql; 
source /Data/software/zabbix-2.4.5/database/mysql/data.sql; 
grant all privileges on zabbix.* to zabbix@'localhost' identified by 'zabbix';
flush privileges;
EOF

mkdir /etc/zabbix
cd /Data/software/zabbix-2.4.5
cp conf/zabbix_server.conf /etc/zabbix
#zabbix_server.conf基础配置
#DBName=localhost
#DBName=zabbix
#DBUser=zabbix
#DBUser=zabbix
#DBPassword=zabbix

#start zabbix_server(default port 10051)
useradd zabbix
/Data/app/zabbix/sbin/zabbix_server -c /etc/zabbix/zabbix_server.conf

#nginx配置好虚拟机，如 vhosts/monitor.my.com，假设根目录设置为/Data/code/zabbix
cd /Data/software/zabbix-2.4.5
cp -a frontends/php/* /Data/code/zabbix
#http://monitor.my.com开始zabbix的配置及访问,初始用户名密码admin/zabbix
