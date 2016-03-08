#!/bin/sh

MANAGE_SOURCE=/Data/source/Platform/trunk
MINA_SOURCE=/Data/source/Mina/trunk/Mina
BUILDDIR=/Data/war/mina/trunk
START_TIME=`date "+%Y%m%d-%T"`

echo -e "选择适用的环境,多选无效"
echo -e "1)dev.feezu.cn"
echo -e "2)test.feezu.cn"
echo -e "3)final.feezu.cn"
echo -e "4)demo.feezu.cn"
echo -e "5)www.feezu.cn"
echo -ne "Enter your choice from [1-5]:"

read need
case $need in
    1)
        SERVER=dev
        break
    ;;
    2)
        SERVER=test
        sed -i '/^mina_id/ s/dev/test/' ${MINA_SOURCE}/config/config.properties
        break
    ;;
    3)
        SERVER=final1
        sed -i '/^mina_id/ s/dev/final1/' ${MINA_SOURCE}/config/config.properties
    ;;
    4)
        SERVER=demo
        sed -i 's/127.0.0.1/10.172.191.112/' ${MINA_SOURCE}/config/msgConfig.properties

        echo -e "选择要更新的后端服务器"
        echo -e "1)mina_server1"
        echo -e "2)mina_server2"
        echo -e "3)mina_server3"
        echo -ne "Enter your choice from [1-3]:"

        read realserver 
        case $realserver in
        1)
        sed -i '/^mina_id/ s/dev/s1/' ${MINA_SOURCE}/config/config.properties
        ;; 
        2)
        sed -i '/^mina_id/ s/dev/s2/' ${MINA_SOURCE}/config/config.properties
        ;; 
        3)
        sed -i '/^mina_id/ s/dev/s3/' ${MINA_SOURCE}/config/config.properties
        ;; 
        esac
    ;;
    5) 
        sed -i 's/127.0.0.1/10.171.44.14/' ${MINA_SOURCE}/config/msgConfig.properties
        sed -i '/^mina_id/ s/dev/www/' ${MINA_SOURCE}/config/config.properties
        SERVER=www
    ;;     
    *)
        echo "Error!Please give the right choice"
        exit
    ;;
esac


cd ${MANAGE_SOURCE}/manage-common
svn update
mvn clean install

cd ${MINA_SOURCE}
svn update
svn info ${MINA_SOURCE} |tee /tmp/svninfo
sed -i '=' /tmp/svninfo && sed -i 'N;s/\n/-/' /tmp/svninfo
VERSION=`sed -n '/^[37]/p;/^1[01]/p' /tmp/svninfo | awk -F '-' '{print $2}'`
mvn clean package

if [ -f "${BUILDDIR}/mina.jar" ];then
	rm -f ${BUILDDIR}/mina.jar
fi

if [ -d "${BUILDDIR}/lib" ];then
	rm -rf ${BUILDDIR}/lib
fi

cp ${MINA_SOURCE}/target/*.jar ${BUILDDIR}
cp -a ${MINA_SOURCE}/target/lib ${BUILDDIR}

echo "msg.brokerURL=tcp://127.0.0.1:61616" > ${MINA_SOURCE}/config/msgConfig.properties
sed -i '/mina_id/d' ${MINA_SOURCE}/config/config.properties
sed -i '/^mina_type/ a \mina_id=mina_v77_dev\' ${MINA_SOURCE}/config/config.properties
dos2unix ${MINA_SOURCE}/config/msgConfig.properties
dos2unix ${MINA_SOURCE}/config/config.properties

END_TIME=`date "+%Y%m%d-%T"`

cat >> /Data/logs/deplog/depmina.log <<EOF
=========================
rebuild mina for [$SERVER] server success.
TIME:${START_TIME}
Mina Version: $VERSION
EOF

exit 0
