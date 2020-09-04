#!/bin/bash
##lnmp_64.sh
# install nginx+php-fpm+mysql on centos X86_64
# you can custom sourcedir and app_dir,upload tarball to the $sourcedir ,then run this script
# php mysql will be installed to $app_dir
# modified by shidg    20150126

source_dir="/usr/local/src/lnmp/"
[ "$PWD" != "${source_dir}" ] && cd ${source_dir}

app_dir="/Data/app/"

function ERRTRAP {
    echo "[LINE:$1] Error: exited with status $?"
    kill $!
    exit 1
}

function dots {
    while true;do
        for cha in '-' '\\' '|' '/'
        do
            echo -ne "executing...$cha\r"
            sleep 1
        done
    done
}

function success {
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

if [ ! -d ${app_dir} ];then
    mkdir -p ${app_dir}
fi

echo "install dependent libraries"
dots &
exec 1>&2
yum -y install gcc gcc-c++ libtool ncurses ncurses-devel openssl openssl-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel  sqlite sqlite-devel zlib zlib-devel libpng-devel gd-devel freetype-devel
exec 1>&6
success
#ncurses  openssl bison Ϊ����mysql5����
#libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel Ϊ��װgd��������

echo "install libiconv..."
dots &
exec 1>&2
tar zxvf libiconv-1.15.tar.gz && cd libiconv-1.15 && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install libxslt..."
dots &
exec 1>&2
tar zxvf libxslt-1.1.29.tar.gz && cd libxslt-1.1.29
#�����/bin/rm: cannot remove `libtoolT��: No such file or directory ��
sed -i '/$RM "$cfgfile"/ s/^/#/' configure
./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install libmcrypt"
dots &
exec 1>&2
tar zxvf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8 && ./configure --prefix=/usr && make && make install
cd libltdl && ./configure --prefix=/usr/ --enable-ltdl-install && make && make install
exec 1>&6
success

cd ../../
echo "install mhash"
dots &
exec 1>&2
tar jxvf mhash-0.9.9.9.tar.bz2 && cd mhash-0.9.9.9 && ./configure && make && make install
exec 1>&6
success

echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

cd ..
echo "install mcrypt"
dots &
exec 1>&2
tar zxvf mcrypt-2.6.8.tar.gz && cd mcrypt-2.6.8  && ./configure && make && make install
exec 1>&6
success

cd ..
echo "install libevent"
dots &
exec 1>&2
tar zxvf libevent-2.1.8-stable.tar.gz && cd libevent-2.1.8-stable && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install re2c"
dots &
exec 1>&2
tar zxvf re2c-0.16.tar.gz && cd re2c-0.16 && ./configure && make && make install
exec 1>&6
success

cd ..
echo "install php"
dots &
exec 1>&2
tar jxvf php-5.6.14.tar.bz2 && cd php-5.6.14 && ./configure --prefix=${app_dir}php-5.6.14  --with-config-file-path=${app_dir}php-5.6.14/etc --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir --with-zlib --with-gd --with-freetype-dir --with-mcrypt=/usr --with-mhash --enable-gd-native-ttf  --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear --enable-fpm --enable-mbstring --enable-soap --enable-xml --enable-pdo --enable-ftp  --enable-zip --enable-bcmath --enable-sockets --enable-opcache && make ZEND_EXTRA_LIBS='-liconv' && make install 
exec 1>&6
success

cd ..
echo "install mysql"
dots &
exec 1>&2
tar zxvf mysql-5.5.40-linux2.6-x86_64.tar.gz -C ${app_dir}
exec 1>&6
success

#openssl
#cd ext/openssl
#mv mv config0.m4 config.m4
#/usr/local/php/bin/phpize
#./configure --with-openssl --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/openssl.so /usr/local/php/ext
#cd ..

cd ..

# add lua-nginx-module
# https://github.com/openresty/lua-nginx-module#installation
mkdir -p /Data/app/LuaJIT
tar zxvf LuaJIT-2.0.4.tar.gz && cd LuaJIT-2.0.4
make PREFIX=/Data/app/LuaJIT
make install PREFIX=/Data/app/LuaJIT

ln -s /Data/app/LuaJIT/lib/libluajit-5.1.so.2.0.4 /usr/lib/libluajit-5.1.so.2
export LUAJIT_LIB=/Data/app/LuaJIT/lib/ && export LUAJIT_INC=/Data/app/LuaJIT/include/luajit-2.0/

#add sticky module
#https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/
#https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/downloads/
echo "install nginx"
dots &
exec 1>&2
tar jxvf pcre-8.41.tar.bz2 && tar zxvf openssl-1.1.0g.tar.gz && tar zxvf nginx-1.12.2.tar.gz && cd nginx-1.12.2

#���ذ汾��Ϣ
export N_VERSION=1.12.2
rm -f html/index.html

sed -i '/u_char ngx_http_server_string/ s/nginx/Tengine/' src/http/ngx_http_header_filter_module.c
sed -i '/u_char ngx_http_server_full_string/ s/ NGINX_VER//' src/http/ngx_http_header_filter_module.c
sed -i '/u_char ngx_http_server_full_string/ s/Server: /Server: Tengine/' src/http/ngx_http_header_filter_module.c

sed -i "/#define NGINX_VERSION/ s/${N_VERSION}/2.2.1/" src/core/nginx.h
sed -i 's/nginx\//Tengine/' src/core/nginx.h

sed -i '/center>nginx/ s/nginx/Tengine/' src/http/ngx_http_special_response.c

# https://github.com/vision5/ngx_devel_kit/tags
# https://github.com/calio/form-input-nginx-module/tags

./configure --prefix=/Data/app/nginx-1.12.2  --with-pcre=../pcre-8.41 --with-openssl=../openssl-1.1.0g --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --add-module=../nginx-sticky-module-ng --add-module=../ngx_devel_kit-0.3.0 --add-module=../form-input-nginx-module-master --add-module=../lua-nginx-module-master

exec 1>&6 6>&-
exec 2>&7 7>&-
stty echo
echo -ne "OK,That is all!\nThanks \n"
