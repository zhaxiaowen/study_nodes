# Elasticsearch常见故障处理方法总结

### 一.分片未分配

#### 1.问题现象:

* 分片未分配

可能原因

* 磁盘空间不足:没有磁盘空间来分配分片
* 分片数限制:每个节点的分片数量过多,在创建新索引或删除某些节点且系统找不到它们的位置时很常见
* JVM或内存限制:一些版本在内存不足时可以限制分片分配
* 路由或分配规则:通用高可用云或大型复杂系统会遇到

#### 2.定位过程

* 查看**Unassigned Shards**原因: `curl 'localhost:9200/_cluster/allocation/explain?pretty'`

```
#错误内容
* shard has execeeded the maximum number of retries [5] on failed allocation attempts
* failed to create shard
```

* 查看**fd**情况: `curl -XGET http://localhost:9200/_nodes/stats/process?`,fd情况正常
* 查看es日志:`cat elasticsearch.log |grep -i "allocation_status"`

#### 3.问题原因

* shard 自动分配 已经达到最大重试次数5次，仍然失败了，所以导致"shard的分配状态已经是：no_attempt"

#### 4.解决方案

`curl -XPOST http://localhost:9200/_cluster/reroute?retry_failed=true`

#### 5.改进建议



### 二.

#### 1.问题现象:



#### 2.定位过程



#### 3.问题原因



#### 4.解决方案



#### 5.改进建议
