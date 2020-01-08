#! /bin/bash

MINA_PID=`ps -ef | grep mina | grep -v "grep" |awk '{print $2}'`
NETTY_PID=`ps -ef | grep gateway | grep -v "grep" |awk '{print $2}'`

#function SEND_MAIL() {
#	MAIL="/bin/mail"
#	echo -e "Current fd: $FD_TOTAL\nsys.fd.max: $FD_MAX" > /tmp/fd.info
#	$MAIL -s "!FD_WARNING!"  shidg@eg.com < /tmp/fd.info
#}

#if [ $FD_TOTAL -ge $FD_MAX ]; then
#	SEND_MAIL
#fi

function MINAFD () {
    sudo ls /proc/$MINA_PID/fdinfo | wc -l
}
function NETTYFD () {
    sudo ls /proc/$NETTY_PID/fdinfo | wc -l
}
function SYSFD () {
    cat /proc/sys/fs/file-max
}


case $1 in
   MINA)
         MINAFD
        ;;
  NETTY)
         NETTYFD
        ;;
  SYS)
          SYSFD
        ;;
       *)
          exit 1
        ;;
esac
