# Nginx报499,5xx

1. 查看nginx**请求流量状态，没有增加，反而减少；不是流量突增导致故障**
2. **查看nginx响应时间监控（rpcdfe.latency）,响应时间变长**

1. **查看nginx upstream响应时间；响应时间边长，猜测后端upstream响应时间拖住nginx,导致nginx出现请求流量异常**
2. **top查看cpu，发现nginx worker cpu比较高；** 主要开销在free,malloc,json解析上面  
