#!/bin/bash
#autodeploy.sh
#Run at 20:00 everyday,update source code from svn.and rebuild *.war
#start a new tomcat to use new *.war
#Modified by shidg,20150610


# Define Variables
BUILDDIR=/root/trunk
BUILDDIRB=/root/trunkB
TA=/usr/local/tomcatA
TB=/usr/local/tomcatB
MAVEN_HOME=/usr/local/apache-maven
SUBVERSIOIN_HOME=/usr/local/subversion
NGINX_HOME=/Data/app/nginx
NGINX=${NGINX_HOME}/sbin/nginx
PROXY_CONF=${NGINX_HOME}/conf/vhosts/feezu.cn
PATH=$PATH:${MAVEN_HOME}/bin:${SUBVERSION_HOME}/bin:${NGINX_HOME}/sbin
SVN_SERVER=xx.xx.xx.xx
REPOSITORY_NAME="wzc/manage/source/trunk"
SVN_USER=jira
SVN_PASS=jira
MAIL_LIST=xxx@qq.com,xxx@xx.cn,xxx@xx.com
LOG_PATH=/Data/logs/xxx

PROJS2=(manage-web consumer-app manage-metadata manage-datawarehouse manage-report manage-orders)
PROJCPMTEXT=(metadata report orders analysis manage app)

#Trap Err Function
function ERRTRAP(){
    echo "[LINE:$1] Error: Command or function exited with status $?" | mail -s "1.61 deploy faild" xxx@qq.com
    exit
}

trap 'ERRTRAP $LINENO' ERR

if [ "`ls -A ${BUILDDIR}`" = " " ];then
    svn co svn://${SVN_SERVER}/${REPOSITORY_NAME} ${BUILDDIR} --username ${SVN_USER} --password ${SVN_PASS}
elif [ "`ls -A ${BUILDDIRB}`" = " " ];then
    svn co svn://${SVN_SERVER}/${REPOSITORY_NAME} ${BUILDDIRB} --username ${SVN_USER} --password ${SVN_PASS}
fi

OLD_TPORT=`mktemp /tmp/tmpfile1.XXXX`
if ss -tnl | grep 8080;then
    echo 8080 > ${OLD_TPORT}
    START_TIME=`date "+%Y%m%d-%T"`
#update source code
    svn up ${BUILDDIRB}| tee /tmp/svninfo
    VERSION=`sed -n '/revision/p' /tmp/svninfo`

#build war packages
    cd ${BUILDDIRB}/wzc
    mvn clean package
    $TA/bin/shutdown.sh
        if ls $TB/webspps | grep -P ".*\.war";then
            rm -f $TB/webapps/*war
        fi
    for PROJ in ${PROJS2[*]}
        do
	        cp ${BUILDDIRB}/${PROJ}/target/*war /Data/war/B/${PROJ}.war-${VERSION}
	        mv ${BUILDDIRB}/${PROJ}/target/*war $TB/webapps/
        done
    for CONTEXT in ${PROJCPMTEXT[*]}
        do
	        if [ -d "$TB/webapps/${CONTEXT}" ];then	
		        rm -rf $TB/webapps/${CONTEXT}
	        fi
        done
#open new tomcat
    $TB/bin/startup.sh

#proxy to new tomcat
    sed -i 's/tomcatA/tomcatB/' ${PROXY_CONF}
    ${NGINX} -s reload
    END_TIME=`date "+%Y%m%d-%T"`
cat > /tmp/upinfo <<EOF
=========================
server: xx.xx.xx.xx
source code now: $VERSION
Start at:${START_TIME}
Finish at:${END_TIME}
EOF
    mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo
    cat /tmp/upinfo >> ${LOG_PATH}/autodeploy.log
else
    echo 8081 > ${OLD_TPORT}
    START_TIME=`date "+%Y%m%d-%T"`
#update source code
    svn up ${BUILDDIR}| tee /tmp/svninfo
    VERSION=`sed -n '/revision/p' /tmp/svninfo`
    cd ${BUILDDIR}/wzc
#build war packages
    mvn clean package
    $TB/bin/shutdown.sh
    if ls $TA/webapps | grep -P ".*\.war";then
        rm -f $TA/webapps/*war
    fi
    for PROJ in ${PROJS2[*]}
        do
	        cp ${BUILDDIR}/${PROJ}/target/*war /Data/war/A/${PROJ}.war-${VERSION}
	        mv ${BUILDDIR}/${PROJ}/target/*war $TA/webapps
        done
    for CONTEXT in ${PROJCPMTEXT[*]}
        do
	        if [ -d "$TA/webapps/${CONTEXT}" ];then	
		        rm -rf $TA/webapps/${CONTEXT}
	        fi
        done
#open new tomcat
    $TA/bin/startup.sh
    sed -i 's/tomcatB/tomcatA/' ${PROXY_CONF}
    $NGINX -s reload
    END_TIME=`date "+%Y%m%d-%T"`
cat > /tmp/upinfo <<EOF
=========================
server: XX.XX.XX.XX.
source code now: $VERSION
Start at:${START_TIME}
Finish at:${END_TIME}
EOF
    mail -s "redeploy success" ${MAIL_LIST} < /tmp/upinfo
    cat /tmp/upinfo >> ${LOG_PATH}/autodeploy.log
fi

#close old tomcat
TMPFILE=`mktemp /tmp/tmpfile2.XXXX`
if grep 8080 ${OLD_TPORT};then
    ps -ef | grep tomcatA | grep -v "grep"  | awk '{print $2}'> $TMPFILE
    for TPID in `cat $TMPFILE`
        do
            kill -9 $TPID
        done
else
    ps -ef | grep tomcatB | grep -v "grep"  | awk '{print $2}'> $TMPFILE
    for TPID in `cat $TMPFILE`
        do
            kill -9 $TPID
        done
fi

#delete tmp file
rm -f /tmp/{svninfo,upinfo}
rm -f $OLD_TPORT $TMPFILE
