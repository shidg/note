#修改tomcat运行模式为apr
tar jxvf apr-1.5.2.tar.bz2 && cd apr-1.5.2/
./configure --prefix=/Data/app/apr && make && make install

tar jxvf apr-iconv-1.2.1.tar.bz2  && cd apr-iconv-1.2.1/
./configure --prefix=/Data/app/apr-iconv --with-apr=/Data/app/apr && make && make install

tar jxvf apr-util-1.5.4.tar.bz2 && cd apr-util-1.5.4/
./configure --prefix=/Data/app/apr-util --with-apr=/Data/app/apr --with-apr-iconv=/Data/app/apr-iconv/bin/apriconv
Make && make install

cd  /Data/app/tomcat/bin
tar zxvf tomcat-native.tar.gz
cd  tomcat-native-1.1.33-src/jni/native/
./configure --with-apr=/Data/app/apr --with-java-home=/Data/app/jdk1.7.0_80
make && make install



#tomcat以普通用户身份运行
#创建用户
useradd -M -s /sbin/nologin tomcat
tar -zxvf apache-tomcat-7.0.65.tar.gz -C /Data/app/
cd /Data/app
chown –R tomcat:tomcat apache-tomcat-7.0.65
ln -s apache-tomcat-7.0.65/ tomcat 

#编译jsvc
cd /Data/app/tomcat/bin
tar zxvf commons-daemon-native.tar.gz && cd commons-daemon-1.0.15-native-src/unix
sh support/buildconf.sh
./configure --with-java=/Data/app/jdk1.7.0_80
make
cp -a jsvc /Data/app/tomcat/bin/
rm -rf /Data/app/tomcat/bin/commons-daemon-1.0.15-native-src/


#将启动脚本放到/etc/init.d下，并做相应修改
cp /Data/app/tomcat/bin/daemon.sh /etc/init.d/tomcat

vi /etc/init.d/tomcat


export JAVA_HOME=/Data/app/jdk1.7.0_80
export TOMCAT_HOME=/Data/app/tomcat
export CATALINA_HOME=/Data/app/tomcat
export CATALINA_BASE=/Data/app/tomcat
export CATALINA_TMPDIR=/Data/app/tomcat/temp
export LD_LIBRARY_PATH=/usr/local/apr/lib



# 调整运行参数
# 
vi /etc/init.d/tomcat
添加如下内容 （服务器内存32G）
CATALINA_OPTS="-server -Xms16000m -Xmx16000m -Xmn6000m  -Xss256k -XX:NewSize=1024m -XX:MaxNewSize=1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:ParallelGCThreads=8  -XX:+DisableExplici
tGC -XX:+UseConcMarkSweepGC -Djava.awt.headless=true -verbose:gc -Xloggc:/Data/app/tomcat/logs/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"




#隐藏tomcat版本信息：
cd ${TOMCAT_HOME}/lib
mkdir -p org/apache/catalina/util && cd org/apache/catalina/util
vi ServerInfo.properties,添加以下内容：
server.info=Apache



#  server.xml
cd /Data/app/tomcat/conf
vi server.xml 
找到如下字段 添加红色部分
<Connector port="8080" protocol="HTTP/1.1"
connectionTimeout="20000"
maxThreads="3000"   
minSpareThreads="15"  
maxSpareThreads="25"  
acceptCount="200"
disableUploadTimeout="true"
enableLookups="false"
redirectPort="8443" useBodyEncodingForURI="true" URIEncoding="UTF-8" />

#在前端有nginx做反向代理的时候可开启以下配置，注释掉上一段内容
<Executor name="tomcatThreadPool" namePrefix="catalina-exec-"
        maxThreads="150" minSpareThreads="4"/>

    <Connector executor="tomcatThreadPool"
        port="8080" protocol="org.apache.coyote.http11.Http11AprProtocol"
        connectionTimeout="30000" maxKeepAliveRequests="1"
        redirectPort="8443" acceptCount="200" useBodyEncodingForURI="true" URIEncoding="UTF-8" />

    <Connector port="8009" executor="tomcatThreadPool" protocol="AJP/1.3" enableLookups="false" connectionTimeout="30000" redirectPort="8443" />

#在<Host>……</Host>段中添加以下（定义首先加载metadata项目）：
<Context docBase="/Data/app/tomcat/webapps/metadata" path="/metadata" reloadable="true" />


#添加以下内容，使VisualVM可以监控到tomcat运行状态
<Listener className="org.apache.catalina.mbeans.JmxRemoteLifecycleListener"
            rmiRegistryPortPlatform="10122" rmiServerPortPlatform="10123" />

在/Data/app/tomcat/lib目录下新增catalina-jmx-remote.jar，用来支持VisualVM
在/Data/app/tomcat/bin下增加setenv.sh，同样也是为了支持VisualVM,setenv.sh文件的内容如下：
#!/bin/sh                                                                                                                          
Export JAVA_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=10.10.8.34"





#以tomcat用户的身份，运行tomcat服务

service tomcat start

