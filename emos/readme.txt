企业级开源邮箱EMOS1.5
(转载请保留作者信息，大部分内容为网络收集整理)

版本：EMOS1.5 x64_86
SSH文件传输命令rz和sz安装：yum install lrzsz
整理作者：szyzln@vip.qq.com 

一、升级Extmail1.2
下载地址：http://www.extmail.org/download
备份原来的extmail和extman
cd /var/www/extsuite
mv extmail extmail.bak      mv extman extman.bak

升级extmail：
替换，然后重命名“webmail.cf.default”为“webmail.cf”
SYS_MYSQL_USER = extmail （数据库用户名）
SYS_MYSQL_PASS = a1s2d3f4g5  （数据库密码）
修改cgi目录的权限()：
drwxr-xr-x 2 vuser vgroup  4096 Jun  6 11:31 cgi
命令：chown vuser.vgroup cgi -R （一定要有带-R的参数）
创建tmp前台邮件临时目录，并修改权限
drwxr-xr-x 2 vuser vgroup  4096 Jun  6 11:35 tmp

二、升级Extman1.1
替换，然后重命名“webman.cf.default”为“webman.cf”
SYS_MYSQL_USER = webman   
SYS_MYSQL_PASS = a1s2d3f4g5
修改cgi目录的权限：
drwxr-xr-x 2 vuser vgroup  4096 Jun  6 11:31 cgi
命令：chown vuser.vgroup cgi -R （一定要有带-R的参数）
创建tmp后台邮件临时目录，并修改权限
drwxr-xr-x 2 vuser vgroup  4096 Jun  6 11:35 tmp
还有一个后台登陆出错问题，详见第五[常见问题]章节


三、升级Clamav
默认安装，clamav版本为“ClamAV 0.95.2/17828/Sun Sep  8 06:38:21 2013”，是启动失败的。当我们手动“/etc/init.d/clamd restart”会得到这样的警告提示：
LibClamAV Warning: ***  This version of the ClamAV engine is outdated.     ***
LibClamAV Warning: *** DON'T PANIC! Read http://www.clamav.net/support/faq ***
软件版本过旧。不影响使用，这里仅建议更新。方法如下：
下载地址：http://sourceforge.net/projects/clamav/files/clamav/0.97.8
RPM包下载：http://pkgs.repoforge.org/clamav/(暂未发布0.97.8)
#yum -y install zlib zlib-devel   
#service clamd stop
#tar zxvf clamav-0.97.8.tar.gz
#cd clamav-0.97.8
#./configure  (30秒)
#make （4-5分钟）
#make install
#vi /usr/local/etc/freshclam.conf
(里面第8行有个Example需要加上“#”注释符号，应该是源代码作者失误导致)
#创建“/usr/local/share/clamav/”目录并赋予写权限
#service clamd start
最后执行更新病毒库命令：
#freshclam -verbose    (会下载病毒库文件)
最终显示结果如下：
WARNING: Your ClamAV installation is OUTDATED!
WARNING: Local version: 0.97.7 Recommended version: 0.97.8


四、Web管理
本章节属应用范围，详细可参考《Extmail及Extman使用说明.doc》
1、http://域名/extmail 或 http://域名
用户名：普通邮件用户				密码：普通邮件用户
2、http://域名/extman  （后台管理）
用户名：root@wangpiao.cn				密码：*******
（角色分超级管理员和域管理员界面。）
3、http://域名/phpmyadmin		
（建议卸载，改用其它MySQL客户端来管理或直接使用命令行）
4、http://域名/dspam


五、常见问题
1、extman1.1输入中文乱码问题
【解决方法】：修改my.cnf
#vi /etc/my.cnf
在[mysqld]中加入init-connect=”set names uft8”

2、修复dspamd
默认系统安装会显示错误日志“Unable to open file for writing: /var/run/dspamd.pid: Permission denied”
【解决方法】
#vi nano /etc/dspam/dspam.conf
将“ServerPID 	/var/run/dspamd.pid”
修改为“ServerPID	 /var/run/dspamd/dspamd.pid”
然后创建“/var/run/dspamd”目录并赋予权限：
#chown dspam:dspam dspamd
#chmod -R 755  /var/run/dspamd

3、登陆Extman后台提示“Can't open /tmp/extman//sid_”
【解决方法】
将“/var/www/extsuite/extman/webman.cf”里的“tmp/extman/”修改为“/var/tmp/extman/”
并创建这个目录和赋予权限：chown vuser.vgroup /var/tmp/extman/

4、默认安装完后无法接收QQ邮件
无法接收邮件的情况很多，这里仅仅只是限于日志错误提示类型为“blocked using zen.spamhaus.org”且接收来自126和gamil邮箱正常。
可能原因就是Slockd过滤规则太严格，封掉了一些常用的大运营商免费邮局域名。
【解决方法】
详见第八章第3节[垃圾过滤原理]细节。

5、maillog日志清空
如果是直接使用”rm /var/log/maillog”，则需重启下syslog服务。如下：
#/etc/rc.d/init.d/syslog restart
建议还是使用“cat /dev/null >/var/log/maillog”比较妥当。

6、无法收邮件，提示“connect from unknown”
如下：“ localhost postfix/smtpd[29080]: connect from unknown[220.181.15.57]”
【解决方法】
检查DNS设置，或停止防火墙服务
7、用户注册需后台审核激活
#/var/www/extsuite/extman/libs/Ext/Mgr/MySQL.pm
将里面“sub add_user { 
XXXXX
$sth->execute(”
“$active”改成"0"。
这样注册成功的用户写入数据库后active字段值为0，表示不启用，需要后台管理员激活。


8、邮件大小限制
1. 修改/etc/php.ini 
max_execution_time = 60 #改为60 (增加处理脚本的时间限制) 
memory_limit = 60M #改为20M (这样才能发10M的附件) 
post_max_size = 2M #改为12M 
upload_max_filesize = 5M #改为12M 
#/etc/postfix/main.cf   
message_size_limit = 10485760 单封发送邮件大小,10M
mailbox_size_limit = 10485760 单封接收邮件大小,10M,建议设为0
#/var/www/extsuite/extmail/webmail.cf
SYS_MESSAGE_SIZE_LIMIT = 10242880


9、日志“Recipient address rejected: Try again”
原因：这是您第一次发信给收件人，请隔一段时间重试
      前后两次发信间隔小于阀值 (300秒)
解决方法：默认的值已经是60S了，无需更改


10、日志“user unknown. Command output: Invalid user specified”
方法一：修改/etc/postfix/main.cf
将“#receive_override_options = no_address_mappings”注释掉。
方法二：（有问题，目前不推荐）
修改：/etc/authlib/authmysqlrc
将其中的“WHERE username = '$(local_part)@$(domain)'”修改为
“WHERE username = replace(replace('$(local_part)@$(domain)','{',''),'}','')”
最后：/etc/init.d/courier-authlib restart


六、业务架构整理

1、邮件收发流程
   见1.jpg

2、邮件过滤驱动流程
   见2.jpg

3、其它组件列表
   见3.jpg


七、系统管理
1、防火墙iptables
学习网贴：http://www.cnblogs.com/JemBai/archive/2009/03/19/1416364.html
# iptables -A INPUT -s 218.241.219.26/27 -p tcp --dport 22 -j ACCEPT
#

#################################端口说明####################################
TCP：22(SSH登陆)25(SMTP)80(HTTP)110(POP3)143(IMAP)443(IMAP SSH)993(IMAPS)995(POP3S)



2、maillog日志
位置：/var/log/maillog
用户从web版登录：
Sep  6 14:35:09 localhost extmail[3981]: user=<szyzln@wangpiao.cn>, client=218.241.219.28, module=login, status=loginok
用户web发送邮件成功：
Sep  6 14:36:11 localhost postfix/smtpd[4016]: connect from localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost postfix/smtpd[4016]: D0F9DE86A3: client=localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost postfix/cleanup[4019]: D0F9DE86A3: message-id=<20130906063611.D0F9DE86A3@mail.wangpiao.cn>
Sep  6 14:36:11 localhost postfix/qmgr[2491]: D0F9DE86A3: from=<szyzln@wangpiao.cn>, size=614, nrcpt=1 (queue active)
Sep  6 14:36:11 localhost postfix/smtpd[4016]: disconnect from localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost postfix/smtpd[4023]: connect from localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost postfix/smtpd[4023]: EFBAFE86A5: client=localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost postfix/cleanup[4019]: EFBAFE86A5: message-id=<20130906063611.D0F9DE86A3@mail.wangpiao.cn>
Sep  6 14:36:11 localhost postfix/qmgr[2491]: EFBAFE86A5: from=<szyzln@wangpiao.cn>, size=1068, nrcpt=1 (queue active)
Sep  6 14:36:11 localhost postfix/smtpd[4023]: disconnect from localhost.localdomain[127.0.0.1]
Sep  6 14:36:11 localhost amavis[2376]: (02376-02) Passed CLEAN, MYNETS LOCAL [127.0.0.1] [127.0.0.1] <szyzln@wangpiao.cn> -> <szyzln@vip.qq.com>, Message-ID: <20130906063611.D0F9DE86A3@mail.wangpiao.cn>, mail_id: zg6pqnD6jwmM, Hits: -, size: 614, queued_as: EFBAFE86A5, 86 ms
Sep  6 14:36:11 localhost postfix/smtp[4020]: D0F9DE86A3: to=<szyzln@vip.qq.com>, relay=127.0.0.1[127.0.0.1]:10024, delay=0.15, delays=0.05/0/0/0.09, dsn=2.0.0, status=sent (250 2.0.0 Ok, id=02376-02, from MTA([127.0.0.1]:10025): 250 2.0.0 Ok: queued as EFBAFE86A5)
Sep  6 14:36:11 localhost postfix/qmgr[2491]: D0F9DE86A3: removed
Sep  6 14:36:12 localhost postfix/smtp[4024]: EFBAFE86A5: to=<szyzln@vip.qq.com>, relay=mx3.qq.com[58.250.132.64]:25, delay=0.89, delays=0.01/0/0.2/0.68, dsn=2.0.0, status=sent (250 Ok: queued as )
Sep  6 14:36:12 localhost postfix/qmgr[2491]: EFBAFE86A5: removed
Clama病毒邮件扫描通过
Sep  8 14:20:58 localhost amavis[2501]: (02501-04) Passed CLEAN, [220.181.15.54] [182.48.101.10] <szyzln@126.com> -> <szyzln@wangpiao.cn>, Message-ID: <60ecb4a4.472.140fc38a86f.Coremail.szyzln@126.com>, mail_id: ibwCy9ScZyFz, Hits: -0.746, size: 1694, queued_as: 971A119C8693, dkim_id=@126.com, 535 ms


3、垃圾过滤原理
EMOS采用“slockd+dspam+amavisd”
【解决方法】用户反映slockd的RBL功能经常把大型运营商邮箱判断为垃圾并退回给发件人。这里可以把slockd的RBL服务禁用掉，直接使用dspam，把判断为垃圾邮件的直接投递到用户的“垃圾邮件”目录里。
#vi /usr/local/slockd/config/plugin.cf   
dnsbl_plugiin = yes改为no
#/usr/local/slockd/slockd-init restart
#
【slockd过滤规则】
邮件进来---提取发件人地址信息---whitelist---没有----blacklist----没有----sender_whitelist---没有---sender_blacklist---没有----直接进入用户邮箱或下一处理过程
大致原则：
白名单一旦有定义则不进行后面的LIST检查，直接PASS
白名单没有定义，黑名单有定义则直接REJECT
白名单与黑名单都未定义也是直接PASS


4、POSTFIX专题
学习网贴：http://www.linuxso.com/linuxrumen/16529.html
#vi /etc/postfix/main.cf
#################################POSTFIX全局环境配置########################
alias_database = hash:/etc/postfix/aliases 邮件别名配置数据库postaliases
alias_maps = hash:/etc/postfix/aliases 邮件别名配置文件postmap
command_directory = /usr/sbin  
config_directory = /etc/postfix    
daemon_directory = /usr/libexec/postfix  
debug_peer_level = 2
mail_owner = postfix 所属用户
mailq_path = /usr/bin/mailq.postfix 
manpage_directory = /usr/share/man MAN手册位置
newaliases_path = /usr/bin/newaliases.postfix
queue_directory = /var/spool/postfix  邮件队列位置
sample_directory = /etc/postfix
sendmail_path = /usr/sbin/sendmail.postfix
setgid_group = postdrop
#####################################主机网络标识##############################
mynetworks = 127.0.0.1 用来区分是本地还是远程发来的邮件
myhostname = mail.wangpiao.cn  
mydomain = wangpiao.cn	根域名
mydestination = $mynetworks, $myhostname
########################################标识##################################
mail_name = EMOS V1.5 (Postfix)
smtpd_banner = $myhostname ESMTP $mail_name
########################################返回信息##############################
smtpd_error_sleep_time = 0s
unknown_local_recipient_reject_code = 550  错误收件人返回的代码

# extmail config here
virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf
virtual_mailbox_domains = mysql:/etc/postfix/mysql_virtual_domains_maps.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf
virtual_transport = maildrop:
message_size_limit = 10485760 
mailbox_size_limit = 10485760
# maildrop setting
maildrop_destination_recipient_limit = 1
#content_filter = smtp-amavis:[127.0.0.1]:10024  是否转入内容杀毒。
###################################发件人地址限制##############################
smtpd_sender_restrictions =                    
        permit_mynetworks,
        reject_sender_login_mismatch,
        reject_authenticated_sender_login_mismatch,
        reject_unauthenticated_sender_login_mismatch
###################################收件人地址限制##############################
smtpd_recipient_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_hostname,
        reject_non_fqdn_sender,
        reject_non_fqdn_recipient,
        reject_unauth_destination,
        reject_unauth_pipelining,
        reject_invalid_hostname,
        check_policy_service inet:127.0.0.1:10030 交给solck进行过滤判断


5、Slock专题
#/usr/local/slockd/config/main.cf



6、Spamassassin
#vi //etc/mail/spamassassin/dspam.cf
#查看自学习的数据信息
sa-learn --dump all
#查看调试信息
spamassassin -lint -D
include   dspam.cf
学习贴：
http://www.extmail.org/forum/thread-10393-1-1.html

7、Dspam专题
#vi /etc/dspam/dspam.conf
官方文档： 
http://wiki.extmail.org/dspam_for_emos
Web配置访问URL配置：/etc/httpd/conf.d/dspam.conf
Web配置图解说明：http://www.extmail.org/forum/thread-11250-1-1.html


8、courier-imap
#vi nano /usr/lib/courier-imap/etc/imapd
IMAPDSTART=NO  是否启用IMAP
# vi /usr/lib/courier-imap/etc/imapd-ssl
IMAPDSSLSTART=NO 是否启用IMAPS


9、fail2ban
学习网贴：http://www.networkquestions.org/archives/890
/etc/fail2ban
fail2ban.conf	日志设定文档
jail.conf	阻挡设定文档
filter.d	具体阻挡内容设定目录


10、MYSQL
提示：
由于建议卸载PhpMyadmin，EMOS默认安装MySQL的root用户仅允许本地访问。需要先使用MySQL命令行设置为root允许远程访问，然后在防火墙中设置3306仅对公司办公网或特定安全的网络开放。
#update user set host = '%' where user = 'root'; 
#flush privileges;


11、http.conf配置
#vi /etc/httpd/conf/httpd.conf
Include conf.d/*.conf
DocumentRoot "/var/www/html" 定义HTTP的根目录是“/var/www/html”
NameVirtualHost *:80 定义虚拟主机，基于端口80，不限域名
Include conf/vhost_*.conf
#vi /etc/httpd/conf/vhost_extmail.conf   （这是我修改后的虚拟主机配置文件）
<VirtualHost *:80> 虚拟主机，基地80端口，不限域名，也就是所有解析到此主机的域名均将采用此配置，这也是为什么我们无论输哪个域名，出来的网页内容是一样的
ServerName sdfadsfa 服务名称，默认是配置domain，我这里故意随便写，表示不影响
DocumentRoot /var/www/extsuite/extmail/html/ 根目录
ScriptAlias /extmail/cgi/       /var/www/extsuite/extmail/cgi/ 虚拟二级目录
Alias /extmail                  /var/www/extsuite/extmail/html/
ScriptAlias /extman/cgi/        /var/www/extsuite/extman/cgi/
Alias /extman                   /var/www/extsuite/extman/html/
# Suexec config
SuexecUserGroup vuser vgroup
</VirtualHost>
大家可以了解一样Linux下的Apache配置。虚拟主机的根目录覆盖HTTP配置的根目录。
当我们访问“http://domain”为什么自动出来的是“http://domain/extmail/cgi/index.cgi”
因为：浏览器在解析“http://domain”时会在根目录下“/var/www/extsuite/extmail/html/”下找到名为“index.html”文件，而此文件内容是“url=/extmail/cgi/index.cgi”。所以.......



12、批量用户迁移域名
1、添加域
2、访问新域注册一个用户(这样才会在/home/domains下建立新域目录)
3、修改数据库extmail中的mailbox表部分字列值
执行如下mysql语句进行替换:
update mailbox set username=REPLACE(username,'wangpiao.cn','imlina.com.cn');
update mailbox set maildir=REPLACE(maildir,'wangpiao.cn','imlina.com.cn');
update mailbox set homedir=REPLACE(homedir,'wangpiao.cn','imlina.com.cn');
update mailbox set homedir=REPLACE(homedir,'wangpiao.cn','imlina.com.cn');
update mailbox set domain=REPLACE(domain,'wangpiao.cn','imlina.com.cn');
update mailbox set homedir=REPLACE(homedir,'wangpiao.cn','imlina.com.cn');
4、进入"/home/domains",使用"cp或mv"将原域名目录下的所有用户复制或移动到新域目录;



13、群组邮箱只接收本地域
一般情况下，我们使用另名按照公司部门来组合个人邮箱，通常是不愿意接收到来自外域发来的任何邮件。这时候我们就需要使用Postfix来限制了。方法是：
#/etc/postfix/main.cf里添加如下三行：
check_recipient_access hash:/etc/postfix/local_recipient
smtpd_restriction_classes = local_only
local_only = check_sender_access hash:/etc/postfix/local_sender, reject
其中第一条应该加在[smtpd_sender_restrictions =]下一行。后2条是单独添加的。
然后分别创建“/etc/postfix/local_recipient”和“/etc/postfix/local_sender”，并使用“postmap”来生成hash文件。
#/etc/postfix/local_recipient内容填写只接收本域的群组邮箱列表及执行的动作名称。如下：
shangwu@wangpiao.cn 	    local_only
Jishu@wangpiao.cn   local_only
#/etc/postfix/local_sender内容填写只接收对方来信的来源地址是自己的公司域名。如下：
wangpiao.cn		OK
imlina.com.cn		OK
当然你也可以指定特定用户(如user@wangpiao.cn)，表示只接收来自此用户的邮件。


14、关闭IMAP
由于EMOS1.5版本不支持IMAP的uf7编码，所以需要关闭IMAP服务。
#/usr/lib/courier-imap/etc/imapd
#/usr/lib/courier-imap/etc/imapd-ssl
分别将其中的“IMAPDSTART=”和“IMAPDSSLSTART=”值改为“NO”



八、修改模板
本章节不做详细模板指导。
详情见Exail官方文档：
http://wiki.extmail.org/extmail_template_intro





九、EMOS原贴
1、mbox 转换成maildir(邮件系统转移方案)
http://www.extmail.org/forum/thread-6281-1-72.html


2、限制部分Postfix用户只能内部收发的例子
http://www.extmail.org/forum/thread-6447-1-1.html


3、彻底关闭反病毒和防垃圾邮件功能
http://www.networkquestions.org/archives/458


4、DSpamf+SLOCK过滤机制
http://www.extmail.org/forum/thread-10393-1-1.html


5、Extmail文档
http://wiki.extmail.org/extmail


6、EMOS项目文档
http://wiki.extmail.org/_export/xhtml/


7、EMOS 备份
http://www.extmail.org/forum/thread-24410-1-5.html
