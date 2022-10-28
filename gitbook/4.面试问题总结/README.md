# 

1. [redis原理及问题,JAVA,HTTP,中间件相关问题](https://blog.csdn.net/xiaofeng10330111/category_8448193.html)
2. TCP/IP:小林code网络篇
3. [kafka:石臻臻杂货铺](https://www.szzdzhp.com/kafka/)
4. [k8s](https://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247514668&idx=1&sn=26e13d69f4011de314633aabef955fce&chksm=e918df30de6f56265e5b6b716d7b79f72c52fb940d5114bbe7e261c1a4c026309de006d908c4&scene=178&cur_album_id=1790435592028160001#rd)
5. [web运维](https://www.it610.com/article/1445576746060525568.htm)
6. 高并发
6. [lvs](https://www.cnblogs.com/skychen1218/p/13327965.html)
6. [es1](https://www.cnblogs.com/kevingrace/p/6298022.html)
6. [es2](https://www.cnblogs.com/kevingrace/p/10682264.html)



### SRE

* 如何保证服务稳定性

* 如何做好容量规划

  > 容量规划是以当前的性能作为基线,来决定你需要什么及什么时候需要
  >
  > 单台服务器的最大QPS,集群的QPS,需要扩容吗?扩多少?

  * 收集指标:通过测试了解当前服务的数据指标,QPS,时延等
  * 明确目标:对外承诺的服务质量,比如说3000QPS,响应时间小于200ms
  * 趋势预测:根据历史数据,判断未来的业务增长速率,是否会达到集群的瓶颈,提前做好准备

* 如何定位问题

* 系统设计

  * 高可用性:多副本,弹性扩缩容
  * 能承受并发量:比如单台的QPS,可以从容量规划方面说

### 个人相关

* 职业规划
* 离职原因

### 生产相关

* 公司架构
* 遇到过的生产故障

### 你有什么问题

* 岗位的职责,日常工作内容是什么（即日常做哪些工作，协调沟通方面以及要面对的问题）

* 业务目前部署在哪里,自建机房,还是腾讯云这种,后续有切k8s的计划吗?

* 如何处理技术负债（技术负债这件事，如果能积极面对和解决，对个人和企业的提升都是有很大帮助的，但如果不重视这件事，那么工作的推进是比较心累的）？

* 作为领导,你更希望手下的组员,在工作态度或技能方面,有哪些需求

* 

* 版本发布流程,是否有灰度,A/B等;是否严格按发版流程执行(判断流程是否全面合理清晰,避免流程混乱带来的很多问题)

* 新业务的上线,运维是在哪个环节开始参与的
  * 需求评审阶段就介入,还是在准备上线时介入
  
* 一些重要系统的变更,是否有评审环节

* 是否有在职培训、技术经验业务分享等（职级晋升、快速融入、个人的非物质收益等）？

  

### 系统相关

- uptime命令中load average字段后的3个数字代表什么？如何判断系统整体负载的高低？
  - 一分钟内,五分钟内,十五分钟内的系统平均负载;
  - load 是一定时间内计算机有多少个活跃任务,也就是说是计算机的任务执行队列的长度,cpu计算的队列,所以一般认为CPU核数的就是load值的上线。
- 如何查看某个进程的CPU、内存和负载情况？
  - 通常我们使用top命令去交互查看系统负载信息。
- free命令中shared  buff/cache  available 这3个字段是什么意思？
  - shared 多进程使用的共享内存;
  - buff/cache 读写缓存内存,这部分内存是当空闲来用的,当free内存不足时,linux内核会将此内存释放;
  - available 是可以被程序所使用的物理内存;
- 描述下在linux中给一个文件授予 644权限是什么意思？
  - 644 即〔当前用户读和写权限,〔群组用户〕读权限,〔其它〕读权限。
- linux中如何禁止一个用户通过shell登录？
  - 使用命令或者通过修改/etc/passwd文件的用户shell部分为/sbin/nologin 即可实现。
- 如何观察当前系统的网络使用情况？
  - 使用iftop等工具。
- 如何追踪A主机到B主机过程中的丢包情况？
  - traceroute、mtr, 或者其他双端带宽测试工具。
- linux 系统中ID为0是什么用户？
  - root
- 怎么统计当前系统中的活跃连接数？
  - netstat -na|grep ESTABLISHED|wc -l
- time_wait 状态处于TCP连接中的那个位置？
  - 客户端发出FIN请求服务端断连, 服务器未发送ack+fin确认。

#### 问题

| 浏览器输入一个url到整个页面显示出来经历了哪些过程？ | https://blog.csdn.net/weixin_34348174/article/details/93722583 |
| --------------------------------------------------- | ------------------------------------------------------------ |
| 死锁产生的原因及解决方法                            | https://zhuanlan.zhihu.com/p/108169678                       |
| 线程和进程的区别是什么？                            | https://www.zhihu.com/question/25532384                      |
| 内存管理:虚拟内存的优点                             | 小林code                                                     |

### k8s

#### 容器和主机部署的区别--(待完善)

* 容器

#### k8s有哪些组件,具体的功能是什么

* master节点
  * kubectl:客户端命令行工具,整个k8s集群的操作入口
  * api server:资源操作的唯一入口,提供认证、授权、访问控制、API注册和发现等机制
  * controller manager:负责维护集群的状态,故障检测、自动扩展、滚动更新
  * scheduler:负责资源的调度,按照预定的调度策略将pod调度到响应的node节点上
  * etcd:担任数据中心,保存了整个群集的状态
* node节点:
  * kubelet:负责维护pod的生命周期,同时也负责Volume和网络的管理,运行在所有的节点上,当scheduler确定某个node上运行pod后,将pod的具体信息发送给节点的kubelet,kubelet根据信息创建和运行容器,并向master返回运行状态;容器状态不对时,kubelet会杀死pod,重新创建pod
  * kube-proxy:运行在所有节点上,为service提供cluster内部的服务发现和负载均衡(外界服务,service接收到请求后就是通过kube-proxy来转发到pod上的)
  * container-runtime:负责管理运行容器的软件
  * pod:集群里最小的单位,每个pod里面可以运行一个或多个container

#### 镜像下载策略

* Always:镜像标签为latest时,总是从指定的仓库中获取镜像
* Never:禁止从仓库下载镜像,只能使用本地已有的镜像
* IfNotPresent:仅本地没有对应镜像时,才下载
* 默认的镜像策略:当镜像标签是latest时,默认策略是Always;当镜像标签是自定义时,默认策略是IfNotPresent

#### pod有哪些状态

* pending:处在这个状态的pod可能正在写etcd,调度或者pull镜像或者启动容器
* running
* succeeded:所有的容器已经正常的执行后退出,并且不会重启
* failed:至少有一个容器因为失败而终止,返回状态码非0
* unknown:api server无法正常获取pod状态信息,可能是无法与pod所在的工作节点的kubelet通信导致的

#### pod的创建过程

* 客户端提交pod的配置信息给kube-apiserver
* apiserver收到指令后,通知controller-manager创建一个资源对象
* controller-manager通过api-server将pod的配置信息存储到etcd
* kube-secheduler检测到pod信息会开始调度预选,先过滤掉不符合pod资源需求的node,然后开始调度调优,然后将pod的资源配置发送给node的kubelet
* kubelet根据scheduler发来的资源配置创建pod,pod创建成功后,将pod的运行信息返回给scheduler,scheduler将返回的pod状态信息存储到etcd

#### 删除pod的过程 --(还是有点不清晰)

* kube-apiserver接收到client的删除指令,默认有30s时间等待优雅退出,超过30s被标记为死亡状态,此时pod状态为Terminating,kubelet看到pod标记为Terminating就开始关闭pod的工作,流程如下:
  * pod从service的endpoint列表中被移除
  * 如果pod定义了停止前的钩子,钩子会在pod内部被调用,停止钩子一般定义了如何优雅结束进程
  * 进程被发送TERM信号(kill -14)
  * 当超过优雅退出时间后,Pod中的所有进程会被发送SIGKILL信号(kill -9)

#### pod的重启策略

* Always:容器失效时,kubelet自动重启容器
* OnFailure:容器终止运行,且退出码不为0时重启
* Nerver:永不重启
  * 不同控制器的重启策略限制如下:
    * RC和DaemonSet:必须设置为Aalways,需要保证容器持续运行
    * Job:OnFailure或Never:确保容器执行完后不再重启

#### Service是什么 

* pod每次重启,其IP地址都会变化,这使得pod间通信,或者外部通信变得困难,service提供一个访问pod的固定入口
* service的endpoint绑定了一组相同配置的pod,通过负载均衡的方式把请求分配到不同的pod上

#### Service负载均衡策略

* RoundRobin:默认轮训模式
* SessionAffinity:基于客户端ip地址进行会话保持

#### Ingress --(待完善)

* ingress和ingress controller结合实现了一个完整的ingress负载均衡器
* ingress controller基于ingress规则将客户端请求直接转发到service对应的后端endpoint上,从而跳过了kube-proxy的转发功能
* ingress controller+ingress规则--->service

#### k8s是怎么进行注册的 --(待完善)

* pod启动后会加载当前环境所有service的信息,以便不通pod根据service名进行通信

#### k8s集群外流量怎么访问pod --(待完善)

* NodePort:会在所有节点上监听同一个端口,比如30000,访问节点的流量都会被重定向到对应的service上

#### 健康检查--资源探针:

* LivenessProbe:存活探针,失败的话杀掉pod,并根据容器的重启策略做出相应的处理

* ReadinessProbe:可读性探针,ready检测,失败的话从service的endpoint列表中删除pod的ip

* startupProbe:为了防止服务因初始化时间较长,被上面2种探针kill调,用来定义初始化时间的

* 设置控制时间

  * initialDelaySeconds:初始第一次探测间隔时间,防止应用还没起来就被健康检查失败
  * periodSeconds:检查间隔,多久执行probe检查,默认10s
  * timeoutSeconds:检查超时时间,探测应用timeout后为失败
  * successThreshold:成功探测阈值,默认探测一次为健康正常

* 探测方法

  * ExecAction:在容器中执行一条命令,状态码为0则健康

  * TcpSocketAction:与容器的某个pod建立连接

  * HttpGetAction:通过向容器IP地址的某个指定端口的指定path发送GET请求,响应码为2xx或3xx即健康

* 探测结果:
  * Success:服务正常
  * Failure:探测到服务不正常
  * Unknown:通常是没有定义探针检测,默认成功

#### RBAC:

* role定义在一个namespace中,clusterrole可以跨namespace
* rolebinding适用于某个namespace授权;clusterrolebinding适用于集群范围的授权

#### 更新策略

* Recreate Deployment:在创建出新的pod前杀掉所有已存在的pod

* Rolling Update Deployment:

  * MaxSurge:用来指定升级过程中可以超过期望pod数量的最大个数,可以是一个绝对值(5),或者Pod数量的百分比(10%),默认值是1;启动更新时,会立即扩容10%,待新Pod ready后,旧的pod缩容

  * MaxUnavailable:指定升级过程中不可用Pod的最大数量,可以是一个绝对值(5),或者Pod数量的百分比(10%),计算百分比的绝对值向下取整,为0时,默认为1;启动更新时,会先缩容到90%,新的Pod ready后,旧的副本再缩容,确保在升级时所有时刻可以用的Pod数量至少是90%

#### kube-proxy iptables原理

* iptables模式下的kube-proxy不再起到Proxy的作用,作用是:通过API Server的Watch接口实时跟踪Service与Endpoint的变更信息,并更新到iptalbes规则,Client的请求流量通过iptables的NAT机制"直接路由"到目标pod

#### kube-proxy ipvs原理

* IPVS用于高性能负载均衡,使用更高效的Hash表,允许几乎无限的规模扩张,被kube-proxy采纳为最新模式
* IPVS使用iptables的扩展ipset,而不是直接调用iptables来生产规则链,iptable规则链是一个线性的数据结构,ipset是带索引的数据结构,因此当规则多时,可以高效的查找和匹配
* 

#### ipvs为啥比iptables效率高

* IPVS和iptables同样基于Netfilter
* IPVS采用hash表;iptables采用一条条的规则列表
* iptables又是为防火墙设计的,集群数量越多,iptables规则就越多,而iptables的规则是从上到下匹配的,所以效率就越低
* 因此当service数量达到一定规模时,hash表的速度优势就显现出来了,从而提高了service的服务性能
* 优势:
  * 为大集群提供了更好的可扩展性和性能
  * 支持比iptables更复杂的负载均衡算法(最小负载,最少连接,加权等)
  * 支持服务器健康检查和连接重试等功能
  * 可以统统修改ipset的集合

#### storageclass,pv,pvc

* PVC:定义一个持久化属性,比如存储的大小,读写权限等
* PV:具体的Volume
* storageclass:充当PV的模板,不用再手动创建PV了
* 流程:pod-->pvc-->storageclass(provisioner)-->pv,pvc绑定pv

#### nginx ingress的原理本质是什么*(原理还不知道)*

* ingress controller通过和api server交互,动态的去感知集群中ingress规则变化
* 然后按照自定义的规则,生成一段nginx配置
* 再写到nginx-ingress-controller的pod里,这个pod里运行着一个nginx服务,控制器会把生成的nginx配置写入/etc/nginx.conf中
* 然后reload一下使配置生效,以此达到域名分配和动态更新的问题

#### 不同node上的pod之间的通信流程*--(待完善)*

* 

#### Scheduler

* 调度算法
  * 预选:输入所有节点,输出满足预选条件的节点,过滤掉不符合的node.节点的资源不足或者不满足预选策略则无法通过预选
  * 优选:根据优先策略为通过预选的Node进行打分排名,选择得分最高的Node:例如:资源越服务员,负载越小的node可能具有越高的排名

#### k8s集群节点需要关机维护,怎么操作

* pod驱逐:kubectl drain <node_name>
* 确认node上已无pod,并且被驱逐的pod已经正常运行在其他node上
* 关机维护
* 维护完成开机
* 解除node节点不可调度:kubectl uncordon node
* 使用节点标签测试node是否可以被正常调度

#### calico和flannel的区别--(待完善)

* flannel:简单,使用居多,基于Vxlan技术(叠加网络+二层隧道),不支持网络策略
* Calico:较复杂,使用率低于flannel:也可以支持隧道网络,但是是三层隧道(IPIP),支持网络策略
* Calico项目既能够独立的为k8s集群提供网络解决方案和网络策略,也能与flannel结合在一起,由flannel提供网络解决方案,而calico仅用于提供网络策略



#### 常用的标签分类

* 版本类标签（release）：stable（稳定版）、canary（[金丝雀](https://www.zhihu.com/search?q=金丝雀&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A2307372651})版本，可以将其称之为测试版中的测试版）、beta（测试版）；
* 环境类标签（environment）：dev（开发）、qa（测试）、production（生产）、op（运维）；
* 应用类（app）：ui、as、pc、sc；
* 架构类（tier）：frontend（前端）、backend（后端）、cache（缓存）；
* 分区标签（partition）：customerA（客户A）、customerB（客户B）；
* 品控级别（Track）：daily（每天）、weekly（每周）。

#### k8s数据持久化

* EmptyDir:yaml没有指定要挂载宿主机的哪个目录,直接由pod内部映射到宿主机上.同个pod里的不同contianer共享同一个持久化目录,
* HostPath:将宿主机的目录挂载到容器内部,增加了pod与节点的耦合度
* PV

#### k8s的RC机制

* replication controller用来管理Pod的副本,保证集群中存在指定数量的pod,当定义了RC后,master节点上的controller manager组件会巡检系统中存活的目标pod,并确保pod数量与期望的RC值一致
* Replica set和replication controller类似,都是指定pod的副本数;不同在于RS使用基于集合的选择器,replication cotroller是基于权限的选择器
