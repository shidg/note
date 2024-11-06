# _cat接口
GET _cat/allocation?v
GET _cat/health?v
GET _cat/nodes?v
GET _cat/indices?v
GET _cat/shards?v


# 创建索引
PUT /index1

# 清空索引
POST /xiaoshuo1/_delete_by_query
{
  "query": {
    "match_all": {}
  }
}

# _cat接口
GET /_cat/allocation?pretty
GET /_cat/health
GET /_cluster/health?pretty


# 查看节点信息
GET /_nodes
GET /_cluster/stats/nodes/
GET /_cluster/stats/nodes/fe_iyMeWSA6u3fXxwzsE2Q


#### 集群增加节点

# 新增服务器并安装es


# 在新es节点启动服务器之前，关闭分片自动重分配
# 目的在于新节点加入后，不自动进行分片的重新分配
# 以防止增加服务器的磁盘IO压力
PUT /_cluster/settings
{
  "persistent": {
    "cluster": {
      "routing": {
        "allocation.enable": "none"
      }
    }
  }
}

# 启动新节点

# 在合适的时间，开启分片自动分配，
# 以完成数据的自动均衡

PUT /_cluster/settings
{
  "persistent": {
    "cluster": {
      "routing": {
        "allocation.enable": "all"
      }
    }
  }
}

#### 从集群中删除节点

# 添加策略，禁用节点
PUT /_cluster/settings
{
 "transient": {
   "cluster": {
     "routing": {
       "allocation.exclude": {
         "_ip": "10.203.43.104"
       }
     }
   }
 }
}

# 停止要删除的节点上的es

# 取消禁用节点的策略
PUT /_cluster/settings
{
 "transient": {
   "cluster": {
     "routing": {
       "allocation.exclude": {
         "_ip": ""
       }
     }
   }
 }
}





# 查看分配状态
GET /_cat/indices?pretty
GET /_cluster/health?pretty
GET /_cluster/pending_tasks?pretty
GET /_nodes/ov69kzisTfuAyKQsgVTepw/stats/indices?pretty
GET /_cat/allocation?v



# 创建共享库
# 创建共享库之前确保elasticsearch.yml中配置了path.repo
# 且path.repo指定的目录是一个共享目录
PUT /_snapshot/baway_backup
{
 "type": "fs", # fs的意思是Shared file system
 "settings": {
   "location": "/data/elasticsearch/backup",
   "compress": true
 }
}

# 查看共享库
GET /_cat/repositories
GET /_snapshot/_all

# 删除共享仓库
DELETE _snapshot/baway_backup

# 为索引创建快照
PUT _snapshot/baway_backup/bawaysnapshot
{
  "indices": "baway*",
  "ignore_unavailable": "true",
  "include_global_state": false
}

# 查看创建的快照
GET _cat/snapshots
GET _snapshot/baway_backup/_all
GET _snapshot/baway_backup/bawaysnapshot/

# 删除索引
DELETE /baway*

# 数据恢复
POST /_snapshot/baway_backup/bawaysnapshot/_restore

# 删除快照
DELETE /_snapshot/baway_backup/bawaysnapshot

