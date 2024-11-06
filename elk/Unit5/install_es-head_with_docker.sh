#!/bin/bash
# File Name: -- install_es-head_with_docker.sh --
# author: -- shidegang --
# Created Time: 2024-10-22 16:48:59

# 镜像地址
registry.cn-hangzhou.aliyuncs.com/shidg/elasticsearch-head:5-alpine

# 启动命令
docker run -d --name es-head -p 9100:9100 registry.cn-hangzhou.aliyuncs.com/shidg/elasticsearch-head:5-alpine
