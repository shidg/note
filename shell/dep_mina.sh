#!/bin/sh

SOURCEDIR=/Data/source/trunk
BUILDDIR=/Data/war/mina

echo -e "选择适用的环境,请勿同时选择多个"
echo -e "1)dev.xxx.cn"
echo -e "2)test.xxx.cn "
echo -e "3)final.xxx.cn"
echo -e "4)demo.xxx.cn"
echo -e "5)www.xxx.cn"
echo -ne "Enter your choice from [1-5]:"

read need
case $need in
    3)
        sed -i 's/127.0.0.1/10.10.8.35/' ${SOURCEDIR}/Mina/config/applicationContext-message.xml
    ;;
    5) 
        sed -i 's/127.0.0.1/10.171.44.14/' ${SOURCEDIR}/Mina/config/applicationContext-message.xml 
    ;;     
    1|2|4 )
        break
    ;;
    *)
        echo "Error!Please give the right choice"
        exit
    ;;
esac

cd ${SOURCEDIR}/manage-common
svn update
mvn clean install

cd ${SOURCEDIR}/Mina
svn update
mvn clean package

if [ -f "${BUILDDIR}/mina.jar" ];then
	rm -f ${BUILDDIR}/mina.jar
fi

if [ -d "${BUILDDIR}/lib" ];then
	rm -rf ${BUILDDIR}/lib
fi

cp ${SOURCEDIR}/Mina/target/*.jar ${BUILDDIR}
cp -a ${SOURCEDIR}/Mina/target/lib ${BUILDDIR}

sed -i '/61616/d;/ActiveMQC/a \\t\t<property name="brokerURL" value="tcp://127.0.0.1:61616"/>' ${SOURCEDIR}/Mina/config/applicationContext-message.xml
dos2unix ${SOURCEDIR}/Mina/config/applicationContext-message.xml

exit 0
