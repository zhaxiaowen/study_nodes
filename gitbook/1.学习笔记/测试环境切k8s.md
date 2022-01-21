# 测试环境切k8s

### 集群规模

* dev:7台16C,128G
* fat:12台16C,128G
* uat:6台16C,128G

### 准备事项

1. 配置安全组,放行线下环境
2. 云存储配置
3. jenkins配置凭据访问k8s



### 1.init k8s env

* 创建apollo configmap
* 创建filebeat configmap
* 创建skywalking agent configmap
* 创建ingress ssl secret
* 创建nginx-https
* 创建拉去镜像secret
* 创建namespace

### 2. 生成jenkins部署任务

### 3.全量发包



TODO:

* TKE集群中，命名空间namespace创建的时候，需要关联企业仓库凭证，创建后的namespace无法关联凭证
* Jenkins目前不支持自动创建凭证，需要手动配置namespace和namespace对应仓库凭证
