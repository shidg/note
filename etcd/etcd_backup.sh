#! /bin/bash

ETCDCTL_API=3 etcdctl --endpoints="https://172.27.11.246:2379"  --cert="/etc/kubernetes/pki/etcd/server.crt"  --key="/etc/kubernetes/pki/etcd/server.key"  --cacert="/etc/kubernetes/pki/etcd/ca.crt"   snapshot save /home/shidegang/backup/etcd/snap-$(date +%Y%m%d%H%M).db

