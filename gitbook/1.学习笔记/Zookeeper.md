# Zookeeper

### 常用查询指令

```yaml
./bin/zkCli.sh
#查询
ls
ls /openlogs
ls /openlogs/brokers 

#获取对应存储的值
get /openlogs/brokers 
```

#### 

```yaml
cZxid：创建该节点的zxid
ctime：该节点的创建时间
mZxid：该节点的最后修改zxid
mtime：该节点的最后修改时间
pZxid：该节点的最后子节点修改zxid
cversion：该节点的子节点变更次数
dataVersion：该节点数据被修改的次数
aclVersion：该节点的ACL变更次数
aphemeraOwner：临时节点所有者会话id，非临时的为0
dataLength：该节点数据长度
numChildren：子节点数
```

### kafka数据在zookeeper中的存储结构讲解

https://articles.zsxq.com/id_4ifi11a9hk2e.html

