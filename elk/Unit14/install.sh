#! /bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2024-10-30 14:55:27


# 二进制安装包直接解压安装,三个节点分别执行以下操作

1. 解压
tar zxf apache-zookeeper-3.9.3-bin.tar.gz  -C /usr/local
cd  /usr/local &&  ln -s apache-zookeeper-3.9.3-bin  ./zookeeper  && cd zookeeper
2. 生成并修改配置文件
cd conf  &&  cp zoo_sample.cfg  zoo.cfg
# 只记录需要修改的参数，其他保持默认即可
dataDir=/var/lib/zookeeper  # 数据存放目录，最好不要使用根分区
server.1=kafka-broker1:2888:3888  # 所有zk节点的主机名(或者直接写ip)，如果是主机名，主机名要写入所有节点的/etc/hosts
server.2=kafka-broker2:2888:3888
server.3=kafka-broker3:2888:3888

3. # 三台服务器的zookeeper数据目录中创建myid文件
touch /var/lib/zookeeper/myid
# 将上述<X>代表的数字分别写入三台机器的myid文件
# kafka-broker1
echo 1 > /var/lib/zookeeper/myid
# kafka-broker2
echo 2 > /var/lib/zookeeper/myid
# kafka-broker3
echo 3 > /var/lib/zookeeper/myid


4. # 将zk相关的可执行文件添加到$PATH中
修改~/.bashrc，添加以下内容
export ZK_HOME=/usr/local/zookeeper
export PATH=$PATH:${ZK_HOME}/bin

添加完成之后要使用 source ~/.bashrc重新加载环境变量

5. 启动服务，三节点分别执行
zkServer.sh start

6. 查看一下zk的运行状态，三节点分别执行
zkServer.sh status
执行结果会是1个leader,2个follower,同时会看到2181,2888,3888三个端口都是开启状态。

zkServer.sh status 
# kafka-broker3
Mode: leader
# kafka-broker1
Mode: follower
# kafka-broker2
Mode: follower


7. 服务关闭,各节点执行
zkServer.sh stop


# 此时多节点数据集群配置文件如下：
# tickTime单位是微秒，1000ms=1s，是以1s为时长单位，所以下面的initLimit就是tickTime的倍数，如果initLimit=30则意味着时间是 30*1000ms=30s。
# 服务器配置信息遵循如下原则：server.<X>=<HOSTNAME>:peerPort:leaderPort。
# peerPort是zookeeper节点间通信的TCP端口2888。
# leaderPort是目前集群中的选举使用的TCP端口3888。
# 客户端只需要2181端口就可以直接连接到zk，但是zk集群间通信则同时需要用到peerPort，leaderPort和clientPort。


三个节点分别执行以下操作
1. 解压缩
tar zxf kafka_2.12-3.8.1.tgz -C /usr/local && cd /usr/local
ln -s kafka_2.12-3.8.1  ./kafka &&  cd kafka
2. 修改配置文件
cd config  && vim  server.properties
# 只记录修改的内容，其他保持默认
broker.id=1(2,3)  # 每个broker的编号，不冲突即可
log.dirs=/var/lib/kafka-logs # 数据存放目录，最好不要使用根分区
zookeeper.connect=kafka-broker1:2181,kafka-broker2:2181,kafka-broker3:2181

3. 把kafka相关的可执行文件添加到系统变量中
打开~/.bashrc,做以下修改

export ZK_HOME=/usr/local/zookeeper
export KAFKA_HOME=/usr/local/kafka
export PATH=$PATH:${ZK_HOME}/bin:${KAFKA_HOME}/bin

source ~/.bashrc

4. 启动kafka
kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

5. 验证服务状态
三台服务器的9092端口都应该处于监听状态
查看${kafka_basedir}/logs/server.log是否有报错
使用客户端工具连接kafka集群进行查看offset exploer 2


6. 服务关闭，各节点执行
kafka-server-stop.sh
