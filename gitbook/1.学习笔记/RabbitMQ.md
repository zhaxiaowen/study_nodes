# RabbitMQ

#### 常用指令

```yaml
rabbitmqctl list_connections: 连接状态查询
rabbitmqctl status: Broker状态查询
rabbitmqctl list_consumers: 查看消费者
rabbitmqctl list_queues: 查询队列
rabbitmq-plugins list:查看插件
rabbitmqctl cluster_status:查看集群节点
```

#### 监控项

```yaml
1.磁盘使用率
2.内存使用率
3.进程down
4.rabbitmq连接数
5.消息积压大于1W
6.rabbitmq节点打开文件描述符数量大于70%
```



### RocketMQ

```
#查看cluster信息
mqadmin clusterList -n 172.17.200.146:9876

#创建topic
mqadmin updateTopic -c wsWangYueChe-dev3-rocketmq01 -r 4 -w 4 -n 172.17.200.146:9876 -t wangyueche-oalog-inner
```

