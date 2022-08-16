# kube-prometheus

> git地址: https://github.com/prometheus-operator/kube-prometheus

### 1.组件说明

1) MetricServer: 收集数据给kubernetes集群使用
2) PrometheusOperater:是一个系统检查和警报工具箱,用来存储监控数据
3) NodeExporter:node的关键度量指标状态数据
4) KubeStateMetrics:收集k8s集群内资源对象数据,制定告警规则
5) Prometheus:采用pull方式收集apiserver,scheduler,controller-manager,kubelet组件数据,通过http协议传输
6) Grafana:可视化数据统计和监控平台
