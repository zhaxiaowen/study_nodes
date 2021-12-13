# FileBeat

FileBeat是用于转发和集中日志数据的轻量级传送工具，监视指定的日志文件或位置，收集日志时间，转发给es或logstash进行索引

#### filebeat的构成

两个组件：inputs(输入)和harvesters(收集器)

input：负责管理harvesters和寻找所有数据来源

harvesters：负责打开和关闭文件，读取单个文件的内容；逐行读取每个文件，并将内容发送到输出；

#### 如何保存文件的状态

1. filebeat保留harvester读取每个文件的最后一个偏移量，并经常将状态刷新到磁盘中的注册表中，并确保发送所有日志行
2. 如果无法访问输出，filebeat将跟踪最后发送的行，并在输出正常后继续读取文件

1. filebeat运行时，每个输入的状态信息保存在内存
2. filebeat重启时，用注册表文件的数据重建状态，Filebeat在最后一个已知位置继续每个harvester。  

1. 对于每个文件，Filebeat存储唯一的标识符，以检测文件是否以前被捕获。  

#### 如何保证至少一次数据消费

1. 在已定义的输出被阻止且未确认所有事件的情况下，Filebeat将继续尝试发送事件，直到输出确认已接收到事件为止。  
2. 如果Filebeat在发送事件的过程中关闭，它不会等待输出确认所有事件后再关闭。 当Filebeat重新启动时，将再次将Filebeat关闭前未确认的所有事件发送到输出。  

1. 可以确保每个事件至少发送一次，但最终可能会有重复的事件发送到输出。

#### 参数详解

```yaml
filebeat.inputs:                   # inputs为复数，表名type可以有多个
- type: log                        # 输入类型
  access:
  enabled: true                    # 启用这个type配置
  paths:
    - /logs/nginx/logs/access.log  # 监控nginx1 的access日志，建议采集日志时先采集单一nginx的access日志。
    - /home/wwwlogs/access.log     # 监控nginx2 的access日志（docker产生的日志）
    - include_lines: ['ERROR', 'WARN'] # 这样 FileBeat 就会收集包含 pro.ERROR、pro.WARN 的日志行。    PS：与 multiline 联合使用的时候，会针对合并后的记录再过滤。
  close_rename: true               # 重命名后，文件将不会继续被采集信息
  tail_files: true                 # 配置为true时，filebeat将从新文件的最后位置开始读取，如果配合日志轮循使用，新文件的第一行将被跳过
  multiline.pattern: '^\[.+\]'     # 这三行表示，如果是多行日志，合并为一行
  multiline.negate: true
  multiline.match: "after"

  fields:                          # 额外的字段
    source: nginx-access-240       # 自定义source字段，用于es建议索引（字段名小写，我记得大写好像不行）
- type: log
  access:
  enabled: true
  paths:
    - /logs/nginx/logs/error.log  # 监控nginx1 的error日志 
    - /home/wwwlogs/error.log     # 监控nginx2 的error日志（docker产生的日志）
  fields:
    source: nginx-error-240
  # 多行合并一行配置
  multiline.pattern: '^\[.+\]'
  multiline.negate: true
  multiline.match: "after"
  tail_files: true

filebeat.config:                 # 这里是filebeat的各模块配置，我理解modules为inputs的一种新写法。
  modules:
    path: ${path.config}/modules.d/*.yml    # 进入容器查看这里有很多模块配置文件，Nginx,redis,apache什么的
    reload.enabled: false                   # 设置为true来启用配置重载
    reload.period: 10s                      # 检查路径下的文件更改的期间（多久检查一次）

# 在7.4版本中，自定义es的索引需要把ilm设置为false， 这里未验证，抄来的
setup.ilm.enabled: false

output.kafka:            # 输出到kafka
  enabled: true          # 该output配置是否启用
  hosts: ["172.168.50.41:9092", "172.168.50.41:9097", "172.168.50.41:9098"]  # kafka节点列表
  topic: "elk-%{[fields.source]}"   # kafka会创建该topic，然后logstash(可以过滤修改)会传给es作为索引名称
  partition.hash:
    reachable_only: true # 是否只发往可达分区
  compression: gzip      # 压缩
  max_message_bytes: 1000000  # Event最大字节数。默认1000000。应小于等于kafka broker message.max.bytes值
  required_acks: 1  # kafka ack等级
  worker: 3  # kafka output的最大并发数
  # version: 0.10.1      # kafka版本
  bulk_max_size: 2048    # 单次发往kafka的最大事件数
logging.to_files: true   # 输出所有日志到file，默认true， 达到日志文件大小限制时，日志文件会自动限制替换，详细配置：https://www.cnblogs.com/qinwengang/p/10982424.html
close_older: 30m         # 如果一个文件在某个时间段内没有发生过更新，则关闭监控的文件handle。默认1h
force_close_files: false # 这个选项关闭一个文件,当文件名称的变化。只在window建议为true 

#没有新日志采集后多长时间关闭文件句柄，默认5分钟，设置成1分钟，加快文件句柄关闭；
#close_inactive: 1m
#
##传输了3h后荏没有传输完成的话就强行关闭文件句柄，这个配置项是解决以上案例问题的key point；
#close_timeout: 3h
#
###这个配置项也应该配置上，默认值是0表示不清理，不清理的意思是采集过的文件描述在registry文件里永不清理，在运行一段时间后，registry会变大，可能会带来问题。
#clean_inactive: 72h
#
##设置了clean_inactive后就需要设置ignore_older，且要保证ignore_older < clean_inactive
#ignore_older: 70h
#
## 限制 CPU和内存资源
#max_procs: 1 
#queue.mem.events: 256
#queue.mem.flush.min_events: 128
filebeat.inputs:
- type: log
  # Change to true to enable this input configuration.
  enabled: true
  # Paths that should be crawled and fetched. Glob based paths.
  paths:
  # 日志实际路径地址
   - /data/learning/learning*.log
  fields:
  # 日志标签，区别不同日志，下面建立索引会用到
    type: "learning"
  fields_under_root: true
  # 指定被监控的文件的编码类型，使用plain和utf-8都是可以处理中文日志的
  encoding: utf-8
  # 多行日志开始的那一行匹配的pattern
  multiline.pattern: ^{
  # 是否需要对pattern条件转置使用，不翻转设为true，反转设置为false。  【建议设置为true】
  multiline.negate: true
  # 匹配pattern后，与前面（before）还是后面（after）的内容合并为一条日志
  multiline.match: after

- type: log
  # Change to true to enable this input configuration.
  enabled: true
  # Paths that should be crawled and fetched. Glob based paths.
  paths:
  # 日志实际路径地址
   - /data/study/study*.log
  fields:
    type: "study"
  fields_under_root: true
  # 指定被监控的文件的编码类型，使用plain和utf-8都是可以处理中文日志的
  encoding: utf-8
  # 多行日志开始的那一行匹配的pattern
  multiline.pattern: ^\s*\d\d\d\d-\d\d-\d\d
  # 是否需要对pattern条件转置使用，不翻转设为true，反转设置为false。  【建议设置为true】
  multiline.negate: true
  # 匹配pattern后，与前面（before）还是后面（after）的内容合并为一条日志
  multiline.match: after
  # Glob pattern for configuration loading
 # path: ${path.config}/modules.d/*.yml
  # Set to true to enable config reloading
  #reload.enabled: true
  # Period on which files under path should be checked for changes
  #reload.period: 10s
setup.kibana:
  #kibanaIP地址
  host: "localhost:5601"
  # Kibana Host
  # Scheme and port can be left out and will be set to the default (http and 5601)
  # In case you specify and additional path, the scheme is required: http://localhost:5601/path
  # IPv6 addresses should always be defined as: https://[2001:db8::1]:5601
  #host: "localhost:5601"
  # Kibana Space ID
  # ID of the Kibana Space into which the dashboards should be loaded. By default,
  # the Default Space will be used.
  #space.id:
output.elasticsearch:
  enabled: true
  # Array of hosts to connect to
  hosts: ["localhost:9200"]
  indices:
       #索引名称，一般为  ‘服务名称+ip+ --%{+yyyy.MM.dd}’。
    - index: "learning-%{+yyyy.MM.dd}"
      when.contains:
      #标签，对应日志和索引，和上面对应
        type: "learning"
    - index: "study-%{+yyyy.MM.dd}"
      when.contains:
        type: "study"

  # Optional protocol and basic auth credentials.
  #protocol: "https"
  username: "#name"
  password: "#pwd"
processors:
- drop_fields:
     fields: ["agent.type","agent.name", "agent.version","log.file.path","log.offset","input.type","ecs.version","host.name","agent.ephemeral_id","agent.hostname","agent.id","_id","_index","_score","_suricata.eve.timestamp","agent.hostname","cloud. availability_zone","host.containerized","host.os.kernel","host.os.name","host.os.version"]
type: log #input类型为log
enable: true #表示是该log类型配置生效
paths：     #指定要监控的日志，目前按照Go语言的glob函数处理。没有对配置目录做递归处理，比如配置的如果是：
- /var/log/* /*.log  #则只会去/var/log目录的所有子目录中寻找以".log"结尾的文件，而不会寻找/var/log目录下以".log"结尾的文件。
recursive_glob.enabled: #启用全局递归模式，例如/foo/**包括/foo, /foo/*, /foo/*/*
encoding：#指定被监控的文件的编码类型，使用plain和utf-8都是可以处理中文日志的
exclude_lines: ['^DBG'] #不包含匹配正则的行
include_lines: ['^ERR', '^WARN']  #包含匹配正则的行
harvester_buffer_size: 16384 #每个harvester在获取文件时使用的缓冲区的字节大小
max_bytes: 10485760 #单个日志消息可以拥有的最大字节数。max_bytes之后的所有字节都被丢弃而不发送。默认值为10MB (10485760)
exclude_files: ['\.gz$']  #用于匹配希望Filebeat忽略的文件的正则表达式列表
ingore_older: 0 #默认为0，表示禁用，可以配置2h，2m等，注意ignore_older必须大于close_inactive的值.表示忽略超过设置值未更新的
文件或者文件从来没有被harvester收集
close_* #close_ *配置选项用于在特定标准或时间之后关闭harvester。 关闭harvester意味着关闭文件处理程序。 如果在harvester关闭
后文件被更新，则在scan_frequency过后，文件将被重新拾取。 但是，如果在harvester关闭时移动或删除文件，Filebeat将无法再次接收文件
，并且harvester未读取的任何数据都将丢失。
close_inactive  #启动选项时，如果在制定时间没有被读取，将关闭文件句柄
读取的最后一条日志定义为下一次读取的起始点，而不是基于文件的修改时间
如果关闭的文件发生变化，一个新的harverster将在scan_frequency运行后被启动
建议至少设置一个大于读取日志频率的值，配置多个prospector来实现针对不同更新速度的日志文件
使用内部时间戳机制，来反映记录日志的读取，每次读取到最后一行日志时开始倒计时使用2h 5m 来表示
close_rename #当选项启动，如果文件被重命名和移动，filebeat关闭文件的处理读取
close_removed #当选项启动，文件被删除时，filebeat关闭文件的处理读取这个选项启动后，必须启动clean_removed
close_eof #适合只写一次日志的文件，然后filebeat关闭文件的处理读取
close_timeout #当选项启动时，filebeat会给每个harvester设置预定义时间，不管这个文件是否被读取，达到设定时间后，将被关闭
close_timeout 不能等于ignore_older,会导致文件更新时，不会被读取如果output一直没有输出日志事件，这个timeout是不会被启动的，
至少要要有一个事件发送，然后haverter将被关闭
设置0 表示不启动
clean_inactived #从注册表文件中删除先前收获的文件的状态
设置必须大于ignore_older+scan_frequency，以确保在文件仍在收集时没有删除任何状态
配置选项有助于减小注册表文件的大小，特别是如果每天都生成大量的新文件
此配置选项也可用于防止在Linux上重用inode的Filebeat问题
clean_removed #启动选项后，如果文件在磁盘上找不到，将从注册表中清除filebeat
如果关闭close removed 必须关闭clean removed
scan_frequency #prospector检查指定用于收获的路径中的新文件的频率,默认10s
tail_files：#如果设置为true，Filebeat从文件尾开始监控文件新增内容，把新增的每一行文件作为一个事件依次发送，
而不是从文件开始处重新发送所有内容。
symlinks：#符号链接选项允许Filebeat除常规文件外,可以收集符号链接。收集符号链接时，即使报告了符号链接的路径，
Filebeat也会打开并读取原始文件。
backoff： #backoff选项指定Filebeat如何积极地抓取新文件进行更新。默认1s，backoff选项定义Filebeat在达到EOF之后
再次检查文件之间等待的时间。
max_backoff： #在达到EOF之后再次检查文件之前Filebeat等待的最长时间
backoff_factor： #指定backoff尝试等待时间几次，默认是2
harvester_limit：#harvester_limit选项限制一个prospector并行启动的harvester数量，直接影响文件打开数

tags #列表中添加标签，用过过滤，例如：tags: ["json"]
fields #可选字段，选择额外的字段进行输出可以是标量值，元组，字典等嵌套类型
默认在sub-dictionary位置
filebeat.inputs:
fields:
app_id: query_engine_12
fields_under_root #如果值为ture，那么fields存储在输出文档的顶级位置

multiline.pattern #必须匹配的regexp模式
multiline.negate #定义上面的模式匹配条件的动作是 否定的，默认是false
假如模式匹配条件'^b'，默认是false模式，表示讲按照模式匹配进行匹配 将不是以b开头的日志行进行合并
如果是true，表示将不以b开头的日志行进行合并
multiline.match # 指定Filebeat如何将匹配行组合成事件,在之前或者之后，取决于上面所指定的negate
multiline.max_lines #可以组合成一个事件的最大行数，超过将丢弃，默认500
multiline.timeout #定义超时时间，如果开始一个新的事件在超时时间内没有发现匹配，也将发送日志，默认是5s
max_procs #设置可以同时执行的最大CPU数。默认值为系统中可用的逻辑CPU的数量。
name #为该filebeat指定名字，默认为主机的hostname
```
