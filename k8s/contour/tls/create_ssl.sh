#!/bin/bash
# File Name: -- create_ssl.sh --
# author: -- shidegang --
# Created Time: 2025-08-25 11:29:15
## 不使用ca,直接生成证书,自签名证书

#1.创建服务器证书密钥文件 server.key：
#openssl genrsa -des3 -out server.key 2048
openssl genrsa  -out server.key 2048
输入密码，确认密码，自己随便定义，但是要记住，后面会用到。


#2.备份一份服务器密钥文件
cp server.key server.key.org

#3.去除文件口令
openssl rsa -in server.key.org -out server.key

#4. 证书签发请求
openssl req -new -config csr.cnf -key server.key -out server.csr

#5 签发证书
openssl x509 -req -in server.csr -signkey server.key  -out server.crt -days 3650 -sha256 -extfile csr.cnf -extensions req_ext
