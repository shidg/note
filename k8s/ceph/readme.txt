rook 1.13.1
k8s version >= 1.22

git clone --single-branch --branch v1.13.1 https://github.com/rook/rook.git

# 注意如果Containerd的systemd配置containerd.service中如果有LimitNOFILE=infinity的配置，后边在使用rook启动Ceph集群时，Ceph的Mon组件会有问题，会出现ms_dispatch进程的cpu一直是100%，Rook社区有两个ISSUES ISSUE 11253和ISSUE 10110讨论了这个问题，需要将LimitNOFILE设置一个合适的值，我这里设置的是1048576

# 本地存储准备，至少需要以下其中一种本地存储
#原始设备(Raw devices)（无分区或格式化文件系统）
#原始分区(Raw partitions)（无格式化文件系统）
#LVM逻辑卷（无格式化文件系统）
#以块模式(block mode)在存储类(storage class)中提供的持久卷


# 部署下载rook,部署ceph集群
git clone --single-branch --branch v1.13.1 https://github.com/rook/rook.git

cd rook/deploy/examples

# 部署ceph-operator
# operator.yaml修改镜像地址
#ROOK_CSI_CEPH_IMAGE: "172.27.8.200/rook-ceph/cephcsi:v3.10.1"
#ROOK_CSI_REGISTRAR_IMAGE: "172.27.8.200/rook-ceph/csi-node-driver-registrar:v2.9.1"
#ROOK_CSI_RESIZER_IMAGE: "172.27.8.200/rook-ceph/csi-resizer:v1.9.2"
#ROOK_CSI_PROVISIONER_IMAGE: "172.27.8.200/rook-ceph/csi-provisioner:v3.6.2"
#ROOK_CSI_SNAPSHOTTER_IMAGE: "172.27.8.200/rook-ceph/csi-snapshotter:v6.3.2"
#ROOK_CSI_ATTACHER_IMAGE: "172.27.8.200/rook-ceph/csi-attacher:v4.4.2"

kl create -f crds.yaml -f common.yaml -f operator.yaml

# 部署ceph-cluster
# cluster.yaml
# spec.storage.config.nodes

#nodes:
#      - name: "172.27.11.247"
#        devices: # specific devices to use for storage can be specified for each node
#          - name: "/dev/sdb1"
#          - name: "nvme01" # multiple osds can be created on high performance devices
#            config:
#              osdsPerDevice: "1"
#          #- name: "/dev/disk/by-uuid/56c6174a-6d70-47a5-8f99-41de254b868f" # devices can be specified using full udev paths
#    #     config: # configuration can be specified at the node level which overrides the cluster level config

kubectl apply -f cluster.yaml

# 启动管理工具
kubectl apply -f toolbox.yaml
kubectl exec -it -n rook-ceph rook-ceph-tools-66b77b8df5-hwt5r -- bash
ceph status

# dashboard创建pool
# 用户名 admin
# 密码保存在secret中
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo


# 创建storageClass （块设备）
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  # clusterID 是 rook 集群运行的命名空间
  clusterID: rook-ceph

  # 指定存储池
  pool: baway

  # RBD image (实际的存储介质) 格式. 默认为 "2".
  imageFormat: "2"

  # RBD image 特性. CSI RBD 现在只支持 `layering` .
  imageFeatures: layering

  # Ceph 管理员认证信息，这些都是在 clusterID 命名空间下面自动生成的
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
  # 指定 volume 的文件系统格式，如果不指定, csi-provisioner 会默认设置为 `ext4`
  csi.storage.k8s.io/fstype: xfs
# uncomment the following to use rbd-nbd as mounter on supported nodes
# **IMPORTANT**: If you are using rbd-nbd as the mounter, during upgrade you will be hit a ceph-csi
# issue that causes the mount to be disconnected. You will need to follow special upgrade steps
# to restart your application pods. Therefore, this option is not recommended.
#mounter: rbd-nbd
reclaimPolicy: Delete
allowVolumeExpansion: true


# 创建pvc
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-test-pv-claim
  labels:
    app: wordpress
spec:
  storageClassName: rook-ceph-block
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi



# 创建storageClass(Filesystem)
# kubectl apply -f filesystem.yaml

# storageClass(cephfs)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-cephfs
# Change "rook-ceph" provisioner prefix to match the operator namespace if needed
provisioner: rook-ceph.cephfs.csi.ceph.com
parameters:
  # clusterID is the namespace where the rook cluster is running
  # If you change this namespace, also change the namespace below where the secret namespaces are defined
  clusterID: rook-ceph

  # CephFS filesystem name into which the volume shall be created
  fsName: myfs

  # Ceph pool into which the volume shall be created
  # Required for provisionVolume: "true"
  pool: myfs-replicated

  # The secrets contain Ceph admin credentials. These are generated automatically by the operator
  # in the same namespace as the cluster.
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph

reclaimPolicy: Delete 

# pvc
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-pv-claim
  labels:
    app: cephfs
spec:
  storageClassName: rook-cephfs
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi


# 对象存储

kubectl apply -f object.yaml

# storageClass(object)

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: rook-ceph-bucket
# Change "rook-ceph" provisioner prefix to match the operator namespace if needed
provisioner: rook-ceph.ceph.rook.io/bucket
reclaimPolicy: Delete
parameters:
  objectStoreName: my-store
  objectStoreNamespace: rook-ceph

# 以上会自动创建一个bucket和configmap，cm中有bucket的两个KEY

#config-map, secret, OBC will part of default if no specific name space mentioned
export AWS_HOST=$(kubectl -n default get cm ceph-bucket -o jsonpath='{.data.BUCKET_HOST}')
export PORT=$(kubectl -n default get cm ceph-bucket -o jsonpath='{.data.BUCKET_PORT}')
export BUCKET_NAME=$(kubectl -n default get cm ceph-bucket -o jsonpath='{.data.BUCKET_NAME}')
export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)

echo $AWS_HOST
echo $PORT
echo $BUCKET_NAME
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

# 使用s5cmd测试上传下载
export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)

mkdir ~/.aws
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

# 通过svc连接并查看桶
s5cmd --endpoint-url  http://10.98.136.218 ls
s3://ceph-bkt-2752d0dc-7eee-4f6e-b133-b1b4acfa7109

# 上传下载
echo "Hello Rook" > /tmp/rookObj
s5cmd --endpoint-url  http://10.98.136.218 cp /tmp/rookObj s3://ceph-bkt-2752d0dc-7eee-4f6e-b133-b1b4acfa7109

s5cmd  --endpoint-url  http://10.98.136.218 cp s3://ceph-bkt-2752d0dc-7eee-4f6e-b133-b1b4acfa7109/rookObj /tmp/rookObj-download
cat /tmp/rookObj-download

