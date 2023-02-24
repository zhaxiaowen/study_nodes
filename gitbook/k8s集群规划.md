### k8s集群规划

#### 1.容器标准

* 镜像仓库:腾讯云
* namespace:业务线-环境: wyc-prod
* 镜像命名规范
  * 统一小写
  * 后端:backend-{service_name}
  * 前端:frontend-{service_name}
* 基础镜像:
  * 前端:openresty:1.21.4.1-1 96MB
  * 后端:centos7.9,jdk1.8  457.94MB
* 网段划分

#### 2.k8s标准化

* namespace:业务线-环境
* deployment
  * name
  * label:
    * business-line
    * env
    * k8s-app
    * qcloud-app
    * tier
    * type
  * 安全上下文
  * 反亲和:避免Pod在同一个node上,导致单点故障
  * 
* service
  * 前端:frontend-{service_name}
  * outterapi:outterapi-{service_name}
* 服务优雅停止
* 安全组
* 公共组件
  * apollo
  * skywalking
  * jmx-exporter

#### 3.内核参数



#### 4.日志系统

* filebeat采用daemonset方式,收集系统日志、容器、主机日志
* 原理
  * 每个k8s节点上,创建/data/logs目录,通过hostpath的方式挂载到pod,pod里面的进程需要将日志收集到挂载的目录上
  * 通过subPathExpr将日志的目录规范化
  * filebeat去宿主机的/data/logs目录下采集日志,推送到kafka,再由kafka写到es
  * 定时任务清除日志宿主机的日志

#### 5.容器发布过程

	1. jenkins校验参数
	1. 编译项目
	1. 将编辑的jar包复制到dockerfile目录,打包镜像
	1. 生成deplyment,svc,ingress配置文件
	1. apply发布
	1. 告警静默

#### 6.遇到的问题

* pod资源超分问题,配置的limits值超过当前节点资源配置
* 基础镜像缺少部分常用的linux命令:已打包到基础镜像了,但是会导致基础镜像较大

* pod无写日志权限:原因是宿主机的log路径权限设置有问题