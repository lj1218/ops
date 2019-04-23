#!/bin/sh
# Author: lj1218

pid_file=/usr/local/webserver/nginx/nginx.pid
[ -r ${pid_file} ] && {
    if [ $(cat /proc/${pid}/comm 2>/dev/null) = "nginx" ]; then
        kill $(cat ${pid_file}) && echo "nginx stopped"
        exit
    fi
}
echo "nginx not running"
