#!/bin/bash
# File Name: -- one_master_install.sh --
# author: -- shidegang --
# Created Time: 2022-12-21 16:23:10

# 版本信息
# CentOS Linux release 7.9.2009 (Core)
# docker 20.10.22
# k8s 1.22.9

# 服务器资源
# 172.27.3.246 k8s-master
# 172.27.3.247 k8s-node1
# 172.27.3.248 k8s-node2




### docker & k8s #####

#### 以下操作在所有节点执行 ####

## /etc/hosts
172.27.3.246 k8s-master
172.27.3.247 k8s-node1
172.27.3.248 k8s-node2

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
yum install -y kubelet-1.22.9-0 kubeadm-1.22.9-0 kubectl-1.22.9-0 --disableexcludes=kubernetes
systemctl enable kubelet



# k8s master节点上执行以下操作
# kubelet 命令补全
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo "source <(kubectl completion bash)" >> ~/.bash_profile && source ~/.bash_profile


# 生成并修改初始化配置文件
kubeadm config print init-defaults --component-configs KubeletConfiguration > /root/kubeadm.yaml
sed -i '/imageRepository/ s/k8s.gcr.io/registry.aliyuncs.com\/google_containers/p' kubeadm.yaml
sed -i '/advertiseAddress/ s/1.2.3.4/172.27.3.246/' kubeadm.yaml
sed -i '/name/ s/node/k8s-master/'  kubeadm.yaml
sed -ri '/kubernetesVersion:/ s/(kubernetesVersion: )(.*)/\11.22.9/ kubeadm.yaml
sed -i '/serviceSubnet/ a\  podSubnet: 10.244.0.0/16' kubeadm.yaml

cat >> /root/kubeadm.yaml <<EOF
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF


# 拉取镜像
kubeadm config images pull --config kubeadm.yaml
# 执行初始化
kubeadm init --config kubeadm.yaml


mkdir ~/.kube/config
cat /etc/kubernetes/admin.conf > ~/.kube/config



#  最后 ，安装网络插件 calico或者flannel二选一即可
# 安装网络插件calico,在master上执行以下两句
curl -O https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml

# 安装网络插件flannel，在master上执行以下两句
curl -O https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml





# 生成join 命令 (--token 和 --discovery-token-ca-cert-hash)
kubeadm token create --print-join-command



# 其他非root用户想使用kubectl命令执行以下操作
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

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
