#!/bin/sh
initfile="/etc/init.d/S52ez-ipupdate"

ddns_dir="/etc/ez-ipupdate"
ddns_cache="$ddns_dir/ez-ipupdate.cache"
ddns_conf="$ddns_dir/ez-ipupdate.conf"
ddns_msg="$ddns_dir/ez-ipupdate.msg"

ddns_enable=$(nvram get ddns_enable)
ddns_service_type=$(nvram get ddns_service_type)
ddns_username=$(nvram get ddns_username)
ddns_passwd=$(nvram get ddns_passwd)
ddns_hostname=$(nvram get ddns_hostname)
ddns_server=$(nvram get ddns_server)
ddns_max_interval=$(nvram get ddns_max_interval)

# (re)start ez-ipupdated
if [ "$ddns_enable" -eq "1" ]; then
    mkdir -p $ddns_dir
    echo "service-type=$ddns_service_type"   > $ddns_conf
    echo "user=$ddns_username:$ddns_passwd" >> $ddns_conf
    echo "host=$ddns_hostname"              >> $ddns_conf
    [ -z "$ddns_server"       ] ||  echo "server=$ddns_server"             >> $ddns_conf
    [ -z "$ddns_max_interval" ] ||  echo "max-interval=$ddns_max_interval" >> $ddns_conf
    
    #[ -f $ddns_cache ] && rm -f  $ddns_cache
    
    [ -f $ddns_cache ] && rm -f $ddns_msg
    echo "(Re)start DynDNS ez-ipupdate" > $ddns_msg
    
    echo "(Re)start ez-ipupdate..."
    
    $initfile restart
else
    echo "Stop ez-ipupdate..."
    $initfile stop
fi
