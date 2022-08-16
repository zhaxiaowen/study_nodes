## k8s常用指令

#### 获取集群kubeconfig,添加lens用

```
kubectl config view --minify --raw
```

#### 通过证书请求k8s apiserver

```
curl https://192.168.122.100:6443/api/ --cacert /etc/kubernetes/pki/ca.crt --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt --key /etc/kubernetes/pki/apiserver-kubelet-client.key

curl https://192.168.122.100:6443/api/v1/nodes --cacert /etc/kubernetes/pki/ca.crt --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt --key /etc/kubernetes/pki/apiserver-kubelet-client.key

curl -sX GET -H "Authorization:bearer `cat /root/dashboard/test/cluster.token`" -k https://192.168.50.100:6443/api/v1/nodes/node1/proxy/metrics/cadvisor
```

#### DNS解析

```
StatefulSet中每个Pod的DNS格式为`statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`
例:kubectl exec redis-cluster-0 -n wiseco -- hostname -f  # 查看pod的dns 
```

#### lable selector

```
kubectl get pod -l tier=frontend
kubectl get pod -l 'tier in (frontend),env in (production)'
kubectl get pod -l 'env notin (production)'
```

#### rollout回滚

```
 # deployment有回滚,pod没回滚功能
 kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1  #更新镜像版本
 
 kubectl rollout history deployment nginx-deployment  #查询deployment
 
 kubectl rollout undo deployment nginx-deployment  #回滚到deployment上一个版本
 
 kubectl rollout undo deployment nginx-deployment --to-revision=2  #回滚到指定版本
 
 kubectl rollout pause deployment nginx-deployment #暂停回滚
 kubectl rollout resume deploy/nginx-deployment    #恢复
```

#### 标签

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

#### 查看命令执行的日志

```
kubectl run --image=nginx --v=10
kubectl top pods -v 9
kubectl get --raw "/api/v1/nodes/node1/proxy/metrics/resource"
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

#### 强制删除pod

```
kubectl delete pod -n monitoring node-exporter-pvwwp --force --grace-period=0
```







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

#### 镜像导入导出

```
docker save busybox > busybox.tar
docker load < busybox.tar
```

#### 容器导入导出

```
docker export busybox > busybox.tar
cat busybox.tar | docker import - busybox:latest
```

### 动态监控pod状况

```
watch kubectl top pods
```

