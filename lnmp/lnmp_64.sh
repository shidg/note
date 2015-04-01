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

trap 'kill $!;exit' 12 3 15
trap 'ERRTRAP $LINENO' ERR

if [ ! -d ${app_dir} ];then
    mkdir -p ${app_dir}
fi

echo "install dependent libraries"
dots &
exec 1>&2
yum -y install gcc gcc-c++ libtool ncurses ncurses-devel openssl openssl-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel  sqlite sqlite-devel zlib zlib-devel
exec 1>&6
success
#ncurses  openssl bison 为编译mysql5必须
#libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel 为安装gd所依赖的

echo "install libiconv..."
dots &
exec 1>&2
tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14 && ./configure --prefix=/usr && make && make install
exec 1>&6
success

## for CentOS 7 ##
#tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14 && ./configure --prefix=/usr
#(cd /Data/software/lnmp/libiconv-1.14;make)
#sed  -i -e '/_GL_WARN_ON_USE (gets/a\#endif' -e '/_GL_WARN_ON_USE (gets/i\#if defined(__GLIBC__) && !defined(__UCLIBC__) && !__GLIBC_PREREQ(2, 16)' srclib/stdio.h
#make && make install

cd ..
echo "install libxslt..."
dots &
exec 1>&2
tar zxvf libxslt-1.1.28.tar.gz && cd libxslt-1.1.28
#解决“/bin/rm: cannot remove `libtoolT’: No such file or directory ”
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
echo "install libevent..."
dots &
exec 1>&2
tar zxvf libevent-2.0.21-stable.tar.gz && cd libevent-2.0.21-stable && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install libpng..."
dots &
exec 1>&2
tar zxvf libpng-1.6.8.tar.gz && cd libpng-1.6.8 && ./configure --prefix=/usr && make && make install
#ln -s /usr/lib/libpng15.so.15.12.0  /usr/lib64/libpng15.so.15
exec 1>&6
success

cd ..
echo "install jpeg"
dots &
exec 1>&2
tar zxvf jpegsrc.v9a.tar.gz && cd jpeg-9a && ./configure --prefix=${app_dir}jpeg --enable-shared --enable-static && make && make install
exec 1>&6
success

cd ..
echo "install freetype"
dots &
exec 1>&2
tar zxvf freetype-2.5.3.tar.gz && cd freetype-2.5.3 && ./configure --prefix=${app_dir}freetype && make && make install
exec 1>&6
success

cd ..
echo "install gd2"
dots &
exec 1>&2
tar jxvf libgd-2.1.0.bz2 && cd gd/2.1.0 && ./configure --prefix=${app_dir}gd --with-zlib --with-png=/usr --with-jpeg=${app_dir}jpeg --with-freetype=${app_dir}freetype --with-tiff=/usr/ && make && make install
exec 1>&6
success

cd ../../
echo "install cmake"
dots &
exec 1>&2
tar zxvf cmake-3.1.0.tar.gz && cd cmake-3.1.0 && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install mysql"
dots &
exec 1>&2
#yum -y install ncurses ncurses-devel openssl openssl-devel
yum install bison
tar zxvf mysql-5.6.15.tar.gz && cd mysql-5.6.15 && cmake . -DCMAKE_INSTALL_PREFIX=${app_dir}mysql/ -DMYSQL_DATADIR=/data/mysql/data -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_TCP_PORT=3306 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_PARTITION_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DWITH_DEBUG=0  -DWITH_SSL=yes -DSYSCONFDIR=/data/mysql -DMYSQL_TCP_PORT=3306 && make && make install
#-DWITH_MEMORY_STORAGE_ENGINE=1  -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1支持的三种数据库引擎，根据需要增减
useradd -s /sbin/nologin www
useradd -s /sbin/nologin mysql
#mkdir -p /data/mysql/{data,binlog,relaylog}
#chown -R mysql:mysql /data/mysql
#touch /data/mysql/my.cnf
cp ${app_dir}mysql/bin/mysql* /usr/bin/ && cp ${app_dir}mysql/support-files/mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld
chkconfig --level 3 mysqld on

exec 1>&6
success

#PHP-5.3.16
cd ..
echo "install php"
dots &
exec 1>&2
tar zxvf php-5.5.8.tar.gz && cd php-5.5.8 && ./configure --prefix=${app_dir}php5.5.8  --with-config-file-path=${app_dir}php5.5.8/etc --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir=${app_dir}jpeg --with-zlib --with-gd=${app_dir}gd --with-freetype-dir=${app_dir}freetype --with-mcrypt=/usr --with-mhash --enable-gd-native-ttf  --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear --enable-fpm --enable-mbstring --enable-soap --enable-xml --enable-pdo --enable-ftp  --enable-zip --enable-bcmath --enable-sockets --enable-opcache && make && make install
ln -s ${app_dir}php-5.5.8  ${app_dir}php
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
echo "install nginx"
dots &
exec 1>&2
#下载ngx_cache_purge模块
#wget http://labs.frickle.com/files/ngx_cache_purge-1.5.tar.gz && tar zxvf ngx_cache_purge-1.5.tar.gz
#tar zxvf pcre-8.30.tar.gz && mv pcre-8.30  /usr/local/ && tar zxvf openssl-1.0.1c.tar.gz && mv openssl-1.0.1c /usr/local/ && tar zxvf nginx-1.2.3.tar.gz && cd nginx-1.2.3 && ./configure --prefix=/usr/local/nginx --add-module=../ngx_cache_purge-1.5 --with-pcre=/usr/local/pcre-8.30 --with-openssl=/usr/local/openssl-1.0.1c --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module && make && make install 

tar jxvf pcre-8.36.tar.bz2 && mv pcre-8.36  ${app_dir} && tar zxvf openssl-1.0.2.tar.gz && mv openssl-1.0.2 ${app_dir} && tar zxvf nginx-1.6.2.tar.gz && cd nginx-1.6.2 && ./configure --prefix=${app_dir}nginx  --with-pcre=${app_dir}pcre-8.36 --with-openssl=${app_dir}openssl-1.0.2 --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module && make && make install

#nginx/mysql/php auto running
echo "${app_dir}nginx/sbin/nginx -c ${app_dir}nginx/conf/nginx.conf" >> /etc/rc.d/rc.local
echo "${app_dir}/php/sbin/php-fpm" >> /etc/rc.d/rc.local

exec 1>&6
success

cd ..
echo "install re2c"
dots &
exec 1>&2
tar zxvf re2c-0.13.7.5.tar.gz && cd re2c-0.13.7.5 && ./configure && make && make install
exec 1>&6
success

exec 1>&6 6>&-
exec 2>&7 7>&-
stty echo

echo -ne "OK,That is all!\nThanks \n"

#cd ..
#echo "Start the installation of memcached..."
#sleep 3
#tar zxvf memcached-1.4.17.tar.gz && cd memcached-1.4.17 && ./configure --prefix=/usr/local/memcached --with-libevent && make && make install
#echo "OK,memcached-1.4.17 has  been successfully installed!"
#sleep 2

#echo "Starting memcached,please wait...."
#sleep 2
#/usr/local/memcached/bin/memcached -d -m 256 -u root -P /tmp/memcached.pid && echo "OK,memcached is runing now" 
#echo "/usr/local/memcached/bin/memcached -d -m 256 -u root -P /tmp/memcached.pid" >> /etc/rc.d/rc.local
#sleep 2

#cd .. 
#echo "Start install memcache extension..."
#如果php版本为5.2，则memcache使用2.2.6版本，否则会因版本问题导致php无法加载memcach模块。
#sleep 2
#tar zxvf memcache-3.0.8.tgz && cd memcache-3.0.8 && /usr/local/php/bin/phpize && ./configure --enable-memcache --with-php-config=/usr/local/php/bin/php-config && make && make install 
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/memcache.so /usr/local/php/ext/
#echo  "OK,Memcache-3.0.6 installed successfully!"

#cd ..
#echo "Start install pdf extension..."
#tar zxvf PDFlib-Lite-7.0.5p3.tar.gz && cd PDFlib-Lite-7.0.5p3.tar.gz
#./configure --prefix=/Data/app/pdflib && make && make install
#cd ..
#tar zxvf pdflib-3.0.4.tgz && cd pdflib-3.0.4.tgz
#${php_prefix}/bin/phpize
#./configure --with-php-config=/Data/app/php/bin/php-config --with-pdflib=/Data/app/pdflib/
#make && make install

#cd ..
#echo "Start install ImageMagick..."
#sleep 2
#tar zxvf ImageMagick-6.8.8-2.tar.gz && cd ImageMagick-6.8.8-2&& ./configure --prefix=/usr/local/imagemagick && make && make install
#echo "/usr/local/imagemagick/lib" >> /etc/ld.so.conf && ldconfig
#echo "OK,ImageMagick-6.8.8-2 has been installed successfully!"
#sleep 2

#cd ..
#echo "Start install imagick for php ..."
#tar zxvf imagick-3.1.2.tgz && cd imagick-3.1.2 && /usr/local/php/bin/phpize && ./configure --with-imagick=/usr/local/imagemagick --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/imagick.so  /usr/local/php/ext/
#echo "OK,imagick-3.1.2 for php has been installed successfully!"
#sleep 2

#php5.3之后不需要再单独安装PDO_MYSQL
#cd ..
#echo "Start install PDO_MYSQL ..."
#tar zxvf PDO_MYSQL-1.0.2.tgz && cd PDO_MYSQL-1.0.2 && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql && make && make install
#cp modules/pdo_mysql.so /usr/local/php/ext/
#echo "OK,PDO_MYSQL-1.0.2 has been installed successfully!"

#cd ..
#echo "Start install APC ..."
#tar zxvf APC-3.1.9.tgz && cd APC-3.1.9 
#/usr/local/php/bin/phpize
#./configure --enable-apc --with-apc-mmap --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/apc.so /usr/local/php/ext/
#echo -ne "[APC]\nextension = \"apc.so\"\napc.enabled = 1\napc.cache_by_default = on\napc.shm_size = 32M\napc.ttl = 600\napc.user_ttl = 600\napc.write_lock = on" >> /usr/local/php/etc/php.ini
#echo -ne "APC-3.1.9 has been installed successfully!"
#cd ..

#yaf.so
#tar zxvf yaf-2.3.3.tgz && cd yaf-2.3.3 
#/usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/yaf.so /usr/local/php/ext/
