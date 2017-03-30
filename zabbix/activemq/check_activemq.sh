#!/bin/sh
#
#Description: get activemq data
HOST=127.0.0.1
PORT=8161
USER=admin
PASSWD=0zeOX17cK3IfTXBzBYe4
Pending=`curl -s -u$USER:$PASSWD http://$HOST:$PORT/admin/xml/queues.jsp | grep "stats size"| awk -F '"'  'BEGIN{total=0} {total+=$2} END{print total}'`
Consumers=`curl -s -u$USER:$PASSWD http://$HOST:$PORT/admin/xml/queues.jsp | grep "consumerCount"| awk -F '"'  'BEGIN{total=0} {total+=$2} END{print total}'`
Enqueued=`curl -s -u$USER:$PASSWD http://$HOST:$PORT/admin/xml/queues.jsp | grep "enqueueCount"| awk -F '"'  'BEGIN{total=0} {total+=$2} END{print total}'`
Dequeued=`curl -s -u$USER:$PASSWD http://$HOST:$PORT/admin/xml/queues.jsp | grep "dequeueCount"| awk -F '"'  'BEGIN{total=0} {total+=$2} END{print total}'`

case $1 in
 Pending|pending)
 echo "$Pending"
 ;;
 Consumers|consumers)
 echo $Consumers
 ;;
 Enqueued|enqueued)
 echo $Enqueued
 ;;
 Dequeued|dequeued)
 echo $Dequeued
 ;;
 *)
 echo "Usage: $0 Pending|Consumers|Enqueued|Dequeued"
esac
