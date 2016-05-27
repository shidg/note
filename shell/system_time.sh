#! /bin/bash
# changetime.sh
# change date and time and then restart tomcat
# Modified by shidg at 20160527

function FLUSH_REDIS() {
#where is the redis command
REDIS_CLI=/Data/app/redis/bin/redis-cli
read -p "Do you want to delete all redis keys before restart tomcat?" answer
    case $answer in
        Y|y)
        ${REDIS_CLI} -a "e@V3qf%Ve3Ff6uAcQ99uA7Dnx)Y%.d" keys "*" | xargs ${REDIS_CLI} -a "e@V3qf%Ve3Ff6uAcQ99uA7Dnx)Y%.d" del 
        echo "All redis keys has been cleared!"
        ;;  
        N|n)
        break
        ;;  
        *)  
        FLUSH_REDIS  
        ;;  
    esac
}   

function RESTART_TOMCAT(){
echo -e "Now,tomcat will be restared.about 7 minutes needed,have a tea. :) "
sleep 2
TMPFILE=`mktemp /tmp/tmpfile.XXXX`
    if ss -tnl | grep 8080;then
        ps -ef | grep  "jsvc.exec" | grep -v grep | awk '{print $2}'> $TMPFILE
            for TPID in `cat $TMPFILE`
            do  
                kill -9 $TPID
            done
        if [ -f /Data/app/tomcat/logs/catalina-daemon.pid ];then
            rm -f /Data/app/tomcat/logs/catalina-daemon.pid
        fi  
    fi
service tomcat start 
}

echo -e "Enter the date and time you want,example:20150825 14:00,Then press the Enter key\nIf you enter the wrong,please use \"Ctrl+C\" and Re-run"
read DATE TIME
#timedatectl set-time  "$DATE $TIME"
date -s "$DATE $TIME"

echo "System time has been modified"

sleep 1
read -p "need to restart tomcat?" T
case $T in
    Y|y)
    echo
    FLUSH_REDIS
    RESTART_TOMCAT
    ;;
    N|n)
    echo "Bye"
    break
    ;;
    *)
    echo "Unknown parameters,tomcat will not be restarted"
    ;;
esac
