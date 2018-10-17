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
#scandir()


#java环境

#deps
yum install net-snmp-devel libxml2-devel curl curl-devel unixODBC unixODBC-devel

#install
tar zxvf zabbix-4.0.0.tar.gz
cd zabbix-4.0.0
./configure --prefix=/Data/app/zabbix-4.0.0 --enable-server --enable-proxy --enable-java --enable-agent --with-mysql=/Data/app/mysql/bin/mysql_config --with-net-snmp --with-libiconv=/usr/ --with-libcurl --with-unixodbc --with-ldap
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
cd /Data/software/zabbix-4.0.0
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
/Data/app/zabbix/sbin/zabbix_java/startup.sh

#nginx配置好虚拟机，如 vhosts/monitor.my.com，假设根目录设置为/Data/code/zabbix
cd /Data/software/zabbix-4.0.0
cp -a frontends/php/* /Data/code/zabbix
#http://monitor.my.com开始zabbix的配置及访问,初始用户名密码admin/zabbix

# zabbix client
tar zxvf zabbix-4.0.0.tar.gz && cd zabbix-4.0.0
./configure --prefix=/Data/app/zabbix-4.0.0/ --enable-agent
make && make install

mkdir /etc/zabbix
cp /etc/zabbix_agentd.conf /etc/zabbix/

useradd zabbix
/Data/app/zabbix-4.0.0/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf


# 邮件报警配置（脚本方式）

# 添加媒介类型。 管理-->报警媒介类型-->创建媒体类型
# 名称 SendEmail,类型 脚本 ,脚本名称 SendEmail.sh, 脚本参数共三个: {ALERT.SENDTO} {ALERT.SUBJECT} {ALERT.MESSAGE}



# 添加报警动作。 配置-->动作-->创建动作

#名称 CRITICAL 条件 自定义

#操作：
#默认标题: 
[Zabbix] 故障通知,服务器:{HOSTNAME1}发生: {TRIGGER.NAME}故障!

#消息内容：
故障主机: {HOST.NAME1}<br />
故障时间: {EVENT.DATE} {EVENT.TIME}<br />
故障等级: {TRIGGER.SEVERITY}<br />
告警信息: {TRIGGER.NAME}<br />
问题详情: {ITEM.NAME}:{ITEM.VALUE}<br />
当前状态: {TRIGGER.STATUS}<br />
事件ID: {EVENT.ID}

#发送细节自定义


# 恢复操作
#默认标题
[Zabbix] 恢复通知. 服务器:{HOSTNAME1}已恢复!

# 消息内容
恢复主机:{HOSTNAME1} <br />
恢复时间:{EVENT.RECOVERY.DATE} {EVENT.RECOVERY.TIME}<br />
告警等级:{TRIGGER.SEVERITY}<br />
告警信息: {TRIGGER.NAME}<br />
当前状态:{TRIGGER.STATUS} ({ITEM.VALUE1})<br />
事件ID:{EVENT.ID}

#发送细节
Notify all involved	

# 添加用户，为用户配置媒介类型、接收邮箱等信息
# 邮件报警配置完成
