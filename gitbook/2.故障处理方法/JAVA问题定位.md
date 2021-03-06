# JAVA问题定位

#### 查看CPU使用率

- mpstat -P ALL 5 :显示所有CPU指标
- pidstat -u 5:间隔5s输出一组数据，-u：指CPU

#### Java

```plain
生产环境下JAVA进程高CPU占用故障排查 
解决过程：
1，根据top命令，发现PID为2633的Java进程占用CPU高达300%，出现故障。

2，找到该进程后，如何定位具体线程或代码呢，首先显示线程列表,并按照CPU占用高的线程排序：
[root@localhost logs]# ps -mp 2633 -o THREAD,tid,time | sort -rn

显示结果如下：
USER     %CPU PRI SCNT WCHAN  USER SYSTEM   TID     TIME
root     10.5  19    - -         -      -  3626 00:12:48
root     10.1  19    - -         -      -  3593 00:12:16

找到了耗时最高的线程3626，占用CPU时间有12分钟了！

将需要的线程ID转换为16进制格式：
[root@localhost logs]# printf "%x\n" 3626
e18

最后打印线程的堆栈信息：
[root@localhost logs]# jstack 2633 |grep e18 -A 30

总结：
1. 先使用top命令查询java占用cpu高的进程
2. 使用 ps -mp 查找出该进程下里面耗用时间长的线程
3. 使用printf "%x\n" 3626 将线程转换为16进制
4. 使用 jstack 2633 |grep e18 -A 30 使用此命令打印出该进程下面的此线程的堆栈信息
```
