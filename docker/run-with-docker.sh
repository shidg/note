#!/bin/bash
# File Name: -- run-with-docker.sh --
# author: -- shidegang --
# Created Time: 2024-08-16 08:14:41

docker run --name zabbix-server -e DB_SERVER_HOST="10.1.0.217" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="password" -p 10051:10051  -d zabbix/zabbix-server-mysql:ubuntu-6.0-latest

docker run --name zabbix-web --link zabbix-server:zabbix-server -e DB_SERVER_HOST="10.1.0.217" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="password" -e ZBX_SERVER_HOST="zabbix-server" -e PHP_TZ="Asia/Shanghai" -p 8080:8080  -d zabbix/zabbix-web-nginx-mysql:ubuntu-6.0-latest
