#!/bin/bash
#autodeploy.sh
#Run at 20:00 everyday,update source code from svn.and rebuild *.war
#push *war to remote server,default test_server
#Modified by shidg,20150610


#Trap Err Function
function ERRTRAP(){
    echo "[LINE:$1] Error: Command or function exited with status $?" | mail -s "test_server redeploy faild" 94586572@qq.com
    exit
}

trap 'ERRTRAP $LINENO' ERR

# Define Variables
source ~/.bashrc
SOURCEDIR=/Data/source/trunk/
BUILDDIR=/Data/war/trunk
SVN_SERVER=svn.feezu.cn
REPOSITORY_NAME="repos/wzc/manage/source/trunk"
SVN_USER=jira
SVN_PASS=jira
SYNC_USER=rsync_user
TEST=10.10.8.32
DEV=10.10.8.31
FINAL_WEB=10.10.8.34
FINAL_SERVICE=10.10.8.35
REMOTE_SERVER=$TEST
MODULE=webapps
MAIL_LIST=94586572@qq.com,op@feezu.cn,ceshi@feezu.cn,jishu@feezu.cn
#MAIL_LIST=94586572@qq.com


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
fi

# begin
PROJS2=(manage-web consumer-app manage-metadata manage-datawarehouse manage-report manage-orders)
PROJCPMTEXT=(metadata report orders analysis manage app)


if [ "`ls -A ${BUILDDIR}`" = " " ];then
    svn co svn://${SVN_SERVER}/${REPOSITORY_NAME} ${BUILDDIR}/ --username ${SVN_USER} --password ${SVN_PASS}
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
rm -rf ${BUILDDIR}/*

# move war to /Data/war/trunk
for PROJ in ${PROJS2[*]}
    do
	    mv ${SOURCEDIR}/${PROJ}/target/*war ${BUILDDIR}
    done

# rsync war to remote server
if [ "$1" = "final" ];then
    rsync -az --delete --exclude="app-download" --password-file=/etc/rsync.pass ${BUILDDIR}/{app.war,manage.war} ${SYNC_USER}@${REMOTE_SERVER[0]}::$MODULE
    rsync -az --delete --exclude="app-download" --password-file=/etc/rsync.pass ${BUILDDIR}/{analysis.war,metadata.war,orders.war,report.war} ${SYNC_USER}@${REMOTE_SERVER[1]}::$MODULE

#restart tomcat on ${REMOTE_SERVER}
(ssh F_MANAGE "/bin/bash /Data/scripts/restart_tomcat.sh")                                                     
wait 
(ssh F_SERVICE "/bin/bash /Data/scripts/restart_tomcat.sh")
wait

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
mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo

#log
cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log

#recovery activemq addr
for D in ${DIR[*]}
    do  
        sed -i "s/${FINAL_SERVICE}/127.0.0.1/" $SOURCEDIR/$D$POSITION$FILENAME
    done

elif [ "$1" = "dev" ];then
    rsync -az --delete --exclude="app-download" --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE
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
mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo

#log
cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log

else    
    rsync -az --delete --exclude="app-download" --password-file=/etc/rsync.pass ${BUILDDIR}/ ${SYNC_USER}@${REMOTE_SERVER}::$MODULE
#restart tomcat on $(REMOTE_SERVER)
    ssh TEST "/Data/scripts/restart_tomcat.sh" 

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
mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo

#log
cat /tmp/upinfo >> /Data/logs/wzc/autodeploy.log
fi

# Done
exit 0
