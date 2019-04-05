#!/bin/sh
# Author: lj1218

function destory_firewall_rules()
{
    iptables -D OUTPUT -j OUTPUT_LIMIT
    iptables -F OUTPUT_LIMIT
    iptables -X OUTPUT_LIMIT
}

function setup_firewall_rules()
{
    iptables -N OUTPUT_LIMIT
    iptables -I OUTPUT -j OUTPUT_LIMIT
    iptables -A OUTPUT_LIMIT -p tcp -m tcp --sport 22 -j RETURN
    iptables -A OUTPUT_LIMIT -d 10.199.109.48 -p tcp -m tcp --dport 8080 -j RETURN
    iptables -A OUTPUT_LIMIT -d 10.199.109.0/24 -j DROP
}

function usage()
{
    echo "Usage: $0 <start | stop | restart>"
    exit 1
}

function do_start()
{
    setup_firewall_rules
}

function do_stop()
{
    destory_firewall_rules
}

function do_restart()
{
    do_stop
    do_start
}

[ $# -eq 0 ] && usage
opt=$1
case $opt in
    start)
        do_start
        ;;
    stop)
        do_stop
        ;;
    restart)
       do_restart
        ;;
    *)
        usage
        ;;
esac

