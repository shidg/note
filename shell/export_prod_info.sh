#! /bin/bash
# export_prod_info.sh
# Run at 1st, 00:00:00 every month
# modify by shidg (20190102)
# mail to chanpin@feezu.cn

MAIL="/bin/mail"
MYSQL="/Data/app/mysql/bin/mysql"
DB_SERVER="rr-2zev3gzmso46nikib.mysql.rds.aliyuncs.com"
DB_USER="mainuser"
DB_PASS="NbcbKCSTQpa"
DB_NAME="wzc"
DB2_NAME="orders"
DB3_NAME="device_order"
DATE=`date -d yesterday +%Y-%m-%d`
SAVE_PATH="/tmp"
TXT2XLS=/usr/bin/t2e

## 定义时间点：
# 当前时间
CURRENT_TIME=`date +"%Y-%m-%d %H:%M:%S"`

# 当前年度表达式
CURRENT_YEAR=`date +%Y`

# 本年度开始时间
BEGIN_OF_THIS_YEAR="${CURRENT_YEAR}-01-01 00:00:00"

# 上月开始时间
BEGIN_OF_LAST_MONTH=`date +"%Y-%m-%d %H:%M:%S" -d "last month"`

# 三个月前开始时间
BEGIN_OF_THREE_MONTHs_AGO=`date +"%Y-%m-%d %H:%M:%S" -d "-3 month"`

# 上个月表达式
LAST_MONTH=`date +%Y-%m -d "last month"`

#: << BLOCK

# 累计装机数
echo -e "---累计装机总数"> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT COUNT(*) FROM device ;" | awk 'NR == 1 {next} {print}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt


# 本年度累计装机数据
echo -e "---本年度(${CURRENT_YEAR})累计装机数据">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT COUNT(*) FROM device WHERE INSTALL_TIME >= '${BEGIN_OF_THIS_YEAR}' ;" | awk 'NR ==1 {next} {print}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 上月装机数据
echo "---${LAST_MONTH} 装机数据">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT COUNT(*) FROM device WHERE INSTALL_TIME >= '${BEGIN_OF_LAST_MONTH}' AND INSTALL_TIME <= '${CURRENT_TIME}' ;" | awk 'NR == 1 {next} {print}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 本年度各月装机数据
echo "---本年度(${CURRENT_YEAR})各月装机数据">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT DATE_FORMAT(INSTALL_TIME,'%Y-%m') as time, COUNT(DEVICE_ID) FROM device WHERE INSTALL_TIME >= '${BEGIN_OF_THIS_YEAR}' GROUP BY time;" | awk '{printf "%-20s %-20s\n",$1,$2}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# top10 API装机客户及装机数 1 代表平台 3-api
echo "---API装机客户及装机数 top10">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT c.\`COMPANY_NAME\`,COUNT(d.\`DEVICE_NO\`) AS m FROM device d ,company c WHERE d.\`COMPANY_ID\` = c.\`Id\` AND c.\`company_access_type\` = 3 AND c.\`COMPANY_STATUS\` = 1 GROUP BY c.\`Id\`,c.\`COMPANY_NAME\` ORDER BY m DESC LIMIT 10 ;" | awk 'BEGIN {printf "%-50s \t %-10s\n","公司名称","装机总数"} NR == 1 {next} {printf "% -45s  \t%-15s\n",$1,$2}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# top10 平台装机客户及装机数
echo "---平台装机客户及装机数 top10">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "SELECT c.\`COMPANY_NAME\`,COUNT(d.\`DEVICE_NO\`) AS m FROM device d ,company c WHERE d.\`COMPANY_ID\` = c.\`Id\` AND c.\`company_access_type\` = 1 AND c.\`COMPANY_STATUS\` = 1 GROUP BY c.\`Id\`,c.\`COMPANY_NAME\` ORDER BY m DESC LIMIT 10 ;" | awk 'BEGIN {printf "%-50s \t %-10s\n","公司名称","装机总数"} NR == 1 {next} {printf "% -45s  \t%-15s\n",$1,$2}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 本年度平台各月订单数据
echo "---本年度(${CURRENT_YEAR})平台各月订单数据">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT DATE_FORMAT( order_time, '%Y-%m' ) AS time, COUNT( order_id ) FROM app_order WHERE order_time >= '${BEGIN_OF_THIS_YEAR}' GROUP BY time;" | awk 'BEGIN {printf "%-15s \t %-10s\n","月份","订单量"} NR == 1 {next} {printf "% -20s   \t %-15s\n",$1,$2}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 本年度API各月订单数据
echo "---本年度(${CURRENT_YEAR})API各月订单数据">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB3_NAME} -e "SELECT DATE_FORMAT( order_time, '%Y-%m' ) AS time, COUNT( order_id ) FROM api_order_history WHERE order_time >= '${BEGIN_OF_THIS_YEAR}' GROUP BY time;" | awk 'BEGIN {printf "%-15s \t %-10s\n","月份","订单量"} NR == 1 {next} {printf "% -20s\t  %-15s\n",$1,$2}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 上月top10 API平台及平台订单数据
echo "---${LAST_MONTH} API平台及平台订单数据 top10">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB3_NAME} -e "SELECT c.\`COMPANY_NAME\`,COUNT( order_id ) FROM api_order_history a,wzc.\`company\` c WHERE a.order_time >= '${BEGIN_OF_LAST_MONTH}' AND a.order_time <= '${CURRENT_TIME}' AND a.\`company_id\` = c.\`Id\` GROUP BY a.company_id ORDER BY COUNT( order_id ) DESC LIMIT 10;" | awk 'BEGIN {printf "%-50s \t %-10s\n","公司名称","订单总量"} NR == 1 {next} {printf "% -45s  \t%-15s\n",$1,$2}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 上月top10 APP平台及平台订单数据
echo "---${LAST_MONTH} APP平台及平台订单数据 top10">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT c.\`COMPANY_NAME\`,COUNT( order_id ) FROM app_order a,wzc.\`company\` c WHERE a.order_time >= '${BEGIN_OF_LAST_MONTH}' AND a.order_time <= '${CURRENT_TIME}' AND a.\`company_id\` = c.\`Id\` GROUP BY a.company_id ORDER BY COUNT( order_id ) DESC LIMIT 10;" | awk 'BEGIN {printf "%-50s \t %-10s\n","公司名称","订单总量"} NR == 1 {next} {printf "% -45s  \t%-15s\n",$1,$2}' >> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 累计B客户，正在运营的B客户数据 备注：累计三个月有订单，认为在实际运营
echo "---累计B客户，正在运营的B客户数据 备注：累计三个月有订单，认为在实际运营">> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT c.\`COMPANY_NAME\`,CASE WHEN c.company_access_type IN ('1','2') THEN '平台用户' WHEN c.company_access_type = '3' THEN 'API用户' WHEN c.company_access_type = '4' THEN 'API平台混合客户' ELSE '其他用户' END AS '公司类型',COUNT( order_id ) AS 'count' FROM app_order a,wzc.\`company\` c WHERE a.order_time >= '${BEGIN_OF_THREE_MONTHs_AGO}' AND a.order_time <= '${CURRENT_TIME}' AND a.company_id = c.Id GROUP BY a.company_id ORDER BY count DESC;" | awk 'BEGIN {printf "%-60s\t\t%-30s \t%-15s\n","公司名称","公司类型","订单总量"} NR == 1 {next} {printf "%-60s   \t% -30s\t%-10s\n",$1,$2,$3}' >> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} -e "SELECT c.\`COMPANY_NAME\`,CASE WHEN c.company_access_type IN ('1','2') THEN '平台用户' WHEN c.company_access_type = '3' THEN 'API用户' WHEN c.company_access_type = '4' THEN 'API平台混合客户' ELSE '其他用户' END AS '公司类型',COUNT( order_id ) AS 'count' FROM device_order.\`api_order_history\` a,wzc.\`company\` c WHERE a.order_time >= '${BEGIN_OF_THREE_MONTHs_AGO}' AND a.order_time <= '${CURRENT_TIME}' AND a.company_id = c.Id GROUP BY a.company_id ORDER BY count DESC;" | awk 'NR == 1 {next} {printf "%-60s   \t% -30s\t%-10s\n",$1,$2,$3}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt
# 累计C端用户
echo "---累计C端用户" >> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT COUNT(*) FROM app_user;" | awk 'NR == 1 {next} {print}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

# 本年度各月新增用户数据
echo "---本年度(${CURRENT_YEAR})各月新增用户数据" >> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT DATE_FORMAT( register_date, '%Y-%m' ) AS time, COUNT( app_user_id ) FROM app_user WHERE register_date >= '${BEGIN_OF_THIS_YEAR}' GROUP BY time;" | awk 'BEGIN {printf "%-15s \t %-20s\n","月份","新增用户数"} NR == 1 {next} {printf "% -20s\t  %-15s\n",$1,$2}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt
 
#BLOCK
# top10 上月平台客户用户数据`app_user`
echo "---${LAST_MONTH} 平台客户用户数据 top10" >> ${SAVE_PATH}/prod.txt
$MYSQL -h ${DB_SERVER} -u ${DB_USER} -p${DB_PASS} ${DB2_NAME} -e "SELECT c.\`COMPANY_NAME\`,DATE_FORMAT( register_date, '%Y-%m' ) AS time, COUNT(a.app_user_id) FROM app_user AS a,wzc.\`company\` c WHERE register_date >= '${BEGIN_OF_LAST_MONTH}' AND register_date  < '${CURRENT_TIME}' AND a.company_id = c.Id  GROUP BY a.company_id,time ORDER BY COUNT( a.app_user_id ) DESC LIMIT 10;" | awk 'BEGIN {printf "%-60s\t\t%-20s   \t%-15s\n","公司名称","月份","用户总量"} NR ==      1 {next} {printf "%-60s   \t% -30s\t%-10s\n",$1,$2,$3}'>> ${SAVE_PATH}/prod.txt
echo -e "\n" >> ${SAVE_PATH}/prod.txt

#convert txt to xls

#$TXT2XLS ${SAVE_PATH}/SQL1.txt ${SAVE_PATH}/SQL1
#$TXT2XLS ${SAVE_PATH}/SQL2.txt ${SAVE_PATH}/SQL2
#$TXT2XLS ${SAVE_PATH}/SQL3.txt ${SAVE_PATH}/SQL3
#$TXT2XLS ${SAVE_PATH}/SQL4.txt ${SAVE_PATH}/SQL4
#gzip -9 ${SAVE_PATH}/SQL4.txt

#mail
$MAIL -s "ProdInfo" -a ${SAVE_PATH}/prod.txt -c zhongzheng@feezu.cn -c dongle@feezu.cn -c mengzl@feezu.cn -c fangyi@feezu.cn -c xiedan@feezu.cn -c tiansh@feezu.cn -c gaoaj@feezu.cn -b shidg@feezu.cn yelw@feezu.cn < /Data/scripts/prodinfo.txt
#$MAIL -s "ProdInfo" -a ${SAVE_PATH}/prod.txt shidg@feezu.cn  < /Data/scripts/prodinfo.txt

#rm -f ${SAVE_PATH}/SQL*.txt
mkdir -p /Data/backup/ProdInfo/$DATE
mv ${SAVE_PATH}/prod.txt /Data/backup/ProdInfo/$DATE
