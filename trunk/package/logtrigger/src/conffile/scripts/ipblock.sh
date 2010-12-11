#!/bin/sh
ipt_run () {
	RUN="/usr/sbin/iptables $@"
	echo $RUN
#	$RUN
}

[ ! -z $LT_ip ] && ipt_run -I INPUT -s $LT_ip -j DROP

#ipt_run -A OUTPUT -d $z -j DROP