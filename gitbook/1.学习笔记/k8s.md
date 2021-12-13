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
kubectl port-forward es-0 9200:9200 -n logging
curl http://localhost:9200/_cluster/state?pretty   # 在另一个端口测试
```

