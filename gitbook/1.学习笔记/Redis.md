# Redis

#### 监控项

```yaml
进程状态
内存使用率
redis连接数超过90%
redis key的数量过多
从库复制发生中断
redis周期5分钟内驱逐数大于1
主从连接异常
CPU使用率
出口流量大于100M
```

#### redis启用密码认证

1. redis启用密码认证一定要requirepass和masterauth同时设置。
2. 如果主节点设置了requirepass登录验证，在主从切换，slave在和master做数据同步的时候首先需要发送一个ping的消息给主节点判断主节点是否存活，再监听主节点的端口是否联通，发送数据同步等都会用到master的登录密码，否则无法登录，log会出现响应的报错。也就是说slave的masterauth和master的requirepass是对应的，所以建议redis启用密码时将各个节点的masterauth和requirepass设置为相同的密码，降低运维成本。当然设置为不同也是可以的，注意slave节点masterauth和master节点requirepass的对应关系就行。
3. masterauth作用：主要是针对master对应的slave节点设置的，在slave节点数据同步的时候用到。
4. requirepass作用：对登录权限做限制，redis每个节点的requirepass可以是独立、不同的。
