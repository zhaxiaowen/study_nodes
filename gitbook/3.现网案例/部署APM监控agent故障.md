# 部署APM监控agent故障

#### 背景：

生产改造，所有java应用添加APM监控agent

#### 故障现象

部署agent后，生产java进程每过8小时左右会突然挂掉

#### 问题定位

1. 怀疑agent版本问题，因为其他生产环境部署2.4版本的未出现问题
2. 抓java和agent的trace给研发定位，未发现异常

1. 查看生产和测试环境的环境，发现jdk版本不一致，生产未openjdk,测试环境为jdk1.8

#### 问题处理

1. 将测试环境的jdk替换为openjdk验证，故障复现
2. 将生产的openjdk替换为jkd1.8，故障修复
