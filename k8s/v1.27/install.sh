#!/bin/bash
# File Name: -- one_master_install.sh --
# author: -- shidegang --
# Created Time: 2023-03-20 19:37:10

# 版本信息
# CentOS Linux release 7.9.2009 (Core)
# containerd 1.7.1
# k8s 1.27.2-0

# 1 master 2 node
# 172.27.3.246 k8s-master
# 172.27.3.247 k8s-node1
# 172.27.3.248 k8s-node2
# 172.27.3.249 k8s-node3



#######  定义变量   ########
# 各节点主机名
host_name_of_master=k8s-master
host_name_of_node1=k8s-node1
host_name_of_node2=k8s-node2
host_name_of_node3=k8s-node3

# 各节点ip地址，根据自己的实际情况修改
host_ip_of_master=172.27.3.246
host_ip_of_node1=172.27.3.247
host_ip_of_node2=172.27.3.248
host_ip_of_node2=172.27.3.249


# 修改主机名
# 如果脚本是在master上跑，注释掉2、3行
# 如果脚本是在node1上跑，注释掉1、3行
# 如果脚本是在node2上跑，注释掉1、2行
hostnamectl --static set-hostname ${host_name_of_master}
#hostnamectl --static set-hostname ${host_name_of_node1}
#hostnamectl --static set-hostname ${host_name_of_node2}



#####  主机名及对应ip写入hosts文件 ######
cat >> /etc/hosts << EOF
${host_ip_of_master}  ${host_name_of_master}
${host_ip_of_node1}  ${host_name_of_node1}
${host_ip_of_node2}  ${host_name_of_node2}
${host_ip_of_node3}  ${host_name_of_node3}
EOF

# 升级内核版本
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum -y install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
yum --enablerepo=elrepo-kernel install kernel-lt -y

# 
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg


# 安装必要基础工具
# chrony: 时间同步
# yum-utils: yum扩展工具
# bash-completion: systemctl命令补全
# wget: 下载
yum install chrony yum-utils wget -y



# 关闭并禁用firewalld
systemctl stop firewalld && systemctl disable firewalld

# 关闭并禁用Selinux
setenforce 0
sed -i '/^SELINUX=/ c\SELINUX=disabled' /etc/selinux/config

# 关闭并禁用swap
swapoff -a
if grep 'swap' /etc/fstab;then
    sed -i '/swap/ s/^/#/g' /etc/fstab
fi

# 自动加载必要模块
cat >> /etc/sysconfig/modules/k8s.modules << EOF
#! /bin/bash
modprobe overlay
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
vm.overcommit_memory=1
vm.swappiness=0
fs.file-max=52706963
fs.nr_open=52706963
user.max_user_namespaces=28633
EOF

sysctl -p /etc/sysctl.d/k8s.conf


### containerd & k8s #####
## 安装containerd
# 下载解压缩
wget https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz
tar zxvf containerd-1.7.1-linux-amd64.tar.gz -C /usr/local/

# 生成初始配置文件
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml

# 配置文件修改
sed -i '/SystemdCgroup/ s/false/true/'  /etc/containerd/config.toml
sed -i '/sandbox_image/ s/registry.k8s.io\/pause:3.8/registry.aliyuncs.com\/google_containers\/pause:3.9/' /etc/containerd/config.toml
# 使用systemd管理服务
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service  -P /usr/lib/systemd/system

# 启动containerd
systemctl daemon-reload && systemctl enable --now containerd


##安装RunC
# 升级依赖(libseccomp>=2.4)
# 卸载自带libseccomp
rpm -e chrony-3.4-1.el7.x86_64
rpm -e libseccomp-2.3.1-4.el7.x86_64
# 下载安装高版本libseccomp
wget https://github.com/opencontainers/runc/releases/download/v1.1.7/libseccomp-2.5.4.tar.gz
yum install gperf
tar zxvf libseccomp-2.5.4.tar.gz && cd libseccomp-2.5.4
make && make install


# 重新安装chrony
yum install chrony -y && systemctl enable -- now chronyd

# 安装RunC
# https://github.com/opencontainers/runc
wget https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
# 验证runc
runc -v

## 安装cni
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz

## 安装crictl
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.27.0/crictl-v1.27.0-linux-amd64.tar.gz
tar zxvf crictl-v1.27.0-linux-amd64.tar.gz -C /usr/local/bin/
crictl config runtime-endpoint unix:///run/containerd/containerd.sock
# 验证
critl ps



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
yum install -y kubelet-1.27.2-0 kubeadm-1.27.2-0 kubectl-1.27.2-0 --disableexcludes=kubernetes
systemctl enable kubelet

# 使用新内核启动
echo  "K8S部署完成，系统将在10秒钟后使用新内核启动"
for i in $(seq 10| tac)
do
    echo -ne "\aThe system will reboot after $i seconds...\r"
    sleep 1
done
echo
shutdown -r now



# 以下为手动执行部分 
# master节点执行
# 生成k8s集群配置文件
kubeadm config print init-defaults --component-configs KubeletConfiguration > /root/kubeadm.yaml
sed -ri "/advertiseAddress/ s/(advertiseAddress: )(.*)/\1${host_ip_of_master}/" /root/kubeadm.yaml
sed -ri "/name/ s/(name: )(.*)/\1${host_name_of_master}/" /root/kubeadm.yaml
sed -i '/imageRepository/ s/k8s.gcr.io/registry.aliyuncs.com\/google_containers/' /root/kubeadm.yaml
sed -ri '/kubernetesVersion:/ s/(kubernetesVersion: )(.*)/\11.26.3/' /root/kubeadm.yaml
sed -i '/serviceSubnet/ a\  podSubnet: 10.244.0.0/16' /root/kubeadm.yaml

cat >> /root/kubeadm.yaml <<EOF
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF


kubeadm config images pull --config kubeadm.yaml && \
kubeadm init --config kubeadm.yaml

# 设置k8s环境变量，使kubectl可以管理集群
mkdir ~/.kube/config
cat /etc/kubernetes/admin.conf > ~/.kube/config

# kubelet 命令补全
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo "source <(kubectl completion bash)" >> ~/.bash_profile


## 从节点执行
执行kubeadm join (从master复制过来的那句)



#  最后 ，安装网络插件 calico或者flannel二选一即可
# 安装网络插件calico,在master上执行以下两句
# https://projectcalico.docs.tigera.io/manifests/calico.yaml
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl apply -f calico.yaml

# 安装网络插件flannel，在master上执行以下两句
curl -O https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml










#### 以下为一些常用操作，作为笔记使用,不需要执行 ####
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


####### 从calico切换到flannel  #########
kubectl delete -f calico.yaml #master节点
modprobe -r ipip #所有节点
rm -rf /var/lib/calico && rm -f /etc/cni/net.d/*  # 所有节点
systemctl  restart kubelet  # 所有节点
kubectl apply -f kube-flannel.yml  # master节点
# https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl  restart kubelet  #所有节点
