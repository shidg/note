#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-11-22 10:08:18

# 版本信息
# docker 18.09.9
# k8s 1.16.3
# dashboard 2.0 beta6

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
yum install -y docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io

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
yum clean all && yum makecache

# 安装k8s
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet

# kubelet 命令补全
echo "source <(kubectl completion bash)" >> ~/.bash_profile && source ~/.bash_profile

# 下载镜像
# 从阿里云镜像仓库下载镜像，拉取到本地以后改回默认的镜像tag
# 脚本中的url为阿里云镜像仓库地址，version为安装的kubernetes版本
##  images.sh
#!/bin/bash
url=registry.cn-hangzhou.aliyuncs.com/google_containers
version=v1.16.3
images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
for imagename in ${images[@]} ; do
  docker pull $url/$imagename
  docker tag $url/$imagename k8s.gcr.io/$imagename
  docker rmi -f $url/$imagename
done

######  以下操作在master节点执行 ##########
# 初始化master
kubeadm init --kubernetes-version=v1.16.3 --apiserver-advertise-address 192.168.x.x --pod-network-cidr=10.244.0.0/16

# 记录下如下信息
# kubeadm join 10.10.12.63:6443 --token yjzxvz.ll846nc34snt0di0 \
    --discovery-token-ca-cert-hash sha256:9bfcd6c1cca6333fac8fd858118011a157ba70364a97846392f20e2983536906

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


######### 以下操作在node节点进行 ###########

kubeadm join 10.10.12.63:6443 --token yjzxvz.ll846nc34snt0di0 \
    --discovery-token-ca-cert-hash sha256:9bfcd6c1cca6333fac8fd858118011a157ba70364a97846392f20e2983536906

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


# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# 做如下修改
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  # 新增type行
  type: NodePort
  ports:
    - port: 443
      # 新增nodePort行
      nodePort: 30009
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard


# 启动dashboard
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
# cat dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

kubectl apply -f dashboard-adminuser.yaml

# 将admin-user用户绑定到cluster-admin角色
# cat dashboard-ClusterRoleBinding.yaml
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

kubectl apply -f dashboard-ClusterRoleBinding.yaml


# 查询admin-user用户的token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


# metrics-server
# 在node1上操作
# 下载镜像并重新打tag
docker pull mirrorgooglecontainers/metrics-server-amd64:v0.3.6
docker tag mirrorgooglecontainers/metrics-server-amd64:v0.3.6 k8s.gcr.io/metrics-server-amd64:v0.3.6


# 在master上操作
# https://github.com/kubernetes-sigs/metrics-server
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
        imagePullPolicy: IfNotPresent #修改
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







### k8s集群的监控 ###

# https://github.com/cuishuaigit/k8s-monitor
