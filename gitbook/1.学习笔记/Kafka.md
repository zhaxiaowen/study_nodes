# Kafka

### [kafka概念](https://mp.weixin.qq.com/s/NreJPGiO5NlUBkEdpqHWDA)

### 消费者

##### 提交方式

1. 自动提交:将enable.auto.commit设置为true,消费者在poll调用后每隔5s提交一次位移.可能会导致重复消费
2. 异步提交:如果服务器返回提交失败,异步提交不会进行重试

##### 消费者拦截器

发送端同时发送2条消息,其中一条超时,只收到未超时的消息

##### 消费者参数

fetch.min.bytes:指定了消费者读取的最小数据量

fetch.matx.wait.ms:指定了消费者读取时最长等待时间,避免长时间阻塞,默认500ms

### 分区

由于消息是以追加到分区中的，多个分区顺序写磁盘的总效率要比随机写内存还要高,，是Kafka高吞吐率的重要保证之一。

##### 副本机制

Producer和Consumer都只会与Leader角色的分区副本相连

增加分区数可以提高kafka集群的吞吐量,但是集群的总分区数或单台服务器的分区数过多,会增加不可用及延迟的风险

分区leader选举:zookeeper针对每个topic维护一个ISR集合,只有在这个ISR列表李的,才有资格成为leader

##### 分配策略

- **RangeAssignor分配策略:**将消费组内所有订阅这个topic的消费者按照名称的字典序排序，然后为每个消费者划分固定的分区范围，如果不够平均分配，那么字典序靠前的消费者会被多分配一个分区
- **RoundRobinAssignor分配策略**:是将消费组内所有消费者以及消费者所订阅的所有topic的partition按照字典序排序，然后通过轮询方式逐个将分区以此分配给每个消费者

- **StickyAssignor分配策略:**分区的分配要尽可能的均匀； 分区的分配尽可能的与上次分配的保持相同

### 存储

- 每个partition的文件,被分成多个segment(最大1G)文件
- segment file:有index file(索引文件)和data file(数据文件)

- segment file命名规则:partition全局的第一个segment从0开始,每一个segment文件名称为上一个segment文件最后一条消息的offset值;数值最大为64为long大小,19位数字字符长度,没有数字用0填充
- 数据文件以该段中最小的offset命名,在查找指定offset的message时,用二分查找就可以快速定位

- 偏移量索引:为了提高查询效率,kafka为每个分段后的数据文件建立了索引文件,文件名与数据文件的名称相同,只是文件扩展名为.index



数据查询流程:查找绝对offset为7的 message

1. 用二分查找确定它在哪个logsegment中2
2. 打开这个segment的index文件,用二分查找找到offset小于或等于指定offset的索引条目中最大的那个offset

1. 再通过索引文件知道offset为6的message在数据文件中的位置为多少

一句话，Kafka的Message存储采用了分区(partition)，分段(LogSegment)和稀疏索引这几个手段来达到了高效性。



### Kafka配置文件说明

#### **Server.properties配置文件说明**：

```yaml
#broker的全局唯一编号，不能重复
broker.id=0

#用来监听链接的端口，producer或consumer将在此端口建立连接
port=9092

#处理网络请求的线程数量
num.network.threads=3

#用来处理磁盘IO的线程数量
num.io.threads=8

#发送套接字的缓冲区大小
socket.send.buffer.bytes=102400

#接受套接字的缓冲区大小
socket.receive.buffer.bytes=102400

#请求套接字的缓冲区大小
socket.request.max.bytes=104857600

#kafka运行日志存放的路径
log.dirs=/export/data/kafka/

#topic在当前broker上的分片个数
num.partitions=2

#用来恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1

#segment文件保留的最长时间，超时将被删除
log.retention.hours=168

#滚动生成新的segment文件的最大时间
log.roll.hours=1

#日志文件中每个segment的大小，默认为1G
log.segment.bytes=1073741824

#周期性检查文件大小的时间
log.retention.check.interval.ms=300000

#日志清理是否打开
log.cleaner.enable=true

#broker需要使用zookeeper保存meta数据
zookeeper.connect=zk01:2181,zk02:2181,zk03:2181

#zookeeper链接超时时间
zookeeper.connection.timeout.ms=6000

#partion buffer中，消息的条数达到阈值，将触发flush到磁盘
log.flush.interval.messages=10000

#消息buffer的时间，达到阈值，将触发flush到磁盘
log.flush.interval.ms=3000

#删除topic需要server.properties中设置delete.topic.enable=true否则只是标记删除
delete.topic.enable=true

#此处的host.name为本机IP(重要),如果不改,则客户端会抛出:Producer connection to localhost:9092 unsuccessful 错误!
host.name=kafka01

advertised.host.name=192.168.140.128

producer生产者配置文件说明
#指定kafka节点列表，用于获取metadata，不必全部指定
metadata.broker.list=node01:9092,node02:9092,node03:9092
# 指定分区处理类。默认kafka.producer.DefaultPartitioner，表通过key哈希到对应分区
#partitioner.class=kafka.producer.DefaultPartitioner
# 是否压缩，默认0表示不压缩，1表示用gzip压缩，2表示用snappy压缩。压缩后消息中会有头来指明消息压缩类型，故在消费者端消息解压是透明的无需指定。
compression.codec=none
# 指定序列化处理类
serializer.class=kafka.serializer.DefaultEncoder
# 如果要压缩消息，这里指定哪些topic要压缩消息，默认empty，表示不压缩。
#compressed.topics=

# 设置发送数据是否需要服务端的反馈,有三个值0,1,-1
# 0: producer不会等待broker发送ack 
# 1: 当leader接收到消息之后发送ack 
# -1: 当所有的follower都同步消息成功后发送ack. 
request.required.acks=0 

# 在向producer发送ack之前,broker允许等待的最大时间 ，如果超时,broker将会向producer发送一个error ACK.意味着上一次消息因为某种原因未能成功(比如follower未能同步成功) 
request.timeout.ms=10000

# 同步还是异步发送消息，默认“sync”表同步，"async"表异步。异步可以提高发送吞吐量,
也意味着消息将会在本地buffer中,并适时批量发送，但是也可能导致丢失未发送过去的消息
producer.type=sync

# 在async模式下,当message被缓存的时间超过此值后,将会批量发送给broker,默认为5000ms
# 此值和batch.num.messages协同工作.
queue.buffering.max.ms = 5000

# 在async模式下,producer端允许buffer的最大消息量
# 无论如何,producer都无法尽快的将消息发送给broker,从而导致消息在producer端大量沉积
# 此时,如果消息的条数达到阀值,将会导致producer端阻塞或者消息被抛弃，默认为10000
queue.buffering.max.messages=20000

# 如果是异步，指定每次批量发送数据量，默认为200
batch.num.messages=500

# 当消息在producer端沉积的条数达到"queue.buffering.max.meesages"后 
# 阻塞一定时间后,队列仍然没有enqueue(producer仍然没有发送出任何消息) 
# 此时producer可以继续阻塞或者将消息抛弃,此timeout值用于控制"阻塞"的时间 
# -1: 无阻塞超时限制,消息不会被抛弃 
# 0:立即清空队列,消息被抛弃 
queue.enqueue.timeout.ms=-1


# 当producer接收到error ACK,或者没有接收到ACK时,允许消息重发的次数 
# 因为broker并没有完整的机制来避免消息重复,所以当网络异常时(比如ACK丢失) 
# 有可能导致broker接收到重复的消息,默认值为3.
message.send.max.retries=3

# producer刷新topic metada的时间间隔,producer需要知道partition leader的位置,以及当前topic的情况 
# 因此producer需要一个机制来获取最新的metadata,当producer遇到特定错误时,将会立即刷新 
# (比如topic失效,partition丢失,leader失效等),此外也可以通过此参数来配置额外的刷新机制，默认值600000 
topic.metadata.refresh.interval.ms=60000
```

#### **consumer消费者配置详细说明**:

```yaml
# zookeeper连接服务器地址
zookeeper.connect=zk01:2181,zk02:2181,zk03:2181
# zookeeper的session过期时间，默认5000ms，用于检测消费者是否挂掉
zookeeper.session.timeout.ms=5000
#当消费者挂掉，其他消费者要等该指定时间才能检查到并且触发重新负载均衡
zookeeper.connection.timeout.ms=10000
# 指定多久消费者更新offset到zookeeper中。注意offset更新时基于time而不是每次获得的消息。一旦在更新zookeeper发生异常并重启，将可能拿到已拿到过的消息
zookeeper.sync.time.ms=2000
#指定消费 
group.id=itcast
# 当consumer消费一定量的消息之后,将会自动向zookeeper提交offset信息 
# 注意offset信息并不是每消费一次消息就向zk提交一次,而是现在本地保存(内存),并定期提交,默认为true
auto.commit.enable=true
# 自动更新时间。默认60 * 1000
auto.commit.interval.ms=1000
# 当前consumer的标识,可以设定,也可以有系统生成,主要用来跟踪消息消费情况,便于观察
conusmer.id=xxx 
# 消费者客户端编号，用于区分不同客户端，默认客户端程序自动产生
client.id=xxxx
# 最大取多少块缓存到消费者(默认10)
queued.max.message.chunks=50
# 当有新的consumer加入到group时,将会reblance,此后将会有partitions的消费端迁移到新  的consumer上,如果一个consumer获得了某个partition的消费权限,那么它将会向zk注册 "Partition Owner registry"节点信息,但是有可能此时旧的consumer尚没有释放此节点, 此值用于控制,注册节点的重试次数. 
rebalance.max.retries=5

# 获取消息的最大尺寸,broker不会像consumer输出大于此值的消息chunk 每次feth将得到多条消息,此值为总大小,提升此值,将会消耗更多的consumer端内存
fetch.min.bytes=6553600

# 当消息的尺寸不足时,server阻塞的时间,如果超时,消息将立即发送给consumer
fetch.wait.max.ms=5000
socket.receive.buffer.bytes=655360
# 如果zookeeper没有offset值或offset值超出范围。那么就给个初始的offset。有smallest、largest、anything可选，分别表示给当前最小的offset、当前最大的offset、抛异常。默认largest
auto.offset.reset=smallest
# 指定序列化处理类
derializer.class=kafka.serializer.DefaultDecoder
```

### 生产者属性

#### bootstrap.servers

```yaml
指定broker的地址
```

#### acks

```yaml
生产者数据发送出去，需要服务端返回一个确认码，即ack响应码；ack的响应有三个状态值0,1，-1
acks=0:消息发送出去,就默认成功
acks=1:只要集群leader节点收到消息,生产者就会收到一个来自服务器的响应
acks=all:只有当所有参与复制的节点全收到消息,生产者才会接收到成功的响应
```

#### buffer.memory

```yaml
设置生产者内存缓冲区大小
```

#### compression.type

```yaml
压缩消息;默认发送的消息不压缩,如果需要,可以配置该参数,有snappy,gzip,lz4
```

#### retries

```yaml
发生错误后,重试次数;如果超过设定值,生产者就会放弃重试并返回错误
```

#### batch.size

```yaml
当有多个消息需要被发送到同一个分区时，生产者会把它们放在同一个批次里。该参数指定一个批次可以使用的内存大小,按字节数算;16384
```

#### linger.ms

```yaml
该参数指定了生产者在发送批次之前等待更多消息加入批次的时间
```

#### client.id

```yaml
客户端id,服务器用来识别消息的来源
```

####  max.in.flight.requests.per.connection  

```yaml
指定了生产者在收到服务器响应之前可以发送多少个消息。它的值越高，就会占用越多的内存，不过也
会提升吞吐量，把它设置为 1 可以保证消息是按照发送的顺序写入服务器，即使发生了重试。
```

####  timeout.ms, request.timeout.ms & metadata.fetch.timeout.ms  

```yaml
timeout.ms 指定了 borker 等待同步副本返回消息的确认时间；
request.timeout.ms 指定了生产者在发送数据时等待服务器返回响应的时间；
metadata.fetch.timeout.ms 指定了生产者在获取元数据（比如分区首领是谁）时等待服务器返回响应的时间。
```

#### max.block.ms

```yaml
当生产者的发送缓冲区已满，或者没有可用的元数据时，这些方法会阻塞。在阻塞时间达到 max.block.ms时，生产者会抛出超时异常。
```

#### max.request.size

```yaml
该参数用于控制生产者发送的请求大小。它可以指发送的单个消息的最大值，也可以指单个请求里所有消息总的大小。
```

####  receive.buffer.bytes & send.buffer.byte  

```yaml
分别指定 TCP socket 接收和发送数据包缓冲区的大小，-1 代表使用操作系统的默认值。
```

####  key.deserializer  &&  value.deserializer  

```yaml
指定键的反序列化器和值的反序列化器
```

### 消费者属性

#### enable.auto.commit

```yaml
设置offset提交方式,true自动,false手动
手动提交偏移量:
1)手动提交当前偏移量:即手动提交当前轮询的最大偏移量
2)手动提交固定偏移量:即按照业务需求,提交某一个固定的偏移量
3)手动提交又分为同步提交和异步提交
```

####  auto.commit.interval.ms  

```yaml
设置提交间隔,默认5s
```

#### fetch.min.byte

```yaml
消费者读取记录的最小字节数.如果小于该值,broker会等待有足够的数据时,才会把它返回给消费者
```

#### fetch.max.wait.ms

```yaml
broker返回给消费者数据的等待时间,默认500ms
```

#### max.partition.fetch.bytes

```yaml
指定了服务器从每个分区返回给消费者的最大字节数,默认1M
```

#### session.timeout.ms

```yaml
消费者在被认为死亡之前可以与服务器断开连接的时间，默认是 3s。
```

#### auto.offset.reset

```yaml
该属性指定了消费者在读取一个没有偏移量的分区或者偏移量无效的情况下该作何处理：
1)latest(默认值):从最新的记录开始消费
2)erliest:从起始位置消费
```

#### max.poll.records

```yaml
单次调用poll()方法能够返回的记录数量
```

#### broker.rack

```yaml
为broker指定机架信息,会尽可能把每个分区的副本分配到不同机架的broker上
```

![es_kafka生产配置](.\picture\es_kafka生产配置.jpg)

### zookeeper在kafka中的作用

```
一、概述
Apache Kafka是一个使用Zookeeper构建的分布式系统。Zookeeper的主要作用是在集群中的不同节点之间建立协调；如果任何节点失败，我们还使用Zookeeper从先前提交的偏移量中恢复，因为它做周期性提交偏移量工作。

二、详解
2.1 ZooKeeper作用之：Broker注册
Broker是分布式部署并且相互之间相互独立，但是需要有一个注册系统能够将整个集群中的Broker管理起来，此时就使用到了Zookeeper。在Zookeeper上会有一个专门用来进行Broker服务器列表记录的节点。

2.2 ZooKeeper作用之：Topic注册
在Kafka中，同一个Topic的消息会被分成多个分区并将其分布在多个Broker上，这些分区信息及与Broker的对应关系也都是由Zookeeper在维护，由专门的节点来记录。

2.3 ZooKeeper作用之：生产者负载均衡
由于同一个Topic消息会被分区并将其分布在多个Broker上，因此，生产者需要将消息合理地发送到这些分布式的Broker上，那么如何实现生产者的负载均衡，Kafka支持传统的四层负载均衡，也支持Zookeeper方式实现负载均衡。

2.4 ZooKeeper作用之：消费者负载均衡
与生产者类似，Kafka中的消费者同样需要进行负载均衡来实现多个消费者合理地从对应的Broker服务器上接收消息，每个消费者分组包含若干消费者，每条消息都只会发送给分组中的一个消费者，不同的消费者分组消费自己特定的Topic下面的消息，互不干扰。

2.5 ZooKeeper作用之：分区与消费者的关系
消费组（Consumer Group）：consumer group下有多个Consumer（消费者），对于每个消费者组 （Consumer Group），Kafka都会为其分配一个全局唯一的Group ID，Group 内部的所有消费者共享该 ID。 订阅的topic下的每个分区只能分配给某个 group 下的一个consumer（当然该分区还可以被分配给其他group）。 同时，Kafka为每个消费者分配一个Consumer ID，通常采用"Hostname:UUID"形式表示。

在Kafka中，规定了每个消息分区 只能被同组的一个消费者进行消费，因此，需要在 Zookeeper 上记录 消息分区 与 Consumer 之间的关系，每个消费者一旦确定了对一个消息分区的消费权力，需要将其Consumer ID 写入到 Zookeeper 对应消息分区的临时节点上。

2.6 ZooKeeper作用之：消费进度Offset记录
在消费者对指定消息分区进行消息消费的过程中，需要定时地将分区消息的消费进度Offset记录到Zookeeper上，以便在该消费者进行重启或者其他消费者重新接管该消息分区的消息消费后，能够从之前的进度开始继续进行消息消费。Offset在Zookeeper中由一个专门节点进行记录。节点内容是Offset的值。

2.7 ZooKeeper作用之：消费者注册
每个消费者服务器启动时，都会到Zookeeper的指定节点下创建一个属于自己的消费者节点。

早期版本的Kafka用zk做meta信息存储，consumer的消费状态，group的管理以及offset的值。考虑到zk本身的一些因素以及整个架构较大概率存在单点问题，新版本中确实逐渐弱化了zookeeper的作用。新的consumer使用了kafka内部的group coordination协议，也减少了对zookeeper的依赖。

来源：http://www.mianshitiba.com/kafka/77.html
```

