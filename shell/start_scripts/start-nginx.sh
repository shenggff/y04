#!/bin/bash
. /etc/init.d/functions
start_nginx=/usr/local/nginx/sbin/nginx
USAGE() {
  echo "USAGE $0 {start|stop|restart}"
  exit 1
}

if [ $# -ne 1 ]
  then
    USAGE
fi

if [ "$1" == "start" ]
  then
    action "start nginx" /bin/true
    $start_nginx
elif [ "$1" == "stop" ]
  then
    action "stop nginx" /bin/true
    killall nginx
elif [ "$1" == "restart" ]
  then
    action "restart nginx" /bin/true
    killall nginx
    sleep 2
    $start_nginx
else
  USAGE
fi

