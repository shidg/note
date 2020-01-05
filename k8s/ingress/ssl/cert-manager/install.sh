#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2020-01-04 22:49:06

## cert-manager v0.12.0

# cert-manager可以自动进行证书的申请和续期,结合let's encrypt，实现ssl证书的免费和自动管理
# install cert-manager

kubectl create namespace cert-manager

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
# 在cert-manager.yaml的(Deployment)cert-manager.spec.template.spec.container.args下添加了三行内容作为启动参数
- --default-issuer-name=letsencrypt-prod
- --default-issuer-kind=ClusterIssuer
- --default-issuer-group=cert-manager.io
三行内容的作用是支持ingress中使用"kubernetes.io/tls-acme: "true""

# ClusterIssuer 用来从Let’s Encrypt申请证书
kubectl apply -f letsencrypt-prod.yaml

# LoadBalancer类型的nginx-ingress,并在ingress 中添加以下注解:
#kubernetes.io/tls-acme: "true"
or
#cert-manager.io/cluster-issuer: letsencrypt-prod

# 在开始为域名申请证书之前，应该保证该域名已经解析到了nginx-ingress的外网地址（ExternalIP）

