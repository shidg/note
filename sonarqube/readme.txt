## INSTALL SONARQUBE-5.6.6 ON CentOS-7.2 ##

# install mysql-5.6.32

#创建数据库
create database sonar default charset=utf8; 

#配置数据库用户
create user 'sonar' identified by 'sonar123';  
grant all on sonar.* to 'sonar'@'%' identified by 'sonar123';  
grant all on sonar.* to 'sonar'@'localhost' identified by 'sonar123';  
flush privileges; 

# install sonarqube
# https://www.sonarqube.org/downloads/
cd /Data/app
unzip sonarqube-5.6.6.zip
ln -s sonarqube-5.6.6 ./sonarqube

cd sonarqube/conf
edit the file sonar.properties

# start service

/Data/app/sonarqube/bin/sonar.sh start

#http://ip:9000


#install nginx as a proxy server#


# install ldap-plugin,then log in with AD domain users#




##jenkins中的项目构建触发sonar进行一次扫描

#jenkins 服务器安装SonarQube Scanner
#https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

cd /Data/app
unzip sonar-scanner-cli-3.0.3.778-linux.zip
ln -s sonar-scanner-3.0.3.778-linux/ ./sonar-scanner

# 在jenkins中配置sonar-scanner,系统管理-->Global Tool Configuration--->SonarQube Scanner

Name  Sonar Scanner

SONAR_RUNNER_HOME   /Data/app/sonar-scanner/


##配置jenkins项目

Pre Steps中，Add pre-build stap--->Execute SonarQube Scanner
Task to run
JDK
Analysis properties:
sonar.projectKey=ci
sonar.projectName=ci
sonar.projectVersion=1.0
sonar.sourceEncoding=UTF-8
sonar.language=java
sonar.sources=/Data/jenkins/jobs/unit_test_trunk/workspace


