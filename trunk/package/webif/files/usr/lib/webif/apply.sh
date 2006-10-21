#!/bin/ash
#
# Default handlers for config files
#

cron_init="/etc/init.d/S51crond"

HANDLERS_config='
	wireless) reload_wireless;;
	network) reload_network;;
	system) reload_system;;
	cron) reload_cron;;
	syslog) reload_syslog;;
	wifi-enable) reload_wifi_enable;;
	wifi-disable) reload_wifi_disable;;
	
'
HANDLERS_file='
	hosts) rm -f /etc/hosts; mv $config /etc/hosts; killall -HUP dnsmasq ;;
	ethers) rm -f /etc/ethers; mv $config /etc/ethers; killall -HUP dnsmasq ;;
	firewall) mv /tmp/.webif/file-firewall /etc/config/firewall && /etc/init.d/S??firewall;;
	dnsmasq.conf) mv /tmp/.webif/file-dnsmasq.conf /etc/dnsmasq.conf && /etc/init.d/S50dnsmasq;;				
'

# for some reason a for loop with "." doesn't work
eval "$(cat /usr/lib/webif/apply-*.sh 2>&-)"

reload_wifi_enable() {
	ifup lan
	ifup wifi
	killall dnsmasq
	/etc/init.d/S??dnsmasq
}

reload_wifi_disable() {
	ifup lan
	killall dnsmasq
	/etc/init.d/S??dnsmasq
}

reload_network() {
	echo '@TR<<Reloading>> @TR<<networking settings>> ...'
	grep '^wan_' config-network >&- 2>&- && {
		ifdown wan
		ifup wan
		killall -HUP dnsmasq
	}
	
	grep '^lan_' config-network >&- 2>&- && {
		ifdown lan
		ifup lan
		killall dnsmasq
		/etc/init.d/S??dnsmasq
	}
}

reload_wireless() {
	echo '@TR<<Reloading>> @TR<<wireless settings>> ...'
	killall nas >&- 2>&- && sleep 2
	(
		/sbin/wifi
		[ -f /etc/init.d/S41wpa ] && /etc/init.d/S41wpa
	) >&- 2>&- <&-
}

reload_cron() {
	echo '@TR<<Reloading Cron>> ...'
# (re)start crond
if [ -x $cron_init ]; then
    echo "(Re)start cron..."
    $cron_init restart
fi
}

reload_syslog() {
getPID(){
    echo `ps -elf | grep 'syslogd' | grep -v grep | awk '{ print $1 }'`
}
# (re)start syslogd

echo "(Re)start syslogd..."
pid=$(getPID)
if [ -n "$pid" ]; then
    echo -n "Stopping syslogd: "
    ( { 
        kill $pid >/dev/null 2>&1
      } && echo "OK" ) || echo "ERROR"
fi
echo -n "Start syslogd: "
syslog_ip=$(nvram get log_ipaddr)
ipcalc -s "$syslog_ip" || syslog_ip=""
log_port=$(nvram get log_port) 
log_port=${log_port:+:$log_port} 
log_mark=$(nvram get log_mark) 
log_mark=${log_mark:+-m $log_mark}
can_prefix=`syslogd --help 2>&1 | grep -e 'PREFIX' `
log_prefix=""
[ -z "$can_prefix" ] || log_prefix=$(nvram get log_prefix)
log_prefix=${log_prefix:+-P "$log_prefix"}
syslogd -C 16 ${syslog_ip:+-L -R $syslog_ip$log_port} $log_mark $log_prefix

echo "OK"
}

reload_system() {
	echo '@TR<<Applying>> @TR<<system settings>> ...'
	echo "$(nvram get wan_hostname)" > /proc/sys/kernel/hostname
	grep '_admin' config-system >&- 2>&- && {
	    echo '@TR<<Reloading>> @TR<<firewall settings>> ...'
	    /etc/init.d/S??firewall
	}
}

cd "/tmp/.webif"

is_read_only() {	
	rom_file="/rom/$1"
	touch "$1" 2>&- || [ -f "$rom_file" ]
}

# edited-files/*		user edited files - stored with directory tree in-tact
for edited_file in $(find "/tmp/.webif/edited-files/" -type f 2>&-); do
	target_file=$(echo "$edited_file" | sed s/'\/tmp\/.webif\/edited-files'//g)
	echo "@TR<<Processing>> $target_file"
	# for squashfs symlink hack
	is_read_only "$target_file" && {		
		rm "$target_file"
	}
	if cp "$edited_file" "$target_file"; then
		rm "$edited_file" 2>&-
	else
	 	echo "@TR<<Critical Error>> : Could not replace $target_file. Media full?"
	fi						
done
# leave if some files not applied
rm -r "/tmp/.webif/edited-files" 2>&-

# file-* 		other config files
for config in $(ls file-* 2>&-); do
	name=${config#file-}
	echo "@TR<<Processing>> @TR<<config file>>: $name"
	eval 'case "$name" in
		'"$HANDLERS_file"'
	esac'
done

# config-qos		QOS Config file
for config in $(ls config-qos 2>&-); do 
echo '@TR<<Applying>> @TR<<QOS settings>> ...'
/usr/bin/qos-stop
mv -f config-qos /etc/qos.conf
/usr/bin/qos-start
echo '@TR<<Done>>'
done

# config-wifi-enable		QOS Config file
for config in $(ls config-wifi-enable 2>&-); do
	ifdown wifi
	ifdown lan
done

# config-wifi-disable		QOS Config file
for config in $(ls config-wifi-disable 2>&-); do
	ifdown wifi
	br_int=$(nvram get wifi_ifname)
	brctl delbr $br_int
	ifdown lan
done

# config-conntrack	  Conntrack Config file
for config in $(ls config-conntrack 2>&-); do 
echo '@TR<<Applying>> @TR<<Conntrack settings>> ...'
	for conntrack in $(grep ip_conntrack_max /tmp/.webif/config-conntrack |cut -d '"' -f2); do
		sysctl -w net.ipv4.ip_conntrack_max=$conntrack
	done
	
	for conntrack in $(grep tcp_timeout /tmp/.webif/config-conntrack |cut -d '"' -f2); do
		sysctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_established=$conntrack
	done
	
	for conntrack in $(grep udp_timeout /tmp/.webif/config-conntrack |cut -d '"' -f2); do
		sysctl -w  net.ipv4.netfilter.ip_conntrack_udp_timeout=$conntrack
	done
rm -f /tmp/.webif/config-conntrack
echo '@TR<<Done>>'
done

# config-*		simple config files
(
	cd /proc/self
	cat /tmp/.webif/config-* 2>&- | grep '=' >&- 2>&- && {
		cat /tmp/.webif/config-* 2>&- | tee fd/1 | xargs -n1 nvram set
		echo "@TR<<Committing>> NVRAM ..."
		nvram commit
	}
)
for config in $(ls config-* 2>&-); do 
	name=${config#config-}
	eval 'case "$name" in
		'"$HANDLERS_config"'
	esac'
done
sleep 2
rm -f config-*
