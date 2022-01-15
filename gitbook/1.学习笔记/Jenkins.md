# Jenkins

#### 调用docker

```
pipeline {
    agent {
        docker { image 'node:7-alpine' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}
```

#### cat <<-EOF>

```
def JENKINS_AGENT_NODE = "test"
def zookeeper_package="zookeeper-3.4.14-ws.tar.gz"
def middleware_list = "jdk,zookeeper,kafka,canal,azkaban,apollo_config,flink,emr_operation"

pipeline{
	agent any
    parameters{
        string(name: 'infrastructure_ips', defaultValue: '', description: '基础组件部署的ip，一般为三台，用逗号分隔')
        extendedChoice  description: '请选择安装组件', 
        multiSelectDelimiter: ',', 
        name: 'deploy_middleware',
        quoteValue: true, 
        saveJSONParameterToFile: false, 
        type: 'PT_CHECKBOX', 
        value: middleware_list, 
        visibleItemCount: 6
        booleanParam(name: 'is_topic_auto_create', defaultValue: false, description: '是否开启kafka topic自动创建，如果勾选，则表示开启')
    }
    stages{
        stage('功能测试'){
            steps{
                script{
                    if(false){
                        input_infrastructure_ips= infrastructure_ips.replaceAll('"','').split(',')
                        for(ip in input_infrastruncture_ips){
                        sh """
                        """
                        }
                    }
                }
            }
        }
        stage('安装所选组件'){
            steps{
                script{
                    if (true){
                        input_infrastructure_ips= infrastructure_ips.trim().replaceAll('"','').split(',')
                        input_master_ips=[]  
                        input_master02_ip=""
                        deploy_middleware_list = deploy_middleware.replaceAll('"','').split(',')
                        if(deploy_middleware_list.contains("jdk")){
                            for(ip in input_infrastructure_ips ){
                                sh """
                                   ssh $ip "cat <<-EOF> /root/redis-sentinel.service
[Unit]
Description=redis-sentinel
After=redis.service
 
[Service]
User=roots
Group=root
Type=forking
ExecStart=/redis_sentinel.sh start
ExecReload=/redis_sentinel.sh restart
ExecStop=/redis_sentinel.sh stop
LimitNOFILE=102400
 
[Install]
WantedBy=multi-user.target
EOF" 
                                """
                            }
                        }
                        for(middleware in deploy_middleware_list){
                            if( middleware == "jdk"){
                                continue
                            }
                            switch(middleware){
                                case "zookeeper":
                                    def i=0
                                    for(ip in input_infrastructure_ips ){
                                        i=i+1
                                        sh """
                                            echo $ip
                                        """
                                        def j=0
                                        for(ip2 in input_infrastructure_ips){
                                            j=j+1
                                            sh """
                                                echo $ip:$j
                                            """
                                            
                                        }
                                        sh """
                                            echo $ip
                                        """
                                    }
                                    break
                                case "kafka":
                                    def zk_connector=""
                                    for(ip in input_infrastructure_ips ){
                                        
                                    }
                            }
                        }
                    }
                }
            }
        }
    }


}
```



#### 部署kafka/zookeeper

```
//dtmpl_auto_deploy_middleware

@Library('jenkinslib@master') _

def log = new com.devops.Log()
//执行 pipeline 的Jenkins agent
def JENKINS_AGENT_NODE = "tc_mvn"

//部署的中间件列表
def jenkins_home="/data/hadoop/jenkins"
def middleware_list = "jdk,zookeeper,kafka,canal,azkaban,apollo_config,flink,emr_operation"
def wget_dir="http://192.168.50.100/soft"
def src_dir="/data/src"
def soft_dir="/data/soft"
def jdk_package="jdk-8u121-linux-x64.tar.gz"
def zookeeper_package="zookeeper-3.4.14-ws.tar.gz"
def kafka_package="kafka_2.12-2.2.2-ws.tgz"
def canal_package="canal.deployer-1.1.4.tar.gz"
def canal_home="/data/soft/canal/canal-deployer"
def canal_admin_address="192.168.50.100:8089"
def azkaban_exec_package="azkaban-exec-server-0.1.0-SNAPSHOT.tar.gz"
def azkaban_web_package="azkaban-web-server-0.1.0-SNAPSHOT.tar.gz"
def apollo_home="/data/wanshun/config/apollo"

pipeline {
    agent {
        node {
            label "${JENKINS_AGENT_NODE}"
        }
    }
    options { 
        buildDiscarder(logRotator(numToKeepStr: '30')) // 保留构建记录为30次
        disableConcurrentBuilds() // 关闭同时执行流水线
        timeout(time: 1, unit: 'HOURS')  // 设置流水线超时时间
        timestamps() //日志打印时间戳
    }
    parameters {
        string(name: 'infrastructure_ips', defaultValue: '', description: '基础组件部署的ip，一般为三台，用逗号分隔')
        text(name: 'emr_ips', defaultValue: '', description: 'emr节点，七台，一行写一个')
        string(name: 'azkaban_param', defaultValue: '', description: '部署azkaban所需参数，参数1部署环境，参数2依赖的数据库ip。 空格分隔，示例 fat1 127.0.0.1')
        string(name: 'config_param', defaultValue: '', description: '安装apollo config文件夹所需参数--环境名称，示例 fat1')
        string(name: 'flink_param', defaultValue: '', description: '升级flink所需参数--hdfs集群命名空间namesparce，示例 HDFS19641')
        extendedChoice  description: '请选择安装组件', 
                multiSelectDelimiter: ',', 
                name: 'deploy_middleware',
                quoteValue: true, 
                saveJSONParameterToFile: false, 
                type: 'PT_CHECKBOX', 
                value: middleware_list, 
                visibleItemCount: 6

        booleanParam(name: 'is_deploy_all', defaultValue: false, description: '是否选择所有组件，如果勾选，则上面的选项全部选中')
        booleanParam(name: 'is_topic_auto_create', defaultValue: false, description: '是否开启kafka topic自动创建，如果勾选，则表示开启')

    }
    environment {
        workDir = "${env.WORKSPACE}"       
    }


    stages {
        stage('功能测试') {
            steps {
                script {
                    if (false) {
                    input_infrastructure_ips= infrastructure_ips.replaceAll('"','').split(',')
                  
                    for(ip in  input_infrastructure_ips){
                    sh """

                    """

                    }





                    }
                }
            }
        }

        stage('安装所选组件') {
            steps {
                script {
                if( true ){

                    input_infrastructure_ips= infrastructure_ips.trim().replaceAll('"','').split(',')
                    log.info("基础节点列表: $input_infrastructure_ips")

                    input_emr_ips=emr_ips.trim().replaceAll('"','').split('\n')
                    input_master_ips=[]
                    
                    input_master02_ip=""
                    if( input_emr_ips.size() > 2 ){
                        input_master02_ip=input_emr_ips[-1]
                        input_master_ips.add(input_emr_ips[-2])
                        input_master_ips.add(input_emr_ips[-1])
                    }
                    log.info("emr master节点： $input_master_ips")           
                    log.info("master02节点: $input_master02_ip")


                    // 部署组件列表
                    if ( params.is_deploy_all ) {
                        deploy_middleware_list = middleware_list.replaceAll('"','').split(',')

                    } else {
                        deploy_middleware_list = deploy_middleware.replaceAll('"','').split(',')
                    }
                    log.info("部署的组件列表: $deploy_middleware_list")


                    if( deploy_middleware_list.contains("jdk") ){
                        log.info("开始安装jdk")
                        for(ip in input_infrastructure_ips ){
                            sh """
                            ssh $ip "sudo chown carapp. /data;mkdir -p $soft_dir;mkdir -p $src_dir"
                            ssh $ip "cd $src_dir;wget -q -c $wget_dir/jdk/$jdk_package;tar -zxf $jdk_package -C $soft_dir"
                            ssh $ip "ln -snf $soft_dir/jdk1.8.0_121 /data/jdk;chown -R carapp. /data/jdk"
                            scp ${jenkins_home}/java.sh $ip:$src_dir
                            ssh $ip "sudo mv $src_dir/java.sh /etc/profile.d/;sudo chown root. /etc/profile.d/java.sh"
                            ssh $ip "sudo -s source /etc/profile"
                            """
                            log.info("${ip}安装jdk完毕！")
                        }

                    }

                    for(middleware in deploy_middleware_list){
                        if( middleware == "jdk"){
                            continue
                        }

                        switch(middleware){
                            case "zookeeper":
                                log.info("开始安装zookeeper")
                                def i=0
                                for(ip in input_infrastructure_ips ){
                                    log.info("安装节点$ip")
                                    i=i+1
                                    sh """
                                    ssh $ip "cd $src_dir;wget -q -c $wget_dir/zookeeper/$zookeeper_package;tar -zxf $zookeeper_package -C $soft_dir"
                                    ssh $ip "ln -snf $soft_dir/zookeeper-3.4.14 /data/zookeeper"
                                    ssh $ip "echo $i >/data/zookeeper/data/myid"
                                    """
                                    def j=0
                                    for(ip2 in input_infrastructure_ips){
                                        j=j+1
                                        addStr="server.$j=$ip2:2888:3888"
                                        sh """
                                        ssh $ip "echo $addStr >>/data/zookeeper/conf/zoo.cfg"
                                        """
                                    }

                                    sh """
                                    ssh $ip "/data/zookeeper/bin/zkServer.sh start"
                                    """
                                }

                                break

                            case "kafka":
                                log.info("开始安装kafka")

                                def zk_connector=""
                                for(ip in input_infrastructure_ips ){
                                    zk_connector=zk_connector.concat("$ip").concat(":2181,")
                                }
                                zk_connector=zk_connector.substring(0,zk_connector.length()-1)
                                zk_connector=zk_connector.concat("/kafka")

                                def j=0

                                for(ip in input_infrastructure_ips ){
                                    log.info("安装节点$ip")
                                    j=j+1
                                    sh """
                                    ssh $ip "cd $src_dir;wget -q -c $wget_dir/kafka/$kafka_package;tar -zxf $kafka_package -C $soft_dir"
                                    ssh $ip "ln -snf $soft_dir/kafka_2.12-2.2.2 /data/kafka"
                                    ssh $ip "sed -i 's/^broker.id=.*/broker.id=$j/g'  /data/kafka/config/server.properties"
                                    ssh $ip "sed -i 's#^listeners=.*#listeners=PLAINTEXT://$ip:9092#g'  /data/kafka/config/server.properties"
                                    ssh $ip "sed -i 's#^zookeeper.connect=.*#zookeeper.connect=$zk_connector#g'  /data/kafka/config/server.properties"                                                                
                                    """
                                    if( params.is_topic_auto_create ){
                                        sh """
                                        ssh $ip "sed -i 's#^auto.create.topics.enable=.*#auto.create.topics.enable=true#g'  /data/kafka/config/server.properties"
                                        """
                                    }
                                    sh """
                                    scp ${jenkins_home}/kafka.sh $ip:$src_dir
                                    ssh $ip "sudo mv $src_dir/kafka.sh /etc/profile.d/;sudo chown root. /etc/profile.d/kafka.sh"
                                    ssh $ip "sudo -s source /etc/profile"
                                    ssh $ip "/data/kafka/bin/kafka-server-start.sh  -daemon /data/kafka/config/server.properties"
                                    ssh $ip "sudo -s source /etc/profile"
                                    """
                                }

                                break
                            case "canal":
                                log.info("开始安装canal")
                                
                                for(ip in input_infrastructure_ips ){
                                    log.info("安装节点$ip")                                  
                                    sh """
                                    ssh $ip "mkdir -p $canal_home"
                                    ssh $ip "cd $src_dir;wget -q -c $wget_dir/canal/$canal_package;tar -zxf $canal_package -C $canal_home"
                                    ssh $ip "ln -snf $soft_dir/canal /data/canal"
                                    ssh $ip "rm -f $canal_home/conf/canal.properties;cp $canal_home/conf/canal_local.properties $canal_home/conf/canal.properties"
                                    ssh $ip "sed -i 's#^canal.admin.manager =.*#canal.admin.manager = $canal_admin_address#g'  $canal_home/conf/canal.properties"
                                    ssh $ip "$canal_home/bin/startup.sh"
                                    """   
                                }

                                break
                            case "azkaban":
                                log.info("开始安装azkaban")
                                if(azkaban_param==""){
                                    log.error("没有输入azkaban 参数")
                                    break
                                }
                                azkaban_param_list=azkaban_param.trim().replaceAll('"','').split(' ')
                                azk_env=""
                                azk_mysql=""
                                if(azkaban_param_list.size()==2){
                                    azk_env=azkaban_param_list[0].toUpperCase()
                                    azk_mysql=azkaban_param_list[1]
                                }
                                log.info("azkaban参数azk_env azk_mysql: $azk_env $azk_mysql")
                                sh """
                                ssh $input_master02_ip "sudo chown carapp. /data;mkdir -p $soft_dir;mkdir -p $src_dir"
                                ssh $input_master02_ip "cd $src_dir;wget -q -c $wget_dir/azkaban/download/$azkaban_exec_package;tar -xzf $azkaban_exec_package -C $soft_dir"
                                ssh $input_master02_ip "cd $src_dir;wget -q -c $wget_dir/azkaban/download/$azkaban_web_package;tar -xzf $azkaban_web_package -C $soft_dir"
                                ssh $input_master02_ip "ln -snf $soft_dir/azkaban-exec-server-0.1.0-SNAPSHOT /data/azkaban-exec;ln -snf $soft_dir/azkaban-web-server-0.1.0-SNAPSHOT /data/azkaban-web"
                                ssh $input_master02_ip "sed -i 's#env#${azk_env}#g' /data/azkaban-exec/conf/azkaban.properties"
                                ssh $input_master02_ip "sed -i 's#^mysql.host=.*#mysql.host=${azk_mysql}#g' /data/azkaban-exec/conf/azkaban.properties"
                                ssh $input_master02_ip "sed -i 's#env#${azk_env}#g' /data/azkaban-web/conf/azkaban.properties"
                                ssh $input_master02_ip "sed -i 's#^mysql.host=.*#mysql.host=${azk_mysql}#g' /data/azkaban-web/conf/azkaban.properties"
                                ssh $input_master02_ip "sudo chown -R hadoop. /data/soft/azkaban-exec-server-0.1.0-SNAPSHOT;sudo chown -R hadoop. /data/soft/azkaban-web-server-0.1.0-SNAPSHOT"
                                ssh $input_master02_ip "sudo chown -R hadoop. /data/azkaban-exec;sudo chown -R hadoop. /data/azkaban-web"
                                """

                                break
                            case "apollo_config":
                                log.info("开始安装apollo_config")

                                if(config_param==""){
                                    log.error("没有输入config_param")
                                    break
                                }
                                
                                config_env=config_param.trim().substring(0,config_param.trim().length()-1).toLowerCase()
                                config_idc="Cluster-0".concat(config_param.trim().substring(config_param.trim().length()-1))
                                config_metaIp=""
                                if(config_env=="dev"){
                                    config_metaIp="172.25.53.16"
                                }else if(config_env=="fat"){
                                    config_metaIp="172.25.53.17"
                                }else if(config_env=="uat"){
                                    config_metaIp="172.25.53.18"
                                }else{
                                    log.error("apollo环境名称不正确，退出")
                                    break
                                }

                                log.info("apollo参数env meta idc： $config_env $config_metaIp $config_idc")

                                sh """
                                ssh $input_master02_ip "sudo chown carapp. /data;mkdir -p /data/wanshun/hadoop"
                                scp -r ${jenkins_home}/config $input_master02_ip:/data/wanshun
                                ssh $input_master02_ip "sed -i 's#^env=.*#env=${config_env}#g' $apollo_home/apollo-env.properties"
                                ssh $input_master02_ip "sed -i 's#^.*meta=.*#${config_env}.meta=http://${config_metaIp}:8080#g' $apollo_home/apollo-env.properties"
                                ssh $input_master02_ip "sed -i 's#^idc=.*#idc=${config_idc}#g' $apollo_home/apollo-env.properties"
                                ssh $input_master02_ip "cp -f $apollo_home/apollo-env.properties $apollo_home/dataMpl"
                                """
                                break

                            case "flink":
                                log.info("开始安装flink")
                                if(flink_param==""){
                                    log.error("没有输入flink 参数")
                                    break
                                }
                                flink_param=flink_param.trim()

                                for( i=0; i<input_emr_ips.size() ; i++ ){
                                    sh """
                                    ssh ${input_emr_ips[i]} "sudo mv /usr/local/service/flink /usr/local/service/flink.back"
                                    """
                                }
                                for(ip in input_master_ips ){
                                    sh """
                                    scp -r ${jenkins_home}/flink $ip:/home/carapp
                                    ssh $ip "sed -i 's#HDFS19641#${flink_param}#g' /home/carapp/flink/conf/flink-conf.yaml"                                    
                                    ssh $ip "sudo mv /home/carapp/flink /usr/local/service"
                                    ssh $ip "sudo chown hadoop:hadoop -R /usr/local/service/flink"
                                    ssh $ip "sudo chmod 777 /usr/local/service/flink/log -R"
                                    """  
                                }

                            case "emr_operation":
                               log.info("服务器目录权限设置")
                               for(ip in input_emr_ips){
                                   sh """
                                   ssh $ip "sudo chmod 777 /data/emr/hdfs/logs -R ; sudo chmod 777 /data/emr/hdfs/tmp -R"
                                   ssh $ip "sudo chmod 777 /data/emr/hive/logs -R ; sudo chmod 777 /data/emr/hive/tmp -R"
                                   ssh $ip "sudo chmod 777 /data/emr/spark/logs -R ; sudo chmod 777 /data/emr/yarn/logs -R ; sudo chmod 777 /data/emr/flink/logs -R"
                                   """ 
                               }
                               sh """
                               ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -mkdir -p /emr/logs && hdfs dfs -chmod -R  755 /emr'"
                               ssh $input_master02_ip "sudo yum -y install jq"
                               """
                               if(false){
                                log.info("集群hdfs目录放权")
                                   sh """
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -mkdir -p /flink/flink-jobs && hdfs dfs -mkdir -p /flink/flink-checkpoints && hdfs dfs -mkdir -p /flink/flink-savepoints && hdfs dfs -mkdir -p /flink/flink-checkpoints/fs' "
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -mkdir -p /spark-history && hdfs dfs -chmod -R  777 /spark-history' "
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -mkdir -p /usr/hive/warehouse && hdfs dfs -chmod -R 777  /usr'"
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -mkdir -p /emr/logs && hdfs dfs -chmod -R  777 /emr'"
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -chmod -R  777 /user'"
                                   ssh $input_master02_ip "sudo su - hadoop -s /bin/bash -c 'hdfs dfs -chmod -R  777 /tmp'"
                                   """
                               }
                                break
                            default :
                                log.info("Thanks You For use")
                                break                                      

                        }


                    }



                }
                }
            }
        }
    }
}

```

