1. CPU高，排查方向：
   1. 用户CPU和Nice CPU高，说明用户态进程占用CPU,着重排查进程的性能问题
   1. 系统CPU高，说明内核态占用CPU,着重排查内核线程或系统调用的性能问题
   1. I/O等待CPU高，说明等待I/O时间较长，着重排查系统存储是不是出现了I/O问题
   1. 软中断和硬中断高，着重排查内核中的中断服务程序

1. CPU高，但是找不到对应的进程
   * 查看top的task栏，处于running的个数
   * 查看top显示的进程，处于R状态的，ps aux |grep pid，查看进程，如果进程pid不停的在变化，原因可能如下
     * 进程在不停的崩溃重启，比如段错误，配置错误等，进程退出后，又被监控系统自动重启了（应用启动过程的初始化，可能会占用很多CPU）
     * 这些进程都是短时进程，在其他应用内部通过exec调用的外面命令。这些命令一般运行时间很短，top可能监测不到
     * 可以用pstree |grep stress，查看进程树
     * perf recoard -g  ; perf report,查看性能报告
     * 或者用execsnoop.专门为短时进程设计的工具
   * 这类进程，可以通过pstree或execsnoop找到父进程，从父进程入手排查


3. iowait%高

4. iowait
   * 高不一定是I/O性能瓶颈，可能是代码问题直接读磁盘，没有用系统缓存
   * dstat可以显示CPU和I/O信息，方便比对



## TODO: CPU问题定位，可以看Linux性能优化实战--02-CPU--11:如何心事分析出CPU的瓶颈



![img](https://cdn.nlark.com/yuque/0/2021/png/21484941/1638176714785-90a6e2eb-f148-4027-a3ba-2554a40486e6.png)

![img](https://cdn.nlark.com/yuque/0/2021/png/21484941/1638176825100-dfbc814a-0c5e-46ae-ac88-57dc75d41ddc.png)

![img](https://cdn.nlark.com/yuque/0/2021/png/21484941/1638176892998-2fd4aa80-2f23-46eb-a89a-c8297fc6bc64.png)
