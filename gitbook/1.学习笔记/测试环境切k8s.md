![k8s架构图](E:\git-project\gitbook\1.学习笔记\picture\k8s架构图.jpg)



#### k8s中的资源对象

* apiVersion:创建该对象所使用的kubernetes API版本
* kind:想要创建的对象类型
* metadata:帮助识别对象唯一性的数据,包括`name` `UID` `namespace`字段

* `spec`字段:必须提供,用来描述该对象的期望状态,以及关于对象的基本信息 

* Annotation:可以将kubernetes资源对象关联到任意的非标识行元数据
