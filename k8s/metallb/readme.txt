# https://github.com/metallb/metallb
# https://metallb.universe.tf/installation

# MetalLB 是一个用于裸机 Kubernetes 集群的负载均衡器实现，使用标准路由协议。
# k8s 并没有为裸机集群实现负载均衡器，因此我们只有在以下 IaaS 平台
#（GCP, AWS, Azure）上才能使用 LoadBalancer 类型的 service。
# 因此裸机集群只能使用 NodePort 或者 externalIPs service 来对面暴露服务，
# 然而这两种方式和 LoadBalancer service 相比都有很大的缺点。
# 而 MetalLB 的出现就是为了解决这个问题

### 限制条件
# 1)需要 Kubernetes v1.13.0 或者更新的版本
# 2）集群中的 CNI 要能兼容 MetalLB，具体兼容性参考这里 network-addons
#    像常见的 Flannel、Cilium 等都是兼容的，Calico 的话大部分情况都兼容，BGP 模式下需要额外处理
# 3）提供一下 IPv4 地址给 MetalLB 用于分配
# 一般在内网使用，提供同一网段的地址即可。
# 4）BGP 模式下需要路由器支持 BGP
# 5）L2 模式下需要各个节点间 7946 端口联通



### install

如果 kube-proxy 使用的是 ipvs 模式，需要修改 kube-proxy 配置文件，启用严格的 ARP
kubectl edit configmap -n kube-system kube-proxy
ipvs:
  strictARP: true

# Layer2 模式
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml

# 创建 IPAdressPool

cat <<EOF > IPAddressPool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  # 可分配的 IP 地址,可以指定多个，包括 ipv4、ipv6
  - 172.20.175.140-172.20.175.150
EOF

# 创建 L2Advertisement，并关联 IPAdressPool
cat <<EOF > L2Advertisement.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool #上一步创建的 ip 地址池，通过名字进行关联
EOF
