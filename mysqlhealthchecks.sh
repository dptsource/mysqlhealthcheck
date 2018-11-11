#############################################################################
# Don't make any changes to this script                                     #
# File :    mysqlhealthchecks.sh                                            #
# Purpose : The purpose of this script is to report Database health check   #
#                                                                  #
# History:                                                                  #
# Name                   Date                                Version        #
# ***********************************************************************   #
# MySQL Health Script                                          1.0          #
# dptsource                                                                 #
# Dheeraj Porayil Thekkinakathu                                             #
#############################################################################
#! /bin/bash
#Checking if this script is being executed as ROOT. For maintaining proper directory structure, this script must be run from a root user.
if [ $EUID != 0 ]
then
  echo "Please run this script as root so as to see all details! Better run with sudo."
  exit 1
fi
#Declaring variables
#set -x
MYUSER=mysqluser
MYPASS=*********
dte=`date`
hstname=`hostname`
ip_add=`ifconfig | grep "inet" | head -2 | awk {'print$2'}| cut -f2 -d: `
UP1=$(service mysqld status|grep 'active (running)' | wc -l);
if [ "$UP1" != 0 ]
then
INSTSTAT=("${ERRORS[@]}" "Running")
elif [ "$UP1" = 0 ]
then
INSTSTAT=("${ERRORS[@]}" "Not Running")
fi
upt=`mysql -u$MYUSER -p$MYPASS -e "status;" | grep "Uptime" | awk '{ print $2 ;print $3 }'`
sr_version=`mysql -u$MYUSER -p$MYPASS -e "status;" | grep "Server version" | awk '{print $3;print $4;print $5; print $6}'`
max_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_variables where variable_name='max_connections';" --skip-column-names --silent  `
th_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_status where variable_name='Threads_connected';" --skip-column-names --silent  `
usd_conn=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_status where variable_name='max_used_connections';" --skip-column-names --silent  `
load_avg=`cat /proc/loadavg  | awk {'print$1,$2,$3'} | sed 's/ /,/g'`
ram_usage=`free -m | head -2 | tail -1 | awk {'print$3'}`
ram_total=`free -m | head -2 | tail -1 | awk {'print$2'}`
mem_pct=`free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }'`
bin_stat=`mysql -u$MYUSER -p$MYPASS -e "select variable_value from information_schema.global_variables where variable_name='log_bin';"  --skip-column-names --silent `
rep_hst=`mysql -u$MYUSER -p$MYPASS -e "SHOW SLAVE STATUS\G" | grep "Master_Host" | awk '{ print $2 }'`
rep_io=`mysql -u$MYUSER -p$MYPASS -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running" | awk '{ print $2 }'`
rep_sql=`mysql -u$MYUSER -p$MYPASS -e "SHOW SLAVE STATUS\G" | grep "Slave_SQL_Running" | awk '{ print $2}'| grep -v "Slave" `
rep_sec=`mysql -u$MYUSER -p$MYPASS -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master" | awk '{ print $2 }'`
rep_state=`mysql -u$MYUSER -p$MYPASS -e "SHOW SLAVE STATUS\G" | grep "Slave_SQL_Running_State"`
mnt_pnt=`df -PH | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 "  " $6":" }' | sed 's/:/,/g'`

#Creating a directory if it doesn't exist to store reports first, for easy maintenance.
if [ ! -d ${HOME}/mysql_health_reports ]
then
  mkdir ${HOME}/mysql_health_reports
fi
find ${HOME}/mysql_health_reports/ -mtime +1 -exec rm {} \;
html="${HOME}/mysql_health_reports/MySQL-Health-Report-`hostname`-`date +%y%m%d`-`date +%H%M`.html"
for i in `ls /home`; do sudo du -sh /home/$i/* | sort -nr | grep G; done > /tmp/dir.txt
#Generating HTML file
echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">" >> $html
echo "<html>" >> $html
echo "<link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css">" >> $html
echo "<body bgcolor="#FBFFC2">" >> $html
echo "<fieldset>" >> $html
echo "<center>" >> $html
echo "<h2><u>MySQL Server Health Report</u></h2>" >> $html
echo "<h3><legend>MySQL Server health Report</legend></h3>" >> $html
echo "<h4><legend>Version 1.0</legend></h4>" >> $html
echo "</center>" >> $html
echo "</fieldset>" >> $html
echo "<br>" >> $html
echo "<center>" >> $html
############################################MySQL Instance Details#######################################################################
echo "<h3><u>MySQL Instance Details:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Hostname</th>" >> $html
echo "<th>IP Address</th>" >> $html
echo "<th>Instance Status</th>" >> $html
echo "<th>Server Version</th>" >> $html
echo "<th>Uptime</th>" >> $html
echo "<th>Date & Time</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$hstname</td>" >> $html
echo "<td>$ip_add</td>" >> $html
echo "<td><font color="Red">$INSTSTAT</font></td>" >> $html
echo "<td>$sr_version</td>" >> $html
echo "<td>$upt</td>" >> $html
echo "<td>$dte</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
############################################MySQL Connection Details#######################################################################
echo "<h3><u>MySQL Connection Details:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Max Connection</th>" >> $html
echo "<th>Threads Connected</th>" >> $html
echo "<th>Max Used Connection</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$max_conn</td>" >> $html
echo "<td>$th_conn</td>" >> $html
echo "<td>$usd_conn</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
############################################MySQL Replication Status#######################################################################
echo "<h3><u>MySQL Replication Status :</u> </h3>" >> $html
echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Binlog Status</th>" >> $html
echo "<th>Master Host</th>" >> $html
echo "<th>Slave IO Status</th>" >> $html
echo "<th>Slave SQL Status</th>" >> $html
echo "<th>Seconds Behind Master</th>" >> $html
echo "<th>Slave Running State</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td><center>$bin_stat</center></td>" >> $html
echo "<td><center>$rep_hst</center></td>" >> $html
echo "<td><center>$rep_io</center></td>" >> $html
echo "<td><center>$rep_sql</center></td>" >> $html
echo "<td><center>$rep_sec</center></td>" >> $html
echo "<td><center>$rep_state</center></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
########################################### Resource Status #######################################################################
echo "<h3><u>Resource Utilization :</u> </h3>" >> $html
echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Load Average</th>" >> $html
echo "<th>Used RAM(in MB)</th>" >> $html
echo "<th>Total RAM(in MB)</th>" >> $html
echo "<th>Memory Utilization %</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td><center>$load_avg</center></td>" >> $html
echo "<td><center>$ram_usage</center></td>" >> $html
echo "<td><center>$ram_total</center></td>" >> $html
echo "<td><center>$mem_pct</center></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
########################################### Disk Utilization #######################################################################
echo "<h3><u>Disk Utilization:</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th><center>Mount Point Usage</center></th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$mnt_pnt</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br />" >> $html
echo "</table>" >> $html
echo "</body>" >> $html
echo "</html>" >> $html
echo "Report has been generated in ${HOME}/mysql_health_reports with file-name = $html. Report has also been sent to $email_add."
#Sending Email to the user
mailx -a $html -s "MySQL Health Report" username@email.com < /dev/null
