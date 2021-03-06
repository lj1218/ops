#!/bin/sh
# Author: lj1218

localport="21000"
remoteip="10.199.103.219"
remoteport="21000"
forward_conf="0.0.0.0 ${localport} ${remoteip} ${remoteport}"
forward_conf_file="/etc/rinetd.conf"
forward_cmd="rinetd -c ${forward_conf_file}"

function kill_forward_process()
{
    pkill rinetd
    rm -f ${forward_conf_file}
}

function start_forward_process()
{
    echo ${forward_conf} >${forward_conf_file}
    ${forward_cmd}
}

function destory_firewall_rules()
{
    iptables -D OUTPUT -j OUTPUT_LIMIT
    iptables -F OUTPUT_LIMIT
    iptables -X OUTPUT_LIMIT
    iptables -D IN_public_allow -j IN_public_allow_forward
    iptables -F IN_public_allow_forward
    iptables -X IN_public_allow_forward
}

function setup_firewall_rules()
{
    iptables -N OUTPUT_LIMIT
    iptables -I OUTPUT -j OUTPUT_LIMIT
    iptables -A OUTPUT_LIMIT -p tcp -m tcp --sport 22 -j RETURN
    iptables -A OUTPUT_LIMIT -p tcp -m tcp --sport ${localport} -j RETURN
    iptables -A OUTPUT_LIMIT -d 10.199.109.48 -p tcp -m tcp --dport 8080 -j RETURN
    iptables -A OUTPUT_LIMIT -d ${remoteip} -p tcp -m tcp --dport ${remoteport} -j RETURN
    iptables -A OUTPUT_LIMIT -d 10.199.109.0/24 -j DROP
    iptables -N IN_public_allow_forward
    iptables -A IN_public_allow -j IN_public_allow_forward
    iptables -A IN_public_allow_forward -p tcp -m tcp --dport ${localport} -m conntrack --ctstate NEW -j ACCEPT
}

function usage()
{
    echo "Usage: $0 <start | stop | restart>"
    exit 1
}

function do_start()
{
    setup_firewall_rules
    start_forward_process
}

function do_stop()
{
    destory_firewall_rules
    kill_forward_process
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

