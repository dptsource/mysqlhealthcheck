#### THE GOAL

    Consolidate main MySQL and system health metrics in one report.
    Useful for routine daily and weekly MySQL checks.

    Report provides:
    - Basic OS-level parameters: disk space, hostname,IP Address, Date & Time ,load average, memory utilization 
    - Important MySQL statistics : Instance Status , Uptime, version,max_connection,threads_connected,Max_used_connection,binlog , replication status  

    Report example: 

#### CONFIGURING AND RUNNING

    1. Edit MySQL credentials in mysqlhealthchecks.sh
    2. Run ./mysqlhealthchecks.sh
    3. Enjoy!

    Script will automatically send report to email address given in script.
  
    Report will be emailed to you. Useful when running script via cron.

#### DOCUMENTATION

 version 1.0

#### DOWNLOAD LATEST

  
