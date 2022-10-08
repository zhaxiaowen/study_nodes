# iptables

大多数linux发行版都默认集成了iptables，先通过一个简单的iptables命令来了解一下：

```js
iptables -A INPUT -t filter -s 192.168.1.10 -j DROP
```

上面的命令是一条防火墙入站规则，意思是指不允许来源为192.168.1.10的IP访问本机的服务；

我们来详细解释下上面的命令，iptables是命令的固定前缀

- ```
  -A
  ```

   是指后面追加一条规则，其它：

  - `-I`是前面插入规则，优先级更高
  - `-D`是删除规则
  - `-N`是新增加链
  - `-F`清除链上的所有规则或所有链
  - `-X`删除一条用户自定义链
  - `-P`更改链的默认策略
  - `-L`展示指定的链上的规则

- `INPUT`是iptables链的名称，指示当前规则工作在哪个netfilter的扩展点，iptables有五条固定的链，与netfilter子系统的扩展点一一对应，分别是：INPUT、OUTPUT、PREROUTING、FORWARD、POSTROUTING；根据上面对netfilter的扩展点的功能解释，防火墙规则一般只工作在INPUT/OUTPUT/FORWARD三个扩展点，而我们是要限制访问本机运行的服务，而INPUT点专门负责入站检测规则，所以选择了INPUT点；所以说我们要先了解netfilter子系统的五个点才能更好地使用iptables；

- ```
  -t
  ```

  指定当前命令操作所属的表，主要有：

  - filter表，主要用于拦截或放行，不修改包；如果不指定，则默认为filter表
  - nat表，主要用于修改IP包的源/目标地址
  - mangle表，主要用于给数据包打标记
  - raw表，没用过不知道干什么的哈哈
  - security表，没用过

- ```
  -s
  ```

  是数据包的匹配规则，配置规则可以一个或多个，多个是与的效果，这里

  ```
  -s
  ```

  是匹配来源IP的意思，还有其它：

  - `-d`是匹配目标IP
  - `--sport`是匹配来源端口
  - `--dport`是匹配目标端口
  - `-p tcp`是匹配协议类型

- ```
  -j DROP
  ```

  是执行的动作，这里是跳转到

  ```
  DROP
  ```

  链，iptables有几个预定义的链：

  - `DROP`丢弃进入该链的包
  - `ACCEPT`接受进入该链的包
  - `RETURN`返回上一级链
  - `SNAT`源地址转换，要指定转换后的源地址，下面会有示例
  - `DNAT`目标地址转换，要指定转换后目标地址
  - `MASQUERADE`对进入该链的包进行源地址转换，与SNAT类似，但不用指定具体的转换后的源地址，会自动应用发送网卡的地址作为源地址，通常都用这条链完成SNAT

再来看几个iptables的命令：

- 把本机应用发往10.96.0.100的数据包的目标地址换成10.244.3.10上，注意是要影响本机应用，所以用的是OUTPUT链（注意图3），clusterIP主要就是使用下面的这条规则完成：

```js
iptables -A OUTPUT -t nat -d 10.96.0.100 -j DNAT --to-distination 10.244.3.10
```

- 上面的规则只对本机的应用程序发送的流量有影响，对于本机的pod发出的流量没有影响，如果要影响本机的pod，还要再加一条，规则都一样，就是工作在PREROUTING链（注意图4）：

```js
iptables -A PREROUTING -t nat -d 10.96.0.100 -j DNAT --to-distination 10.244.3.10
```

- 对本机发送的数据包中来源IP为172.20.1.10的数据包进行源地址伪装，注意修改源地址只有一个点可以用，就是POSTROUTING，下面的规则就是配置pod上外网时使用的：

```js
iptables -A POSTROUTING -t nat -s 172.20.1.10 -j MASQUERADE
```

- 允许来源IP为192.168.6.166并访问本机的TCP80端口：

```js
iptables -A INPUT -t filter -s 192.168.8.166 -p tcp --dport 80 -j ACCEPT
```



为了使数据包能够尽量正常地处理与转发，iptables上的规则创建会有一些限制，例如我们不能在POSTROUTING链上创建DNAT的规则，因为在POSTROUTING之前，数据包要进行路由判决，内核会根据当前的目的地选择一个最合适的出口，而POSTROUTING链的规则是在路由判决后发生，在这里再修改数据包的目的地，会造成数据包不可到达的后果，所以当我们用iptables执行如下命令时：

```js
iptables -A POSTROUTING -t nat -d 192.168.8.163 -j DNAT --to-distination 192.168.8.162

iptables:Invalid argument. Run `dmesg` for more information.

##执行dmesg命令会看到iptables提示：DNAT模块只能在PREROUTING或OUTPUT链中使用
##x_tables:iptables:DNAT target:used from hooks POSTROUTING,but only usable from PREROUTING/OUTPUT
```



# 一、一般报文流向：

流入本机：PREROUTING --> INPUT
 由本机流出：OUTPUT --> POSTROUTING
 转发：PREROUTING --> FORWARD --> POSTROUTING

# 二、功能表：

filter：过滤，防火墙；
 nat：network address translation；用于修改源IP或目标IP，也可以改端口；
 mangle：拆解报文，做出修改，并重新封装起来；
 raw：关闭nat表上启用的连接追踪机制；

## （一）通常情况下功能表包含的链：

raw：PREROUTING， OUTPUT
 mangle：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING
 nat：PREROUTING，[INPUT，]OUTPUT，POSTROUTING
 filter：INPUT，FORWARD，OUTPUT

# 三、[iptables](https://so.csdn.net/so/search?q=iptables&spm=1001.2101.3001.7020)的链：内置链和自定义链

内置链：对应于hook function
 自定义链接：用于内置链的扩展和补充，可实现更灵活的规则管理机制；

## （一）、内核中的五个钩子：

需要将规则送到内核钩子上去才能使规则生效，而iptables就是编辑规则并将规则送到内核钩子上的工具：
 hook function
 input
 output
 forward
 prerouting
 postrouting

## （二）、链：规则检查和应用法则：

(1) 同类规则（访问同一应用），匹配范围小的放上面；
 (2) 不同类的规则（访问不同应用），匹配到报文频率较大的放在上面；
 (3) 将那些可由一条规则描述的多个规则合并起来；
 (4) 设置默认策略；
 iptables/netfilter
 用户空间用的是iptables工具编写规则，内核空间是netfilter检查内核的五个钩子上的规则并根据规则进行处理报文；

# 四、 规则=匹配条件+处理动作：

组成部分：根据规则匹配条件来尝试匹配报文，一旦匹配成功，就由规则定义的处理动作作出处理；

## （一）、匹配条件：

基本匹配条件
 扩展匹配条件

## （二）、处理动作：

基本处理动作
 扩展处理动作
 自定义处理机制

## （三）、添加规则时的考量点：

(1) 要实现哪种功能：判断添加到哪个表上；
 (2) 报文流经的路径：判断添加到哪个链上；

# 五、应用：iptables命令

iptables [-t table] {-A|-C|-D} chain rule-specification

iptables [-t table] -I chain [rulenum] rule-specification

iptables [-t table] -R chain rulenum rule-specification

iptables [-t table] -D chain rulenum

iptables [-t table] -S [chain [rulenum]]

iptables [-t table] {-F|-L|-Z} [chain [rulenum]] [options…]

iptables [-t table] -N chain

iptables [-t table] -X [chain]

iptables [-t table] -P chain target

iptables [-t table] -E old-chain-name new-chain-name

rule-specification = [matches…] [target]

match = -m matchname [per-match-options]

target = -j targetname [per-target-options]

规则格式：iptables [-t table] COMMAND chain [-m matchname [per-match-options]] -j targetname [per-target-options]

-t table：raw, mangle, nat, [filter]–默认

## （一）、链管理：

-N：new, 自定义一条新的规则链；
 -X： delete，删除自定义的规则链；
 -P：Policy，设置默认策略；对filter表中的链而言，其默认策略有：
 ACCEPT：接受
 DROP：丢弃
 REJECT：拒绝（扩展的）
 -E：重命名自定义链；引用计数不为0的自定义链不能够被重命名，也不能被删除；

## （二）、规则管理：

-A：append，追加；
 -I：insert, 插入，要指明位置，省略时表示第一条；
 -D：delete，删除；
 (1) 指明规则序号；
 (2) 指明规则本身；
 -R：replace，替换指定链上的指定规则； 
 -F：flush，清空指定的规则链；
 -Z：zero，置零；
 iptables的每条规则都有两个计数器：
 (1) 匹配到的报文的个数；
 (2) 匹配到的所有报文的大小之和； 
 查看：
 -L：list, 列出指定鏈上的所有规则；
 -n：numberic，以数字格式显示地址和端口号；
 -v：verbose，详细信息；
 -vv, -vvv
 -x：exactly，显示计数器结果的精确值；
 –line-numbers：显示规则的序号；

### 1、匹配条件：

#### （1）、基本匹配条件：

无需加载任何模块，由iptables/netfilter自行提供；
 [!] -s, --source address[/mask][,…]：检查报文中的源IP地址是否符合此处指定的地址或范围；
 [!] -d, --destination address[/mask][,…]：检查报文中的目标IP地址是否符合此处指定的地址或范围；
 [!] -p, --protocol protocol
 protocol: tcp, udp, udplite, icmp, icmpv6,esp, ah, sctp, mh or “all”{tcp|udp|icmp}
 [!] -i, --in-interface name：数据报文流入的接口；只能应用于数据报文流入的环节，只能应用于PREROUTING，INPUT和FORWARD链；
 [!] -o, --out-interface name：数据报文流出的接口；只能应用于数据报文流出的环节，只能应用于FORWARD、OUTPUT和POSTROUTING链；

#### （2）、扩展匹配条件： 需要加载扩展模块，方可生效；

##### ①、隐式扩展匹配条件：

不需要手动加载扩展模块；因为它们是对协议的扩展，所以，但凡使用-p指明了协议，就表示已经指明了要扩展的模块；
 tcp：
 [!] --source-port, --sport port[:port]：匹配报文的源端口；可以是端口范围；
 [!] --destination-port,–dport port[:port]：匹配报文的目标端口；可以是端口范围；
 [!] --tcp-flags mask comp
 mask is the flags which we should examine, written as a comma-separated list，例如SYN,ACK,FIN,RST
 comp is a comma-separated list of flags which must be set，例如SYN
 例如：“–tcp-flags SYN,ACK,FIN,RST SYN”表示，要检查的标志位为SYN,ACK,FIN,RST四个，其中SYN必须为1，余下的必须为0；
 [!] --syn：用于匹配第一次握手，相当于”–tcp-flags SYN,ACK,FIN,RST SYN“； 
 udp
 [!] --source-port, --sport port[:port]：匹配报文的源端口；可以是端口范围；
 [!] --destination-port,–dport port[:port]：匹配报文的目标端口；可以是端口范围；

icmp
 [!] --icmp-type {type[/code]|typename}
 echo-request：8
 echo-reply：0

##### ②、显式扩展匹配条件：

必须要手动加载扩展模块， [-m matchname [per-match-options]]；

### 2、处理动作：

#### （1）、基本处理动作：

无需加载任何模块，由iptables/netfilter自行提供；
 -j targetname [per-target-options]
 ACCEPT
 DROP
 REJECT
 RETURN：返回调用链；
 REDIRECT：端口重定向；
 LOG：记录日志；
 MARK：做防火墙标记；
 DNAT：目标地址转换；
 SNAT：源地址转换；
 MASQUERADE：地址伪装；
 …
 自定义链：

#### （2）、显式扩展处理动作：

必须显式地指明使用的扩展模块进行的扩展；

##### ①、multiport扩展：以离散方式定义多端口匹配；最多指定15个端口；

[!] --source-ports,–sports port[,port|,port:port]…：指定多个源端口；
 [!] --destination-ports,–dports port[,port|,port:port]…：指定多个目标端口；
 [!] --ports port[,port|,port:port]…：指明多个端口；

example：~]# iptables -A INPUT -s 172.16.0.0/16 -d 172.16.100.67 -p tcp -m multiport --dports 22,80 -j ACCEPT

##### ②、iprange扩展：指明连续的（但一般不脑整个网络）ip地址范围；

[!] --src-range from[-to]：源IP地址；
 [!] --dst-range from[-to]：目标IP地址；

example：~]# iptables -A INPUT -d 172.16.100.67 -p tcp --dport 80 -m iprange --src-range 172.16.100.5-172.16.100.10 -j DROP

##### ③、string扩展：对报文中的应用层数据做字符串模式匹配检测；

–algo {bm|kmp}：字符串匹配检测算法；
 bm：Boyer-Moore
 kmp：Knuth-Pratt-Morris
 [!] --string pattern：要检测的字符串模式；
 [!] --hex-string pattern：要检测的字符串模式，16进制格式；

example：~]# iptables -A OUTPUT -s 172.16.100.67 -d 172.16.0.0/16 -p tcp --sport 80 -m string --algo bm --string “gay” -j REJECT

##### ④、time扩展：根据将报文到达的时间与指定的时间范围进行匹配；

–datestart YYYY[-MM[-DD[Thh[:mm[:ss]]]]]
 –datestop YYYY[-MM[-DD[Thh[:mm[:ss]]]]]

–timestart hh:mm[:ss]
 –timestop hh:mm[:ss]

[!] --monthdays day[,day…]
 [!] --weekdays day[,day…]

–kerneltz：使用内核上的时区，而非默认的UTC；

example：~]# iptables -A INPUT -s 172.16.0.0/16 -d 172.16.100.67 -p  tcp --dport 80 -m time --timestart 14:30 --timestop 18:30 --weekdays  Sat,Sun --kerneltz -j DROP

##### ⑤、connlimit扩展：根据每客户端IP做并发连接数数量匹配；

–connlimit-upto n：连接的数量小于等于n时匹配；
 –connlimit-above n：连接的数量大于n时匹配；

example：~]# iptables -A INPUT -d 172.16.100.67 -p tcp --dport 21 -m connlimit --connlimit-above 2 -j REJECT

##### ⑥、limit扩展：基于收发报文的速率做匹配；

令牌桶过滤器；

–limit rate[/second|/minute|/hour|/day]
 –limit-burst number

example1：~]# iptables -I INPUT -d 172.16.100.67 -p icmp --icmp-type 8 -m limit --limit 3/minute --limit-burst 5 -j ACCEPT
 example2：~]# iptables -I INPUT 2 -p icmp -j REJECT

##### ⑦、state扩展：根据”连接追踪机制“去检查连接的状态；

conntrack机制：追踪本机上的请求和响应之间的关系；状态有如下几种：
 NEW：新发出请求；连接追踪模板中不存在此连接的相关信息条目，因此，将其识别为第一次发出的请求；
 ESTABLISHED：NEW状态之后，连接追踪模板中为其建立的条目失效之前期间内所进行的通信状态；
 RELATED：相关联的连接；如ftp协议中的数据连接与命令连接之间的关系；
 INVALID：无效的连接；
 UNTRACKED：未进行追踪的连接；

[!] --state state

example：~]# iptables -A INPUT -d 172.16.100.67 -p tcp -m multiport --dports 22,80 -m state --state NEW,ESTABLISHED -j ACCEPT
 example：~]# iptables -A OUTPUT -s 172.16.100.67 -p tcp -m multiport --sports 22,80 -m state --state ESTABLISHED -j ACCEPT

会话状态追踪：
 我们必须将能追踪的数量调大，使更多的用户都使用上状态追踪功能，调整连接追踪功能所能够容纳的最大连接数量，开启追踪功能非常消耗内存，我们必须确保我们服务器的内存大小满足需要：
 /proc/sys/net/nf_contrack_max

已经追踪到会话状态的并记录下来的连接：
 /proc/net/nf_conntrack

不同的协议的连接追踪时长：
 /proc/sys/net/netfilter/

iptables的链接跟踪表最大容量为/proc/sys/net/ipv4/ip_conntrack_max，链接碰到各种状态的超时后就会从表中删除；当模板满载时，后续的连接可能会超时

解決方法一般有两个：
 (1) 加大nf_conntrack_max 值
 vi /etc/sysctl.conf
 net.ipv4.nf_conntrack_max = 393216
 net.ipv4.netfilter.nf_conntrack_max = 393216

(2) 降低 nf_conntrack timeout时间
 vi /etc/sysctl.conf
 net.ipv4.netfilter.nf_conntrack_tcp_timeout_established = 300
 net.ipv4.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
 net.ipv4.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
 net.ipv4.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120

规则优化：
 服务器端规则设定：任何不允许的访问，应该在请求到达时给予拒绝；
 (1) 可安全放行所有入站的状态为ESTABLISHED状态的连接；
 (2) 可安全放行所有出站的状态为ESTABLISHED状态的连接；
 (3) 谨慎放行入站的新请求
 (4) 有特殊目的限制访问功能，要于放行规则之前加以拒绝；

如何使用自定义链：
 自定义链：需要被调用才能生效；自定义链最后需要定义返回规则；

返回规则使用的target叫做RETURN；

规则的用效期限：
 使用iptables命令定义的规则，手动删除之前，其生效期限为kernel存活期限；

# 六、netfilter: nat table

nat: network address translation
 snat: source nat
 dnat: destination nat
 pnat: port nat

## （一）、源地址转换snat：POSTROUTING, OUTPUT

让本地网络中的主机通过某一特定地址访问外部网络时；

## （二）、目的地址转换dnat：PREROUTING

把本地网络中的某一主机上的某服务开放给外部网络中的用户访问时；

## （三）、nat表的target：

### 1、SNAT

–to-source [ipaddr[-ipaddr]][:port[-port]]
 –random

### 2、DNAT

–to-destination [ipaddr[-ipaddr]][:port[-port]]

### 3、MASQUERADE

–to-ports port[-port]
 –random

### 4、示例：

#### （1）、SNAT示例：

~]# iptables -t nat -A POSTROUTING -s 192.168.12.0/24 -j SNAT --to-source 172.16.100.67

#### （2）、MASQUERADE示例：

源地址转换：当源地址为动态获取的地址时，MASQUERADE可自行判断要转换为的地址；

~]# iptables -t nat -A POSTROUTING -s 192.168.12.0/24 -j MASQUERADE

#### （3）、DNAT示例：

~]# iptables -t nat -A PREROUTING -d 172.16.100.67 -p tcp --dport 80 -j DNAT --to-destination 192.168.12.77

~]# iptables -t nat -A PREROUTING -d 172.16.100.67 -p tcp --dport 80 -j DNAT --to-destination 192.168.12.77:8080
 ~]# iptables -t nat -A PREROUTING -d 172.16.100.67 -p tcp --dport 22012 -j DNAT --to-destination 192.168.12.78:22

