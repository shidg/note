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


change master to master_host='10.10.8.62', master_user='rep_user',master_password='123456', master_log_file='mysql-bin-master.000002', master_log_pos=863;

slave start;
1826803
show slave status\G;


GRANT REPLICATION SLAVE ON *.* to 'rep_user'@'%' identified by '123456'

