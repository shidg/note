#!/bin/bash
#autodeploy.sh
#Run at 20:00 everyday,update source code from svn.and rebuild *.war
#start a new tomcat to use new *.war
#Modified by shidg,20150610

#Trap Err Function
function ERRTRAP(){
    echo "[LINE:$1] Error: Command or function exited with status $?" | mail -s "1.61 deploy faild" shidg@feezu.cn
    exit
}
trap 'ERRTRAP $LINENO' ERR

# Define Variables
BUILDDIR=/root/trunk
BUILDDIRB=/root/trunkB
TA=/usr/local/tomcatA
TB=/usr/local/tomcatB
MAVEN_HOME=/usr/local/apache-maven-3.2.5
SUBVERSIOIN_HOME=/usr/local/subversion-1.8.13
NGINX_HOME=/Data/app/nginx
NGINX=${NGINX_HOME}/sbin/nginx
PROXY_CONF=${NGINX_HOME}/conf/vhosts/feezu.cn
PATH=$PATH:${MAVEN_HOME}/bin:${SUBVERSION_HOME}/bin:${NGINX_HOME}/sbin
SVN_SERVER=192.168.1.15
REPOSITORY_NAME="wzc/manage/source/trunk"
SVN_USER=jira
SVN_PASS=jira
OLD_TPORT=`mktemp /tmp/tmpfile1.XXXX`

PROJS2=(manage-web consumer-app manage-metadata manage-datawarehouse manage-report manage-orders)
PROJCPMTEXT=(metadata report orders analysis manage app)

if [ "`ls -A ${BUILDDIR}`" = " " ];then
    svn co svn://${SVN_SERVER}/${REPOSITORY_NAME} ${BUILDDIR} --username ${SVN_USER} --password ${SVN_PASS}
fi

if ss -tnl | grep 8080;then
echo 8080 > ${OLD_TPORT}
START_TIME=`date "+%m%d-%T"`

#update source code
svn up ${BUILDDIRB}| tee /tmp/svninfo
VERSION=`sed -n '/revision/p' /tmp/svninfo`

#build war packages
cd ${BUILDDIRB}/wzc
mvn clean package

#stop old tomcat
$TA/bin/shutdown.sh

if ls $TB/webspps | grep -P ".*\.war";then
    rm -f $TB/webapps/*war
fi

for PROJ in ${PROJS2[*]}
do
	mv ${BUILDDIRB}/${PROJ}/target/*war $TB/webapps/
done

for CONTEXT in ${PROJCONTEXT[*]}
do
	if [ -d "$TB/webapps/${CONTEXT}" ];then	
		rm -rf $TB/webapps/${CONTEXT}
	fi
done

#open new tomcat
$TB/bin/startup.sh

#proxy to new tomcat
sed -i 's/tomcatA/tomcatB/' ${PROXY_CONF}

#reload nginx
${NGINX} -s reload

END_TIME=`date "+%m%d-%T"`

cat > /tmp/upinfo <<EOF
server:192.168.1.61.
source code now: $VERSION
Start at:${START_TIME}
Finish at:${END_TIME}
EOF

#report
#mail -s "redeploy success" shidg@feezu.cn < /tmp/upinfo
else
echo 8081 > ${OLD_TPORT}
START_TIME=`date "+%m%d-%T"`

#update source code
svn up ${BUILDDIR}| tee /tmp/svninfo
VERSION=`sed -n '/revisioin/p' /tmp/svninfo`

cd ${BUILDDIR}/wzc
#build war packages
mvn clean package

#stop old tomcat
$TB/bin/shutdown.sh

if ls $TA/webapps | grep -P ".*\.war";then
    rm -f $TA/webapps/*war
fi

for PROJ in ${PROJS2[*]}
do
	mv ${BUILDDIR}/${PROJ}/target/*war $TA/webapps
done

for CONTEXT in ${PROJCONTEXT[*]}
do
	if [ -d "$TA/webapps/${CONTEXT}" ];then	
		rm -rf $TA/webapps/${CONTEXT}
	fi
done

#open new tomcat
$TA/bin/startup.sh

#proxy to new tomcat
sed -i 's/tomcatB/tomcatA/' ${PROXY_CONF}

#reload nginx
$NGINX -s reload
END_TIME=`date "+%m%d-%T"`

cat > /tmp/upinfo <<EOF
server:192.168.1.61.
source code now:$VERSION
Start at:${START_TIME}
Finish at:${END_TIME}
EOF

#report
#mail -s "redeploy success" shidg@feezu.cn < /tmp/upinfo
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
