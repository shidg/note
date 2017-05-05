mysql> 		

flush tables with read lock;

unlock table;

show master status;


slave stop;

change master to
master_host='192.168.48.128',
master_user='backup',
master_password='backup',
master_log_file='mysql-bin.000003',
master_log_pos=1826803;

slave start;
1826803
show slave status\G;


GRANT REPLICATION SLAVE ON *.* to 'mysync'@'%' identified by 'q123456'
