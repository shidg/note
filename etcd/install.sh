#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2023-12-05 14:35:47

# etcd下载地址
# https://github.com/etcd-io/etcd/tags 


# 创建自签发证书

# 准备cfssl工具
curl -s -L -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -s -L -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
curl -s -L -o /usr/local/bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x /usr/local/bin/cfssl*

# 开始创建证书
mkdir -p /etc/etcd/ssl &&  cd /etc/etcd/ssl

#ca机构配置：有效期10年
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "www": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF

#ca机构配置:　机构名称Comman Name，所在地Country国家, State省, Locality市
cat >  ca-csr.json <<EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "Beijing",
            "L": "Beijing"
        }
    ]
}
EOF

#向ca机构申请：证书注册 (中国，北京省，北京市), 提供服务的ip
# Organization Name, Common Name
cat >  server-csr.json <<EOF
{
    "CN": "etcd",
    "hosts": [
    "192.168.56.180", # 这里列出所有etcd节点的ip,如果后续有扩容节点的可能，需预留出ip地址
    "192.168.56.201"
    ], 
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O":"aa.com",
            "CN":"beijing.aa.com"
        }
    ]
}
EOF


# 生成证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server

# 检查生成的证书
# ls *pem
# ca-key.pem  ca.pem  server-key.pem  server.pem

# 部署etcd，每个节点分别执行
tar zxvf etcd-v3.4.28-linux-amd64.tar.gz -C /usr/local/ && mv /usr/local/etcd-v3.4.28 /usr/local/etcd


# etcd.conf 注意修改节点名称和IP
cat > /etc/etcd/etcd.conf <<EOF
#[Member]
ETCD_NAME="peer1"
ETCD_DATA_DIR="/opt/etcd/data"
ETCD_LISTEN_PEER_URLS="https://172.27.11.247:2380"
ETCD_LISTEN_CLIENT_URLS="https://172.27.11.247:2379"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.27.11.247:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://172.27.11.247:2379"
ETCD_INITIAL_CLUSTER="peer1=https://172.27.11.247:2380,peer2=https://172.27.11.248:2380,peer3=https://172.27.11.249:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_HEARTBEAT_INTERVAL=300
ETCD_ELECTION_TIMEOUT=1500
EOF

# 使用systemd管理etcd服务
cat > /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
[Service]
Type=notify
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/local/etcd/etcd \
          --cert-file=/etc/etcd/ssl/server.pem \
          --key-file=/etc/etcd/ssl/server-key.pem \
          --peer-cert-file=/etc/etcd/ssl/server.pem \
          --peer-key-file=/etc/etcd/ssl/server-key.pem \
          --trusted-ca-file=/etc/etcd/ssl/ca.pem \
          --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

# 启动服务, 各节点分别执行
systemctl daemon-reload && systemctl start etcd

# 查看集群状态
ETCDCTL_API=3 /usr/local/etcd/etcdctl  --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/server.pem --key=/etc/etcd/ssl/server-key.pem --endpoints="https://172.27.11.247:2379,https://172.27.11.248:2379,https://172.27.11.249:2379" endpoint health
# 查看结果如下表示集群运行正常
https://172.27.11.247:2379 is healthy: successfully committed proposal: took = 12.246126ms
https://172.27.11.248:2379 is healthy: successfully committed proposal: took = 130.412337ms
https://172.27.11.249:2379 is healthy: successfully committed proposal: took = 243.411376ms


# 数据备份与恢复
# 创建快照
etcdctl --endpoints $ENDPOINT snapshot save snapshot.db
# 查看快照详情
etcdctl --write-out=table snapshot status snapshot.db

# 快照恢复
# 在恢复时快照完整性的检验是可选的。
# 如果快照是通过 etcdctl snapshot save 得到的，它将有一个被 etcdctl snapshot restore 检查过的完整性hash # 如果快照是从数据目录复制而来，没有完整性hash，因此它只能通过使用 --skip-hash-check 来恢复

etcdctl snapshot restore snapshot.db \
  --name m1 \
  --initial-cluster m1=http:/host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host1:2380
etcdctl snapshot restore snapshot.db \
  --name m2 \
  --initial-cluster m1=http:/host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host2:2380
etcdctl snapshot restore snapshot.db \
  --name m3 \
  --initial-cluster m1=http:/host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host3:2380


# 使用新目录启动etcd，恢复快照数据
etcd \
  --name m1 \
  --listen-client-urls http://host1:2379 \
  --advertise-client-urls http://host1:2379 \
  --listen-peer-urls http://host1:2380 &
etcd \
  --name m2 \
  --listen-client-urls http://host2:2379 \
  --advertise-client-urls http://host2:2379 \
  --listen-peer-urls http://host2:2380 &
etcd \
  --name m3 \
  --listen-client-urls http://host3:2379 \
  --advertise-client-urls http://host3:2379 \
  --listen-peer-urls http://host3:2380 &
