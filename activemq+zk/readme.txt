activemq Master Slave的实现有以下集中方式：
#基于共享文件系统
#基于JDBC（MySQL）

#基于Leveldb

#Leveldb是一个google实现的非常高效的kv数据库，是单进程的服务，能够处理十亿级别规模Key-Value型数据，占用内存小。

#基于可复制LevelDB的集群方案，需要引入ZooKeeper。根据ZooKeeper的使用方式可以分为单节点的ZooKeeper和Zookeeper集群。这里我们只讲述ZooKeeper集群，单节点不是一个可靠的选择。
## ########################################INSTALL ZOOKEEPER ON 3 Servers ##################################

echo >> /etc/profile << EOF
# for zookeeper
JAVA_HOME=/Data/app/jdk1.7.0_80
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib
ZOOKEEPER_HOME=/Data/app/zookeeper-3.4.6
PATH=$PATH:$JAVA_HOME/bin:$ZOOKEEPER_HOME/bin
export JAVA_HOME CLASSPATH ZOOKEEPER_HOME PATH
EOF

echo >> /etc/hosts <<EOF
10.X.X.X K-slave1
10.X.X.X K-slave2
10.X.X.X K-slave3
EOF

tar zxvf zookeeper-3.4.6.tar.gz -C /Data/app
cd /Data/app/zookeeper-3.4.6/conf
cp zoo_sample.cfg zoo.cfg

echo > zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/Data/zookeeper
clientPort=2181
#maxClientCnxns=60
#autopurge.snapRetainCount=3
#autopurge.purgeInterval=1
server.1=K-slave1:2888:3888
server.2=K-slave2:2888:3888
server.3=K-slave3:2888:3888
EOF

mkdir /Data/zookeeper
echo 1 > /Data/zookeeper/myid
#每个服务器上的myid文件中的值不得相同，用来标识不同的zookeeper节点


chown -R hadoop:hadoop /Data/app/zookeeper-3.4.6

################################################ STARTZOOKEEPER###########################################
zkServer.sh start



##################install activemq#####################

#activemq.xml
<persistenceAdapter>
      <replicatedLevelDB 
         directory="${activemq.data}/leveldb"
         replicas="3"
         bind="tcp://0.0.0.0:0"
         zkAddress="x.x.x.x:2181,x.x.x.x:2181,x.x.x.x:2181" 
         hostname="10.10.x.x" #本机ip地址
         zkPath="/activemq/leveldb-stores"
      />
 </persistenceAdapter>

