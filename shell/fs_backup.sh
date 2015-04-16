#!/bin/sh
# fs_backup.sh
# 24 pm on the 1st of the month,This directory(BACK_FROM) full backup \
# otherwise,Differential backup
# files older than 30 days will be removed

# Begin
BACK_FROM=/Data/code/gold60/
BACK_TO=/Data/backup/fsback/
if [ ! -d ${BACK_TO} ];then
	mkdir -p ${BACK_TO}
fi
MON=`date +%Y%m`
DAY=`date -d '-1 day' +%d`

if [ "$DAY" = '01' ];then
	mkdir -p ${BACK_TO}$MON
	zl=" "
	tar $zl -czf ${BACK_TO}$MON/back-full.tgz ${BACK_FROM}
else
	if [ ! -d ${BACK_TO}$MON ];then
		mkdir ${BACK_TO}$MON
	fi
	zl=`date +'%Y-%m-02 01:00:01'`
	tar -N "$zl" -czf ${BACK_TO}$MON/back_diff-$DAY.tgz ${BACK_FROM}
fi
exit
#del files 30 days ago
find ${BACK_TO} -mtime +30 | xargs -i rm -rf {}

# End
