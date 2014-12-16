#! /bin/bash
# chage.sh#
# runing every 3 months find users that uid >=500 and chageit#

DATE=`date +%Y-%m-%d`
ALL_USERS=/tmp/user.list
awk -F ':' '{if($3>=500) print $1}' /etc/passwd > /tmp/user.list

while read user
do
    chage -m 0 -M 100 -d $DATE -W 20 -I 15 $user
done < ${ALL_USERS}
