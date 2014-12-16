yum install logwatch

cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/logwatch.conf

vi /etc/logwatch/conf/logwatch.conf

内部参数
LogDir = /var/log logwatch      会去 /var/log 找你定义的 log 文件
TmpDir = /var/cache/logwatch
#Save = /tmp/logwatch           开启此项, 处理结果将保存在/tmp/logwatch,
                                不邮寄或显示
MailTo = your@mail.com          多个邮箱逗号隔开
MailFrom = Logwatch             当你收到邮件时, 显示是谁发给你的
Range = All                     处理什么时候的日志 , 可选项 All ,
                                Yesterday , Today , 即所有, 昨天的 , 今天的
Detail = High                   日志详细度, 可选项 Low , Med , High ,
                                或是 0-10数字
Print = No                      可选项, Yes 会被打印到系统标准输出,
                                并且不会以邮件的形式发送到 MailTo 设定的邮箱里 ,
                                No 选项则会发到邮箱中
Server = All                    监控所有服务 all
Service = “-httpd”              不监控的服务前面加 “-” , 如 -httpd ,
                                即不监控 httpd 服务 , 可以写多条
Service = “-sshd”


#测试
/usr/bin/perl /usr/share/logwatch/scripts/logwatch.pl


#添加计划任务
00 00 * * * /usr/bin/perl /usr/share/logwatch/scripts/logwatch.pl > /dev/null 2>&1


##命令行使用
logwatch –detail High –Service All –range All –print
# 显示所有日志, –detail , –Service, –range 开关可以在 logwatch.conf中找到
 
logwatch –service cron –detail High
# 查看 sshd 日志

##参数说明
–detail < level>: 报告的详细度，可选项: High, Med, Low , 数字 0-10
–logfile < name>: 指日志文件名
–service < name>: 服务名，有对应的解析脚本，可以在 /usr/share/logwatch/scripts/services 中找到
–print: 打印打标准输出
–mailto < addr>: 收件人地址
–archives: 使用压缩的文件, 轮转的文件, 例如 messages.1、messages.1.gz
–save < filename>: 保存到文件
–range < range>: 日期范围, Yesterday, Today, All
–debug < level>: 调试级别： High, Med, Low
–splithosts: 为每个主机创建一份报告
–multiemail: 将报告发送给多个邮件地址

