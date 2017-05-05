#!/bin/sh
#
#Description: get activemq data
HOST=127.0.0.1
PORT=8161
USER=admin
PASSWD=0zeOX17cK3IfTXBzBYe4
RESULT=`ss -ano | grep 9000`
ESTAB=`echo "$RESULT" | grep "ESTAB" | awk  'BEGIN{total=0} {total+=1} END{print total}'`
TIMEWAIT=`echo "$RESULT" | grep "TIME-WAIT" | awk  'BEGIN{total=0} {total+=1} END{print total}'`
FINWAIT1=`echo "$RESULT" | grep "FIN-WAIT-1" | awk  'BEGIN{total=0} {total+=1} END{print total}'`
FINWAIT2=`echo "$RESULT" | grep "FIN-WAIT-2" | awk  'BEGIN{total=0} {total+=1} END{print total}'`

case $1 in
 ESTAB|estab)
 echo "$ESTAB"
 ;;
 TIMEWAIT|timewait)
 echo ${TIMEWAIT}
 ;;
 FIN1|fin1)
 echo ${FINWAIT1}
 ;;
 FIN2|fin2)
 echo ${FINWAIT2}
 ;;
 CLOSEWAIT|closewait)
 echo ${CLOSEWAIT}
 ;;
 *)
 echo "Usage: $0 ESTAB|TIME-WAIT|FIN1|FIN2"
esac
