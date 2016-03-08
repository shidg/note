#!/bin/bash
# autodeploy.sh
# Run at 20:00 everyday,update source code from svn.and rebuild *.war
# Push *war to remote server,default test_server
# Send mail to ${ERROR_REPORT} when Script execution failed
# Modified by shidg,20150610

# Define Variables
source ~/.bashrc
SOURCEDIR=/Data/source/Platform/trunk/
BUILDDIR=/Data/war/Platform/trunk
SVN_SERVER=svn.feezu.cn
REPOSITORY_NAME="repos/wzc/manage/source/trunk"
SVN_USER=jira
SVN_PASS=jira*12345
SYNC_USER=rsync_user
TEST=10.10.8.32
TEST1=10.10.8.52
TEST2=10.10.8.62
DEV=10.10.8.31
DEMO=123.56.86.141
FINAL_WEB=10.10.8.34
FINAL_SERVICE=10.10.8.35
REMOTE_SERVER=$TEST
FINAL1_SERVICE=123.56.76.78
MODULE=war
#MAIL_LIST=94586572@qq.com
#ERROR_REPORT=94586572@qq.com,luokui@feezu.cn,songting@feezu.cn,wangliang@feezu.cn,maocc@feezu.cn,liuzhen@feezu.cn
#ERROR_REPORT=94586572@qq.com
START_TIME=`date "+%Y%m%d-%T"`

#
for MQADDR in manage-datawarehouse manage-metadata manage-orders
do
    echo "msg.brokerURL=tcp://127.0.0.1:61616" > ${SOURCEDIR}${MQADDR}/src/main/resources/msgConfig.properties
done

echo -e "选择适用的环境,多选无效"
echo -e "1)dev.feezu.cn"
echo -e "2)test.feezu.cn"
echo -e "3)final1.feezu.cn"
#echo -e "4)final.feezu.cn"
#echo -e "5)demo.feezu.cn"
echo -ne "Enter your choice from [1-3]:"

read need
case $need in 
    1)
        REMOTE_SERVER=$DEV
        TYPE="dev"
    ;;
    2)
        REMOTE_SERVER=$TEST
        REMOTE_SERVER1=$TEST1
        REMOTE_SERVER2=$TEST2
        TYPE="test"
    ;;     
    4)
        REMOTE_SERVER=(${FINAL_WEB} ${FINAL_SERVICE})
        DIR=(manage-datawarehouse/ manage-metadata/ manage-orders/)
        POSITION=src/main/resources/
        FILENAME=msgConfig.properties
        for D in ${DIR[*]}
            do  
                sed -i "s/127.0.0.1/${FINAL_SERVICE}/" $SOURCEDIR/$D$POSITION$FILENAME
            done
        TYPE="final"
    ;;     
    5)
        REMOTE_SERVER=$DEMO
        TYPE="demo"
    ;;     
    3) 
        REMOTE_SERVER=$FINAL1_SERVICE
        TYPE="final1"
     ;; 
    *)
        echo "Error!Please give the right choice"
        exit
    ;;
esac

#Trap Err Function
function ERRTRAP(){
    mail -s "${TYPE}_server redeploy failed" ${ERROR_REPORT} < /tmp/audpfail.log
    exit
}

#trap 'ERRTRAP $LINENO' ERR


# begin
    if [ "`ls -A ${SOURCEDIR}`" = " " ];then
        svn co https://${SVN_SERVER}/${REPOSITORY_NAME} ${SOURCEDIR}/ --username ${SVN_USER} --password ${SVN_PASS}
        fi
# update source code
        svn up ${SOURCEDIR}
        svn info ${SOURCEDIR} | tee /tmp/svninfo
        sed -i '=' /tmp/svninfo && sed -i 'N;s/\n/-/' /tmp/svninfo
        SVN_MSG=`sed -n '/^[39]/p;/^10/p' /tmp/svninfo | awk -F '-' '{print $2}'`
        SVN_VERSION=`sed -n '/^7/p' /tmp/svninfo | awk -F '-' '{print $2}'|cut -d: -f2`
        if [ -f /tmp/last_version_trunk ];then
            LAST_SVN_VERSION=`cat /tmp/last_version_trunk`
        fi
        echo ${SVN_VERSION} > /tmp/last_version_trunk
#build war packages
        cd ${SOURCEDIR}/wzc
        mvn clean package

# delete old wars & move war to /Data/war/trunk or v0.6
PROJS2=(manage-web consumer-app manage-metadata manage-datawarehouse manage-report manage-orders)
rm -rf ${BUILDDIR}/*
for PROJ in ${PROJS2[*]}
    do
        mv ${SOURCEDIR}/${PROJ}/target/*war ${BUILDDIR}
    done

# rsync war to remote server
if [ "$need" = "4" ];then
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/{app.war,manage.war} ${SYNC_USER}@${REMOTE_SERVER[0]}::$MODULE
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/{analysis.war,metadata.war,orders.war,report.war} ${SYNC_USER}@${REMOTE_SERVER[1]}::$MODULE
        
#restart tomcat on ${REMOTE_SERVER}
ssh F_MANAGE "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}"                                                     
ssh F_SERVICE "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}"

END_TIME=`date "+%Y%m%d-%T"`

#log
cat > /tmp/upinfo <<EOF
=========================
server:final_server
Start at:${START_TIME}
Finish at:${END_TIME}
$SVN_MSG
Current version:${SVN_VERSION}
Last version:${LAST_SVN_VERSION}
EOF
cat /tmp/upinfo >> /Data/logs/deplog/dep_trunk.log

#recovery activemq addr
for D in ${DIR[*]}
    do  
        sed -i "s/${FINAL_SERVICE}/127.0.0.1/" $SOURCEDIR/$D$POSITION$FILENAME
    done
                
elif [ "$need" = "1" ];then
    rsync -az --delete --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE

#restart tomcat on $(REMOTE_SERVER)
ssh -n DEV  "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}"

END_TIME=`date "+%Y%m%d-%T"`

#log

cat > /tmp/upinfo <<EOF
=========================
server:dev_server
Start at:${START_TIME}
Finish at:${END_TIME}
$SVN_MSG
Current version:${SVN_VERSION}
Last version:${LAST_SVN_VERSION}
EOF
cat /tmp/upinfo >> /Data/logs/deplog/dep_trunk.log

elif [ "$need" = "5" ];then
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/*war ${SYNC_USER}@${REMOTE_SERVER}::$MODULE

#restart tomcat on $(REMOTE_SERVER)
ssh DEMO "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}"

END_TIME=`date "+%Y%m%d-%T"`

#log
cat > /tmp/upinfo <<EOF
=========================
server:demo.feezu.cn
Start at:${START_TIME}
Finish at:${END_TIME}
$SVN_MSG
Current version:${SVN_VERSION}
Last version:${LAST_SVN_VERSION}
EOF
cat /tmp/upinfo >> /Data/logs/deplog/dep_trunk.log

elif [ "$need" = "3" ];then
    rsync -az --password-file=/etc/rsync.pass ${BUILDDIR}/*war ${SYNC_USER}@${REMOTE_SERVER}::$MODULE

#restart tomcat on $(REMOTE_SERVER)
ssh FINAL1_SERVICE "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}"

END_TIME=`date "+%Y%m%d-%T"`

#log
cat > /tmp/upinfo <<EOF
=========================
server:bomb.feezu.cn
Start at:${START_TIME}
Finish at:${END_TIME}
$SVN_MSG
Current version:${SVN_VERSION}
Last version:${LAST_SVN_VERSION}
EOF
cat /tmp/upinfo >> /Data/logs/deplog/dep_trunk.log

else    
   rsync -az --delete --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE &
#   rsync -az --delete --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER1}::$MODULE &
#   rsync -az --delete --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER2}::$MODULE &
#wait for rsync done
wait

#restart tomcat on $(REMOTE_SERVER)
ssh TEST "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}" &
#ssh TEST1 "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}" &
#ssh TEST2 "/Data/scripts/restart_tomcat.sh ${SVN_VERSION}" &

wait
END_TIME=`date "+%Y%m%d-%T"`
    
cat > /tmp/upinfo <<EOF
=========================
server:test_server
Start at:${START_TIME}
Finish at:${END_TIME}
$SVN_MSG
Current version:${SVN_VERSION}
Last version:${LAST_SVN_VERSION}
EOF

#log
cat /tmp/upinfo >> /Data/logs/deplog/dep_trunk.log
fi
         
# Done

exit 0
