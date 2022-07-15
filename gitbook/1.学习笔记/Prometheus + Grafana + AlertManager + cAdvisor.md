# Prometheus + Grafana + AlertManager + cAdvisor

### 1.Grafana模板

```yaml
redis: 763 / 11835 / 14615(pod)
linux主机：8919 / 9276
k8snode: 315 / 13824
state-metrics(k8spod): 13332
blackbox: 7587
kafka: 721
docker: 10566
```

### 2.Prometheus常用指令

```yaml
# prometheus默认端口为9090,此次写的是30003
curl -XGET http://192.168.50.100:30003/-/healthy  #检查prometheus健康状况
curl -XGET http://192.168.50.100:30003/-/ready    #就绪检查
curl -XPOST http://192.168.50.100:30003/-/reload  #热加载
```

### 3.内置函数

```yaml
irate() #用于计算区间向量中时间序列每秒的即时增长率 irate(node_cpu[2m])

increase(node_cpu[2m]) / 120  #获取最近2分钟的样本，计算出2分钟增长量，除以120s,得到node_cpu样本在最近2分钟的平均增长率

rate(node_cpu[2m]) #直接计算区间向量在2m内平均增长速率，跟increase结果相同
	increase/rate计算平均增长速率，无法反应在时间窗口内样本数据的突发变化；适合长期趋势分析或告警
	irate相比rate，提供了更高的灵敏度，不过不适合长期趋势分析
  
predict_linear(v range-vector, t scalar) #可以预测时间序列v在t秒后的值,可以用来监控某些业务增长率提升过快的情况
predict_linear(node_filesystem_free{job="node"}[2h],4 * 3600) < 0  #基于2小时的样本数据，来预测主机可用磁盘空间的是否在4个小时候被占满

label_replace(v instant-vector, dst_label string, replacement string, src_label string, regex string) #为时间序列添加额外的标签	
 	label_replace(up, "host", "$1", "instance",  "(.*):.*")  #时间序列将包含一个host标签，host标签的值为Exporter实例的IP地址
  
  
```

#### 聚合函数

```yaml
#作用域为瞬时向量，可以将瞬时表达式返回的样本数据进行聚合，形成一个新的时间序列
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
	without (label):从计算结果中移除列举的标签
  by (label):只保留列出的标签，其余标签移除

sum (求和)
min (最小值)
max (最大值)
avg (平均值)
stddev (标准差)
stdvar (标准方差)
count (计数)
count_values (对value进行计数)
bottomk (后n条时序)
topk (前n条时序)
quantile (分位数)

count_values(对value进行计数) count_values("count", http_requests_total)

topk和bottomk:用于对样本值进行排序，返回前n位或后n位的时间序列    topk(5, http_requests_total)

quantile:计算当前样本数据值的分布情况
	topk(5, http_requests_total)   #φ为0.5时，找到当前样本数据中的中位数
```

### Grafana里的prometheus查询语法

| 名称                        | 描述                                           |
| --------------------------- | ---------------------------------------------- |
| label_values(label)         | 返回label每个指标中的标签值列表。              |
| label_values(metric, label) | 返回label指定度量标准中的标签值列表。          |
| metrics(metric)             | 返回与指定metric正则表达式匹配的度量标准列表。 |
| query_result(query)         | 返回一个Prometheus查询结果列表query。          |

### 4.Grafana做一个Dashboard

1. 新建一个Dashboard
2. 进入新建的Dashboard,选择右上角的Dashboard settings
3. 配置General
4. Add Panel:Convert to row,增加一个标签栏，可以将dashboard放入
5. 配置Variables
6. 创建dashboard

### 5.配置文件详解

#### 1.prometheus配置文件

 https://blog.csdn.net/weixin_46837396/article/details/120075294

[relabel_configs详解](https://www.modb.pro/db/50726)

[relabel_configs使用方法列举](https://www.cnblogs.com/weifeng1463/p/12846459.html)

```yaml
# 全局配置
global:
  scrape_interval:     15s # 数据收集频率
  evaluation_interval: 15s # 多久评估一次规则
  scrape_timeout: 10s  # 收集数据的超时时间

#####Alertmanager配置模块

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
      - targets:
        - ['127.0.0.1:9093'] #配置告警信息接收端口

# ###规则文件，支持通配符
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
  # - "rules/*.rules"
  # - "*.rules"


# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'    # 被监控资源组的名称

    # metrics_path defaults to '/metrics' #该行可不写，获取数据URI，默认为/metrics
    # scheme defaults to 'http'.          # #默认http方式采集

    static_configs:           ##节点地址与获取Metrics数据端口，多个地址用逗号分隔，也可以写多行
    - targets: ['localhost:9090']
   #- targets: ['localhost:9090','192.168.1.100:9100']
     #- 192.168.1.101:9100
     #- 192.168.1.102:9100
     #- 192.168.1.103:9100
global:  #全局配置，这里的配置项可以单独配置在某个job中
  scrape_interval: 15s  #采集数据间隔，默认15秒
  evaluation_interval: 15s  #告警规则监测频率，比如已经设置了内存使用大于70%就告警的规则，这里就会每15秒执行一次告警规则
  scrape_timeout: 10s   #采集超时时间

scrape_configs:
  - job_name: 'prometheus-server'  #定义一个监控组名称
    metrics_path defaults to '/metrics'  #获取数据URI默认为/metrics
    scheme defaults to 'http'  #默认http方式采集
    static_configs:
    - targets: ['localhost:9090','192.168.1.100:9100']  #节点地址与获取Metrics数据端口，多个地址用逗号分隔，也可以写多行。

  - job_name: 'web_node'  #定义另一个监控组
    metrics_path defaults to '/metrics'  #获取数据URI默认为/metrics
    scheme defaults to 'http'  #默认http方式采集
    static_configs:
    - targets: ['10.160.2.107:9100','192.168.1.100:9100']  #组内多个被监控主机
      labels:  #自定义标签，通过标签可以进行查询过滤
        server: nginx  #将上面2个主机打上server标签，值为nginx

  - job_name: 'mysql_node'
    static_configs:
    - targets: ['10.160.2.110:9100','192.168.1.111:9100']
    metric_relable_configs:   #声明要重命名标签
    - action: replace  #指定动作，replace代表替换标签，也是默认动作
      source_labels: ['job']  #指定需要被action所操作的原标签
      regex: (.*)  #原标签里的匹配条件，符合条件的原标签才会被匹配，支持正则
      replacement: $1  #原标签需要被替换的部分，$1代表regex正则的第一个分组
      target_label: idc  #将$1内容赋值给idc标签

    - action: drop  #正则删除标签示例
      regex: "192.168.100.*"  #正则匹配标签值
      source_labels: ["__address__"]  #需要进行正则匹配的原标签

    - action: labeldrop  #直接删除标签示例
      regex: "job"  #直接写标签名即可
```

##### kubernetes_sd_configs

```
# 匹配node_name
source_labels: [__meta_kubernetes_node_name]
regex: (.+)
${1}  # $1的值就是node的名称
```



#### 2.altermanager.yml

```yaml
# route用来设置报警的分发策略，是个重点，告警内容从这里进入，寻找自己应该用那种策略发送出去
route:
  # 告警应该根据那些标签进行分组
  group_by: ['job', 'altername', 'cluster', 'service','severity']

  # 同一组的告警发出前要等待多少秒，这个是为了把更多的告警一个批次发出去
  group_wait: 30s

  #同一组的多批次告警间隔多少秒后，才能发出
  group_interval: 5m

  # 重复的告警要等待多久后才能再次发出去
  repeat_interval: 12h

  # 一级的receiver，也就是默认的receiver，当告警进来后没有找到任何子节点和自己匹配，就用这个receiver
  receiver: 'wechat'

  # 上述route的配置会被传递给子路由节点，子路由节点进行重新配置才会被覆盖
  # 子路由树
  routes:

  # 用于匹配label。此处列出的所有label都匹配到才算匹配
  - match_re:
      service: ^(foo1|foo2|baz)$
    receiver: 'wechat'

    # 在带有service标签的告警同时有severity标签时，他可以有自己的子路由，同时具有severity != critical的告警则被发送给接收者team-ops-mails,对severity == critical的告警则被发送到对应的接收者即team-ops-pager
    routes:
    - match:
        severity: critical
      receiver: 'wechat'

  # 比如关于数据库服务的告警，如果子路由没有匹配到相应的owner标签，则都默认由team-DB-pager接收
  - match:
      service: database
    receiver: 'wechat'

  # 我们也可以先根据标签service:database将数据库服务告警过滤出来，然后进一步将所有同时带labelkey为database
  - match:
      severity: critical
    receiver: 'wechat'

# 抑制规则，当出现critical告警时 忽略warning
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  # Apply inhibition if the alertname is the same.
  #   equal: ['alertname', 'cluster', 'service']
```

### 6.cAdvisor

可以搜集一台机器上所有运行的容器信息,Go语言开发,利用Linux的cgroups获取容器的资源使用信息

常用查询语法

|                           |                                                              |                                                            |
| ------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------- |
| 正在运行的容器数量        | count(rate(container_last_seen{id=~".+",$label=~".+"}[1m])   | $label :标签条件，按照拥有$label标签的项查询     .+ ：通配 |
| 容器 CPU相关              | sum(rate(container_cpu_system_seconds_total[1m]))    sum(rate(container_cpu_system_seconds_total{name=~".+"}[1m]))    sum(rate(container_cpu_system_seconds_total{id="/"}[1m]))    sum(rate(process_cpu_seconds_total[1m])) * 100  sum(rate(container_cpu_system_seconds_total{name=~".+"}[1m])) + sum(rate(container_cpu_system_seconds_total{id="/"}[1m])) + sum(rate(process_cpu_seconds_total[1m])) |                                                            |
| 每个容器的cpu使用率       | sum(rate(container_cpu_usage_seconds_total{name=~".+"}[1m])) by (name) * 100 |                                                            |
| 全部容器的CPU使用率总和： | sum(sum(rate(container_cpu_usage_seconds_total{name=~".+"}[1m])) by (name) * 100) |                                                            |
| total CPU Usage           | sum(rate(container_cpu_user_seconds_total{image!=""}[5m]) * 100) |                                                            |
| CPU Usage per container   | rate(container_cpu_user_seconds_total{image!=""}[5m]) * 100  |                                                            |
| 所有容器内存              | container_memory_rss{name=~".+"}                             |                                                            |
| 所有容器内存总和          | sum(container_memory_rss{name=~".+"})                        |                                                            |
| 所有容器当前内存使用      | container_memory_usage_bytes{name=~".+"}                     |                                                            |
| 所有容器当前内存使用总和  | sum(container_memory_usage_bytes{name=~".+"})                |                                                            |

#### Blackbox_exporter

1.[检测icmp/tcp/http/ssl证书](https://blog.csdn.net/qq_25934401/article/details/84325356)



#### prometheus标签替换

* relabel_configs ： 在采集之前（比如在采集之前重新定义元标签）
* metric_relabel_configs：在存储之前准备抓取指标数据时，可以使用relabel_configs添加一些标签、也可以只采集特定目标或过滤目标。 已经抓取到指标数据时，可以使用metric_relabel_configs做最后的重新标记和过滤。

```
    relabel_configs:
      - source_labels: ['__meta_consul_service_metadata_metric']
        regex: '.*actuator.*'
        action: drop
      - source_labels: ['__meta_consul_service_metadata_project'] #只收集匹配到的标签值
        regex: 'wsWangYueChe'
        action: keep
      - source_labels: ['__metrics_path__']
        regex: /metrics
        target_label: __metrics_path__
        replacement: /prometheus/metrics
        action: replace
      - source_labels: ['__meta_consul_tags'] #__meta_consul_tags值=",prod," 
        action: replace
        regex: (,+)(.*), #匹配标签的值,用$2的值替换掉原来的标签值
        replacement: $2
        target_label: env #替换标签名称
      - source_labels: ['__meta_consul_service_metadata_project']  #将__meta_consul_service_metadata_project标签名替换成project
        target_label: project
      - source_labels: ['__meta_consul_service_metadata_category']
        target_label: category
      - source_labels: ['__meta_consul_service_metadata_exporter']
        target_label: exporter
      - source_labels: ['__meta_consul_service_metadata_hostname']
        target_label: hostname
      - source_labels: ['__meta_consul_service_metadata_appname']
        target_label: appname
        
```

