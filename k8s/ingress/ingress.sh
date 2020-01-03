#!/bin/bash
# File Name: -- ingress.sh --
# author: -- shidegang --
# Created Time: 2019-11-27 21:19:26

# install ingress controller
# 使用镜像nginx-ingress-controller部署一个pod
# 可以理解为使用deployment部署了一个nginx pod，该nginx将用来将请求转发到后端的service)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

# 将上一步骤中的nginx pod做为service暴露出去，使其可以接受外部流量
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

# 查看service外部端口
kubectl get svc ingress-nginx -n ingress-nginx
#NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
#ingress-nginx   NodePort   10.103.4.150   <none>        80:32543/TCP,443:31322/TCP   167m


# 创建另外一个service，假设name: myapp


# 创建ingress资源(转发规则) ingress-myapp.yaml
# ingress资源将被ingress-controller实时监听并应用(相当于ingress controller会自动加载ingress资源的最新配置并reload)
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-myapp
  namespace: default
  annotations:
    kubernets.io/ingress.class: "nginx"
spec:
  rules:
  - host: myapp.magedu.com
    http:
      paths:
      - path:
        backend:
          serviceName: myapp
          servicePort: 80

# 应用ingress资源
kubectl apply -f ingress-myapp.yaml


# 通过ingress访问名为"myapp"的service
http://node_ip:32543
https://node_ip:31322
