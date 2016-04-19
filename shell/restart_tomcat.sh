#! /bin/bash

#获取svn的最后修改版本号
SVN_VERSION=$1
#部署服务器传送过来的war包存放目录
WAR_SRC_DIR=/Data/war
#解压后的war包存放处
WAR_DST_DIR=/Data/webs
#tomcat家目录
TOMCAT_HOME=/Data/app/tomcat

#定义捕捉错误信号的函数
#function ERRTRAP(){
#    echo "[LINE:$1] Error: Command or function exited with status $?" | mail -s "test_server tomcat restart faild" 94586572@qq.com
#    exit
#}

#报警邮件的收件人列表
MAIL_LIST=94586572@qq.com,315159578@qq.com

START_TIME=`date "+%Y%m%d-%T"`

#以svn最后修改版本号为名创建目录，war包将解压至此
if [ -d ${WAR_DST_DIR}/${SVN_VERSION} ];then
    V=`echo $RANDOM`
    mv ${WAR_DST_DIR}/${SVN_VERSION} ${WAR_DST_DIR}/${SVN_VERSION}-$V
    mkdir -p ${WAR_DST_DIR}/${SVN_VERSION}
else
    mkdir -p ${WAR_DST_DIR}/${SVN_VERSION}
fi

#解压war包至指定位置，并指定解压后的目录名
for i in `ls ${WAR_SRC_DIR}`
    do 
        #war包解压后的目录名
        WAR_DEPLOY_NAME=`echo $i | sed 's/\(.*\)\.war/\1/'`

        unzip -oq ${WAR_SRC_DIR}/$i -d ${WAR_DST_DIR}/${SVN_VERSION}/${WAR_DEPLOY_NAME}
    done


#修改银联回调地址
PAY_FILE1=${WAR_DST_DIR}/${SVN_VERSION}/orders/WEB-INF/classes/acp_sdk.properties
PAY_FILE2=${WAR_DST_DIR}/${SVN_VERSION}/orders/WEB-INF/classes/refund.properties
PAY_FILE3=${WAR_DST_DIR}/${SVN_VERSION}/report/WEB-INF/classes/acp_sdk.properties
sed -i 's/111.202.44.157/demo.feezu.cn/' ${PAY_FILE1}
sed -i 's/111.202.44.157/demo.feezu.cn/' ${PAY_FILE2}
sed -i 's/111.202.44.157/demo.feezu.cn/' ${PAY_FILE3}

#ZK_FOR_DUBBO
sed -i '/dubbo:registry/ s/127.0.0.1/10.171.51.137/' ${WAR_DST_DIR}/${SVN_VERSION}/manage/WEB-INF/classes/applicationContext-dubbo-consumer.xml

# server_id
FILE_PATH=WEB-INF/classes
SERVER_FILE=serverconfig.properties
for D in analysis metadata orders report
do
        sed -i '/serverId/ s/serverId=.*/serverId=${D}_demo_1/' ${WAR_DST_DIR}/${SVN_VERSION}/${D}/${FILE_PATH}/${SERVER_FILE}
done


#修改目录属主
chown -R tomcat:tomcat ${WAR_DST_DIR}/${SVN_VERSION}

# 手机端app下载相关 
ln -s ${WAR_DST_DIR}/app-down ${WAR_DST_DIR}/${SVN_VERSION}/app-down
ln -s ${WAR_DST_DIR}/download ${WAR_DST_DIR}/${SVN_VERSION}/download

#nagios监控相关
ln -s ${WAR_DST_DIR}/ROOT ${WAR_DST_DIR}/${SVN_VERSION}/ROOT


#删除旧软链接
if ls ${TOMCAT_HOME}/webapps;then
    rm -f ${TOMCAT_HOME}/webapps
fi

#建立新软链接
ln -s ${WAR_DST_DIR}/${SVN_VERSION} ${TOMCAT_HOME}/webapps

#重启tomcat
TMPFILE=`mktemp /tmp/tmpfile.XXXX`
if ss -tnl | grep 8080;then
    ps -ef | grep  "jsvc.exec" | grep -v grep | awk '{print $2}'> $TMPFILE
    for TPID in `cat $TMPFILE`
        do
            kill -9 $TPID
        done
    if [ -f /Data/app/tomcat/logs/catalina-daemon.pid ];then
        rm -f /Data/app/tomcat/logs/catalina-daemon.pid
    fi 
fi

service tomcat start

END_TIME=`date "+%Y%m%d-%T"`

cat > /tmp/tomcatinfo <<EOF
=================================
tomcat restart.
server: demo_server_1
start at:$START_TIME
finish at :$END_TIME
EOF
if [ ! "ss -tnl | grep 8080" ];then
    mail -s "tomcat restart failed" ${MAIL_LIST} < /tmp/tomcatinfo
fi

# log file
cat /tmp/tomcatinfo >> /Data/logs/deploy/deploy.log
#delete tmpfile
rm -f $TMPFILE
