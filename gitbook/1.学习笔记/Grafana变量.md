| **key**     | **value**                              | **desicrible**   |
| ----------- | -------------------------------------- | ---------------- |
| name        | 主机基础监控                           | 模板名           |
| description | 包含：CPU 内存 磁盘 IO 网络 等监控指标 | 描述模板的展示项 |
| Tags        | Prometheus                             | 设置标签         |
| Timezone    | Local browser time                     | 本地浏览器时间   |

#### 变量

#### $job

| **key**     | **value**            | **desicrible**                                     |
| :---------- | :------------------- | :------------------------------------------------- |
| Name        | job                  |                                                    |
| Type        | Query                |                                                    |
| Label       | 分组名称             | 显示在左上角的分组信息，可以选择数据源             |
| Data source | Prometheus           |                                                    |
| Refresh     | On Dashboard Load    |                                                    |
| Query       | label_values(up,job) | job对应的prometheus里不同的监控任务，redis/kafka等 |

#### $node

| **key** | **value**                             | **desicrible**                           |
| ------- | ------------------------------------- | ---------------------------------------- |
| Name    | node                                  |                                          |
| Label   | IP地址                                | 显示在左上角的信息，可以选择对应node节点 |
| Refresh | On Dashboard Load                     |                                          |
| Query   | label_values(up{job="$job"},instance) |                                          |

#### $hostname

| **key** | **value**                                           | **desicrible** |
| ------- | --------------------------------------------------- | -------------- |
| Name    | hostname                                            | 主机名         |
| Label   | 主机名                                              |                |
| Query   | label_values(node_uname_info{job=~"$job"},nodename) |                |

#### $maxmount

| **key** | **value**                                                    | **desicrible** |
| ------- | :----------------------------------------------------------- | -------------- |
| Name    | maxmount                                                     |                |
| Type    | Query                                                        |                |
| Query   | query_result(topk(1,sort_desc (max(node_filesystem_size_bytes{instance=~'$node',fstype=~"ext4\|xfs"}) by (mountpoint)))) |                |
| Regex   | /.*\"(.*)\".*/                                               |                |
| Sort    | Disabled                                                     |                |

#### $interval

| **key** | **value**               | **desicrible** |
| ------- | ----------------------- | -------------- |
| Name    | interval                |                |
| Label   | 时间间隔                |                |
| Values  | 30s,1m,2m,3m,5m,10m,30m |                |

#### $device

| **key** | **value**                                                    | **desicrible** |
| ------- | ------------------------------------------------------------ | -------------- |
| Name    | device                                                       |                |
| Label   | 网卡                                                         |                |
| Query   | label_values(node_network_info{origin_prometheus=~"$origin_prometheus",device!~'tap.*\|veth.*\|br.*\|docker.*\|virbr.*\|lo.*\|cni.*'},device) |                |

#### $nic

| **key** | **value**                                       | **desicrible** |
| ------- | ----------------------------------------------- | -------------- |
| Name    | nic                                             |                |
| Type    | Query                                           |                |
| Label   | 网卡                                            |                |
| Hide    | Variable                                        |                |
| Query   | query_result(node_network_up{interface="eth0"}) |                |
| Regex   | /interface="(\S*)",job/                         |                |
| Sort    | Disabled                                        |                |





#### Dashboard填写参数

| 参数              | value                                                        | desicrible             |
| ----------------- | ------------------------------------------------------------ | ---------------------- |
| **Query**         |                                                              |                        |
| Metrics           |                                                              | 查询语句               |
| Legend            |                                                              | 图例                   |
| Min step          |                                                              | 最小步长               |
| Resolution        | 1/1  1/2                                                     | 解析度(数据显示精细度) |
| Format            | time series（时间序列） Heatmap(热图)                        |                        |
| Instance          | open/close                                                   |                        |
| Min time interval |                                                              | 最小时间间隔           |
| Relative time     |                                                              | 相对时间               |
| Time shift        |                                                              | 时间偏移               |
| **Visualization** | Graph(图形)Singlestat(单态)Gauge(测量)Bar Gauge(条规)Table(表格)Text(文本)Heatmap(热图)Alert List(警报列表)Dashboard list(仪表盘列表)Logs(日志)Plugin list(插件列表) |                        |
| Show              | current minmax                                               |                        |
| Prefix            |                                                              | 字首                   |
| Postfix           |                                                              | 后缀                   |
| Unit              |                                                              | 单元                   |
| Font size         |                                                              | 字体大小               |
| Type              | value to textrange to text                                   |                        |
| **General**       |                                                              |                        |
| Title             | 系统运行时间                                                 | dashboard名称          |
| Repeat            |                                                              | 重复                   |
