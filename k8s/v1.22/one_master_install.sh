#!/bin/bash
# File Name: -- one_master_install.sh --
# author: -- shidegang --
# Created Time: 2022-12-21 16:23:10

# 版本信息
# CentOS Linux release 7.9.2009 (Core)
# docker 20.10.22
# k8s 1.22.9

# 至少3master 3node
# 172.27.3.246 k8s-master
# 172.27.3.247 k8s-node1
# 172.27.3.248 k8s-node2


if [ $# -ne 1 ];then
    echo "Usage: $0 <master|node1|node2|node3...>"
    exit 1
else
    k8s_hostname="k8s-$1"
fi

## /etc/hosts




### docker & k8s #####

#### 以下操作在所有节点执行 ####

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
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 更新缓存
yum clean all && yum makecache -y

# 安装k8s
# yum --showduplicates list kubelet
yum install -y kubelet-1.22.9-0 kubeadm-1.22.9-0 kubectl-1.22.9-0 --disableexcludes=kubernetes
systemctl enable kubelet

# kubelet 命令补全
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo "source <(kubectl completion bash)" >> ~/.bash_profile && source ~/.bash_profile

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


kubeadm config images pull --config kubeadm.yaml
kubeadm init --config kubeadm.yaml


mkdir ~/.kube/config
cat /etc/kubernetes/admin.conf > ~/.kube/config




# calico
curl -O https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml



# 生成join 命令 (--token 和 --discovery-token-ca-cert-hash)
kubeadm token create --print-join-command



# 其他非root用户想使用kubectl命令执行以下操作
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



# metrics-server
# 在各worker nodes上操作
# 下载镜像并重新打tag
docker pull mirrorgooglecontainers/metrics-server-amd64:v0.3.6
docker tag mirrorgooglecontainers/metrics-server-amd64:v0.3.6 k8s.gcr.io/metrics-server-amd64:v0.3.6


# 在master上操作
# https://github.com/kubernetes-sigs/metrics-server.git
git clone https://github.com/kubernetes-incubator/metrics-server.git
cd metrics-server/
# vi deploy/1.8+/metrics-server-deployment.yaml
containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
          # 以下两行增加
          - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
          - --kubelet-insecure-tls
        ports:
        - name: main-port
          containerPort: 4443
          protocol: TCP
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
        #以下两行新增
        command:
        - /metrics-server

# 启动
kubectl apply  -f 1.8+/

#检查安装是否成功
kubectl get apiservices | grep metrics
#v1beta1.metrics.k8s.io                 kube-system/metrics-server   True 29m

# 几分钟后验证效果
kubectl top nodes


kubeadm init \
--apiserver-advertise-address=当前master机器的ip \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.20.0-0 \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--control-plane-endpoint 192.168.200.214:8443 \
--upload-certs


参数描述
–apiserver-advertise-address：用于指定kube-apiserver监听的ip地址,就是 master本机IP地址。
–image-repository: 指定阿里云镜像仓库地址
–kubernetes-version: 用于指定k8s版本；
–pod-network-cidr：用于指定Pod的网络范围；10.244.0.0/16
–service-cidr：用于指定SVC的网络范围；
–control-plane-endpoint：指定keepalived的虚拟ip
–upload-certs：上传证书
