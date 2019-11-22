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

# 关闭并禁用firewalld
systemctl stop firewalld && systemctl disable firewalld

# 修改内核参数
cat >> /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
EOF

sysctl -p /etc/sysctl.d/k8s.conf

# 禁用swap
swapoff -a

if grep 'swap' /etc/fstab;then
    sed -i '/swap/ s/^/#/g' /etc/fstab
fi

# 安装docker
# docker源
yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io

# 启动docker
systemctl start docker && systemctl enable docker

# 配置阿里镜像源
# https://cr.console.aliyun.com

cat >> /etc/docker/daemon.json <<EOF
{
  # 阿里镜像服务加速器
  "registry-mirrors": ["https://v16stybc.mirror.aliyuncs.com"],
  # cgroupdriver修改为systemd,与k8s保持一致
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

# 环境变量
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile && source ~/.bash_profile

# 安装pod网络
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


######### 以下操作在node节点进行 ###########

kubeadm join 10.10.12.63:6443 --token yjzxvz.ll846nc34snt0di0 \
    --discovery-token-ca-cert-hash sha256:9bfcd6c1cca6333fac8fd858118011a157ba70364a97846392f20e2983536906

### master上查看运行信息
kubectl get -A pods -o wide
kubectl get nodes


### 安装dashboard  在master上执行 ##

# 生成自签名证书
mkdir ~/certs  && cd ~/.certs
openssl genrsa -out tls.key 2048
openssl req -days 36000 -new -out tls.csr -key tls.key -subj '/CN=dashboard-cert'
openssl x509 -req -in tls.csr -signkey tls.key -out tls.crt

# 生成dashboard使用的证书，要和dashboar在同一个namespace中(-n 参数指定namespace) 
kubectl create namespace kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs -n kubernetes-dashboard

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

# Secret部分注释掉
#apiVersion: v1
#kind: Secret
#metadata:
#  labels:
#    k8s-app: kubernetes-dashboard
#  name: kubernetes-dashboard-certs
#  namespace: kubernetes-dashboard
#type: Opaque

kind: Deployment
apiVersion: apps/v1
    spec:
      containers:
        - name: kubernetes-dashboard
          image: kubernetesui/dashboard:v2.0.0-beta6
          imagePullPolicy: Always
          ports:
            - containerPort: 8443
              protocol: TCP
          args:
            - --auto-generate-certificates
            - --namespace=kubernetes-dashboard
            # 以下两行新增
            - --tls-cert-file=/tls.crt
            - --tls-key-file=/tls.key


# 启动dashboard
kubectl apply -f recommended.yaml

# dashboard默认权限非常小，需要新增用户并设置权限
# 为dashboard添加用户，类型为ServiceAccount,用户名admin-user
# cat dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

kubectl apply -f cat dashboard-adminuser.yaml

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
