# 查看集群状态
hdfs dfsadmin -report

# HBASE集群中的所有服务器，其hosts文件中不能有HBASE节点名称之外的其他主机名记录，否则MASTER在识别各SLAVE节点的时候会出现问题。例如：
# 本来预期的节点名称应该是SLAVE-4,实际上读出来的主机名确实xxx.com，集群会出现问题

# 清空数据表
truncate 'table_name' #该命令是 disable、drop、create三个动作的自动化集成

# 单独启动节点

# hadoop
./sbin/hadoop-daemon.sh start datanode
./sbin/yarn-daemon.sh start nodemanager

# hbase
./bin/hbase-daemon.sh start regionserver
