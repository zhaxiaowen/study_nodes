# Consul

```yaml
./consul agent -dev -client 192.168.50.100   #启动
```

#### 通过API注册服务

```yaml
curl http://127.0.0.1:8500/v1/agent/service/register -X PUT -i -H "Content-Type:application/json" -d '
{
  "ID": "userServiceId", //服务id
  "Name": "userService", //服务名
  "Tags": [              //服务的tag，自定义，可以根据这个tag来区分同一个服务名的服务
    "primary",
    "v1"
  ],
  "Address": "127.0.0.1",//服务注册到consul的IP，服务发现，发现的就是这个IP
  "Port": 8000,          //服务注册consul的PORT，发现的就是这个PORT
  "EnableTagOverride": false,
  "Check": {             //健康检查部分
    "DeregisterCriticalServiceAfter": "90m",
    "HTTP": "http://www.baidu.com", //指定健康检查的URL，调用后只要返回20X，consul都认为是健康的
    "Interval": "10s"   //健康检查间隔时间，每隔10s，调用一次上面的URL
  }
  
  
  curl http://127.0.0.1:8500/v1/catalog/service/userService  # 查看服务是否注册成功
  curl http://192.168.10.10:8500/v1/health/service/userService?passing  # 健康检查
  curl -X PUT  http://192.168.50.100:8500/v1/agent/service/deregister/kafka   #删除服务
```

#### 注册kafka_exporter

http://t.zoukankan.com/Bccd-p-13365087.html

```plain
curl -X PUT -d '{"id": "kafka_export","name": "kafka_export","address": "192.168.50.100","port": 9308,"checks": [{"http": "http://192.168.50.100:9308/metrics","interval": "30s"}]}' http://192.168.50.100:8500/v1/agent/service/register
```
