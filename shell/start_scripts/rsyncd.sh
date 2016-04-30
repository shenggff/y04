#!/bin/bash
#chkconfig:2345 21 21
#description:Rsync control script
. /etc/init.d/functions

rsync_bin="/usr/bin/rsync"
rsync_pid="/var/run/rsyncd.pid"

start(){
rsync_status=$(netstat -tlnp|grep 873|wc -l)
if [ $rsync_status -lt 1 ]
  then
	$rsync_bin --daemon &>/dev/null
	sleep 1
	action "Start Rsync.." /bin/true
else
  echo "Rsync is Running.."
  exit 1
fi 
}

stop(){
rsync_status=$(netstat -tlnp|grep 873|wc -l)
if [ $rsync_status -ge 1 ]
  then
	killall rsync &>/dev/null
	sleep 1
	action "Stop Rsync Successful"	/bin/true
	rm -rf $rsync_pid
else
  action "Rsync is not Running." /bin/false
fi
}

restart(){
stop
start
}
 

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
  *)
	echo "USAGE:$0 {start|stop|restart|reload}"
	exit 3
	;;
esac

