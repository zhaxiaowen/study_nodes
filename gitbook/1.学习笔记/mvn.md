# mvn

| -pl  | --projects             | Build specified reactor projects instead of all projects     | 选项后可跟随{groupId}:{artifactId}或者所选模块的相对路径(多个模块以逗号分隔) |
| ---- | ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| -am  | --also-make            | If project list is specified, also build projects required by the list | 表示同时处理选定模块所依赖的模块                             |
| -amd | --also-make-dependents | If project list is specified, also build projects that depend on projects on the list | 表示同时处理依赖选定模块的模块                               |
| -N   | --Non-recursive        | Build projects without recursive                             | 表示不递归子模块                                             |
| -rf  | --resume-from          | Resume reactor from specified project                        | 表示从指定模块开始继续处理                                   |

1. mvn clean: 清除各个模块target目录及里面的内容
2. mvn validate:
3. mvn compile: 静态编译，根据xx.java生成xx.class文件
4. mvn test: 单元测试
5. mvn package: 打包，生成各个模块下面的target目录及里面的内容
6. mvn verify:
7. mvn install： 把打好的包放入本地仓库(~/.m2/repository)
8. mvn site:
9. mvn deploy: 部署，把包发布到远程仓库

```
mvn clean package -Dmaven.test.skip=true -am -DwsBuild.path.jar=/home/jenkins/agent/workspace/wsWangYueChe-backend-dev-cardCouponClientServiceImpl/public_project/targetjar -DwsBuild.path.zip=/home/jenkins/agent/workspace/wsWangYueChe-backend-dev-cardCouponClientServiceImpl/public_project/targetzip

mvn clean package -pl cardCouponClientServiceImpl -Dmaven.test.skip=true -am -DwsBuild.path.jar=/home/jenkins/agent/workspace/wsWangYueChe-backend-dev-cardCouponClientServiceImpl/project/targetjar -DwsBuild.path.zip=/home/jenkins/agent/workspace/wsWangYueChe-backend-dev-cardCouponClientServiceImpl/project/targetzip
```

