# Elasticsearch

#### [ES博客教程](https://elasticstack.blog.csdn.net/article/details/102728604)

#### [吃透Elasticsearch 堆内存]( https://blog.csdn.net/zpf_940810653842/article/details/102785970)

#### [为什么Java进程使用的内存(RSS)比Heap Size大](https://blog.csdn.net/flyingnet/article/details/108491460)

#### 优化

```yaml
应用方面：
1._source只存储需要的字段
2.开启字段store 属性true,会有单独的存储空间为这个字段做存储，这个存储是独立于_source;能提高查询效率
```

#### 遇到性能问题，排查思路

```plain
实例：https://blog.51cto.com/u_15060469/2681020
    看日志，是否有字段类型不匹配，是否有脏数据。
    看CPU使用情况，集群是否异构
    客户端是怎样的配置？使用的bulk 还是单条插入
    查看线程堆栈，查看耗时最久的方法调用
    确定集群类型：ToB还是ToC，是否允许有少量数据丢失？
    针对ToB等实时性不高的集群减少副本增加刷新时间
    index buffer优化 translog优化，滚动重启集群
   
GET /_cat/thread_pool/?v  
GET /_cat/thread_pool/?v&h=id,name,active,rejected,completed,size,type&pretty&s=type
# name:代表某种线程池（写入，检索，刷新等）
# type:代表线程数类型
```

#### reject：拒绝请求

```plain
https://cloud.tencent.com/developer/article/1797226
现象：es集群拒绝索引写入请求
原因：通常，这表明一个或多个节点无法跟上索引 / 删除 / 更新 / 批量请求的数量，从而导致在该节点上建立队列且队列逐渐累积。
		 一旦索引队列超过队列的设置的最大值（如 elasticsearch.yml 定义的值或者默认值），则该节点将开始拒绝索引请求。
排查方法：检查线程池状态，查明索引拒绝是否总是在同一节点上发生，还是分布在所有节点上。
GET /_cat/thread_pool?v

如果 reject 仅发生在特定的数据节点上，那么您可能会遇到负载平衡或分片问题。
如果 reject 与高 CPU 利用率相关联，那么通常这是 JVM 垃圾回收的结果，而 JVM 垃圾回收又是由配置或查询相关问题引起的。
如果集群上有大量分片，则可能存在过度分片的问题。
如果观察到节点上的队列拒绝，但监控发现 CPU 未达到饱和，则磁盘写入速度可能存在问题。
```
