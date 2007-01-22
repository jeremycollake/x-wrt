#!/bin/sh
#
# script called after a sucessful ip update
#
RUN_D=/var/run
PID_F=$RUN_D/ez-ipupdate.pid

ddns_dir="/etc/ez-ipupdate"
ddns_cache="$ddns_dir/ez-ipupdate.cache"
ddns_msg="$ddns_dir/ez-ipupdate.msg"

echo -n "OK. Successful update to $1 at: " > $ddns_msg 
date >> $ddns_msg
