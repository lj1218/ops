#!/bin/sh
# Author: lj1218
# Config file: /usr/local/webserver/nginx/conf/nginx.conf

pid_file=/usr/local/webserver/nginx/nginx.pid
[ -r ${pid_file} ] && [ $(cat /proc/${pid}/comm 2>/dev/null) = "nginx" ] && kill $(cat ${pid_file})
/usr/local/webserver/nginx/sbin/nginx
