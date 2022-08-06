# k8s 

#### k8s中的资源对象

* apiVersion:创建该对象所使用的kubernetes API版本
* kind:想要创建的对象类型
* metadata:帮助识别对象唯一性的数据,包括`name` `UID` `namespace`字段

* `spec`字段:必须提供,用来描述该对象的期望状态,以及关于对象的基本信息 

* Annotation:可以将kubernetes资源对象关联到任意的非标识行元数据

### 一. service

1. endpoint

   * 用来记录一个service对应的所有pod的访问地址,存储在etcd中,就是service关联的pod的ip地址和端口
   * service配置了selector,endpoint controller才会自动创建对应的endpoint对象,否则不会生产endpoint对象

2. 没有selector的Service

   * 使用k8s集群外部的数据库
   * 希望服务执行另一个namespace中或其他集群中的服务
   * 正在将工作负载迁移到k8s集群

3. ExternalName

   * 没有selector,也没有定义port和endpoint,对于运行在集群外的服务,通过返回该外部服务的别名这种方式来提供服务

     ```
     kind: Service
     apiVersion: v1
     metadata:
       name: my-service
       namespace: prod
     spec:
       type: ExternalName
       externalName: my.database.example.com
       
     当请求my-service.prod.svc.cluster时,集群的DNS服务将返回一个my.database.example.com的CNAME记录
     ```

4. Headless service

   * 不需要或不想要负载均衡,指定spec.ClusterIP: None来闯将Headless Service
   * 对这类service不会分配ClusterIP,kube-proxy不会处理它们,不会为它们进行负载均衡和路由;DNS如何实现自动配置,依赖于Service是否定义了selector
   * 配置selector的,endpoint控制器在API中创建了endpoints记录,并且修改DNS配置返回A记录,通过这个地址直达后端Pod

5. externalIPs

   * *my-service*可以在80.11.12.10:80上被客户端访问

     ```
     kind: Service
     apiVersion: v1
     metadata:
       name: my-service
     spec:
       selector:
         app: MyApp
       ports:
         - name: http
           protocol: TCP
           port: 80
           targetPort: 9376
       externalIPs: 
         - 80.11.12.10
     ```

### [二. configMap使用](https://www.bbsmax.com/A/kvJ3NoVwzg/)

1. items字段使用:

* 不想以key名作为配置文件名可以引入​​items​​​ 字段，在其中逐个指定要用相对路径​​path​​替换的key
* 只有items下的key对应的文件会被挂载到容器中

```
  volumes:
    - name: config-volume
      configMap:
        name: cm-demo1
        items:
        - key: mysql.conf
          path: path/to/msyql.conf
```

2. valueFrom:映射一个key值,与configMapKeyRef搭配使用
3. envFrom:把ConfigMap的所有键值对都映射到Pod的环境变量中去,与configMapRef搭配使用

#### DNS解析方式

```
servicehname.namespace.svc.cluster.local
```

#### Pod名称格式

```
${deployment-name}-${template-hash}-${random-suffix}
```

#### StatefulSet

* StatefulSet中每个Pod的DNS格式为`statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`
* 例:kubectl exec redis-cluster-0 -n wiseco -- hostname -f  # 查看pod的dns 

### [k8s部署应用,故障排查思路](https://www.cnblogs.com/rancherlabs/p/12330916.html)

[k8s故障诊断流程](https://cloud.tencent.com/developer/article/1899950)

1. Deploymenr:创建名为Pods的应用程序副本的方法
2. Service:内部负载局衡器,将流量路由到Pods
3. Ingress:将流量从集群外部流向Service

#### 故障排查思路

> Pod是否正在运行
>
> Service是否将流量路由到Pod
>
> 检查Ingress是否正确配置

#### 0.退出状态码

> kubectl describe pod  ;查看State字段,ExitCode即程序退出的状态码,正常退出为0

* 退出状态码必须在0-255之间
* 外界中断将程序退出的时候状态码在129-255区间(操作系统给程序发送中断信号,例:kill-9等)
* 程序自身原因导致的异常退出,状态码在1-128区间

#### 1.常见Pod错误

> 启动错误

```
ImagePullBackoff
ImageInspectError
ErrImagePull
ErrImageNeverPull
RegistryUnavailable
InvalidImageName
```

> 运行错误

```
CrashLoopBackOff: 可能是应用程序存在错误,导致无法启动;错误配置了容器;liveness探针失败次数太多
RunContainerError
KillContainerError
VerifyNonRootError
RunInitContainerError: 通常是错误配置导致,比如安装一个不存在的volume;将只读volume安装为可读写
CreatePodSandboxError
ConfigPodSandboxError
KillPodSandboxError
SetupNetworkError
TeardownNetworkErro
```

* 例:CrashLoopBackOff
  1. 获取describe pod,主要看event事件:`kubectl describe pod es-0 -n logging` 
  2. 观察pod日志:`kubectl logs es-0 -n logging`
  3. 查看liveness探针,可能是pod因`liveness`探测器未返回成功而崩溃,再看`describe pod `

#### 2.排查Service故障

1. 主要查看service是否与pod绑定:` kubectl describe svc redis-exporter -n wiseco|grep "Endpoints" `
2. 测试端口:`kubectl port-forward es-0 9200:9200 -n logging`

#### 3.k8s - Annotations

##### TODO:可以只在service上加,因为service-endpoints最终也会落到pod上

>  kubernetes-pods

* prometheus.io/scrape，为true则会将pod作为监控目标
* prometheus.io/path，默认为/metrics
* prometheus.io/port , 端口

> kubernetes-service-endpoints

- prometheus.io/scrape，为true则会将pod作为监控目标
- prometheus.io/path，默认为/metrics
- prometheus.io/port , 端口
- prometheus.io/scheme 默认http，如果为了安全设置了https，此处需要改为https

#### 4.抓包方法

> https://zhuanlan.zhihu.com/p/372567807
>
> https://blog.csdn.net/chongdang2813/article/details/100863010

### [容器中获取Pod信息](https://blog.csdn.net/lsx_3/article/details/124399768)(https://www.cnblogs.com/cocowool/p/kubernetes_get_metadata.html)

* 环境变量:将pod或容器信息设置为容器的环境变量
* volume挂载:将pod或容器信息以文件的形式挂载到容器内部

```
通过fieldRef设定的元数据如下:
metadata.name：Pod名称
metadata.namespace： Pod所在的命名空间名称
metadata.uid：Pod的UID （Kubernetes 1.8.0 +）
metadata.labels[‘<KEY>’]：Pod某个Label的值，通过KEY进行引用
metadata.annotations[‘<KEY>’]：Pod某个Annotation的值，通过KEY进行引用

Pod元数据信息可以设置为容器内的环境变量:
status.podIP：Pod的IP地址
spec.serviceAccountName：Pod使用的ServiceAccount名称
spec.nodeName：Pod所在Node的名称 （Kubernetes 1.4.0 +）
status.hostIP：Pod所在Node的IP地址 （Kubernetes 1.7.0 +）

```

### 调度策略

* Predicate算法:筛选符合条件的node

| GeneralPredicates           | 包含3项基本检查:节点,端口,规则                               |
| --------------------------- | ------------------------------------------------------------ |
| **NoDiskConflict**          | 检查Node是否可以满足Pod对硬盘的需求                          |
| **NoVolumeZoneConflict**    | 单集群跨AZ部署时，检查node所在的zone是否能满足Pod对硬盘的需求 |
| **PodToleratesNodeTaints**  | 检查Pod是否能够容忍node上所有的taints                        |
| **CheckNodeMemoryPressure** | 当Pod QoS为besteffort时，检查node剩余内存量，排除内存压力过大的node |
| **MatchInterPodAffinity**   | 检查node是否满足pod的亲和性、反亲和性需求                    |

* Priority算法:给剩余的node评分,挑选最优的节点

| **LeastRequestedPriority**     | 按node计算资源(CPU/MEM)剩余量排序，挑选最空闲的node          |
| ------------------------------ | ------------------------------------------------------------ |
| **BalancedResourceAllocation** | 补充LeastRequestedPriority，在cpu和mem的剩余量取平衡         |
| SelectorSpreadPriority         | 同一个Service/RC下的Pod尽可能的分散在集群中。Node上运行的同个Service/RC下的Pod数目越少，分数越高。 |
| **NodeAffinityPriority**       | 按soft(preferred) NodeAffinity规则匹配情况排序，规则命中越多，分数越高 |
| **TaintTolerationPriority**    | 按pod tolerations与node taints的匹配情况排序，越多的taints不匹配，分数越低 |
| **InterPodAffinityPriority**   | 按soft(preferred) Pod Affinity/Anti-Affinity规则匹配情况排序，规则命中越多，分数越高 |



#### 限流:[NetworkPolicy网络插件](https://blog.csdn.net/xixihahalelehehe/article/details/108422856)

* 基于源IP的访问控制:
  * 限制Pod的进/出流量
  * 白名单
* Pod网络隔离的一层抽象
  * lable selector
  * namespace selector
  * port
  * CIDR
