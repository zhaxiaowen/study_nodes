# Ansible

ansible配置文件路径: /etc/ansible

### command

```plain
# 在远程主机执行命令;不支持$VARNAME<> |;&
ansible all -m command -a "hostname"
```

### Shell

```plain
# 与command相似,支持各种符号
ansible all -m shell -a "hostname"
```

### Script

```plain
# 在远程主机上运行ansible服务器上的脚本
ansible all -m script -a /root/test.sh
```

### Copy

```plain
# 从ansible服务器复制文件到远程主机

# 目标存在,默认覆盖,先备份
ansible all -m copy -a "src=/root/test.sh dest=/root owner=root mode=600 backup=yes"

#指定内容,直接生成目标文件
ansible all -m copy -a "content='test line1\ntest lin2' dest=/root/test.sh"

#复制/etc目录自身,/etc后面没有/
ansible all -m copy -a "src=/etc dest=/backup"

#复制/etc/下的文件,不包括/etc/目录
ansible all -m copy -a "src=/etc/ dest=/backup"
```

### Fetch

```plain
# 从远程主机提取文件到ansible服务器,与copy相反,不支持目录
ansible all -m fetch -a "src=/root/test.sh dest=/root/test.sh"
```

### File

```plain
# 设置文件属性,创建软链接

# 创建空文件
ansible all -m file -a "path=/data/test.txt state=touch"
ansible all -m  file  -a 'path=/data/test.txt state=absent'
ansible all -m file -a "path=/data/test.txt owner=root mode=755

# 创建目录
ansible all -m file -a "path=/data/mysql state=direcotory owner=mysql group=mysql"

# 创建软链接
ansible all -m file -a "src=/data/testfile path|dest|name=/data/testfile-link state=link"

# 递归修改目录属性
ansible all -m file -a "path=/data/mysql state=directory owner=mysql group=mysql recurse=yes"
```

### unarchive

```plain
# 解压缩
1.将ansible主机上的压缩包传到远程主机,解压,copy=yes
2.将远程主机上的某个包,解压缩,copy=no

ansible all -m unarchive -a "src=/data/foo.tgz dest=/var/lib/foo owner=root group=bin"
ansible all -m unarchive -a 'src=/tmp/foo.zip dest=/data copy=no mode=0777'
ansible websrvs -m unarchive -a 'src=https://releases.ansible.com/ansible/ansible-2.1.6.0-0.1.rc1.tar.gz dest=/data/   owner=mysql remote_src=yes'
```

### Hostname

```plain
# 管理主机名
ansible node1 -m hostname -a "name=websrv"
```

### Cron

```plain
# 计划任务
#备份数据库脚本
[root@centos8 ~]#cat /root/mysql_backup.sh 
#!/bin/bash
mysqldump -A -F --single-transaction --master-data=2 -q -uroot |gzip > 
/data/mysql_`date +%F_%T`.sql.gz
#创建任务
ansible 10.0.0.8 -m cron -a 'hour=2 minute=30 weekday=1-5 name="backup mysql" 
job=/root/mysql_backup.sh'
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate ntp.aliyun.com 
&>/dev/null' name=Synctime"
#禁用计划任务
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 
&>/dev/null' name=Synctime disabled=yes"
#启用计划任务
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 
&>/dev/null' name=Synctime disabled=no"
#删除任务
ansible websrvs -m cron -a "name='backup mysql' state=absent"
ansible websrvs -m cron -a 'state=absent name=Synctime'
```

### Yum和Apt

```plain
ansible websrvs -m yum -a 'name=httpd state=present'  #安装
ansible websrvs -m yum -a 'name=httpd state=absent'   #删除
ansible websrvs -m yum -a 'name=sl,cowsay'

ansible websrvs -m apt -a 'name=rsync,psmisc state=absent'
```

### Service

```plain
# 管理服务
ansible all -m service -a "name=httpd state=started enabled=yes"
ansible all -m service -a "name=httpd state=stopped"
ansible all -m service -a "name=httpd state=reloaded"
```

### Lineinfile

```plain
# lineinfile功能相当sed,用于修改文件内容
ansible all -m lineinfile -a 'path=/etc/fstab state=absent regexp="^#"'
```

### Replace

```plain
#类似sed,用于基于正则匹配和替换
ansible all -m replace -a "path=/etc/fstab regexp='^(UUID.*)' replace='#\1'"
```

### Setup

```plain
# 用来收集主机的系统信息
ansible all -m setup
ansible all -m setup -a "filter=ansible_nodename"
ansible all -m setup -a "filter=ansible_hostname"
```

## playbook

```plain
ansible-playbook <file.yml> [optins]
--syntax-check	#语法检查
-C --check	#只检测可能发生的改变,不真正执行
--list-hosts	#列出运行任务的主机
--list-tags		#列出tag
--list-tasks	#列出task
-v -vv -vvv		#显示过程
```
