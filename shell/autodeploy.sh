#!/bin/bash
# autodeploy.sh
# Run at 20:00 everyday,update source code from svn.and rebuild *.war
# Push *war to remote server,default test_server
# Send mail to ${ERROR_REPORT} when Script execution failed
# Modified by shidg,20150610

# Define Variables
source ~/.bashrc
SOURCEDIR=/Data/source/trunk/
BUILDDIR=/Data/war/trunk
DEMOBUILDDIR=/Data/war/v0.6
SVN_SERVER=svn.feezu.cn
REPOSITORY_NAME="repos/wzc/manage/source/trunk"
SVN_USER=jira
SVN_PASS=jira*12345
SYNC_USER=rsync_user
TEST=10.10.8.32
DEV=10.10.8.31
DEMO=123.56.86.141
FINAL_WEB=10.10.8.34
FINAL_SERVICE=10.10.8.35
REMOTE_SERVER=$TEST
MODULE=webapps
ARG1=$1
#MAIL_LIST=94586572@qq.com
ERROR_REPORT=94586572@qq.com,332819226@qq.com,luokui@feezu.cn,songting@feezu.cn,wangliang@feezu.cn,maocc@feezu.cn,liuzhen@feezu.cn
#ERROR_REPORT=94586572@qq.com


#Trap Err Function
function ERRTRAP(){
    if [ ! -z "$ARG1" ];then
        mail -s "${ARG1}_server redeploy failed" ${ERROR_REPORT} < /tmp/audpfail.log
    else
        mail -s "test_server redeploy failed" ${ERROR_REPORT} < /tmp/audpfail.log
    fi
    exit
}

trap 'ERRTRAP $LINENO' ERR

#activemq server addr
if [ "$1" = "final" ];then
    REMOTE_SERVER=(${FINAL_WEB} ${FINAL_SERVICE})
    DIR=(manage-datawarehouse/ manage-metadata/ manage-orders/)
    POSITION=src/main/resources/
    FILENAME=msgConfig.properties
        for D in ${DIR[*]}
            do  
                sed -i "s/127.0.0.1/${FINAL_SERVICE}/" $SOURCEDIR/$D$POSITION$FILENAME
            done
elif [ "$1" = "dev" ];then
    REMOTE_SERVER=$DEV
elif [ "$1" = "demo" ];then
    REMOTE_SERVER=$DEMO
    sed -i 's/111.202.44.157/demo.feezu.cn/' ${SOURCEDIR}manage-orders/src/main/resources/acp_sdk.properties
    sed -i 's/hbase.feezu.cn/10.162.196.41/' ${SOURCEDIR}manage-datawarehouse/src/main/resources/hbase-site.xml 
    sed -i 's/image.feezu.cn/demo.feezu.cn/' ${SOURCEDIR}manage-metadata/src/main/resources/ftpconfig.properties
    sed -i 's/image.feezu.cn/demo.feezu.cn/' ${SOURCEDIR}manage-web/src/main/resources/ftpconfig.properties
fi
                                                
# begin
PROJS2=(manage-web consumer-app manage-metadata manage-datawarehouse manage-report manage-orders)
PROJCPMTEXT=(metadata report orders analysis manage app)
    
    
    if [ "`ls -A ${SOURCEDIR}`" = " " ];then
        svn co https://${SVN_SERVER}/${REPOSITORY_NAME} ${SOURCEDIR}/ --username ${SVN_USER} --password ${SVN_PASS}
        fi
        
        START_TIME=`date "+%Y%m%d-%T"`
# update source code
        svn up ${SOURCEDIR}
        svn info ${SOURCEDIR} | tee /tmp/svninfo
        sed -i '=' /tmp/svninfo && sed -i 'N;s/\n/-/' /tmp/svninfo
        VERSION=`sed -n '/^[369]/p' /tmp/svninfo | awk -F '-' '{print $2}'`
#build war packages
        cd ${SOURCEDIR}/wzc
        mvn clean package
        
# delete old wars
#        rm -rf ${BUILDDIR}/*
                             
# delete old wars & move war to /Data/war/trunk or v0.6
if [ "$1" = "demo" ];
then
    rm -rf ${DEMOBUILDDIR}/*
    for PROJ in ${PROJS2[*]}
        do
            mv ${SOURCEDIR}/${PROJ}/target/*war ${DEMOBUILDDIR}
        done
else
    rm -rf ${BUILDDIR}/*
    for PROJ in ${PROJS2[*]}
        do
            mv ${SOURCEDIR}/${PROJ}/target/*war ${BUILDDIR}
        done
fi                
# rsync war to remote server
if [ "$1" = "final" ];then
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/{app.war,manage.war} ${SYNC_USER}@${REMOTE_SERVER[0]}::$MODULE
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/{analysis.war,metadata.war,orders.war,report.war} ${SYNC_USER}@${REMOTE_SERVER[1]}::$MODULE
        
#restart tomcat on ${REMOTE_SERVER}
ssh F_MANAGE "/Data/scripts/restart_tomcat.sh"                                                     
ssh F_SERVICE "/Data/scripts/restart_tomcat.sh"

END_TIME=`date "+%Y%m%d-%T"`

cat > /tmp/upinfo <<EOF
=========================
server:final_server
Start at:${START_TIME}
Finish at:${END_TIME}
Description:
$VERSION
EOF

#NOTICE
#mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo

#log
cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log

#recovery activemq addr
for D in ${DIR[*]}
    do  
        sed -i "s/${FINAL_SERVICE}/127.0.0.1/" $SOURCEDIR/$D$POSITION$FILENAME
    done
                
elif [ "$1" = "dev" ];then
    rsync -az --delete --exclude="app-download" --exclude="ROOT" --exclude="host-manager" --exclude="manager" --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE

#解压cacti监控tomcat所需目录    
#ssh  -n DEV  "tar -zxvf /Data/app/tomcat/webapps/ctineed.tar.gz -C /Data/app/tomcat/webapps/"
#restart tomcat on $(REMOTE_SERVER)
ssh  -n DEV  "/Data/scripts/restart_tomcat.sh"

END_TIME=`date "+%Y%m%d-%T"`

cat > /tmp/upinfo <<EOF
=========================
server:dev_server
Start at:${START_TIME}
Finish at:${END_TIME}
Description:
$VERSION
EOF

#notice
#mail -s "redeploy success" ${MAIL_LIST}< /tmp/upinfo

#log
cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log

elif [ "$1" = "demo" ];then
    rsync -az --delete --exclude="app-down" --exclude="download" --exclude="ROOT" --exclude="host-manager" --exclude="manager" --password-file=/etc/rsync.pass ${DEMOBUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE

#解压cacti监控tomcat所需目录    
#    ssh TEST "tar -zxvf /Data/app/tomcat/webapps/ctineed.tar.gz -C /Data/app/tomcat/webapps/"
#restart tomcat on $(REMOTE_SERVER)
    ssh TEST_ONLINE "/Data/scripts/restart_tomcat.sh"

END_TIME=`date "+%Y%m%d-%T"`
 
      cat > /tmp/upinfo <<EOF
     =========================
server:demo.feezu.cn
Start at:${START_TIME}
Finish at:${END_TIME}
Description:
$VERSION
EOF
#notice
#    mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo
#log
    cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log
##银联回调地址恢复
    sed -i 's/demo.feezu.cn/111.202.44.157/' ${SOURCEDIR}manage-orders/src/main/resources/acp_sdk.properties
    sed -i 's/10.162.196.41/hbase.feezu.cn/' ${SOURCEDIR}manage-datawarehouse/src/main/resources/hbase-site.xml 
    sed -i 's/demo.feezu.cn/image.feezu.cn/' ${SOURCEDIR}manage-metadata/src/main/resources/ftpconfig.properties
    sed -i 's/demo.feezu.cn/image.feezu.cn/' ${SOURCEDIR}manage-web/src/main/resources/ftpconfig.properties
else    
    rsync -az --delete --exclude="app-download"  --exclude="ROOT" --exclude="host-manager" --exclude="manager" --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE
#restart tomcat on $(REMOTE_SERVER)
    ssh TEST "/Data/scripts/restart_tomcat.sh" 
#解压cacti监控tomcat所需目录    
# ssh TEST "tar -zxvf /Data/app/tomcat/webapps/ctineed.tar.gz -C /Data/app/tomcat/webapps/"
    
    END_TIME=`date "+%Y%m%d-%T"`
    
    cat > /tmp/upinfo <<EOF
    =========================
server:test_server
Start at:${START_TIME}
Finish at:${END_TIME}
Description:
$VERSION
EOF
        
#notice
#        mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo
#log
        cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log
fi
         
# Done
exit 0
