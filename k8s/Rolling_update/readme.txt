liveness  ## 检测不通过则重启pod,用于自愈
readiness ## 检测不通过则不加入service,不对外提供服务，多用于滚动更新场景
maxSure   ## 滚动更新时的最大副本数（k8s一次新建几个新副本出来）
maxUnavailable ##  滚动更新时最多允许多少副本不可用


eg:
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  strategy:
    rollingUpdate:
      maxSurge: 35%
      maxUnavailable: 35%
  replicas: 10
  template:
    metadata:
      labels:
        run: app
    spec:
      containers:
      - name: app
        image: busybox
        args:
        - /bin/sh
        - -c
        - sleep 3000
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 10
          periodSeconds: 5
