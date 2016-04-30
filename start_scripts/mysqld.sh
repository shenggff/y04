#!/bin/bash
#author:wsh
# chkconfig: 2345 40 40
# description: this is mysqld auto start  

. /etc/init.d/functions
pidfile="/usr/local/mysql/data/mysql.pid"
mysql_path="/usr/local/mysql/bin/"
datadir="/usr/local/mysql/data"
start(){
if [ ! -f "$pidfile" ]
  then
    $mysql_path/mysqld_safe --datadir=$datadir  --pid-file=$pidfile &>/dev/null &
    touch /var/lock/subsys/mysql
    sleep 1
    action "Start MySQL.." /bin/true
  else
    echo "MySQL is Running."
fi
}

stop(){
if [ -f "$pidfile" ]
  then
    kill `cat $pidfile` &>/dev/null
    sleep 1
    action "Stop MySQL.." /bin/true
  else
    action "Stop MySQL.." /bin/false
fi

}


restart() {
  stop
  start
}

USAGE(){
echo "USAGE $0 {start|stop|restart}"
exit 1

}

if [ "$#" -ne 1 ] 
  then
   USAGE
fi

case "$1" in
  "start")
	start
 	;;
  "stop")
	stop
	;;
  "restart")
	restart
	;;
  "*")
	USAGE
	;;
esac


