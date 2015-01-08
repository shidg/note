#!/bin/sh

DATE=`date -d "1 hours ago" +%Y%m%d%H`
DATE1=`date -d "1 hours ago" +%d/%b/%Y:%H`
DATE2=`date -d yesterday +%Y%m%d`
DATE3=`date -d "24 hours ago" +%d/%b/%Y:%H`
HOUR=`date  +"%H"`


HOST=xxx.xxx.xx.xx
USER=getlogs
PASSWORD=xxxxx
TARGET=access_www.log.$DATE
TARGET1=access_cms.log.$DATE
TARGET2=access_bbs.log.$DATE
DEST_DIR=/opt/app/nginx/logs
name=`date -d yesterday +%Y%m%d`
echo "Starting to sftp ${TARGET1} to ${HOST}"

cd /data/backup/
lftp -u ${USER},${PASSWORD} sftp://${HOST} -p 22 <<EOF
cd ${DEST_DIR}
#put ${TARGET}
get ${TARGET}
bye
EOF


lftp -u ${USER},${PASSWORD} sftp://${HOST} -p 22 <<EOF
cd ${DEST_DIR}
#put ${TARGET}
get ${TARGET1}
bye
EOF

lftp -u ${USER},${PASSWORD} sftp://${HOST} -p 22 <<EOF
cd ${DEST_DIR}
#put ${TARGET}
get ${TARGET2}
bye
EOF

date
echo "done"

