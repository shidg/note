#!/bin/bash
# File Name: -- multiple_master_install.sh --
# author: -- shidegang --
# Created Time: 2019-11-29 21:07:10

# 版本信息
# CentOS 7.7
# docker 19.03.11
# docker 最好不要选择最新版本，目前k8s对docker的推荐版本如下：
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
# On each of your machines, install Docker. Version 19.03.11 is recommended, but 1.13.1, 17.03, 17.06, 17.09, 18.06 and 18.09 are 
# known to work as well. Keep track of the latest verified Docker version in the Kubernetes release notes.
# k8s 1.19.1-0
# dashboard 2.0 beta8

# 至少3master 3node
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
# 10.10.8.73 haproxy-1
# 10.10.8.78 haproxy-2
# 10.10.8.88 VIP
# 10.10.8.32 master-1
# 10.10.8.33 master-2
# 10.10.8.80 master-3
# 10.10.12.30 node1
# 10.10.12.34 node2
# 10.10.8.47  node3


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
    server  master-3 10.10.8.80:6443 check

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

# 安装必要基础工具
# chrony: 时间同步
# yum-utils: yum扩展工具
# bash-completion: systemctl命令补全
# wget: 下载
yum install chrony yum-utils bash-completion wget iptables-services -y


# 修改服务器名为期望的名字
# hostnamectl --static set-hostname xxx

# hosts文件添加所有节点的记录

# 关闭并禁用firewalld
systemctl stop firewalld && systemctl disable firewalld

# 自动加载必要模块
# br_netfilter
cat >> /etc/sysconfig/modules/br_netfilter << EOF
#! /bin/bash
modinfo -F filename br_netfilter >/dev/null 2>&1
[[ $? -eq 0  ]] && modprobe br_netfilter
EOF

# ip_vs
cat >> /etc/sysconfig/modules/ipvs.modules << EOF
#! /bin/bash
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
EOF

chmod +x /etc/sysconfig/modules/* && cat /etc/sysconfig/modules/* | bash

# 内核参数修改
cat >> /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.netfilter.nf_conntrack_max=1048576
net.nf_conntrack_max=1048576
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
yum install -y docker-ce-19.03.11 docker-ce-cli-19.03.11 containerd.io

# 启动docker
systemctl start docker && systemctl enable docker

# 配置阿里镜像源
# https://cr.console.aliyun.com

cat >> /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://v16stybc.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# 重启docker
systemctl daemon-reload && systemctl restart docker


# 添加k8s源
cat  > /etc/yum.repos.d/kubernetes.repo <<EOF
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
yum install -y kubelet-1.19.1-0 kubeadm-1.19.1-0 kubectl-1.19.1-0 --disableexcludes=kubernetes
systemctl enable kubelet

# kubelet 命令补全
# bash
echo "source <(kubectl completion bash)" >> ~/.bash_profile && source ~/.bash_profile
# zsh
echo "source <(kubectl completion zsh)" >> ~/.zshrc && source ~/.zshrc

# 下载镜像
# 从阿里云镜像仓库下载镜像，拉取到本地以后改回默认的镜像tag
# 脚本中的url为阿里云镜像仓库地址，version为安装的kubernetes版本
##  images.sh
#!/bin/bash
url=registry.cn-hangzhou.aliyuncs.com/google_containers
version=v1.19.1-0  # kubectl version
images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
for imagename in ${images[@]} ; do
  docker pull $url/$imagename
  docker tag $url/$imagename k8s.gcr.io/$imagename
  docker rmi -f $url/$imagename
done

# 拉取镜像
sh images.sh

# 查看镜像拉取结果
docker images
#REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
#k8s.gcr.io/kube-proxy                v1.19.1-0             9b65a0f78b09        2 weeks ago         86.1MB
#k8s.gcr.io/kube-apiserver            v1.19.1.-0             df60c7526a3d        2 weeks ago         217MB
#k8s.gcr.io/kube-controller-manager   v1.19.1-0             bb16442bcd94        2 weeks ago         163MB
#k8s.gcr.io/kube-scheduler            v1.19.1-0             98fecf43a54f        2 weeks ago         87.3MB
#k8s.gcr.io/etcd                      3.4.3-0             b2756210eeab        2 months ago        247MB
#k8s.gcr.io/coredns                   1.6.7               bf261d157914        3 months ago        44.1MB
#k8s.gcr.io/pause                     3.2                 da86e6ba6ca1        2 years ago         742kB

######  以下操作在master节点执行 ##########
# 初始化第一台 master
# api.k8s.com指向10.10.8.88(VIP)
kubeadm init --kubernetes-version v1.19.1-0 --control-plane-endpoint "api.k8s.com:8443" --service-cidr=10.1.0.0/16  --pod-network-cidr=10.244.0.0/16 --upload-certs

# 记录下如下信息
# 如何添加control-plane nodes:
kubeadm join api.k8s.com:8443 --token qk2l0f.6kx26ibh07jt70vt \
    --discovery-token-ca-cert-hash sha256:ca02030871e3289f8e5086958010308839b641ed2f2d043b88fb9a7ee616e64f \
    --control-plane --certificate-key 7b85308694e52adb80409a064172a8166dafdf0068da373e1968f4e1cf6aec7a

# 如何添加worker nodes:
kubeadm join api.k8s.com:8443 --token qk2l0f.6kx26ibh07jt70vt \
    --discovery-token-ca-cert-hash sha256:ca02030871e3289f8e5086958010308839b641ed2f2d043b88fb9a7ee616e64f

# 查看token
kubeadm token list

# 获取ca证书sha256编码hash值
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# token有效期为24小时，过期后需要重新生成,ca证书的hash值不变(只要初始化时生成的ca证书未更换)
kubeadm token create

# 环境变量
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile && source ~/.bash_profile

# 安装pod网络
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### 添加剩余master节点,在master-2  master-3执行
# 添加control-plane nodes
kubeadm join api.k8s.com:8443 --token qk2l0f.6kx26ibh07jt70vt \
    --discovery-token-ca-cert-hash sha256:ca02030871e3289f8e5086958010308839b641ed2f2d043b88fb9a7ee616e64f \
    --control-plane --certificate-key 7b85308694e52adb80409a064172a8166dafdf0068da373e1968f4e1cf6aec7a

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile && source ~/.bash_profile

# 其他非root用户想使用kubectl命令执行以下操作
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

######### 添加worker nodes  在node1~node3上执行 ###########
# 添加worker nodes
kubeadm join api.k8s.com:8443 --token qk2l0f.6kx26ibh07jt70vt \
    --discovery-token-ca-cert-hash sha256:ca02030871e3289f8e5086958010308839b641ed2f2d043b88fb9a7ee616e64f

# 如果不知道ca的hash值，可以使用--discovery-token-unsafe-skip-ca-verification参数跳过此项
### master上查看运行信息
kubectl get -A pods -o wide
kubectl get nodes

# kube-proxy修改为ipvs模式(默认iptables模式)
# 修改ConfigMap的kube-system/kube-proxy中的config.conf，把 mode: ""
# 改为mode:"ipvs" 保存退出即可
kubectl edit cm kube-proxy -n kube-system

# 删除当前正在运行的kube-proxy  pod, k8s会自动生成新的，并应用新的配置
kubectl get pod -n kube-system |grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'

# 确认新的pod运行正常
kubectl get pods | grep kube-proxy

# 查看日志，有 `Using ipvs Proxier.` 说明kube-proxy的ipvs 开启成功
kubectl logs kube-proxy-54qnw -n kube-system

### 安装dashboard  在master上执行 ##

# 生成自签名证书
mkdir ~/certs  && cd ~/certs

cat csr.cnf

[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = CN
ST = BeiJing
L = BeiJing
O = FEC
OU = Operations
CN = My-CA

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = 10.10.12.63
IP.2 = 127.0.0.1

[v3_ext]
keyUsage = keyEncipherment,dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
basicConstraints = CA:FALSE
authorityKeyIdentifier = keyid,issuer:always
subjectAltName = @alt_names

# 先生成自签名的CA证书
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -days 3650 -config csr.cnf

# 使用自签名的CA证书对自生成的dashboard证书进行签名
openssl genrsa -out dashboard.key 2048
openssl req -new -sha256 -key dashboard.key -out dashboard.csr -config csr.cnf
# 签发证书
openssl x509 -req -sha256 -days 3650 -in dashboard.csr -out dashboard.crt -CA ca.crt -CAkey ca.key -CAcreateserial  -extensions v3_ext  -extfile csr.cnf


# https://github.com/kubernetes/dashboard
# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

kubectl apply -f recommended.yaml

# 更新证书
# 生成dashboard使用的证书，要和dashboar在同一个namespace中(-n 参数指定namespace) 
kubectl delete secret kubernetes-dashboard-certs -n kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file="certs/dashboard.crt,certs/dashboard.key" -n kubernetes-dashboard

# 重启服务
# 删除pod，因为该Pod被Deployment管理，所以删除后k8s会自动再新建一个pod 
kubectl delete pod kubernetes-dashboard-746dfd476-b2r5f -n kubernetes-dashboard

# dashboard默认权限非常小，需要新增用户并设置权限
# 为dashboard添加用户，类型为ServiceAccount,用户名admin-user
# 并将admin-user用户绑定到cluster-admin角色
# cat dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard


kubectl apply -f dashboard-adminuser.yaml

# 查询admin-user用户的token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


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

# 待解决问题
# 1. 证书过期
# 2. 权限控制 RBAC(Role Base Access Control)的权限控制机制


kubeadm init \
--apiserver-advertise-address=当前master机器的ip \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.19.1-0 \
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






### k8s集群的监控 ###
# https://github.com/cuishuaigit/k8s-monitor
