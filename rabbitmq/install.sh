# INSTALL RABBITMQ-3.6.10 ON CentOS 7 ##

## install perl
yum install perl ncurses-devel openssl openssl-devel -y

## install erlang
tar zxvf otp_src_19.3.tar.gz && cd otp_src_19.3
./configure --prefix=/Data/app/erlang --with-ssl && make && make install
ln -s /Data/app/erlang/bin/erl /usr/bin/erl

erl -v

## install python and simplejson (https://pypi.python.org)
yum install python 

tar zxvf simplejson-3.11.1.tar.gz && cd simplejson-3.11.1
python setup.py install

##  xmlto: command not found

yum -y install xmlto rsync zip 

##upgrade gnu make （http://ftp.gnu.org/gnu/make/）

tar zxvf make-4.2.1.tar.gz && cd make-4.2.1
./configure --prefix=/usr && make && make install


##install rabbitmq

xz -d rabbitmq-server-generic-unix-3.6.10.tar.xz && tar xvf rabbitmq-server-generic-unix-3.6.10.tar -C /Data/app/
cd /Data/app
ln -s rabbitmq_server-3.6.10/ ./rabbitmq

./sbin/rabbitmq-server start

./sbin/rabbitmqctl status|stop

mkdir /etc/rabbitmq
./sbin/rabbitmq-plugins enable rabbitmq_management

#http://10.10.x.x:15672
#默认帐号guest/guest只支持localhost登录，不支持远程登录

#创建帐号
./rabbitmqctl add_user ywx Ywx*12345
./rabbitmqctl set_user_tags ywx administrator
./rabbitmqctl set_permissions -p "/" ywx ".*" ".*" ".*"


