# Apollo

[Apollo配置中心组件讲解](https://blog.51cto.com/brucewang/2141843)

![img](https://cdn.nlark.com/yuque/0/2021/png/21484941/1636423811836-2bf10e1e-5207-4a8c-894e-85423452366b.png)

### 组件概念

#### Portal

```plain
1.提供web界面供用户使用
```

#### Admin Server

```plain
1.提供配置管理接口
2.提供配置修改、发布等接口
3.接口服务对象为Portal
```

#### Config Server

```plain
1.包含3个组件：config、meta server、euraka
Config组件：
	a：提供配置获取接口
  b: 提供配置更新推送接口；服务端使用Spring DeferredResult实现异步化，一个应用实例只会发起一个长链接
  c: 接口服务对象为Apollo客户端
Meta Server组件：
  a: Portal通过域名访问Meta Server获取Admin Service服务列表（ip+port）
  b: Client通过域名访问Meta Server获取Config Service服务列表（ip+port）
  c: Meta Server从Eureka获取Config Service和Admin Service服务列表（ip+port）
  d: 增设一个Meta Server主要是为了封装服务发现的细节，对Portal和client而言，永远是通过http接口获取Admin Service和Config Service的服务信息，不需要关心背后实际的服务注册和发现组件
  e: Meta Server只是一个逻辑角色，在部署时和Config Service是在一个JVM进程中的
Eureka组件：
	a: 基于Eureka和Spring Cloud Netflix提供服务注册和发现
  b: Config Service和Admin Service会向Eureka注册服务，并保持心跳
  c: 目前Eureka和Config Service是部署在一个JVM进程中的
```

#### Client

```plain
1.Apollo提供的客户端程序，为应用提供配置获取、实时更新等功能
2.通过Meta Server获取Config Service服务列表（ip+port），通过IP+Port访问服务
3.在client侧做load balance、错误重试
```

#### 用户访问数据流图

![img](https://cdn.nlark.com/yuque/0/2021/png/21484941/1636425014399-a8162f97-ef5f-4db0-8d14-f0b376a4142d.png)

#### 基本机制流程如下：

```plain
1. Config Service启动时候启动Config server，Meta server，Eureka三个服务 ，同时Config Server把自身注册到Eureka上面，并保持心跳。
2. Admin Server 启动时，把自身注册到Eureka 上面，并保持心跳。
3. Config Server，Admin Server都通过Meta Server连接Eureka，所以Meta Server相当于一个Eureka的客户端，提供功能接口。
4. Portal 启动时候，通过Meta Server获取Admin Service 的列表（IP:PORT）,同时通过软件实现LB，错误重试
5. Client 客户端添加到开发项目中，项目启动后，客户端会通过Meta Server获取Config service的列表，并在客户端内部实现了LB,错误重试
```



