# Cassandra

### 遇到的印象深刻的问题

1. 自以为不会影响到业务的案例

- 主机组:修改ntp时间同步的源,导致业务侧出发linux内核bug,主机重启,影响20+集群
- cassandra集群,磁盘坏盘后,做数据修复,出现大量压缩线程堆积,业务侧访问受影响

处理方法:1.提前告知业务,由业务侧决定是否做修复

 2.推动集群上云

1. 告警设置不合理:磁盘告警设为普通告警

云相册在做上云过程中,一次消息堆积,因为kafka经常会出现消息堆积问题,所以告警都是一般级别再加上刚好周末,一般告警大家通常都忽略

导致周一发现时,已堆积上亿条数据

1. CPU毛刺问题定位原因

1)问题现象:业务侧发现某台机器的CPU,每个小时都会从5%突增到17%,持续几分钟,恢复

2)定位过程:定位过程中,发现该集群每个节点,都有出现类似情况;发现是由于compaction压缩线程导致的CPU突高,查看该集群压缩堆积的监控信息,发现CPU变高的时间点与压缩堆积增加的时间点吻合

3)问题原因:压缩堆积导致

4)解决方案:无

5)优化建议:无

1. 音乐集群存量数据迁移到另一个集群:运维人员操作不当,导致现网数据丢失

1)问题现象:数据迁移过程中,停业务,dump,load数据时,发现由于数据中存在特殊字符,导致部分数据导入失败,换另一种copy方法执行,执行成功,但是由于业务侧已经恢复业务,导致部分数据丢失





3.同一集群的节点,使用了不同的cpu型号,性能不一致,导致CPU负载一部分在30%,一部分节点将近60%
