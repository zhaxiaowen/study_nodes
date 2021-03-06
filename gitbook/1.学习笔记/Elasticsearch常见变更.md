# Elasticsearch常见变更

#### 升配

https://cloud.tencent.com/developer/article/1763280

#### 降配

https://cloud.tencent.com/developer/article/1789802



#### reindex



#### 数据迁移

| 迁移方式           | 适用场景                                                     | 缺点                                                         | 优点                                                         |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| COS 快照           | 数据量大的场景（GB、TB、PB 级别）<br />对迁移速度要求较高的场景 | 群维护力度大，每个节点需要配置通信证书，多个集群需配置同一证书，加节点需要全部更新证书； | 索引维护力度小，跨集群索引自动同步，不用手动新增结构等；<br />操纵上手简单，kibana后台直接配置维护，通俗易懂；<br />实时性同步，增删改都能自动实时性实现同步；<br />提供设置整个索引生命周期的功能； |
| logstash           | 迁移全量或增量数据，且对实时性要求不高的场景<br />需要对迁移的数据通过 es query 进行简单的过滤的场景<br />需要对迁移的数据进行复杂的过滤或处理的场景<br />版本跨度较大的数据迁移场景，如 5.x 版本迁移到 6.x 版本或 7.x 版本 | 不能实现实时性同步，有一分钟的延迟时间；<br />不能实现数据删除的同步，但是业务上不涉及数据的删除；<br />需要在从集群手动新增索引结构，不能自动；<br />需要监测索引版本变更和手动切换索引别名； | 变更影响小，原集群可不做任何变动，不用升级集群和索引；<br />变更风险小，不用停服，不用更新应用的配置； |
| elasticsearch-dump | 数据量较小的场景                                             |                                                              |                                                              |



#### 索引扩分片



#### 集群拆分



#### 冷热分离





