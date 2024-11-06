#! /bin/bash
# 检测服务器内存使用情况
# create by shidg on 2024.10.15
# 运行时需要传递至少2个参数，分别是服务器ip 和服务器所在城市

# 检测服务器内存使用情况
# create by shidg on 2024.10.15
# 运行时需要传递至少2个参数，分别是服务器ip 和服务器所在城市


# 定义函数
getMemoryInfo() {
    # 定义变量
    mem_total=$(free -m | grep Mem | awk '{print $2}')
    mem_avai=$(free -m | grep Mem | awk '{print $NF}')

    # 统计内存情况
    echo "当前系统的总内存是: ${mem_total} MB"
    echo "当前系统的可用内存是： ${mem_avai} MB"
}

getCpuInfo(){
# 统计cpu情况
echo 当前系统的cpu核心数是: `lscpu | grep CPU\(s\): | awk '{print $2}'`
echo 当前系统的负载情况如下：`uptime | awk -F ':' '{print $NF}'`

}

main(){
    getMemoryInfo
    getCpuInfo
}

# 调用函数
#main



# for 循环
# 三台主机  k8s-master k8s-node1 k8s-node2

for host in k8s-master k8s-node1 k8s-node2
    do
        echo "$host"的内存使用情况如下:
        ssh $host free -m
        echo  "==================================="
    done


while true
    do
        if ps -ef | grep nginx | grep -v grep ;then
            :
        else
            echo "nginx异常，请检测"
        fi
        sleep 5
    done
    



while read line 
    do
    {
        echo $line
        sleep 1
    } &
    done  < 1
