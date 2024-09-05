# 实训阶段讲解要点

### k8s组件、作用

* [X] master节点
* [X] worker节点

---

### k8s集群规模限制

集群是运行 Kubernetes 代理的、 由[控制平面](https://kubernetes.io/zh-cn/docs/reference/glossary/?all=true#term-control-plane)管理的一组 [节点](https://kubernetes.io/zh-cn/docs/concepts/architecture/nodes/)（物理机或虚拟机）。 Kubernetes v1.30 单个集群支持的最大节点数为 5,000。 更具体地说，Kubernetes 旨在适应满足以下**所有**标准的配置：

* 每个节点的 Pod 数量不超过 110
* 节点数不超过 5,000
* Pod 总数不超过 150,000
* 容器总数不超过 300,000

---

### k8s的网络插件，calico和flannel的区别？

[参考链接](https://www.cnblogs.com/BlueMountain-HaggenDazs/p/18152648)

calico支持的工作模式

* [ ] **BGP**:           CALICO_IPV4POOL_IPIP="Never" 且 CALICO_IPV4POOL_VXLAN=”Never“
* [ ] **IP Tunnel:**   CALICO_IPV4POOL_IPIP="Always" 且 CALICO_IPV4POOL_VXLAN=”Never“
* [ ] **VXLAN** :      CALICO_IPV4POOL_IPIP="Never" 且 CALICO_IPV4POOL_VXLAN=”Always“

 flannel支持的工作模式

* [ ] VXLAN
* [ ] HOST-GW
* [ ] UDP （已废弃）

---

### k8s pod启动流程[以Deployment为例]

* [X] pod创建流程

1. 用户向APIServer发送创建请求[kubectl  或其他web客户端如kuboard、rancher] ；
2. APIServer对请求进行认证、鉴权和准入检查后，把数据存储到ETCD，创建Deployment资源并初始化；
3. controller-manager通过list-watch机制，检查到新的Deployment，将资源加入到内部工作队列，然后检查发现资源没有关联的pod和replicaset，启用Deployment controller创建replicaset资源，再通过replicaset controller创建pod。
4. controller-manager创建完成后将Deployment，replicaset，pod的信息通过apiserver更新存储到etcd；
5. scheduler通过list-watch机制，监测发现新的pod，并通过预选及优选策略算法，来计算出pod最终可调度的node节点，并通过APIServer将数据更新至etcd；
6. kubelet 每隔20s（可以自定义）向APIServer通过NodeName获取自身Node上所要运行的pod清单,通过与自己内部缓存进行比较，如果有新的资源则触发钩子调用CNI接口给pod创建pod网络，调用CRI接口去启动容器，调用CSI进行存储卷的挂载.kubelet会将Pod的运行状态上报给apiserver；
7. kube-proxy为新创建的pod注册动态DNS到CoreOS,给pod的service添加iptables/ipvs规则，用于服务发现和负载均衡；
8. Controller通过control loop（控制循环）将当前pod状态与用户所期望的状态做对比，如果当前状态与用户期望状态不同，则controller会将pod修改为用户期望状态，实在不行会将此pod删掉，然后重新创建pod。

---

### k8s数据备份

1. [X] etcd备份
2. [X] yaml文件备份
3. [X] 镜像备份
4. [X] 共享存储

---

### POD生命周期？(POD有哪些阶段？)

注意某些状态不属于pod的生命周期内的阶段，如 `Terminating`

| `Pending`（悬决）   | Pod 已被 Kubernetes 系统接受，但有一个或者多个容器尚未创建亦未运行。此阶段包括等待 Pod 被调度的时间和通过网络下载镜像的时间。 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `Running`（运行中） | Pod 已经绑定到了某个节点，Pod 中所有的容器都已被创建。至少有一个容器仍在运行，或者正处于启动或重启状态。                      |
| `Succeeded`（成功） | Pod 中的所有容器都已成功终止，并且不会再重启。                                                                                |
| `Failed`（失败）    | Pod 中的所有容器都已终止，并且至少有一个容器是因为失败终止。也就是说，容器以非 0 状态退出或者被系统终止。                     |
| `Unknown`（未知）   | 因为某些原因无法取得 Pod 的状态。这种情况通常是因为与 Pod 所在主机通信失败。                                                  |

---

### pod处于Pending状态，可能得原因：

1. [X] 等待拉取镜像
2. [X] 没有可用节点
3. [X] 等待PV就绪
4. [X] 分配不到IP地址

---

### k8s高可用部署

1. [X] 高可用原理
    k8s高可用包含两个关键点：

    apiserver高可用。其原理是多个apiserver实例进行负载均衡。具体的实现可以使用nginx、lvs、Haproxy作为负载均衡器，使用keepalived生成并管理VIP，客户端请求通过VPI发送给负载均衡器，然后由负载均衡器转发给某一个apiserver。由于VIP可以在多个apiserver实例之间自动漂移，所以某一个实例的宕机不会影响整个集群的可用性。

    etcd高可用。etcd本身就是一个分布式键值存储库，使用3个及以上的节点来进行集群式部署即可实现高可用。k8s支持两种方式的etcd：堆叠etcd和外部etcd。堆叠etcd运行在k8s集群内，每个master节点运行一个etcd实例，外部etcd指的是k8s集群之外单独部署的etcd。

    综上，实现k8s集群的高可用部署，分为两种情况，如果使用堆叠etcd，至少需要3台master来实现高，而使用外部etcd，则至少需要两台master。
2. [X] 部署方式

---

### k8s的证书有效期？ 如何更新证书？

* [X] 有效期查询

  ```shell
  kubeadm certs check-expiration
  ```
* [X] 证书续期

  ```shell
  kubeadm renew all
  # Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager, 
  # kube-scheduler and etcd, so that they can use the new certificates
  # 执行完此命令之后需要重启控制面Pod,并且如果是HA集群，需要在每个控制平面都执行同样的操作



  ```

---

### 静态POD,和普通POD有什么区别?

静态 Pod 在指定的节点上由 kubelet 守护进程直接管理，不需要 API 服务器监管。

 与由控制面管理的 Pod（例如，Deployment、RC、DaemonSet） 不同；kubelet 监视每个静态 Pod（在它崩溃之后重新启动）。

静态 Pod 永远都会绑定到一个指定节点上的 Kubelet。

kubelet 会尝试通过 Kubernetes API 服务器自动创建静态Pod。 这意味着节点上运行的静态 Pod 对 API 服务来说是可见的，但是不能通过 API 服务器来控制。

静态 Pod 名称将把以连字符开头的节点主机名作为后缀。

注意：如果你在运行一个 Kubernetes 集群，并且在每个节点上都运行一个静态 Pod， 就可能需要考虑使用 DaemonSet 替代这种方式；静态 Pod 的 spec 不能引用其他 API 对象 （如：ServiceAccount、 ConfigMap、 Secret 等）；静态 Pod 不支持[临时容器](https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/ephemeral-containers/)。

1. 静态Pod由kubelet进行创建，并在kubelet所在的Node上运行。
2. 由于静态Pod只受所在节点的kubelet控制，可以有效预防通过kubectl或管理工具操作的误删除，可以用来部署核心组件应用，保障应用服务总是运行稳定数量和提供稳定服务。

```shell
# 静态Pod相关的配置
# /var/lib/kubelet/config.yaml
staticPodPath: /etc/kubernetes/manifests
```

---

### k8s中的资源对象

1. [X] api资源
    kubectl api-resources
2. [X] crd资源

---

### deployment和statefulSet

deployment--->rs---->pod

1. [X] 有状态应用
2. [X] 无状态应用

---

### 如何调整deployment的副本数？

* [X] kubectl scale
* [X] kubectl edit
* [X] kubectl apply -f

---

### 创建临时svc用于调试

```shell
# NodePort
kubectl  expose deployment  <deployment_name>   --name <svc_name>  --type="NodePort"  --port  <container_port>
kubectl expose pod <pod_name>  --name <svc_name> --type="NodePort" --port <container_port>

# ClusterIP
kubectl expose deployment <deployment_name>  --name <svc_name>  --port 8080 --target-port <container_port>
kubectl expose pod <pod_name> --name <svc_name>  --port 8080 --target-port <container_port>
```

---

### 创建临时容器用于调试 (k8s version >=1.25)

```shell
# 在pod中添加一个新容器用于调试，--target用来指定原有容器的进程命名空间，以便能够在新容器中看到原容器的进程
kubectl debug <pod_name> -it  --image=busybox --target=<container_name>

# 为pod创建一个副本，并在副本中添加新容器进行调试
kubectl debug <pod_name> -it --image=ubuntu --share-processes --copy-to <pod_name_debug>
```

---

### deployment滚动更新

1. [X] k8s的更新策略 Recreate  RollingUpdate

    ```yaml
    spec:
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0
    ```
2. [X] 常用命令

    ```bash
    kubectl roolout histtory 
    kubectl roolout undo  --to-revision=2
    kubectl roolout pause
    kubectl roolout resume

    # 为更新添加注释，代替原来的--record
    kubectl annotate deployment nginx kubernetes.io/change-cause=""
    ```

    ---

### k8s数据持久化

* [X] hostPath (pod.spec.volumes:)
  ```yaml
  volumes:
  - name: ngx-log
    hostPath:
      path: /data/ngx/logs
      type: DirectoryOrCreate  # 目录不存在则自动创建,默认选项
      type: Directory # 目录必须提前创建
  ```
* [X] emptyDir
* [X] configMap
* [X] subPath

volume方式挂载，且未使用subPath选项的configMap，支持热更新；
环境变量方式使用或者使用了subPath选项，不支持热更新

```bash
spec:
  containers:
  - name: container1
    image: 
    ....
    volumeMounts:
    - name: config1
      mountPath: /etc/config/app.yaml
      subPath: application.yaml
  volumes:
  - name: config1
    configMap:
      name: my-cm1
------------
spec:
  containers:
  - name: container2
    image: 
    ....
    volumeMounts:
    - name: config2
      mountPath: /etc/config
  volumes:
  - name: config2
    configMap:
      name: my-cm2
      items:  # items未列出的key不会被加载到pod中
      - key: application.yaml
        path: app.yaml
      - key: application-uta.yaml
        path: uta.yaml

```

 secret

1. [X] opaque
2. [X] kubenetes.io/Service Account

    ```yaml
    apiVersion: v1
    kind: Secret
    # 表示这个 secret 类型
    type: kubernetes.io/service-account-token
    metadata:
      name: mycontroller
      namespace: kube-system
      annotations:
        # service account 名称
        kubernetes.io/service-account.name: "mycontroller"
    ```
3. [X] kubernetes.io/dockerconfigjson

    ```shell
    kubectl create secret docker-registry  docker-tiger \
        --docker-server="harbor.baway.org.cn:8000" \
        --docker-username="admin" \
        --docker-password="Harbor12345"
    ```

    ```shell
    kubectl create secret generic docker-auth \
        --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
        --type=kubernetes.io/dockerconfigjson
    ```

pv/pvc
pv和pvc是一一对应的绑定关系

1. [X] hostPath
2. [ ] nfs:
3. [ ] ceph
4. [X] local

    ```shell
    # cat pv-local.yml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-local
    spec :
      capacity:
        storage: 2Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Delete
      storageClassName: local-storage
      local:
        path: /data/localpv # k8s-node-03节点上的目录
      nodeAffinity:
        required:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values :
                    - k8s-node-03
    ```

    ```shell
    # cat pvc-local.yml
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: pvc-local
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
      storageClassName: local-storage  #指定sc，集群中没有这个sc不影响pvc与pv的绑定
    ```

    ```shell
    # cat local-sc.yml 
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: local-storage
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer  #延迟绑定参数，很重要
    ```

    ```shell
    # cat hostpath-nginx-pod.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: hostpath-nginx-pod
      labels:
        app: hostpath-nginx-pod
    spec:
      volumes:
      - name: pv-hostpath
        persistentVolumeClaim:
          claimName: pvc-local  # 声明要使用的pvc
      nodeSelector:
        kubernetes.io/hostname: k8s-node-01  指定只能运行在k8s-node-01节点上
      containers:
      - name: nginx-pod
        image: nginx:1.7.5
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: pv-hostpath
    ```
5. [X] pv的访问模式、回收策略、状态各有哪些？
    访问模式：

* ReadWriteOnce（RWO）：读写权限，但是只能被单个节点挂载
* ReadOnlyMany（ROX）：只读权限，可以被多个节点挂载
* ReadWriteMany（RWX）：读写权限，可以被多个节点挂载

5. [X] 回收策略

* Retain：该策略表示保留PV中的数据，不进行回收，必须手动处理。
* Delete：该策略表示在PV释放后自动删除PV中的数据。
* Recycle：该策略表示在PV释放后自动执行清除操作，使PV可以重新使用

  ```shell
  #在Kubernetes中，持久卷（Persistent Volume，PV）的回收策略可以通过persistentVolumeReclaimPolicy字段来定义。这个字段有以下几个可选值：
  # 1. Retain：保留持久卷，不进行自动回收。当持久卷使用完成后，需要手动进行清理和释放。
  # 2. Delete：删除持久卷，当持久卷不再被使用时，Kubernetes会自动删除并释放它。
  # 3. Recycle：回收持久卷，当持久卷不再被使用时，Kubernetes会自动进行回收操作。这种回收策略主要适用于一些旧的存储后端，它会尝试清空持久卷中的数据，但不会保证数据安全。
  # 需要注意的是，Recycle回收策略已经在Kubernetes v1.14版本中被废弃，不再推荐使用。
  # 推荐使用动态卷供应商的回收机制，例如使用StorageClass的reclaimPolicy字段来定义回收策略。
  # 另外，持久卷声明（Persistent Volume Claim，PVC）可以通过persistentVolumeReclaimPolicy字段来覆盖持久卷的回收策略。这样可以在PVC级别上定义不同的回收策略，而不影响底层的持久卷。
  # 总结起来，持久卷的回收策略可以通过persistentVolumeReclaimPolicy字段来定义，可选值包括Retain、Delete和废弃的Recycle。建议使用动态卷供应商的回收机制来定义回收策略<StorageClass>
  ```

---

### pv的状态

1. [X] Available
2. [X] Bound
3. [X] Released
4. [X] Failed

---

### k8s探针

1. [X] 启动

    ```yaml
    #  startupProbe:
          #    httpGet:
          #      path: /
          #      port: 80
          #    initialDelaySeconds: 10 #延迟加载时间
          #    failureThreshold: 3 #检测失败3次表示未就绪
          #    periodSeconds: 10 #重试时间间隔
          #    timeoutSeconds: 3 #超时时间设置
          #    successThreshold: 1 #检查成功为1次表示就绪
    ```
2. [X] 就绪

    ```yaml
    #readinessProbe:
            #  exec:
            #    command:
            #    - cat
            #    - /usr/share/nginx/html/ready.html
            #  initialDelaySeconds: 10 #延迟加载时间
            #  failureThreshold: 3 #检测失败3次表示未就绪
            #  periodSeconds: 10 #重试时间间隔
            #  timeoutSeconds: 3 #超时时间设置
            #  successThreshold: 1 #检查成功1次表示就绪
    ```
3. [X] 存活

    ```yaml
    #livenessProbe:
            #  exec:
            #    command:
            #    - cat
            #    - /usr/share/nginx/html/ready.html
            #  failureThreshold: 3 #检测失败5次表示未就绪
            #  periodSeconds: 10 #重试时间间隔
            #  timeoutSeconds: 3 #超时时间设置
            #  successThreshold: 1 #检查成功1次表示就绪
    ```

---

### k8s排错

1. [X] kubectl  describe
2. [X] kubectl  logs  -f  <--previous>
3. [X] kubectl  get  events  --sort-by='.metadata.creationTimestamp'    --sort-by='.lastTimestamp'

---

### k8s弹性扩缩容

1. [X] HPA
    kubectl autoscale

    ```shell
    kubectl autoscale  deployment  `<deployment_name> --cpu-percent=10  --min=1 --max=5
    ```

    pod级的resource

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: nginx-hpa
      namespace: default
    spec:
      # HPA的伸缩对象描述，HPA会动态修改该对象的pod数量
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: nginx-deployment
      # HPA的最小pod数量和最大pod数量
      minReplicas: 1
      maxReplicas: 10
      # 监控的指标数组，支持多种类型的指标共存
      metrics:
      # Resource类型的指标
      - type: Resource
        resource:
          name: cpu
          # Utilization类型的目标值，Resource类型的指标只支持Utilization和AverageValue类型的目标值
          target:
            type: Utilization
            averageUtilization: 10
          #name: memory
          #target:
          #  type: Utilization
          #  averageUtilization: 60
    ```

    容器级的resource [需要k8s版本1.30及以上]

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: nginx-hpa
      namespace: default
    spec:
      # HPA的伸缩对象描述，HPA会动态修改该对象的pod数量
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: nginx-deployment
      # HPA的最小pod数量和最大pod数量
      minReplicas: 1
      maxReplicas: 10
      # 监控的指标数组，支持多种类型的指标共存
      metrics:
      # ContainerResource类型的指标[k8s1.30+]
      - type: ContainerResource
        containerResource:
          name: cpu
          container: nginx
          # Utilization类型的目标值，Resource类型的指标只支持Utilization和AverageValue类型的目标值
          target:
            type: Utilization
            averageUtilization: 10
          #name: memory
          #target:
          #  type: Utilization
          #  averageUtilization: 60
    ```

    扩缩策略[k8s版本1.23及以上]

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: nginx-hpa
      namespace: default
    spec:
      # HPA的伸缩对象描述，HPA会动态修改该对象的pod数量
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: nginx-deployment
      # HPA的最小pod数量和最大pod数量
      minReplicas: 1
      maxReplicas: 10
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300 #稳定窗口
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
          - type: Pods
            value: 4
            periodSeconds: 15
          selectPolicy: Max
          #selectPolicy: Min
          #selectPolicy: Disabled


      # 监控的指标数组，支持多种类型的指标共存
      metrics:
      # ContainerResource类型的指标[k8s1.30+]
      - type: ContainerResource
        containerResource:
          name: cpu
          container: nginx
          # Utilization类型的目标值，Resource类型的指标只支持Utilization和AverageValue类型的目标值
          target:
            type: Utilization
            averageUtilization: 10
          #name: memory
          #target:
          #  type: Utilization
          #  averageUtilization: 60
    ```

    HPA支持的四种类型的指标

    ```yaml
    apiVersion: autoscaling/v2beta2
    kind: HorizontalPodAutoscaler
    metadata:
      name: php-apache
      namespace: default
    spec:
      # HPA的伸缩对象描述，HPA会动态修改该对象的pod数量
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: php-apache
      # HPA的最小pod数量和最大pod数量
      minReplicas: 1
      maxReplicas: 10
      # 监控的指标数组，支持多种类型的指标共存
      metrics:
      # Object类型的指标
      - type: Object
        object:
          metric:
            # 指标名称
            name: requests-per-second
          # 监控指标的对象描述，指标数据来源于该对象
          describedObject:
            apiVersion: networking.k8s.io/v1beta1
            kind: Ingress
            name: main-route
          # Value类型的目标值，Object类型的指标只支持Value和AverageValue类型的目标值
          target:
            type: Value
            value: 10k
      # Resource类型的指标
      - type: Resource
        resource:
          name: cpu
          # Utilization类型的目标值，Resource类型的指标只支持Utilization和AverageValue类型的目标值
          target:
            type: Utilization
            averageUtilization: 50
      # Pods类型的指标
      - type: Pods
        pods:
          metric:
            name: packets-per-second
          # AverageValue类型的目标值，Pods指标类型下只支持AverageValue类型的目标值
          target:
            type: AverageValue
            averageValue: 1k
      # External类型的指标
      - type: External
        external:
          metric:
            name: queue_messages_ready
            # 该字段与第三方的指标标签相关联，（此处官方文档有问题，正确的写法如下）
            selector:
              matchLabels:
                env: "stage"
                app: "myapp"
          # External指标类型下只支持Value和AverageValue类型的目标值
          target:
            type: AverageValue
            averageValue: 30
    ```



    使用prometheus-adapter提供custom和external接口，以为HPA提供Pods和External两种类型的指标

```yaml
# values.yaml  when install prometheus-adapter with helm

rules:
  default: false

# vabeta1.custom.metrics.k8s.io
  custom:
    - seriesQuery: '{__name__="kube_pod_container_status_running",pod!="",container!="POD",namespace!=""}'
      resources:
        overrides:
          namespace:
            resource: namespace
          pod:
            resource: pods
      name:
        matches: "^(.*)"
        as: "container_running"
      metricsQuery: 'sum(<<.Series>>{<<.LabelMatchers>>}) by (<<.GroupBy>>)'

  # Mounts a configMap with pre-generated rules for use. Overrides the
  # default, custom, external and resource entries
  # existing:

# vabeta1.external.metrics.k8s.io
  external:
    - seriesQuery: '{__name__="istio_requests_total",destination_service_namespace!=""}'
      resources:
        overrides:
          destination_service_namespace:
            resource: namespace
      name:
        matches: "^(.*)"
        as: "http_requests_per_second"
      metricsQuery: 'sum(rate(<<.Series>>{<<.LabelMatchers>>}[5m])) by (<<.GroupBy>>)'

# # vabeta1.metrics.k8s.io
  resource:
    cpu:
      containerQuery: |
        sum by (<<.GroupBy>>) (
          rate(container_cpu_usage_seconds_total{container!="",<<.LabelMatchers>>}[3m])
        )
      nodeQuery: |
        sum  by (<<.GroupBy>>) (
          rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal",<<.LabelMatchers>>}[3m])
        )
      resources:
        overrides:
          instance:
            resource: node
          namespace:
            resource: namespace
          pod:
            resource: pod
      containerLabel: container
    memory:
      containerQuery: |
        sum by (<<.GroupBy>>) (
          avg_over_time(container_memory_working_set_bytes{container!="",<<.LabelMatchers>>}[3m])
        )
      nodeQuery: |
        sum by (<<.GroupBy>>) (
          avg_over_time(node_memory_MemTotal_bytes{<<.LabelMatchers>>}[3m])
          -
          avg_over_time(node_memory_MemAvailable_bytes{<<.LabelMatchers>>}[3m])
        )
      resources:
        overrides:
          instance:
            resource: node
          namespace:
            resource: namespace
          pod:
            resource: pod
      containerLabel: container
    window: 3m


#  templates/configmap.yaml when install prometheus-adapter with helm
{{- if .Values.rules.custom }}
{{ toYaml .Values.rules.custom | indent 4 }}
{{- end -}}
{{- end -}}
{{- if .Values.rules.external }}
    externalRules:
{{ toYaml .Values.rules.external | indent 4 }}
{{- end -}}
{{- if .Values.rules.resource }}
    resourceRules:
{{ toYaml .Values.rules.resource | indent 6 }}
{{- end -}}


# kl get apiservices.apiregistration.k8s.io | grep metrics
v1beta1.custom.metrics.k8s.io          default/prometheus-adapter   True        42h
v1beta1.external.metrics.k8s.io        default/prometheus-adapter   True        15h
v1beta1.metrics.k8s.io                 default/prometheus-adapter   True        43h

# 查看指标数据 
# pods类型
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/{namespace_name}/pods/{pod_name}/{metrics_name}" | jq
# {namespace_name}和{pod_name}都可以替换为*

# 没有pod标签的指标查询
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/{namespace_name}/metrics/{metrics_name}" | jq

# external类型指标查询
kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1/namespaces/{namespace_name}/{metrics_name}" | jq


```

2. [ ] VPA

---

### k8s服务质量(QoS)

1. [X] Guaranteed

    Pod 里的每个容器都必须有内存/CPU 限制和请求，而且值必须相等
2. [X] Burstable

    Pod 里至少有一个容器有内存或者 CPU 请求且不满足 Guarantee 等级的要求，即内存/CPU 的值设置的不同
3. [X] BestEffort

    容器必须没有任何内存或者 CPU 的限制或请求

---

### pod优先级

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority-nonpreempting
value: 1000000
preemptionPolicy: Never  #非抢占式
globalDefault: false  #这个 PriorityClass 的值是否用于没有 priorityClassName 的 Pod
description: "This priority class will not cause other pods to be preempted."
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  priorityClassName: high-priority-nonpreempting
```

---

### k8s资源配额

 pod.spec.resources

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

---

ResourceQuota

`apiserver`的 `--enable-admission-plugins=` 参数中包含 `ResourceQuota`

##### 计算资源配额

| 资源名称             | 描述                                                               |
| -------------------- | ------------------------------------------------------------------ |
| limits.cpu           | 所有非终止状态的 Pod，其 CPU 限额总量不能超过该值。                |
| limits.memory        | 所有非终止状态的 Pod，其内存限额总量不能超过该值。                 |
| requests.cpu         | 所有非终止状态的 Pod，其 CPU 需求总量不能超过该值。                |
| requests.memory      | 所有非终止状态的 Pod，其内存需求总量不能超过该值。                 |
| hugepages-`<size>` | 对于所有非终止状态的 Pod，针对指定尺寸的巨页请求总数不能超过此值。 |
| cpu                  | 与 `requests.cpu` 相同。                                         |
| memory               | 与 `requests.memory`相同。                                       |

##### 存储资源配额

| 资源名称                                                                    | 描述                                                                                                                                                                                  |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| requests.storage                                                            | 所有 PVC，存储资源的需求总量不能超过该值                                                                                                                                              |
| persistentvolumeclaims                                                      | 在该命名空间中所允许的[PVC](https://kubernetes.io/zh-cn/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) 总量。                                                         |
| `<storage-class-name>`.storageclass.storage.k8s.io/requests.storage       | 在所有与 `<storage-class-name>` 相关的持久卷申领中，<br />存储请求的总和不能超过该值。                                                                                              |
| `<storage-class-name>`.storageclass.storage.k8s.io/persistentvolumeclaims | 在与 storage-class-name 相关的所有持久卷申领中，<br />命名空间中可以存在的[持久卷申领](https://kubernetes.io/zh-cn/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)总数 |
| requests.ephemeral-storage                                                  | 在命名空间的所有 Pod 中，本地临时存储请求的总和不能超过此值。                                                                                                                         |
| limits.ephemeral-storage                                                    | 在命名空间的所有 Pod 中，本地临时存储限制值的总和不能超过此值。                                                                                                                       |
| ephemeral-storage                                                           | 与 `requests.ephemeral-storage` 相同。                                                                                                                                              |

##### 对象数量配额

| 资源名称               | 描述                                                                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| configmaps             | 在该命名空间中允许存在的 ConfigMap 总数上限                                                                                           |
| persistentvolumeclaims | 在该命名空间中允许存在的[PVC](https://kubernetes.io/zh-cn/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) 的总数上限。 |
| pods                   | 在该命名空间中允许存在的非终止状态的 Pod 总数上限。Pod 终止状态等价于 Pod 的 `.status.phase in (Failed, Succeeded)` 为真            |
| replicationcontrollers | 在该命名空间中允许存在的 ReplicationController 总数上限。                                                                             |
| resourcequotas         | 在该命名空间中允许存在的 ResourceQuota 总数上限。                                                                                     |
| services               | 在该命名空间中允许存在的 Service 总数上限                                                                                             |
| services.loadbalancers | 在该命名空间中允许存在的 LoadBalancer 类型的 Service 总数上限                                                                         |
| services.nodeports     | 在该命名空间中允许存在的 NodePort 或 LoadBalancer 类型的 Service 的 NodePort 总数上限。                                               |
| secrets                | 在该命名空间中允许存在的 Secret 总数上限。                                                                                            |

##### 配额作用域

| 作用域                    | 描述                                                                                                                         |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Terminating               | 匹配所有 `spec.activeDeadlineSeconds` 不小于 0 的 Pod                                                                      |
| NotTerminating            | 匹配所有 `spec.activeDeadlineSeconds` 是 nil 的 Pod                                                                        |
| BestEffort                | 匹配所有 Qos 是 BestEffort 的 Pod                                                                                            |
| NotBestEffort             | 匹配所有 Qos 不是 BestEffort 的 Pod。                                                                                        |
| PriorityClass             | 匹配所有引用了所指定的[优先级类](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/pod-priority-preemption)的 Pod。 |
| CrossNamespacePodAffinity | 匹配那些设置了跨名字空间[（反）亲和性条件](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/assign-pod-node)的 Pod |

`BestEffort` 作用域限制配额跟踪以下资源：

* `pods`

`Terminating`、`NotTerminating`、`NotBestEffort` 和 `PriorityClass` 这些作用域限制配额跟踪以下资源：

* `pods`
* `cpu`
* `memory`
* `requests.cpu`
* `requests.memory`
* `limits.cpu`
* `limits.memory`

`scopeSelector` 支持在 `operator` 字段中使用以下值：

* `In`
* `NotIn`
* `Exists`
* `DoesNotExist`

定义 `scopeSelector` 时，如果使用以下值之一作为 `scopeName` 的值，则对应的 `operator` 只能是 `Exists`。

* `Terminating`
* `NotTerminating`
* `BestEffort`
* `NotBestEffort`

如果 `operator` 是 `In` 或 `NotIn` 之一，则 `values` 字段必须至少包含一个值

```yaml
scopeSelector:
    matchExpressions:
      - scopeName: PriorityClass
        operator: In
        values:
          - middle
```

##### 基于优先级类(PriorityClass)设置资源配额

```yaml
apiVersion: v1
kind: List
items:
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-high
  spec:
    hard:
      cpu: "1000"
      memory: 200Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator: In
        scopeName: PriorityClass
        values: ["high"]
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-medium
  spec:
    hard:
      cpu: "10"
      memory: 20Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator: In
        scopeName: PriorityClass
        values: ["medium"]
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-low
  spec:
    hard:
      cpu: "5"
      memory: 10Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator: In
        scopeName: PriorityClass
        values: ["low"]
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-priority
spec:
  containers:
  - name: high-priority
    image: ubuntu
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
    resources:
      requests:
        memory: "10Gi"
        cpu: "500m"
      limits:
        memory: "10Gi"
        cpu: "500m"
  priorityClassName: high
```

3. [ ] LimitRange

    `apiserver`的 `--enable-admission-plugins=` 参数中包含 `LimitRanger`

---

### 集群中出现很多"Evicted"状态的POD可能是什么原因造成的?

### k8s日志定制

1. [X] docker

    ```shell
    # vim /etc/docker/daemon.json

    {
      "registry-mirrors": ["http://f613ce8f.m.daocloud.io"],
      "log-driver":"json-file",
      "log-opts": {"max-size":"500m", "max-file":"3"}   
    }
    ```
2. [X] containerd
    kubelet的配置文件中，添加如下配置：

    ```shell
    --container-log-max-files=10
    --container-log-max-size="100Mi"
    ```

---

### 如何修改docker的默认存储路径，为什么要修改

/etc/docker/daemon.json:

"data-root/graph": "/home/xxx"

---

### k8s服务暴露

1. service

   1. [X] ClusterIP
       1.1 无头服务
   2. [X] NodePort
   3. [X] Loadbalancer
   4. [X] ExternalIP
   5. [X] ExternalName #pod跨namespace调用service
2. ingress

   1. [X] ingress-nginx
   2. [X] contour
   3. [X] Traefik

---

### 服务网格

* [X] istio
* [X] skywalking

---

### pod中的应用如何获取用户真实IP

svc的externalTrafficPolicy选项设置为Local

---

### hostPort、hostNetwork的区别？

1. [X] 网络地址空间不同。hostport使用CNI分配的地址，hostNetwork使用宿主机网络地址空间；
2. [X] 宿主机端口生成。hostport宿主机不生成端口，hostNetwork宿主机生成端口；
3. [X] hostport通过iptables防火墙的nat表进行转发，hostNetwork 直接通过主机端口到容器中
4. [X] 配置层级不同：

    hostPort是container级别

    deploy.spec.template.spec.containers.ports.hostPort

    hostNetwork是pod级别

    deploy.spec.template.spec.hostNetwork

* [X] 优先级不同，hostNetwork高于hostPort

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:stable-alpine
        ports:
        - containerPort: 80
          hostPort: 10000
          name: http
          protocol: TCP
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet    ## 注意这，hostNetwork下，需要搭配对应的dns策略
      containers:
      - name: nginx
        image: nginx:stable-alpine
```

---

### pod的DNS配置

* [X] dnsPolicy

1. Default: Pod 从运行所在的节点继承名称解析配置。
2. ClusterFirst:  该参数的默认值。与配置的集群域后缀不匹配的任何 DNS 查询（例如 "www.kubernetes.io"） 都会由 DNS 服务器转发到上游名称服务器。集群管理员可能配置了额外的存根域和上游 DNS 服务器。
3. ClusterFirstWithHostNet: 对于以 hostNetwork 方式运行的 Pod，应将其 DNS 策略显式设置为 "ClusterFirstWithHostNet"。否则，以 hostNetwork 方式和 "ClusterFirst" 策略运行的 Pod 将会做出回退至 "Default" 策略的行为。注意：这在 Windows 上不支持。
4. None: 此设置允许 Pod 忽略 Kubernetes 环境中的 DNS 设置。Pod 会使用其 dnsConfig 字段所提供的 DNS 设置。
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: demo
     namespace: default
   spec:
     containers:
     - image: base/java
       command:
         - "java -jar /opt/app.jar"
       imagePullPolicy: IfNotPresent
       name: demo
     restartPolicy: Always
     dnsPolicy: ClusterFirst

   ```

* [X] dnsConfig
  dnsConfig可以和任何dns策略共存，dnsConfig中指定选项值将会合并到基于dnsPolicy生成的同名选项中，并删除重复项
  但是当dnsPolicy设置为None的时候，必须使用dnsConfig来自定义dns配置

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: demo
    namespace: default
  spec:
    containers:
    - image: base/java
      command:
        - "java -jar /opt/app.jar"
      imagePullPolicy: IfNotPresent
      name: demo
    restartPolicy: Always
    dnsPolicy: None
    dnsConfig:
      nameservers:
        - 172.xxx.xxx.201
      searches:
        - ns1.svc.cluster.local
        - my.dns.search.suffix
      options:
        - name: ndots
          value: "2"
        - name: edns0
  ```

---

### Pod的重启策略

1. [X] Always：容器失效时，自动重启该容器，这是默认值
2. [X] OnFailure：容器停止运行且退出码不为0时重启
3. [X] Never：不论状态为何，都不重启该容器

---

### 镜像的拉取策略：`<pod.containers.imagePullPolicy>`

* [X] Always  <默认值>
* [X] IfNotPresent
* [X] Nerver

---

### pod的调度策略有哪些

1. [X] nodeSelector
2. [X] nodeName
3. [X] taints & tolerations (污点和容忍度) `<pod.spec.tolerations>`

    ```yaml
    tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Equal"
      value: "value1"
      effect: "NoSchedule"
      tolerationSeconds: 3600
    #- key: "key1"
    #  operator: "Exists"
    #  effect: "NoSchedule"

    # 如果 operator 是 Equal，则toleration的key、value都必须与污点相同
    # 此时如果effect 为空，表示可以与键名为key的任意效果相匹配。

    # 如果 operator 是 Exists,容忍度不能指定value，且key和effect都可以为空或省略
    # 如果一个容忍度的 key 为空且 operator 为 Exists， 
    # 表示这个容忍度与任意的 key、value 和 effect 都匹配，即这个容忍度能容忍任何污点。

    ```
4. [X] 亲和与反亲和 (node的亲和反亲和、pod的亲和反亲和 )
    4.1 node亲和性 `<pod.spec.affinity>`

    ```yaml
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/e2e-az-name
              operator: In
              values:
              - e2e-az1
              - e2e-az2
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
            - key: another-node-label-key
              operator: In
              values:
              - another-node-label-value

    # requiredDuringSchedulingIgnoredDuringExecution，这个是必须满足
    # preferredDuringSchedulingIgnoredDuringExecution，这个是优先满足，如果实在不能满足的话，则允许一些pod在其它地方运行
    # In，NotIn，Exists，DoesNotExist，Gt，Lt。你可以使用 NotIn 和 DoesNotExist 来实现节点反亲和行为，
    # 或者使用节点污点将 #pod 从特定节点中驱逐。
    # 如果同时指定了nodeSelector 和 nodeAffinity，两者必须都要满足，才能将 pod 调度到候选节点上。
    # 如果指定多个与 nodeAffinity 类型关联的 nodeSelectorTerms，其中一个 nodeSelectorTerms满足即可调度
    # 如果指定多个与 nodeSelectorTerms 关联的 matchExpressions，必须所有 matchExpressions 满足才能调度
    ```

    4.2 Pod亲和性

    ```yaml
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - web-store
          topologyKey: "kubernetes.io/hostname"
      podAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - store
          topologyKey: "kubernetes.io/hostname"

    # topologyKey可以设置成如下几种类型
    #kubernetes.io/hostname　　＃Node
    #failure-domain.beta.kubernetes.io/zone　＃Zone
    #failure-domain.beta.kubernetes.io/region #Region
    #可以设置node上的label的值来表示node的name,zone,region等信息，pod的规则中指定topologykey的值表示指定topology范围内的node上运行的pod满足指定规则
    ```

    示例：node硬亲和、Pod软反亲和

    ```yaml
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: abc.com/zhongtai
              operator: In
              values:
              - standard
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 50
          podAffinityTerm:
            labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - nginx
            topologyKey: "kubernetes.io/hostname"

    ```

---

### PDB(Pod Disruption Budgets)    k8s v1.21之后才成为stable版本

对于对 高可用要求很高的一些[容器](https://cloud.tencent.com/product/tke?from_column=20065&from=20065)化应用，例如一些 有状态的工作负载，比如[数据库](https://cloud.tencent.com/solution/database?from_column=20065&from=20065)，分布式协调服务等， K8s 集群中 Pod 频繁的调度是不能容忍的一件事。尤其涉及到应用集群数据 同步，共识，心跳等诸多因素. 容易造成可用性降低，数据延迟甚至潜在的**数据丢失**。

集群中的 Pod 正常情况下不会频繁的调度，即使存在大量的超售超用，也可以通过 Qos 等手段在准入的时候控制。当然，除非有人操作，或者节点故障等一些因素的干扰

* [ ] 自愿干扰
* [ ] 非自愿干扰

用最简单的话描述，`Pod Disruption Budgets(PDB)`是 K8s 中的一项功能，可以确保在进行 维护、升级或扩展集群等自愿操作时，不会影响应用程序的 稳定性，从而提高可用性。

一个 PodDisruptionBudget 有 3 个字段：

* `.spec.selector` 用于指定其所作用的 Pod 集合，该字段为必需字段。
* `.spec.minAvailable` 表示驱逐后仍须保证可用的 Pod 数量。即使因此影响到 Pod 驱逐 （即该条件在和 Pod 驱逐发生冲突时优先保证）。
* `.spec.maxUnavailable` （Kubernetes 1.7 及更高的版本中可用）表示驱逐后允许不可用的 Pod 的最大数量。其值可以是绝对值或是百分比。

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: zk-pdb
spec:
  minAvailable: 5
  selector:
    matchLabels:
      app: zookeeper
```

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: zk-pdb
spec:
  maxUnavailable: 30%
  selector:
    matchLabels:
      app: zookeeper
```

1. 用户在同一个 `PodDisruptionBudget` 中只能够指定 `maxUnavailable` 和 `minAvailable` 中的一个。
2. `maxUnavailable` 只能够用于控制存在 相应控制器的 Pod 的驱逐（即不受控制器控制的 Pod 不在 `maxUnavailable` 控制范围内）。
3. 如果将 `maxUnavailable` 的值设置为 0%（或 0）或设置 minAvailable 值为 100%（或等于副本数） 则会阻止所有的自愿驱逐。将无法成功地腾空(drain )运行其中一个 Pod 的节点.

---

### 如何排空一个work节点？

```shell

# 查看获取node节点名称
kubectl get node

# 先停止该节点的调度
kubectl cordon <node name>

# 命令node节点开始释放所有pod，并将节点设置为SchedulingDisabled
kubectl drain [node-name] --force --ignore-daemonsets --delete-local-data

# 恢复调度
kubectl uncordon [node-name]
```

---

### k8s为什么要弃用docker?

---

## Dockerfile中的RUN、CMD和ENTRYPOINT的区别？

###### RUN 、CMD、ENTRYPOINT

1. RUN 执行命令并创建新的镜像层，经常用于安装软件包。
2. CMD 设置容器启动后默认执行的命令及其参数，但能够被 `docker run` 后面跟的命令行参数替换。
3. ENTRYPOINT 配置容器启动时运行的命令

###### Exec、Shell

1. exec
   `<instruction>` ["executable","param1","param2",...]
   exec格式下，指令不会被shell解析，直接调用 `<command>  `

   1.1 ENTRYPOINT 的 Exec 格式用于设置要执行的命令及其参数，同时可通过 CMD 提供额外的参数，ENTRYPOINT 中的参数始终会被使用，而 CMD 的额外参数可以在容器启动时动态替换掉

   1.2 CMD有一种特殊用法，就是只有参数没有可执行命令，这种情况必须与exec格式的ENTRYPOINT组合使用，用来为ENTRYPOINT提供参数
2. shell
   `<instruction> <command>`
   shell格式下，当执行指令时，会调用/bin/sh -c  `<command>`

   2.1 **Shell 格式的ENTRYPOINT会忽略任何 CMD 或 docker run 提供的参数**

```yaml
ENV name Cloud Man  
ENTRYPOINT ["/bin/echo", "Hello, $name"]
```

以上写法，运行容器将输出 Hello,$name,因为exec格式下指令不会被shell解析

```yaml
ENV name Cloud Man  
ENTRYPOINT ["/bin/echo", "Hello, $name"]
```

若要对$name进行解析，可修改成如下写法：

```yaml
ENV name Cloud Man  
ENTRYPOINT ["/bin/sh","-c","echo Hello,$name"]
```

```yaml
ENV name Cloud Man  
ENTRYPOINT echo "Hello,$name"
```

---

### Dockerfile中的ARG和ENV的区别：

`ARG`和 `ENV`指令的最大区别在于它们的作用域。`ARG`指令定义的参数仅在构建映像期间可用，而 `ENV`指令定义的环境变量在容器运行时可用。因此，你可以使用 `ARG`指令来传递构建参数，而使用 `ENV`指令来设置容器的环境变量。

`ARG`指令可以在 `FROM`指令之前使用，但 `ENV`指令则不能。这是因为 `FROM`指令之前的任何指令都在构建上下文中执行，而 `FROM`指令之后的指令则在新的构建阶段中执行

example：

```shell
ARG VERSION=1.0
RUN echo "Version: $VERSION"
```

在这个例子中，我们定义了一个名为 `VERSION`的构建参数，并在 `RUN`指令中使用它。当我们使用 `docker build`命令构建映像时，可以使用 `--build-arg`选项来传递该参数的值。例如：

```shell
docker build --build-arg VERSION=2.0 .
```

`ENV`指令用于定义环境变量。这些变量在容器运行时是可用的，并且可以在容器内部的任何进程中使用。例如：

```shell
ENV DB_HOST localhost
```

我们定义了一个名为 `DB_HOST`的环境变量，并将其设置为 `localhost`。在容器运行时，这个环境变量将在整个容器中可用

![作用域](img/arg-env.webp)