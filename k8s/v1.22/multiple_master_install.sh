#!/bin/bash
# File Name: -- multiple_master_install.sh --
# author: -- shidegang --
# Created Time: 2019-11-29 21:07:10

# 版本信息
# CentOS Linux release 7.9.2009 (Core)
# docker 20.10.22
# k8s 1.22.17


# 至少3master 3node
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
# 10.10.8.73 haproxy-1
# 10.10.8.78 haproxy-2
# 10.10.8.88 VIP
# 10.10.8.32 master-1
# 10.10.8.33 master-2
# 10.10.8.34 master-3
# 10.10.12.35 node1
# 10.10.12.36 node2
# 10.10.12.37 node3


# Haproxy 两台机器同样操作
# https://github.com/haproxy/haproxy
yum install haproxy
# /etc/haproxy/haproxy.cfg
# 仅显示改动部分
defaults
    mode                    tcp
    log                     global
    option                  tcplog
frontend  k8s *:8443
    mode tcp    ## 必须
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js

#    use_backend static          if url_static
    default_backend             k8s

#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
#backend static
#    balance     roundrobin
#    server      static 127.0.0.1:4331 check

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend k8s
    mode tcp
    balance     roundrobin
    server  master-1 10.10.8.32:6443 check
    server  master-2 10.10.8.33:6443 check
    server  master-3 10.10.8.34:6443 check

systemctl start haproxy && systemctl enable haproxy


# keepalived (两台haproxy服务器)
yum install -y libnfnetlink-devel openssl-devel libnl-devel libnl3-devel
yum install -y keepalived
# /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id haproxy-2
   vrrp_skip_check_adv_addr
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_script chk_haproxy {
   script "/Data/scripts/chk_haproxy.sh" # 该脚本要给执行权限
   interval 2 # 单位分钟
}

vrrp_instance VI_1 {
    state BACKUP
    interface eno16777985
    virtual_router_id 51
    nopreempt
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_haproxy
    }
    virtual_ipaddress {
        10.10.8.88/24
    }
}

##  chk_haproxy.sh
#!/bin/bash

A=`ps -C haproxy --no-header | wc -l`

if [ $A -eq 0 ];then
    systemctl start haproxy.service
    sleep 3
    if [ `ps -C haproxy --no-header | wc -l ` -eq 0 ];then
        systemctl stop keepalived.service
    fi
fi

chmod +x chk_haproxy.sh

systemctl start keepalived && systemctl enable keepalived

### docker & k8s #####

#### 以下操作在所有节点执行 ####

## /etc/hosts
10.10.8.32 master-1
10.10.8.33 master-2
10.10.8.34 master-3
10.10.12.35 node1
10.10.12.36 node2
10.10.12.37  node3


# 升级内核版本
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum -y install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
yum --enablerepo=elrepo-kernel install kernel-lt -y

#
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg

# 使用新内核启动
reboot

# 安装必要基础工具
# chrony: 时间同步
# yum-utils: yum扩展工具
# bash-completion: systemctl命令补全
# wget: 下载
yum install chrony yum-utils bash-completion wget iptables-services -y


# 修改服务器名为期望的名字

hostnamectl --static set-hostname ${k8s_hostname}

# hosts文件添加所有节点的记录

# 关闭并禁用firewalld
systemctl stop firewalld && systemctl disable firewalld

# 关闭并禁用Selinux
systemctl stop firewalld && systemctl disable firewalld

# 自动加载必要模块
cat >> /etc/sysconfig/modules/k8s.modules << EOF
#! /bin/bash
modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack
EOF

chmod +x /etc/sysconfig/modules/k8s.modules && cat /etc/sysconfig/modules/k8s.modules | bash

# 内核参数修改
cat >> /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.netfilter.nf_conntrack_max=1048576
net.nf_conntrack_max=1048576
overcommit_memory=1
vm.swappiness=0
fs.file-max=52706963
fs.nr_open=52706963
EOF

sysctl -p /etc/sysctl.d/k8s.conf

# 禁用swap
swapoff -a

if grep 'swap' /etc/fstab;then
    sed -i '/swap/ s/^/#/g' /etc/fstab
fi

# 安装docker
# docker源
#yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io

# 配置阿里镜像源
# https://cr.console.aliyun.com
[ ! -d /etc/docker ] && mkdir -p /etc/docker

cat >> /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://8av7qk0l.mirror.aliyuncs.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
    ],
    "default-address-pools" : [
    {
      "base" : "172.31.0.0/16",
      "size" : 24
    }
    ],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# 重启docker
systemctl daemon-reload && systemctl enable docker


# 添加k8s源
cat  >> /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
EOF

# 更新缓存
yum clean all && yum makecache -y

# 安装k8s
# yum --showduplicates list kubelet
yum install -y kubelet-1.22.17-0 kubeadm-1.22.17-0 kubectl-1.22.17-0 --disableexcludes=kubernetes
systemctl enable kubelet


# k8s master-1节点上执行以下操作
# kubelet 命令补全
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion

# bash
echo "source <(kubectl completion bash)" >> ~/.bash_profile && source ~/.bash_profile
# zsh
echo "source <(kubectl completion zsh)" >> ~/.zshrc && source ~/.zshrc

# 开始初始化k8s集群
# 生成并修改初始化配置文件
kubeadm config print init-defaults --component-configs KubeletConfiguration > /root/kubeadm.yaml
# 修改后的kubeadm.yaml
cat > /root/kubeadm.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.9876543210yhgtfc
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  imagePullPolicy: IfNotPresent
  name: gfs-01
  taints: null
---
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd

# 如果etcd集群为外部独立部署，则这样连接
#etcd:
#  external:
#    endpoints:
#      - https://172.27.11.247:2379
#      - https://172.27.11.248:2379
#      - https://172.27.11.249:2379
#    caFile: /opt/etcd/ssl/ca.pem
#    certFile: /opt/etcd/ssl/server.pem
#    keyFile: /opt/etcd/ssl/server-key.pem

# 镜像仓库修改为国内仓库地址
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
# 要安装的k8s版本
kubernetesVersion: 1.22.17
# 多master模式下，指定apiserver的地址，一般为VIP地址
controlPlaneEndpoint: 10.10.8.88:8443 
# 这里列出所有master的ip地址
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - 10.10.8.32
  - 10.10.8.33
  - 10.10.8.34
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 172.31.0.0/16
scheduler: {}
---
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
logging: {}
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

# 拉取镜像 （该步骤非必要，直接执行kubeadm init会自动拉取镜像）
kubeadm config images pull --config kubeadm.yaml
# 初始化第一台master
kubeadm init --config kubeadm.yaml


# 添加其他master节点
# 将证书拷贝到其他master节点
for node in ${ip_of_master-2} ${ip_of_master-3}; do
  ssh $node "mkdir -p /etc/kubernetes/pki/etcd; mkdir -p ~/.kube/"
  scp /etc/kubernetes/pki/ca.crt $node:/etc/kubernetes/pki/ca.crt
  scp /etc/kubernetes/pki/ca.key $node:/etc/kubernetes/pki/ca.key
  scp /etc/kubernetes/pki/sa.key $node:/etc/kubernetes/pki/sa.key
  scp /etc/kubernetes/pki/sa.pub $node:/etc/kubernetes/pki/sa.pub
  scp /etc/kubernetes/pki/front-proxy-ca.crt $node:/etc/kubernetes/pki/front-proxy-ca.crt
  scp /etc/kubernetes/pki/front-proxy-ca.key $node:/etc/kubernetes/pki/front-proxy-ca.key
  scp /etc/kubernetes/pki/etcd/ca.crt $node:/etc/kubernetes/pki/etcd/ca.crt
  scp /etc/kubernetes/pki/etcd/ca.key $node:/etc/kubernetes/pki/etcd/ca.key
  scp /etc/kubernetes/admin.conf $node:/etc/kubernetes/admin.conf
  scp /etc/kubernetes/admin.conf $node:~/.kube/config

# master-2、master-3加入集群
kubeadm join 10.10.8.88:8443 --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:83370f58a593b43539175844f4d8d895d4a2be4345ae76528e92b2ee52eaba1d \
        --control-plane

# node节点加入集群
kubeadm join 10.10.8.88:8443 --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:83370f58a593b43539175844f4d8d895d4a2be4345ae76528e92b2ee52eaba1d


#  最后 ，安装网络插件 calico或者flannel二选一即可

# 安装网络插件calico,在master上执行以下两句
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.24.6/manifests/calico.yaml
kubectl apply -f calico.yaml
#注意k8s和calico的版本对应关系
# https://docs.tigera.io/calico/3.24/getting-started/kubernetes/requirements

# 安装网络插件flannel，在master上执行以下两句
curl -O https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml



################################# 其他 #########################

# 查询admin-user用户的token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


####  metrics-server
# 在master上操作
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.0/components.yaml

# 修改components.yaml
第139行之后新增一行:       - --kubelet-insecure-tls
第141行，修改为:          image: bitnami/metrics-server:0.6.0

# 启动
kubectl apply  -f  components.yaml

#检查安装是否成功
kubectl get apiservices | grep metrics
#v1beta1.metrics.k8s.io                 kube-system/metrics-server   True 29m



# 几分钟后验证效果
kubectl top nodes



#####################

# 生成join 命令 (--token 和 --discovery-token-ca-cert-hash)
kubeadm token create --print-join-command

# 生成join需要的cert key  (--certificate-key)
kubeadm init phase upload-certs --upload-certs

# 查看token
kubeadm token list
