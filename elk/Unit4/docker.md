# 关于docker命令
docker的架构：C(Client，也就是docker命令)/S (Server  docker守护进程)  

# docker客户都是能做哪些事情
1  容器
   docker  run  -v -p  -d --rm --name  <image>
   docker   start stop  restart  rm 
   docker ps -a 
   docker  logs -f  # 查看容器实时日志
   docker  inspect  #查看容器详情
   docker cp   # 容器和宿主机之间复制文件
   docker exec -it 
2  镜像
   docker images #查看本地镜像
   docker tag
   docker login registry
   docker push
   docker pull
   docker save -o xxx.tar <image>
   docker load -i xxx.tar
3  docker的网络模式
   bridge <默认的网络模式>
   host
   container
   none
4  docker的配置
   docker的配置文件：/etc/docker/daemon.json
   {
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.ustc.edu.cn"
    ],
    "default-address-pools" : [
    {
      "base" : "172.31.0.0/16",
      "size" : 24
    }
    ],
    "insecure-registries":["harbor.baway.org.cn","172.27.11.247","172.27.11.210","172.27.8.200"],
    "exec-opts": ["native.cgroupdriver=systemd"]  # 定义Cgroup的驱动
}
   
   如何解决并避免docker将根分区写满？
   方法1  修改docker的默认存储目录
   方法2  给/var/lib/docker目录单独挂载一块磁盘
   修改容器的默认网段

