# 测试环境迁移到k8s

1. mysql问题:

   mysql内token字段由100改为256,但是DBA操作错误,导致登录测试时,一直失败

2. 域名解析问题

3. apollo配置:

   早期apollo账号经过base64加密后,长度超过限制,因此mysql账号少写几位,迁移apollo后,新环境的配置,是最新的apollo账号,但是旧apollo用户密码未改,导致连接失败,pod健康检查失败
