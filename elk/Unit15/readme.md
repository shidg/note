
# 创建topic
# 旧版本kafka（2.2以下)
```shell
./bin/kafka-topics.sh --create --zookeeper localhost:2181 --partitions 3 --replication-factor 2 --topic bwwg

# 新版本kafka（2.2及以上不需要连接zk)
kafka-topics.sh --create --bootstrap-server localhost:9092   --partitions=3 --replication-factor=2 --topic bwwg
```

# 查询topic
```shell
./bin/kafka-topics.sh --zookeeper localhost:2181 --list                                     
bwwg

# 新版本
kafka-topics.sh --bootstrap-server localhost:9092  --list
```
# topic 详情
```shell
#查看myfirsttopic的详细信息
# ./bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic bwwg

# 新版本
# ./bin/kafka-topics.sh  --bootstrap-server localhost:9092  --describe --topic bwwg
```
# 修改topic partition数量
```shell
./bin/kafka-topics.sh --zookeeper localhost:2181 --alter --partitions 6 --topic myfirsttopic

# 新版本
./bin/kafka-topics.sh  --alter --bootstrap-server localhost:9092 --partitions 6 --topic myfirsttopic
```


# 修改topic replica数量

```shell
#需要先创建一个json文件如下：
# cat partitions-to-move.json
{
    "partitions":
    [
        {
            "topic":"bwwg",
            "partition": 0,
            "replicas": [0,2]
        },
        {
            "topic": "bwwg",
            "partition": 1,
            "replicas": [1,2]
        }
    ],
    "version": 1
}

#执行副本修改
./bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file ./partitions-to-move.json --execute

# 新版本
./bin/kafka-reassign-partitions.sh --bootstrap-server localhost:9092 --reassignment-json-file ./partitions-to-move.json --execute 
```

# 删除topic
```shell
./bin/kafka-topics.sh --zookeeper localhost:2181 --delete --topic bwwg1

./bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic bwwg1
```

# 模拟生产者
```shell
./bin/kafka-console-producer.sh  --broker-list 192.168.0.29:9092 --topic bwwg   
./bin/kafka-console-producer.sh  --bootstrap-server 192.168.0.29:9092 --topic bwwg  
```
# 模拟消费者
```shell
./bin/kafka-console-consumer.sh --bootstrap-server 192.168.0.29:9092 --topic bwwg --from-beginning 
```
