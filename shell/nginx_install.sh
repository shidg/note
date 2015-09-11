#!/bin/bash
##lnmp_64.sh
# install nginx+php-fpm+mysql on centos X86_64
# you can custom sourcedir and app_dir,upload tarball to the $sourcedir ,then run this script
# php mysql will be installed to $app_dir
# modified by shidg    20150126

SOURCE_DIR="/Data/software/"
[ "$PWD" != "${source_dir}" ] && cd ${source_dir}

APP_DIR="/Data/app/"

function ERRTRAP {
    echo "[LINE:$1] Error: exited with status $?"
    kill $!
    exit 1
}

function DOTS {
    while true;do
        for cha in '-' '\\' '|' '/'
        do
            echo -ne "executing...$cha\r"
            sleep 1
        done
    done
}

function SUCCESS {
    printf "%20s"
    echo -e "\rSuccessful!"
    kill $!
}

##########################
stty -echo

exec 6>&1
exec 7>&2
exec 2>/dev/null
#exec 1>&6 6>&-
#exec 2>&7 7>&-

trap 'kill $!;exit' 1 2 3 15
trap 'ERRTRAP $LINENO' ERR

if [ ! -d ${APP_DIR} ];then
    mkdir -p ${APP_DIR}
fi

echo "install dependent libraries"
dots &
exec 1>&2
yum -y install gcc gcc-c++ libtool ncurses ncurses-devel openssl openssl-devel libxml2 libxml2-devel bison
exec 1>&6
SUCCESS
#ncurses  openssl bison 为编译mysql5必须
#libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel 为安装gd所依赖的

echo "install nginx"
dots &
exec 1>&2
tar jxvf pcre-8.37.tar.bz2  && tar zxvf openssl-1.0.2c.tar.gz && tar zxvf nginx-1.8.0.tar.gz && cd nginx-1.8.0 && ./configure --prefix=${APP_DIR}nginx-1.8.0  --with-pcre=${SOURCE_DIR}pcre-8.37 --with-openssl=${SOURCE_DIR}openssl-1.0.2d --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module && make && make install

#nginx auto running
cat > /etc/init.d/nginx << EOF
#! /bin/sh
# chkconfig:345 85 15
# description: web service

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

DESC="nginx daemon"
NAME=nginx
DAEMON=/Data/app/nginx/sbin/$NAME
CONFIGFILE=/Data/app/nginx/conf/$NAME.conf
PIDFILE=/Data/app/nginx/logs/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

set -e
[ -x "$DAEMON" ] || exit 0

do_start() {
$DAEMON -c $CONFIGFILE || echo -n "nginx already running"
}

do_stop() {
kill -INT `cat $PIDFILE` || echo -n "nginx not running"
}

do_reload() {
kill -HUP `cat $PIDFILE` || echo -n "nginx can't reload"
}

case "$1" in
start)
echo -n "Starting $DESC: $NAME"
do_start
echo "."
;;
stop)
echo -n "Stopping $DESC: $NAME"
do_stop
echo "."
;;
reload|gracefu)
echo -n "Reloading $DESC configuration..."
do_reload
echo "."
;;
restart)
echo -n "Restarting $DESC: $NAME"
do_stop
do_start
echo "."
;;
*)
echo "Usage: $SCRIPTNAME {start|stop|reload|restart}" >&2
exit 3
;;
esac
exit 0
EOF

cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]                                                                                                                                                                   
Description=nginx  
After=network.target  
   
[Service]  
Type=forking  
ExecStart=/etc/init.d/nginx start
ExecReload=/etc/init.d/nginx reload
ExecStop=/etc/init.d/nginx stop  
PrivateTmp=true  
   
[Install]  
WantedBy=multi-user.target
EOF

chmod +x /etc/nit.d/nginx
systemctl enable nginx

exec 1>&6
SUCCESS


exec 1>&6 6>&-
exec 2>&7 7>&-
stty echo
echo -ne "OK,That is all!\nThanks \n"
