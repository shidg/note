# docker install
# 1、升级所有包（这步版本够用不要随便进行，会更新系统内核，可能导致开不了机）
#yum update　　//升级所有包，同时升级软件和系统内核
(#yum upgrade   //升级所有包，不升级软件和系统内核）

2、安装依赖包
#yum install -y yum-utils device-mapper-persistent-data lvm2

3、添加aliyun docker软件包源
#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

4、添加软件包源到本地缓存
#yum makecache fast
#rpm --import https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

5、安装docker
#yum -y install docker-ce

6、设置开机启动docker
#systemctl enable docker

7、重启docker
#systemctl restart docker

8 # /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://8av7qk0l.mirror.aliyuncs.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
    ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "default-address-pools": [
    {
      "base" : "172.31.0.0/16",
      "size" : 24
    }
    ]
}


# docker-compose  install

curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmox +x /usr/local/bin/docker-compose

docker-compose -v
