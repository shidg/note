#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-12-03 17:47:29

## with docker
## 本机地址 192.168.0.100


# prometheus server
mkdir /opt/prometheus && cd /opt/prometheus
cat << EOF > prometheus.yml
global:
  scrape_interval: 5s
  evaluation_interval: 5s
  external_labels:
    monitor: 'codelab-monitor'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
    - targets: ['localhost:9090'] # 这里的localhost指的是运行prometheus server的容器，不是运行容器的宿主机
EOF

docker run --name prometheus -d -p 9090:9090 -v /opt/prometheus:/etc/prometheus prom/prometheus --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle

# 将本机/opt/prometheus挂载到容器/etc/prometheus目录，用来存放配置文件
# --web.enable-lifecycle   支持通过 curl -X POST http://ip:9090/-/reload 来热加载配置文件

# 访问效果:
http://192.168.0.100/metrics

### 安装客户端提供metrics接口
# golang客户端提供metrics


# node exporter (docker)提供metrics
docker run -d  --name node-exporter -p 9100:9100  prom/node-exporter

# 将新的metrics接口添加到prometheus.yml
global:
  scrape_interval: 5s
  evaluation_interval: 5s
  external_labels:
    monitor: 'codelab-monitor'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
    - targets: ['localhost:9090']
    - targets: ['http://192.168.0.100:9100'] # 这里为新增，注意要写宿主机ip，而不是localhost，因为不是同一个容器
        labels:
          group: 'client-node-exporter'


# 重新加载prometheus.yml
curl -X POST http://192.168.0.100:9090/-/reload


### pushgateway
mkdir /opt/prometheus/pushgateway && cd /opt/prometheus/pushgateway
docker run -d -p 9091:9091 --name pushgateway prom/pushgateway


## Grafana
docker run -d -p 3000:3000 --name grafana grafana/grafana
# http://192.168.0.100:3000 默认用户名/密码 admin/admin
# 为Grafana添加数据源-->Prometheus--->http://192.168.0.100:9090


# AlertManager
docker run -d -p 9093:9093 --name alertmanager -v /Users/shidegang/prometheus/alertmmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml prom/alertmanager
# alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.xx.xx:25'
  smtp_from: 'prometheus'
  smtp_auth_username: 'xxx@ddd.xx'
  smtp_auth_password: 'fadaxx'
route:
  group_by: ['web']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1m
  receiver: 'ops'
receivers:
- name: 'ops'
  email_configs:
  - to: '94586572@qq.com


# 修改prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'codelab-monitor'
rule_files:
  - /Users/shidegang/prometheus/rules.yml
scrape_configs:
  - job_name: 'myself'
    static_configs:
    - targets: ['192.168.0.100:9090']
  - job_name: 'my-mac'
    static_configs:
    - targets: ['192.168.0.100:9100']
  - job_name: 'MySQL'
    static_configs:
    - targets: ['192.168.0.100:9104']
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['192.168.0.100:9093']
