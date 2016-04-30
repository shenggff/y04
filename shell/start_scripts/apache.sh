#!/bin/bash
#author:wsh
# chkconfig: 2345 30 30
#description: apache
. /etc/init.d/functions
bin_file=/usr/local/apache/bin/apachectl
pid_file=/usr/local/apache/logs/httpd.pid

start(){
if [ ! -f $pid_file ]
 then
  $bin_file -t &>/dev/null
  if [ $? -ne 0 ]
   then
    $bin_file -t
   else
    $bin_file start
    action "Apache Started.." /bin/true
  fi
 else
  echo "Apache is already Running."  
 fi
}

stop(){
if [ -f $pid_file ]
 then
  $bin_file stop
  action "Apache Stoped.." /bin/true 
  rm -f $pid_file
 else
  action "Apache is not Running." /bin/false
  
fi
} 

restart(){
stop
sleep 1
start
}

USAGE(){
  echo "USAGE:$0 {start|stop|restart}"
  exit 1
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
 	 USAGE
 	 ;;
esac

