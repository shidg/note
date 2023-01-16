# 卸载mariadb
rpm -qa | grep mariadb
rpm -e mariadb --nodeps

##### yum 安装 ######
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
yum localinstall mysql57-community-release-el7-8.noarch.rpm
yum install mysql-community-server -y



#### 源码安装 #######
tar zxvf mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz -C /Data/app

cd /Data/app/mysql-5.7.18-linux-glibc2.5-x86_64

mkdir log

cp  my.cnf  ./

cd ..

chown -R mysql:mysql mysql-5.7.18-linux-glibc2.5-x86_64

ln -s mysql-5.7.18-linux-glibc2.5-x86_64 ./mysql
ln -s /Data/app/mysql/my.cnf /etc/my.cnf

cd mysql

./bin/mysqld --defaults-file=/etc/my.cnf --initialize

cp mysql.server /etc/init.d/mysqld

service mysqld start

grep "password" mysql/log/error.log

[Note] A temporary password is generated for root@localhost: !3Q&i6pu0Vli

mysql -u root -p


#修改root密码

ALTER USER 'root'@'localhost' IDENTIFIED BY '********'

UPDATE mysql.user SET authentication_string=PASSWORD(’新密码’) WHERE User=’root’;


