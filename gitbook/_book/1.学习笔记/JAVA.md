# JAVA

[吃透Elasticsearch 堆内存]( https://blog.csdn.net/zpf_940810653842/article/details/102785970)

[为什么Java进程使用的内存(RSS)比Heap Size大](https://blog.csdn.net/flyingnet/article/details/108491460)

#### JavaGC机制讲解

```plain
https://blog.csdn.net/laomo_bible/article/details/83112622
1、什么是GC
2、GC常用算法
```

### JVM监控排查工具

#### jps:查看所有的java进程

https://cloud.tencent.com/developer/article/1664162

```plain
#要在对应进程的用户下执行
jps:查看有哪些运行的java线程
jps -l:输出主类的全名
jps: -v:输出虚拟机启动时的jvm参数
```

#### jstat:监视虚拟机运行状态：查看类加载、垃圾回收、JIT编译、新生代、老年代

```plain
jstat命令使用：http://blog.itpub.net/31543790/viewspace-2657093/
1.jstat -gc "pid":显示与GC相关的堆信息
  S0C:第一个幸存区的大小
  S1C:第二个幸存区的大小
  S0U:第一个幸存区的使用大小
  S1U:第二个幸存区的使用大小
  EC:伊甸园区的大小
  EU:伊甸园区的使用大小
  OC:老年代大小
  OU:老年代使用大小
  MC:方法区大小
  MU:方法区使用大小
  CCSC:压缩类空间大小
  CCSU:压缩类空间使用大小
  YGC:年轻代垃圾回收次数
  YGCT:年轻代垃圾回收消耗时间
  FGC:老年代垃圾回收次数
  FGCT:老年代垃圾回收消耗时间
  GCT:垃圾回收消耗总时间	
  
2.jstat -gcnew "pid":显示新生代信息
  NGCMN:新生代最小容量
  NGCMX:新生代最大容量
  NGC:当前新生代容量
  S0CMX:最大幸存1区大小
  S0C:当前幸存1区大小
  S1CMX:最大幸存2区大小
  S1C:当前幸存2区大小
  ECMX:最大伊甸园区大小
  EC:当前伊甸园区大小
  YGC:年轻代垃圾回收次数
  FGC:老年代垃圾回收次数

3.jstat -gcold "pid":显示老年代信息
  MC:方法区大小
  MU:方法区使用大小
  CCSC:压缩类空间大小
  CCSU:压缩类空间使用大小
  OC:老年代大小
  OU:老年代使用大小
  YGC:年轻代垃圾回收次数
  FGC:老年代垃圾回收次数
  FGCT:老年代垃圾回收消耗时间
  GCT:垃圾回收消耗总时间
    
4.jstat -gcnewcapacity "pid":显示新生代大小使用情况
  NGCMN:新生代最小容量
  NGCMX:新生代最大容量
  NGC:当前新生代容量
  S0CMX:最大幸存1区大小
  S0C:当前幸存1区大小
  S1CMX:最大幸存2区大小
  S1C:当前幸存2区大小
  ECMX:最大伊甸园区大小
  EC:当前伊甸园区大小
  YGC:年轻代垃圾回收次数
  FGC:老年代回收次数
    
5.jstat -gcoldcapacity "pid":显示老年代大小使用情况
  OGCMN:老年代最小容量
  OGCMX:老年代最大容量
  OGC:当前老年代大小
  OC:老年代大小
  YGC:年轻代垃圾回收次数
  FGC:老年代垃圾回收次数
  FGCT:老年代垃圾回收消耗时间
  GCT:垃圾回收消耗总时间
    
6.jstat -gcutil "pid":显示垃圾收集信息
  S0:幸存1区当前使用比例
  S1:幸存2区当前使用比例
  E:伊甸园区使用比例
  O:老年代使用比例
  M:元数据区使用比例
  CCS:压缩使用比例
  YGC:年轻代垃圾回收次数
  FGC:老年代垃圾回收次数
  FGCT:老年代垃圾回收消耗时间
  GCT:垃圾回收消耗总时间
```

#### jinfo:实时查看和调整虚拟机各项参数

```plain
jinfo -flags "pid":打印当前VM的参数值
jinfo  -flag InitialHeapSize "pid":设置指定JVM参数的布尔值
```

#### JVM参数详解

```plain
-Xms:初始堆大小
-Xmx:最大堆大小
-Xmn:年轻代大小
-XX:NewRtion:年轻代与年老代的比值
-XX:SurvivorRatio:Eden区与Survivor区的大小比值
-Xss:每个线程的堆栈大小
-XX:MetaspaceSize:初始元数据空间大小
-XX:MaxMetaspaceSize=128m:最大元数据空间大小
```
