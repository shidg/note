FROM centos:Django
MAINTAINER 94586572@qq.com
EXPOSE 8000
ADD test01.tgz /Data/app/
WORKDIR /Data/app/test01/
ENTRYPOINT python manage.py  runserver 192.168.0.2:8000
