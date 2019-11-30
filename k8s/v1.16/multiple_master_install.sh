#!/bin/bash
# File Name: -- multiple_master_install.sh --
# author: -- shidegang --
# Created Time: 2019-11-29 21:07:10

# https://blog.51cto.com/13053917/2418747
# https://blog.csdn.net/fuck487/article/details/102783300

# Haproxy + keepalived




kubeadm init \
--apiserver-advertise-address=当前master机器的ip \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.16.2 \
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

注：如果由于初始化信息没设置好，已经执行了初始化命令，可以使用kubeadm reset重置。但本人部署时遇到问题，reset后，再次初始化，始终不成功。发现docker ps里面全部镜像都没启动。怀疑是reset时，某些docker相关的文件没有删除干净。通过yum remove docker-ce卸载docker，重启服务器，再重新安装docker，我的问题就解决了

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



# 添加另一个master
kubeadm join 192.168.200.214:8443 --token fo15mb.w2c272dznmpr1qil \
    --discovery-token-ca-cert-hash sha256:3455de957a699047e817f3c42b11da1cc665ee667f78661d20cfabc5abcc4478 \
    --control-plane --certificate-key bcd49ad71ed9fa66f6204ba63635a899078b1be908a69a30287554f7b01a9421
