# es 常用 CRUD操作
es创建索引：

```
PUT /<index>
```

es创建索引的同时指定分片数：

```
PUT /<index>
{
    "settings": {
    "number_of_shards": 2,    #主分片数,一旦创建之后不能修改
    "number_of_replicas": 1   #副本分片数，创建之后也可以修改
    }
}
```

es创建索引的同时指定分片数和mapping:

```
PUT /<index>
{
    "settings": {
    "number_of_shards": 2,    #主分片数,一旦创建之后不能修改
    "number_of_replicas": 1   #副本分片数，创建之后也可以修改
    }
    "mapping": {
        "properties": {
        "music": {
                "type": "text"
            },
            "author": {
                "type": "text"  
            },
            "create_time":{
                "type": "date"
        } 
     }
    }
}
```

es插入文档

```
POST /<index>/_doc
{
  "music": "青花瓷",
  "author": "周杰伦",
  "create_time": "2000-10-10"
}
```

es修改文档

```
POST /<index>/_doc/<id>/_update     #修改指定字段
{
    "doc": {
        "filed": "字段值"
    }
}

# 如果不调用_update接口，像以下这样，修改的是整条文档，且修改后的值值保留最后一次提交的字段，其他字段清空
POST /<index>/_doc 
{
    "field": "字段值"
}
```

es查询索引下的所有文档：

```
GET /<index> #只显示索引的元信息，配置信息，不显示具体文档


GET /<index>/_search # 显示索引下的所有文档

```

es查询索引下的某条文档：

```
GET /<index>/_doc/id

```

es查询按照字段值来查询文档：

```
GET /xiaoshuo1/_search?pretty
{
  "query": {
    "match": {
      "filed": "TEXT"
    }
  }
}
```

es删除索引下的某条文档

```
DELETE /<index>/_doc/id
```

es删除索引下的所有文档,但是保留索引

```
POST /index/_delete_by_query
{
    "query": {
    "match_all": {}
    }
}
```
