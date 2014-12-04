#!/bin/bash
#DB_DIR=/Data/app/mysql/data
#Modify 2014 12 02
#by shidegang

BACK_DIR=/Data/backup/mysql

DB_LST=/tmp/db.lst

DATE=`date +%Y-%m-%d` 

export PATH=$PATH:/Data/app/mysql/bin

mysql -uroot -p9bdgvYHkVRTM9 -e 'show databases' > $DB_LST

[ ! -d $BACK_DIR ] && mkdir -p $BACK_DIR
for i in $(grep -vE "Database|information_schema|performance_schema|mysql" $DB_LST)
do
	mysqldump -uroot -p9bdgvYHkVRTM9 --default-character-set=utf8  $i > $BACK_DIR/$i-$DATE.sql
	[ "$PWD" != "$BACK_DIR" ] && cd $BACK_DIR 
	gzip  -f $i-$DATE.sql
done


find $BACK_DIR -mtime +30 | xargs -i rm -rf {}
