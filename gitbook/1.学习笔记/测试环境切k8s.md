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

测试环境app服务容器化,腾讯云TKE

```
一.TKE相关工作:
    TKE环境初始化:  Ingress,namespace,仓库凭据等
    Jenkins配置: app任务
    kubesphere配置： 权限，企业空间
    日志配置： 生成新logstash
二.网络:安全组
三.基础服务部署:
	app服务:单独部署
	apollo
	网关配置,dns修改
	数据库:单独部署,同步数据
四.切换
	关闭app后端服务,修改git,cmdb配置
	修改域名解析
	网络隔离,拒绝非容器环境访问数据库
	entbus apollo配置修改
	开始容器化部署
五.验证
	验证容器服务是否正常启动
	管理后台验证:域名是否正常访问、登录
	功能验证
	文档修改

遇到问题:
1.管理后台无法加载验证码
	原因:前端项目打包还是旧打包，需要配置npm  run build 环境变量 
	处理:需要关联旧接口
2.容器存活探针一直失败,导致服务重启
	原因:查看日志,发现应用连接数据库信息错误,数据库账号不对,少了最后几个字母;
	历史遗留问题:由于以前数据库对应字段长度设置为128,数据库名经过base64加密后,长度超过,所以手动把库名减少了几位,本次迁移过程中暴露出来
3.网络不通
4.验证时,域名无法访问:未创建ingress
```

