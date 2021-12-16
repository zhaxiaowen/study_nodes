# k8s

### 概念

1. endpoint

> 用来记录一个service对应的所有pod的访问地址,存储在etcd中,就是service关联的pod的ip地址和端口
>
> service配置了selector,endpoint controller才会自动创建对应的endpoint对象,否则不会生产endpoint对象



### 常用指令

> StatefulSet中每个Pod的DNS格式为`statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`
>
> 例:kubectl exec redis-cluster-0 -n wiseco -- hostname -f  # 查看pod的dns 

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



### [k8s部署应用,故障排查思路](https://www.cnblogs.com/rancherlabs/p/12330916.html)

1. Deploymenr:创建名为Pods的应用程序副本的方法
2. Service:内部负载局衡器,将流量路由到Pods
3. Ingress:将流量从集群外部流向Service

#### 故障排查思路

> Pod是否正在运行
>
> Service是否将流量路由到Pod
>
> 检查Ingress是否正确配置

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
