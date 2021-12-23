# 测试环境迁移到k8s

1. mysql问题:

   mysql内token字段由100改为256,但是DBA操作错误,导致登录测试时,一直失败

2. 域名解析问题

3. apollo配置:

   早期apollo账号经过base64加密后,长度超过限制,因此mysql账号少写几位,迁移apollo后,新环境的配置,是最新的apollo账号,但是旧apollo用户密码未改,导致连接失败,pod健康检查失败



#### 访问域名报`服务器异常或没网络`

1. F12,发现请求imp-test5报405错误
2. 手动访问`https://imp-test5.wsecar.com/accountWebImpl`,请求失败,不存在路径
3. 查看服务对应Service,配置正确
4. 查看imp-test5对应Ingress,发现更新转发配置,只有`/api/accountWebImpl/`转发,手动添加`/accountWebImpl`
5. 请求域名,报404,请求资源不存在.查看imp-test5的ingress配置文件,少了后半截,手动添加`rewrite ^/api/accountWebImpl/(.*) /$1 break;rewrite ^/accountWebImpl/(.*) /$1 break;`
6. 请求,回复正常
