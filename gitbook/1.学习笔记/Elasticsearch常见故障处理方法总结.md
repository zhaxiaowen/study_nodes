# Elasticsearch常见故障处理方法总结

#### unassigned分片问题可能的原因

1）INDEX_CREATED：由于创建索引的API导致未分配。

2）CLUSTER_RECOVERED ：由于完全集群恢复导致未分配。

3）INDEX_REOPENED ：由于打开open或关闭close一个索引导致未分配。

4）DANGLING_INDEX_IMPORTED ：由于导入dangling索引的结果导致未分配。

5）NEW_INDEX_RESTORED ：由于恢复到新索引导致未分配。

6）EXISTING_INDEX_RESTORED ：由于恢复到已关闭的索引导致未分配。

7）REPLICA_ADDED：由于显式添加副本分片导致未分配。

8）ALLOCATION_FAILED ：由于分片分配失败导致未分配。

9）NODE_LEFT ：由于承载该分片的节点离开集群导致未分配。

10）REINITIALIZED ：由于当分片从开始移动到初始化时导致未分配（例如，使用影子shadow副本分片）。

11）REROUTE_CANCELLED ：作为显式取消重新路由命令的结果取消分配。

12）REALLOCATED_REPLICA ：确定更好的副本位置被标定使用，导致现有的副本分配被取消，出现未分配。

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
