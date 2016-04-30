#!/bin/bash
# chkconfig: 2345 20 20
# description: Nginx Server Control Script
. /etc/init.d/functions
PROG="/usr/local/nginx/sbin/nginx"
PIDF="/usr/local/nginx/logs/nginx.pid"
start(){
if [ ! -f "$PIDF" ]
  then
   $PROG -t &> /dev/null
   if [ "$?" -eq 0 ]
     then
	$PROG
	action "Strat Nginx.." /bin/true
   else
     $PROG -t	
   fi
else
   echo "Nginx is Running."
fi
}

stop(){
if [ -f "$PIDF" ]
  then
    kill -s QUIT `cat $PIDF` &>/dev/null
    sleep 1
    action "Stop Nginx.." /bin/true
  else
    action "Stop Nginx.." /bin/false
fi
}

reload(){
if [ -f "$PIDF" ]
  then
	$PROG -t &> /dev/null
	if [ "$?" -eq "0" ]
  		then
    		kill -s HUP $(cat $PIDF)
    		action "Reload Nginx config success.." /bin/true
  	else
    		$PROG -t
	fi
else
  echo "Nginx is not Running..Reload Failed"
fi
}

case "$1" in
        start)
		start
                ;;
        stop)
		stop
                ;;
        restart)
                stop
		sleep 1
                start
                ;;
        reload)
		reload
                ;;
        *)
                echo "USAGE:$0 {start | stop | restart | reload}"
                exit 1
esac

