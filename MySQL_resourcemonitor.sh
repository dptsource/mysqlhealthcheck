#! /bin/bash
#Author : - Dheeraj
MYUSER=mysql
MYPASS=XXXXXX
dte=`date`
hstname=`hostname`
os_info=`hostnamectl | grep 'Operating System' | awk {'print$1,$2,$3,$4,$5,$6'} `
upt=`uptime | awk {'print$1'}`
load_avg=`cat /proc/loadavg  | awk {'print$1,$2,$3'} | sed 's/ /,/g'`
mem_pr=`ps -eo %mem,%cpu,comm --sort=-%mem | head -n 6`
ram_usage=`free -m | head -2 | tail -1 | awk {'print$3'}`
ram_free=`free -m | head -2 | tail -1 | awk {'print$4'}`
ram_total=`free -m | head -2 | tail -1 | awk {'print$2'}`
mem_pct=`free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }'`
max_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_variables where variable_name='max_connections';" --skip-column-names --silent  `
th_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_status where variable_name='Threads_connected';" --skip-column-names --silent  `
usd_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_status where variable_name='max_used_connections';" --skip-column-names --silent  `
conn_usg=`mysql -u$MYUSER -p$MYPASS -e "select (select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Threads_connected')/(select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='max_connections')*100 as Connection_Usage_Ratio;"  --skip-column-names --silent `

cred_disktmp=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_status where variable_name='Created_tmp_disk_tables';" --skip-column-names --silent  `
cred_tmp=`mysql -u$MYUSER -p$MYPASS -e "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='created_tmp_tables';" --skip-column-names --silent  `
tmp_usg=`mysql -u$MYUSER -p$MYPASS -e "select ((select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Created_tmp_disk_tables')/(select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='created_tmp_tables')*100) as Tmp_disk_tables_ratio;"  --skip-column-names --silent `

inno_buff=`mysql -u$MYUSER -p$MYPASS -e "select ((select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Innodb_buffer_pool_read_requests')/((select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Innodb_buffer_pool_read_requests') + (select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Innodb_buffer_pool_reads'))*100) as InnoDB_Buffer_Pool_hit_ratio ;"  --skip-column-names --silent `
inno_buff_size=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_variables where variable_name like 'INNODB_BUFFER_POOL_SIZE';"  --skip-column-names --silent `

qcach_size=`mysql -u$MYUSER -p$MYPASS -e "select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='query_cache_size'"  --skip-column-names --silent `
qcach_free=`mysql -u$MYUSER -p$MYPASS -e "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Qcache_free_memory'"  --skip-column-names --silent `
qcach_ratio=`mysql -u$MYUSER -p$MYPASS -e "select (( 1-(select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME='Qcache_free_memory')/(select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='query_cache_size'))*100) as query_cache_usage_rate ;"  --skip-column-names --silent `

inn_engine=`mysql -u$MYUSER -p$MYPASS -e "SHOW ENGINE INNODB STATUS \G;" `


if [ ! -d ${HOME}/mysql_monitor ]
then
  mkdir ${HOME}/mysql_monitor
fi
find ${HOME}/mysql_monitor/ -mtime +1 -exec rm {} \;
outfile="${HOME}/mysql_monitor/mysql-monitor-`hostname`-`date +%y%m%d`-`date +%H%M`.txt"

echo "#################MySQL Monitoring Script#####################" >> $outfile
echo " " >> $outfile
echo "#################Server Status#####################" >> $outfile
echo " " >> $outfile

echo "#*****************Hostname Information********************#" >> $outfile
echo " Date :  $dte" >> $outfile
echo " Hostname : $hstname" >> $outfile
echo " Uptime : $upt" >> $outfile
echo "$os_info" >> $outfile
echo " " >> $outfile
echo "#*****************CPU Utilization*********************#"  >> $outfile
echo "Load Average : $load_avg " >> $outfile
echo " " >> $outfile

echo "#*****************Memory Utilization*************#" >> $outfile
echo "Total Memory (MB)  : $ram_total " >> $outfile
echo "Memory Used  (MB)  : $ram_usage " >> $outfile
echo "Free Memory  (MB)  : $ram_free " >> $outfile
echo " % Memory Usage    : $mem_pct" >> $outfile
echo " " >> $outfile

echo "#***************TOP 5 Memory Consuming Process*************#" >> $outfile
echo "$mem_pr" >> $outfile
echo " " >> $outfile

echo "#################Database Status#####################" >> $outfile
echo " " >> $outfile
echo "#*****************Connection Status*****************#" >> $outfile

echo "Max Connection : $max_conn " >> $outfile
echo "Threads Connected : $th_conn " >> $outfile
echo "Max used Connected : $usd_conn " >> $outfile
echo "Connection usage ratio : $conn_usg % "  >> $outfile
echo " " >> $outfile

echo "#*****************Temp Table Usage*****************#" >> $outfile

echo "Created_tmp_disk_tables : $cred_disktmp " >> $outfile
echo "created_tmp_tables      : $cred_tmp " >> $outfile
echo "Temp table Usage Ratio  : $tmp_usg % " >> $outfile
echo " " >> $outfile


echo "#*****************Buffer Pool*****************#" >> $outfile

echo "innodb_buffer_pool_size (KB) : $inno_buff_size " >> $outfile
echo "Innodb Buffer pool hit ratio     : $inno_buff % " >> $outfile
echo " " >> $outfile

echo "#*****************Query Cache Usage Ratio*****************#" >> $outfile

echo "query_cache_size (KB) : $qcach_size " >> $outfile
echo "Qcache_free_memory (KB) : $qcach_free " >> $outfile
echo "Qcache Usage Ratio  : $qcach_ratio %  " >> $outfile
echo " " >> $outfile


echo "#*****************INNODB ENGINE STATUS*****************#" >> $outfile
echo " " >> $outfile
echo "$inn_engine" >> $outfile
echo " " >> $outfile
