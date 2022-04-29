# k8s + docker

### 概念

1. endpoint

> 用来记录一个service对应的所有pod的访问地址,存储在etcd中,就是service关联的pod的ip地址和端口
>
> service配置了selector,endpoint controller才会自动创建对应的endpoint对象,否则不会生产endpoint对象

### docker

```
# 查看容器细节
docker inspect --format "{{.NetworkSettings.IPAddress}}" <containerid>

# 进入容器的网络命令空间,使用宿主机的命令
nsenter
pid=$(docker inspect --format "{{.State.Pid}}") <container>
nsenter -n -t <pid>
nsenter -t <pid> -n ip addr #进入某个namespace运行命令
lsns #查看当前系统的namespace
lsns -t <type>
ls -al /proc/<pid>/ns/  #查看某进程的namespace
nsenter -t <pid> -n <ip addr> #进入某namespace执行命令
# 不进容器执行命令
docker exec -it <container> /bin/bash -c "ls"

# cp文件到容器
docker cp file1 <container>:/root
```







### 常用指令

> StatefulSet中每个Pod的DNS格式为`statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`
>
> 例:kubectl exec redis-cluster-0 -n wiseco -- hostname -f  # 查看pod的dns 

#### 查看pod/service的yaml文件

```
kubectl get svc grafana -n kubesphere-monitoring-system  -o yaml
```



#### 给node添加/删除标签

```
kubectl label nodes node1 beta.kubernetes.io/fluentd-ds-ready=true   #添加
kubectl label node node1  beta.kubernetes.io/fluentd-ds-ready-   #删除
```

#### 将本地端口9200转发到es-pod对应的端口

```
port-forward: 转发一个本地端口到容器端口
kubectl port-forward es-0 9200:9200 -n logging
curl http://localhost:9200/_cluster/state?pretty   # 在另一个端口测试
```

#### cp

```
kubectl cp mysql-478535978-1dnm2:/tmp/message.log message.log  # 将容器内的文件copy到本地
kubectl cp message.log mysql-478535978-1dnm2:/tmp/message.log  # 将本地文件copy到容器内
```

#### node管理

```
# 禁止pod调度到该节点
kubectl cordon node3
# 取消禁止调度
kubectl uncordon node3

# 驱逐该节点上的所有pod
kubectl drain node3
```





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

#### curl命令请求api

```bash
curl -sX GET -H "Authorization:bearer `cat /root/dashboard/test/cluster.token`" -k https://192.168.50.100:6443/api/v1/nodes/node1/proxy/metrics/cadvisor
```

![Preview](.\picture\Preview.jpg)

#### 4.抓包方法

> https://zhuanlan.zhihu.com/p/372567807
>
> https://blog.csdn.net/chongdang2813/article/details/100863010
