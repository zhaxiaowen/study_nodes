# redis雪崩

#### 故障现象

1. zabbix发送服务探活失败告警，调用地图服务失败
2. 大量iowait告警，请求超时

#### 故障分析

1. 网络波动导致redis连接故障，出现缓存雪崩，请求直接落在Mysql,数据库服务器CPU负载突增，活跃线程暴增，出现大量慢查询



#### 故障处理



#### 优化改进

1. sql改造，提升Mysql性能
2. 
