```shell
# kube-proxy如果使用了IPVS模式，则必须开启严格的arp模式
kubectl edit cm -n kube-system kube-proxy
strictARP: true
kubectl get pod -n kube-system | grep kube-proxy | awk '{system("kubectl delete pod "$1 " -n kube-system")}'

# https://github.com/metallb/metallb
# https://metallb.universe.tf/installation

# MetalLB 是一个用于裸机 Kubernetes 集群的负载均衡器实现，使用标准路由协议。
# k8s 并没有为裸机集群实现负载均衡器，因此我们只有在以下 IaaS 平台
#（GCP, AWS, Azure）上才能使用 LoadBalancer 类型的 service。
# 因此裸机集群只能使用 NodePort 或者 externalIPs service 来对面暴露服务，
# 然而这两种方式和 LoadBalancer service 相比都有很大的缺点。
# 而 MetalLB 的出现就是为了解决这个问题

# MetalLb支持两种模式 L2、BGP
# L2顾名思义是二层，也就是基于arp，当创建一个svc的时候，MetalLb会从地址池中选择一个IP分配给它，作为这个svc的ExternalIP,然后选择集群中的一个节点，把该节点的mac地址广播给客户端，当用户访问ExternalIP的时候
# 请求会由这个节点来响应，节点上的kube-proxy会负责把请求转发给对应的pod，也就是在这种模式下，一个svc绑定在一个节点上，那么该节点就可能成为瓶颈，且该节点故障后，MetalLb需要重新选择一个节点，把新节点的mac
# 地址广播给客户端，在客户端更新mac地址之前，请求还会继续发给故障节点，所以有业务中断的风险

# BGP模式则是，集群中每个节点都会跟BGP Router建立BGP会话，宣告Service的ExternalIP的下一跳为集群节点本身。
# 这样外部流量就可以通过 BGP Router 接入到集群内部，BGP Router 每次接收到目的是 LoadBalancer IP 地址的新流量时，它都会创建一个到节点的新连接
# 也就是集群中的每个节点都可以响应svc的请求

### 限制条件
# 1)需要 Kubernetes v1.13.0 或者更新的版本
# 2）集群中的 CNI 要能兼容 MetalLB，具体兼容性参考这里 network-addons
#    像常见的 Flannel、Cilium 等都是兼容的，Calico 的话大部分情况都兼容，BGP 模式下需要额外处理
# 3）提供一下 IPv4 地址给 MetalLB 用于分配
# 一般在内网使用，提供同一网段的地址即可。
# 4）BGP 模式下需要路由器支持 BGP
# 5）L2 模式下需要各个节点间 7946 端口联通
```
