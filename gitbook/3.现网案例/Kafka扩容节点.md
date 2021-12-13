**原本节点：**0,1,2,3,4，共5个节点

**扩容后：**0,1,2,3,4,5，共6个节点



**注意：**扩容需要注意打通应用到扩容节点的网络权限，应用配置文件可以不用更改。应用只要连接到一个节点获取到元数据后，就可以获取到所有节点。



**1、新节点启动加入集群**

1.1、启动新扩容节点

1.2、查看启动kafka启动日志

1.3、查看机器新节点是否加入

\# /usr/local/kafka/bin/kafka-topics.sh --zookeeper IP:2181 --describe



**2、数据均衡**

2.1 找出大分区

2.2 规划迁移操作

将大分区迁移到新增节点，减少老节点磁盘容量压力。



2.3 准备expand-cluster-reassignment-action.json文件，并检查是否为json格式

\# cat expand-cluster-reassignment-action.json

{

  "version": 1,

  "partitions": [

​    {

​      "topic": "test-device",

​      "partition": 1,

​      "replicas": [

​        0,5

​      ],

​      "log_dirs": [

​        "any","any"

​      ]

​    },

​    {

​      "topic": "test-device",

​      "partition": 2,

​      "replicas": [

​        2, 5

​      ],

​      "log_dirs": [

​        "any", "any"

​      ]

​    }

  ]

}



\# jq . expand-cluster-reassignment-action.json



2.6 通过expand-cluster-reassignment-action.json执行迁移动作[限流30MB/s]

执行迁移操作

\# /usr/local/kafka/bin/kafka-reassign-partitions.sh --zookeeper  IP:2181 --reassignment-json-file expand-cluster-reassignment-action.json -throttle 30000000 --execute



2.7 查看动作

\# /usr/local/kafka/bin/kafka-reassign-partitions.sh --zookeeper  IP:2181 --reassignment-json-file expand-cluster-reassignment-action.json --verify



**3、验证**

3.1 使用kafkatools查看在线broker，或者zookeeper里面看

3.2 均衡验证

查看均衡情况

\# /usr/local/kafka/bin/kafka-reassign-partitions.sh --zookeeper  IP:2181 --reassignment-json-file expand-cluster-reassignment-action.json --verify



查看当前topic ISR列表，是否解除限流

\# /usr/local/kafka/bin/kafka-topics.sh --zookeeper IP:2181 --describe





**经验：**

（1）打开json文件可以知道是以分区为单位迁移的，比如迁移某个Topic的0号分区，那么就是把它的副本重新分布位置

（2）建议先迁移一个进行验证

（3）限速建议15M/s

（4）观察CPU、内存和磁盘

（5）需要提前迁移后磁盘的占用情况，评估磁盘是否够用

（6）先迁移到大分区到新节点（其实只建议迁移大的分区到新节点，不要轻易用脚本生产所有分区然后迁移）

（7）只迁有必要移动的分区，没有必要的不要迁，注意限速
