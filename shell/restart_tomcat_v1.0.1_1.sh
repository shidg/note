#! /bin/bash

#获取svn的最后修改版本号
SVN_VERSION=$1
#部署服务器传送过来的war包存放目录
WAR_SRC_DIR=/Data/package/platform/
#解压后的war包存放处
WAR_DST_DIR=/Data/webs
#tomcat家目录
TOMCAT_HOME=/Data/app

#定义捕捉错误信号的函数
#function ERRTRAP(){
#    echo "[LINE:$1] Error: Command or function exited with status $?" | mail -s "test_server tomcat restart faild" 94586572@qq.com
#    exit
#}

#报警邮件的收件人列表
MAIL_LIST=94586572@qq.com,315159578@qq.com

START_TIME=`date "+%Y%m%d-%T"`

#以svn最后修改版本号为名创建目录，war包将解压至此
for i in tomcatA tomcatB tomcatC tomcatD
do
  if [ -d ${WAR_DST_DIR}/${i}/${SVN_VERSION} ];then
      V=`echo $RANDOM`
      mv ${WAR_DST_DIR}/${i}/${SVN_VERSION} ${WAR_DST_DIR}/${i}/${SVN_VERSION}-$V
      mkdir -p ${WAR_DST_DIR}/${i}/${SVN_VERSION}
  else
      mkdir -p ${WAR_DST_DIR}/${i}/${SVN_VERSION}
  fi
done

#解压war包至指定位置，并指定解压后的目录名
#tomcat A
  unzip -oq ${WAR_SRC_DIR}/app.war -d ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/app
  unzip -oq ${WAR_SRC_DIR}/orders.war -d ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders
#tomcat B
  unzip -oq ${WAR_SRC_DIR}/manage.war -d ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage
  unzip -oq ${WAR_SRC_DIR}/metadata.war -d ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata
#tomcat C
  unzip -oq ${WAR_SRC_DIR}/wechat.war -d ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat
  unzip -oq ${WAR_SRC_DIR}/analysis.war -d ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/analysis
  unzip -oq ${WAR_SRC_DIR}/api.war -d ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api
#tomcat D
  unzip -oq ${WAR_SRC_DIR}/appmanage.war -d ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/appmanage
  unzip -oq ${WAR_SRC_DIR}/report.war -d ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report
  unzip -oq ${WAR_SRC_DIR}/download.war -d ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/download
  unzip -oq ${WAR_SRC_DIR}/thirdparty.war -d ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/thirdparty

#项目配置文件修改
FILE_PATH=WEB-INF/classes
FTP_FILE=ftpconfig.properties
PAY_FILE1=acp_sdk.properties
PAY_FILE2=refund.properties
MSG_FILE=msgConfig.properties
HBASE_FILE=hbase-site.xml
JDBC_FILE=jdbc.properties
DUBBO_FILE=applicationContext-dubbo-consumer.xml
SERVER_FILE=serverconfig.properties


### tomcat A
  # config
    # app
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/app/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/app/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/app/WEB-INF/classes/config.properties
    # order
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/WEB-INF/classes/config.properties
    sed -i '/ANALYSIS_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8030/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/WEB-INF/classes/config.properties
    
  # ftp
  for D in orders app
  do
    sed -i '/img.ftp.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
    sed -i '/img.http.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
  done
  # mq
    sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.171.57.30:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${MSG_FILE}
  # server_id
    sed -i "/^serverId/ s/serverId=.*/serverId=orders_prep_2/" ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${SERVER_FILE}
    sed -i "/^groupServerId/ s/groupServerId=.*/groupServerId=2/" ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${SERVER_FILE}
  # mysql
    sed -i '/db.url/ s/db_01/rds8ei10r74e6ey5j592.mysql.rds.aliyuncs.com/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${JDBC_FILE}
    sed -i 's/:3306\/order/:3306\/orders/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.user/ s/test/mainuser/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.password/ s/test/NbcbKCSTQpa/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${JDBC_FILE}
  # dubbo
    sed -i '/dubbo.registry.address/ s/127.0.0.1/10.172.164.152/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/dubbo.properties
    sed -i '/dubbo:registry/ s/127.0.0.1/10.172.164.152/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/app/${FILE_PATH}/applicationContext-dubbo-consumer.xml
  # db key
    sed -i '/SECURITY_KEY/ s/SECURITY_KEY=/SECURITY_KEY=9GuqbrKIN3Wa\&\%CC/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/securityConfig.properties
    sed -i '/SECURITY_KEY_VERSION/ s/0/160093/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/securityConfig.properties

### tomcat B
  # config
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/WEB-INF/classes/config.properties
    sed -i '/ANALYSIS_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8030/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/WEB-INF/classes/config.properties
  # ftp 
  for D in metadata manage
  do
    sed -i '/img.ftp.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
    sed -i '/img.http.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
  done
    sed -i '/device.host/ s/123.127.240.42/101.200.165.247/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${FTP_FILE}
  # mq
    sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.171.57.30:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${MSG_FILE}
  # server_id
    sed -i "/^serverId/ s/serverId=.*/serverId=metadata_prep_2/" ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${SERVER_FILE}
    sed -i "/^groupServerId/ s/groupServerId=.*/groupServerId=2/" ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${SERVER_FILE}
  # mysql
    sed -i '/db.url/ s/db_01/rds8ei10r74e6ey5j592.mysql.rds.aliyuncs.com/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${JDBC_FILE}
    sed -i 's/:3306\/order/:3306\/orders/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.user/ s/test/mainuser/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.password/ s/test/NbcbKCSTQpa/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/${JDBC_FILE}
  # dubbo
    sed -i '/dubbo:registry/ s/127.0.0.1/10.172.164.152/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/${FILE_PATH}/applicationContext-dubbo-consumer.xml
    sed -i '/dubbo.registry.address/ s/127.0.0.1/10.172.164.152/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/dubbo.properties
  # db key
    sed -i '/SECURITY_KEY/ s/SECURITY_KEY=/SECURITY_KEY=9GuqbrKIN3Wa\&\%CC/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/securityConfig.properties
    sed -i '/SECURITY_KEY_VERSION/ s/0/160093/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/metadata/${FILE_PATH}/securityConfig.properties
  # manage-web
    sed -i '/IS_PRODUCT_ENVIRONMENT_VALID_CODE/ s/true/false/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/${FILE_PATH}/config.properties
    sed -i 's/ALLOW_CHANGE_LOGIN_IDS=/ALLOW_CHANGE_LOGIN_IDS=cur_20003gjvn6vw/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/${FILE_PATH}/config.properties
    sed -i '/mail_switch/ s/0/1/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/${FILE_PATH}/config.properties
    sed -i 's/bill_police_to_mail=/bill_police_to_mail=guoyy@eg.com/' ${WAR_DST_DIR}/tomcatB/${SVN_VERSION}/manage/${FILE_PATH}/config.properties

### tomcat C
  # mq
    sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.171.57.30:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/analysis/${FILE_PATH}/${MSG_FILE}
  # server_id
    sed -i "/^serverId/ s/serverId=.*/serverId=analysis_prep_2/" ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/analysis/${FILE_PATH}/${SERVER_FILE}
    sed -i "/^groupServerId/ s/groupServerId=.*/groupServerId=2/" ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/analysis/${FILE_PATH}/${SERVER_FILE}
  # hbase
    sed -i 's/hbase.eg.com/10.162.198.246/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/analysis/${FILE_PATH}/${HBASE_FILE}
  # wechat
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/localhost:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/localhost:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
    sed -i '/redis.host/ s/127.0.0.1/redis_01/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/jedis.properties
    sed -i '/Request.ConsumerApp.Url/ s/test3.eg.com/prep.eg.com/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
    sed -i '/YwxWeiXin.Url/ s/wx.eg.com/prepwx.eg.com/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
    sed -i '/apiUrl:/ s/test3.eg.com/prep.eg.com/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/resources/js/base.js
    sed -i '/YwxWeiXin.Url/ s/http/https/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
    sed -i '/Request.ConsumerApp.Url/ s/http/https/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/wechat/${FILE_PATH}/config.properties
  # api 
    cd ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes
    for FILE in config jedis msgConfig serverconfig;do
      cp $FILE.properties.template $FILE.properties
    done
    cp log4j.xml.template log4j.xml

    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/10.171.44.14:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/10.171.44.14:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/10.171.44.14:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/config.properties
    sed -i '/redis.host/ s/127.0.0.1/redis_01/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/jedis.properties
    sed -i 's/127.0.0.1/10.171.57.30/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/msgConfig.properties
    sed -i '/serverId/ s/serverId=*/serverId=api_prep1/' ${WAR_DST_DIR}/tomcatC/${SVN_VERSION}/api/WEB-INF/classes/serverconfig.properties

### tomcat D
  # config
    # manage-app
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/appmanage/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/appmanage/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/appmanage/WEB-INF/classes/config.properties
    # report
    sed -i '/METADATA_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8020/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/WEB-INF/classes/config.properties
    sed -i '/REPORT_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8040/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/WEB-INF/classes/config.properties
    sed -i '/ORDER_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8010/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/WEB-INF/classes/config.properties
    sed -i '/ANALYSIS_WEB_SERVICE_DOMAIN/ s/service_01:8080/service_01:8030/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/WEB-INF/classes/config.properties

  for D in report thirdparty
  do
  # ftp
    sed -i '/img.ftp.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
    sed -i '/img.http.host/ s/image.eg.com/imgprep.eg.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${FTP_FILE}
  # server_id
    sed -i "/^serverId/ s/serverId=.*/serverId=${D}_prep_2/" ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${SERVER_FILE}
    sed -i "/^groupServerId/ s/groupServerId=.*/groupServerId=2/" ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${SERVER_FILE}
  # mysql
    sed -i '/db.url/ s/db_01/rds8ei10r74e6ey5j592.mysql.rds.aliyuncs.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${JDBC_FILE}
    sed -i 's/:3306\/order/:3306\/orders/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.user/ s/test/mainuser/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${JDBC_FILE}
    sed -i '/db.password/ s/test/NbcbKCSTQpa/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/${D}/${FILE_PATH}/${JDBC_FILE}
  done
  # mq
    sed -i "s/msg.brokerURL=.*/msg.brokerURL=failover:(tcp:\/\/10.171.57.30:61616,tcp:\/\/10.44.54.183:61616,tcp:\/\/10.162.198.246:61616)/" ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/${FILE_PATH}/${MSG_FILE}
  # dubbo
    sed -i '/dubbo.registry.address/ s/127.0.0.1/10.172.164.152/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/thirdparty/${FILE_PATH}/dubbo.properties
  # download
    sed -i '/request_download_url/ s/app.eg.com/appprep.eg.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/download/${FILE_PATH}/server.properties
  # db key
    for D in  thirdparty report
    do
      sed -i '/SECURITY_KEY/ s/SECURITY_KEY=/SECURITY_KEY=9GuqbrKIN3Wa\&\%CC/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/$D/${FILE_PATH}/securityConfig.properties
      sed -i '/SECURITY_KEY_VERSION/ s/0/160093/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/$D/${FILE_PATH}/securityConfig.properties
    done
  #
    sed -i '/mail_switch/ s/0/1/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/${FILE_PATH}/config.properties
    sed -i 's/bill_police_to_mail=/bill_police_to_mail=guoyy@eg.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/${FILE_PATH}/config.properties
 
### 银联回调
        sed -i 's/123.127.240.42\/app/appprep.eg.com/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${PAY_FILE1}
        sed -i 's/123.127.240.42\/app/appprep.eg.com/' ${WAR_DST_DIR}/tomcatA/${SVN_VERSION}/orders/${FILE_PATH}/${PAY_FILE2}
        sed -i 's/123.127.240.42\/app/appprep.eg.com/' ${WAR_DST_DIR}/tomcatD/${SVN_VERSION}/report/${FILE_PATH}/${PAY_FILE1}

####-------------------------------------------------

#修改目录属主
chown -R tomcat:tomcat ${WAR_DST_DIR}/

# 手机端app下载相关 
for D in tomcatA tomcatB tomcatC tomcatD
do
  ln -s ${WAR_DST_DIR}/app-down ${WAR_DST_DIR}/${D}/${SVN_VERSION}/app-down
done

#nagios监控相关
#ln -s ${WAR_DST_DIR}/ROOT ${WAR_DST_DIR}/${SVN_VERSION}/ROOT


#删除旧软链接
for D in tomcatA tomcatB tomcatC tomcatD
do
  if [ -L ${TOMCAT_HOME}/${D}/webapps ];then
    rm -f ${TOMCAT_HOME}/${D}/webapps
  fi
done

#建立新软链接
for D in tomcatA tomcatB tomcatC tomcatD
do
  ln -s ${WAR_DST_DIR}/${D}/${SVN_VERSION} ${TOMCAT_HOME}/${D}/webapps
done

echo "restarting tomcat,please wait..."
#关闭tomcat
TMPFILE=`mktemp /tmp/tmpfile.XXXX`
    ps -ef | grep  "jsvc.exec" | grep -v grep | awk '{print $2}'> $TMPFILE
      for TPID in `cat $TMPFILE`
      do
        kill -9 $TPID
      done
for i in tomcatD tomcatB tomcatC tomcatA
do
    if [ -f /Data/app/${i}/logs/catalina-daemon.pid ];then
        rm -f /Data/app/${i}/logs/catalina-daemon.pid
    fi 
done
#启动tomcat
  service tomcatD start
while true
do
  if curl --connect-timeout 2 http://127.0.0.1:8040/report/service > /dev/null 2>&1;then
    echo "tomcatD Start successfully"
    service tomcatB start
    break
    else
    echo -ne "\atomcatD starting...\r"
  fi
  sleep 10
done

while true
do
  if curl --connect-timeout 2 http://127.0.0.1:8020/metadata/service > /dev/null 2>&1;then
    echo "tomcatB Start successfully"
    service tomcatC start
    break
    else
    echo -ne "\atomcatB starting...\r"
  fi
  sleep 10
done

while true
do
  if curl --connect-timeout 2 http://127.0.0.1:8030/analysis/service > /dev/null 2>&1;then
    echo "tomcatC Start successfully"
    service tomcatA start
    break
    else
    echo -ne "\atomcatC starting...\r"
  fi
  sleep 10
done

while true
do
  if curl --connect-timeout 2 http://127.0.0.1:8010/orders/service > /dev/null 2>&1;then
    echo "tomcatA Start successfully"
    break
    else
    echo -ne "\atomcatA starting...\r"
  fi
  sleep 10
done
END_TIME=`date "+%Y%m%d-%T"`

cat > /tmp/tomcatinfo <<EOF
=================================
tomcat restart.
server: prep_server_2
start at:$START_TIME
finish at :$END_TIME
EOF
#if [ ! "ss -tnl | grep 8080" ];then
#    mail -s "tomcat restart failed" ${MAIL_LIST} < /tmp/tomcatinfo
#fi

# log file
cat /tmp/tomcatinfo >> /Data/logs/deploy/deploy.log
#delete tmpfile
rm -f $TMPFILE
