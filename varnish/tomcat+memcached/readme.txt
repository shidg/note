# tomcat+memcached实现多tomcat的session共享,也就是memcached-session-manager项目

#注意jar包版本，版本冲突可能导致无法启动,以下版本组合测试通过，未经实地测试勿随意替换.



1. 将以下三个包放到tomcat_dir/lib目录下。
memcached-session-manager-${version}.jar ,

memcached-session-manager-tc7-${version}.jar ,
###tc7对应tomcat7,若是tomcat6则需使用memcached-session-manager-tc6-${version}.jar

spymemcached-${version}.jar

下载地址分别为：
http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager/
http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager-tc7/
http://repo1.maven.org/maven2/net/spy/spymemcached/
(本次测试中使用的版本为1.8.3和2.12.0)


2. 将以下jar文件放到tomcat_dir/lib目录下

asm-3.3.1.jar 
kryo-1.04.jar
kryo-serializers-0.11.jar
minlog-1.2.jar
msm-kryo-serializer-1.8.3.jar
reflectasm-1.01.jar

下载链接分别为
http://repo1.maven.org/maven2/asm/asm/
http://repo1.maven.org/maven2/com/googlecode/kryo/
http://repo1.maven.org/maven2/de/javakaffee/kryo-serializers/0.11/
http://repo1.maven.org/maven2/com/googlecode/minlog/
http://repo1.maven.org/maven2/de/javakaffee/msm/msm-kryo-serializer/
http://repo1.maven.org/maven2/com/googlecode/reflectasm/



3. 将以下内容写入tomcat_dir/conf/context.xml 

<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
    memcachedNodes="n1:10.10.67.220:11211"
    sticky="false"
    sessionBackupAsync="false"
    lockingMode="uriPattern:/path1|/path2"
    requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
    transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"/>

4. 重启tomcat



test.jsp

SessionID:<%=session.getId()%>
<BR>
SessionIP:<%=request.getServerName()%>
<BR>
SessionPort:<%=request.getServerPort()%>
<%
out.println("This is Tomcat Server 212");
%>
