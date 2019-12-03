#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-12-02 20:48:21

# https://repo.saltstack.com
# CentOS 7 py3
yum install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el7.noarch.rpm

# CentOS 7 py2
yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm

# CentOS 8 py3
yum install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el8.noarch.rpm

yum clean expire-cache
yum install salt-master
yum install salt-minion
#yum install salt-ssh
#yum install salt-syndic
#yum install salt-cloud
#yum install salt-api
