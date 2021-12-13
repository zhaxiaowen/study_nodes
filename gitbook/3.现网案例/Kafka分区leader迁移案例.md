# Kafka分区leader迁移案例

首先，写这篇文章的目的是为了帮助在kafka分区迁移leader可能遇到和我一样的问题的同学，同时也为了记录自己迁移遇到的问题。

​	我们所用的生产环境的kafka 版本为0.11.1，一开始只有7台机器作为集群，后来又加入了新的7台机器配置和原集群一样，新加集群是因为原来的7台机器的cpu到达了80%，这样总集群达到了14台。由于新加机器kafka不会自动平衡，需要自己进行分区leader的迁移。我们一开始选取了3种方案：

**一**、**降低数据保留时间，精准迁移** 

大致思路为：

1. 找出需要操作的Topic
2.  调整这些Topic的数据保留时间

1.  对这些Topic进行迁移
2. 等待迁移完成，完成Leader切换，均分集群压力。

**二、往指定节点上添加分区，均分压力**

大致思路为：

1. 找出需要操作的Topic
2. 评估这些Topic需要导多少流量到新节点。这一步比较好做，一般比如要把30%，50%的流量导入到新节点，大概评估一下即可。

1. 扩容目标Topic的分区数，将这些新增的分区指定扩容到新的节点上。

**三：切换Leader，降低单机负载**

大致思路为：

1. 找出负载高的节点上的所有Leader
2. 将节点上分区的Leader切换到负载较低的Follower节点上

​	最后，我们选用了第三种方法，原因是第一二种与业务沟通下来不可进行修改。接下来按照官方推荐的方法为：

1、执行kafka-reassign-partitions.sh --generate 生成迁移的json文件，这步我们没有进行操作，是因为有现成的api能自动生成执行 的json，就是因为这一步没有做，导致了我们生成的json与推荐的不一致，推荐的为：你指定--broker-list，那么他会把你topic分区都迁移到你指定的broker上，例如原来topic为3副本，partition-0的replica为{0,1,2}，指定broker-list为“4,5,6”，那么就会生成一个{4,5,6}的replica，而我们的api生成的副本为{4,1.2},就是随机选取一个新的brolerid放入第一个位置。保留原来的两个副本。

​	这么做的原因是因为：害怕把分区都移到新的上面，迁移的这段时间可能导致不能进行读写。然后就是执行kafka-reassign-partitions.sh --throttle --execute ，这一步又遇到了问题，因为内部之前自己封了一下kafka admin 的接口，可以通过页面直接进行执行kafka-reassign-partitions.sh --throttle --execute的命令，可能之前的人理解的不到位，只是执行了kafka-reassign-partitions.sh --throttle --execute 没有执行kafka-reassign-partitions.sh --verify 导致的问题就是当你执行命令：kafka-topics.sh --describe --zookeeper --topic xxx 你会发现除了自己修改的配置外，还会有两个配置在其中：leader.replication.throttled.replicas 与follower.replication.throttled.replicas，

​	正常情况下这两个配置默认是空的，执行的时候不会出现此配置，但是我们的确确实实出现了，这两项是leader与follower之间加了限速，那么就意味着不正常，可是跑了这么长时间了为啥没有出现流量的异常，我就很匪夷所思。通过查找zk所知：在分区leader与follower的限速上。一共有4条配置：

leader.replication.throttled.rate，follower.replication.throttled.rate，leader.replication.throttled.replicas

follower.replication.throttled.replicas，

​	其中前两条：leader.replication.throttled.rate，follower.replication.throttled.rate是加在broker上的，通过在zk中get /configs/brokers/{brokerid}所获得，后两条：leader.replication.throttled.replicas，follower.replication.throttled.replicas 是在topic上的配置，通过get /config/topics/{topicname}获得，上面说的流量没有异常的原因是：我在get /configs/brokers/{brokerid}后

leader.replication.throttled.rate，follower.replication.throttled.rate是空的，那么就没有此配置，也就是说broker侧的没有加上限速的配置，还是以默认的最大速率进行同步，topic侧显示了限速的副本，对应的配置：leader.replication.throttled.replicas，follower.replication.throttled.replicas

​	那么，通过执行命令：kafka-configs.sh --zookeeper xxx --entity-type topics --entity-name xxx --alter --delete-config follower.replication.throttled.replicas, leader.replication.throttled.replicas 把topic配置删除，实现配置的还原。

​	最后，如果有同学需要进行副本的迁移，那么一定要运行--verfy命令当出现：Throttle was removed.才证明完成了限速也解除了，leader的迁移时，原来的leader是能进行读写的，所以不需要像我一样还放两个副本在旧机器上
