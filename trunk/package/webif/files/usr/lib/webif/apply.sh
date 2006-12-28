#!/bin/ash
#
# This file is compatible with both Kamikaze and White Russian.
#
# Handler for config application of all types.
#
#   Types supported:
#	config-*	Simple config files (tuples)
#	uci-*		UCI config files
#	file-*		Undefined format for whatever
#	edited-files-*  raw edited files
#
#
. /usr/lib/webif/functions.sh
. /lib/config/uci.sh
cron_init="/etc/init.d/S51crond"

HANDLERS_config='
	wireless) reload_wireless;;
	network) reload_network;;
	system) reload_system;;
	cron) reload_cron;;
	syslog) reload_syslog;;
	wifi-enable) reload_wifi_enable;;
	wifi-disable) reload_wifi_disable;;
	hotspot) reload_hotspot;;
	pptp) reload_pptp;;
	log) reload_log;;
	ezipupdate) reload_ezipupdate;;
'

HANDLERS_file='
	hosts) rm -f /etc/hosts; mv $config /etc/hosts; killall -HUP dnsmasq ;;
	ethers) rm -f /etc/ethers; mv $config /etc/ethers; killall -HUP dnsmasq ;;
	firewall) mv /tmp/.webif/file-firewall /etc/config/firewall && /etc/init.d/S??firewall;;
	dnsmasq.conf) mv /tmp/.webif/file-dnsmasq.conf /etc/dnsmasq.conf && /etc/init.d/S??dnsmasq;;
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
	if [ "$(nvram get firmware_version)" = "0.9" ]; then
	ipcalc.sh -s "$syslog_ip" || syslog_ip=""
	else
	ipcalc -s "$syslog_ip" || syslog_ip=""
	fi
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

reload_upnpd() {
	echo '@TR<<Reloading>> @TR<<UPNPd>> ...'
	killall miniupnpd upnpd 2>&- >&-
	exists "/etc/init.d/S95miniupnpd" && /etc/init.d/S95miniupnpd
	exists "/etc/init.d/S65upnpd" && {
		/etc/init.d/S65upnpd stop 2>&- >&-
		/etc/init.d/S65upnpd start
	}
}

reload_ezipupdate() {
	initfile="/etc/init.d/S52ez-ipupdate"

	ddns_dir="/etc/ez-ipupdate"
	ddns_cache="$ddns_dir/ez-ipupdate.cache"
	ddns_conf="$ddns_dir/ez-ipupdate.conf"
	ddns_msg="$ddns_dir/ez-ipupdate.msg"

	if exists "/usr/sbin/nvram"; then
		ddns_enable=$(nvram get ddns_enable)
		ddns_service_type=$(nvram get ddns_service_type)
		ddns_username=$(nvram get ddns_username)
		ddns_passwd=$(nvram get ddns_passwd)
		ddns_hostname=$(nvram get ddns_hostname)
		ddns_server=$(nvram get ddns_server)
		ddns_max_interval=$(nvram get ddns_max_interval)
	else
		echo "ERROR: ez-ipupdate config apply not updated for non-nvram systems."
	fi

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
		
		$initfile restart >&- 2>&- &
	else		
		$initfile stop >&- 2>&- &
	fi
}

mkdir -p "/tmp/.webif"
_pushed_dir=$(pwd)
cd "/tmp/.webif"

# edited-files/*		user edited files - stored with directory tree in-tact
for edited_file in $(find "/tmp/.webif/edited-files/" -type f 2>&-); do
	target_file=$(echo "$edited_file" | sed s/'\/tmp\/.webif\/edited-files'//g)
	echo "@TR<<Processing>> $target_file"
	fix_symlink_hack "$target_file"
	if tr -d '\r' <"$edited_file" >"$target_file"; then
		rm "$edited_file" 2>&-
	else
		echo "@TR<<Critical Error>> : @TR<<Could not replace>> $target_file. @TR<<Media full>>?"
	fi
done
# leave if some files not applied
rm -r "/tmp/.webif/edited-files" 2>&-

# file-*		other config files
for config in $(ls file-* 2>&-); do
	name=${config#file-}
	echo "@TR<<Processing>> @TR<<config file>>: $name"
	eval 'case "$name" in
		'"$HANDLERS_file"'
	esac'
done

# config-webif		Webif config
for config in $(ls config-webif 2>&-); do
	echo '@TR<<Applying>> @TR<<Webif settings>> ...'
	for newlang in $(grep "language" "$config" |cut -d '"' -f2); do
		_tmpwebifconfig=$(mktemp "/tmp/.webif-XXXXXX")
		touch "$_tmpwebifconfig"  # for to exist
		exists "/etc/config/webif" && {
			cat "/etc/config/webif" | sed /'lang='/d > "$_tmpwebifconfig"
		}
		echo "lang=$newlang" >> "$_tmpwebifconfig"
		if equal "$newlang" "en"; then
			mv -f "$_tmpwebifconfig" "/etc/config/webif"
		else
			# build URL for package
			#  since the original webif may be installed to, have to make sure we get latest ver
			webif_version=$(ipkg status webif | awk '/Version:/ { print $2 }')
			xwrt_repo_url=$(cat /etc/ipkg.conf | grep X-Wrt | cut -d' ' -f3)
			# always install language pack, since it may have been updated without package version change
			ipkg install "${xwrt_repo_url}/webif-lang-${newlang}_${webif_version}_mipsel.ipk" -force-reinstall -force-overwrite | uniq
			# switch to it if installed, even old one, otherwise return to previous
			if ! equal "$(ipkg status "webif-lang-${newlang}" |grep "Status:" |grep " installed" )" ""; then
				mv -f "$_tmpwebifconfig" "/etc/config/webif"
			else
				rm -f "$_tmpwebifconfig" 2>/dev/null
				rm -f "/tmp/.webif/config-webif" 2>/dev/null
			fi
		fi
	done
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
	echo '@TR<<Applying>> @TR<<conntrack settings>> ...'
	fix_symlink_hack "/etc/sysctl.conf"
	# set any and all net.ipv4.netfilter settings.
	for conntrack in $(grep ip_ /tmp/.webif/config-conntrack); do
		variable_name=$(echo "$conntrack" | cut -d '=' -f1)
		variable_value=$(echo "$conntrack" | cut -d '"' -f2)
		echo "&nbsp;@TR<<Setting>> $variable_name to $variable_value"
		remove_lines_from_file "/etc/sysctl.conf" "net.ipv4.netfilter.$variable_name"
		echo "net.ipv4.netfilter.$variable_name=$variable_value" >> /etc/sysctl.conf
	done
	sysctl -p 2>&- 1>&- # reload sysctl.conf
	rm -f /tmp/.webif/config-conntrack
	echo '@TR<<Done>>'
done

# init_theme - initialize a new theme
init_theme() {
	echo '@TR<<Initializing theme ...>>'	
	uci_load "webif"
	newtheme="$CONFIG_theme_id"	
	# if theme isn't present, then install it		
	! exists "/www/themes/$newtheme/webif.css" && {
		install_package "webif-theme-$newtheme"	
	}
	if ! exists "/www/themes/$newtheme/webif.css"; then
		# if theme still not installed, there was an error
		echo "@TR<<Error>>: @TR<<installing theme package>>."
	else
		# create symlink to new active theme if its not already set right
		current_theme=$(ls /www/themes/active -l | cut -d '>' -f 2 | sed s/'\/www\/themes\/'//g)
		! equal "$current_theme" "$newtheme" && {
			rm /www/themes/active
			ln -s /www/themes/$newtheme /www/themes/active
		}
	fi		
	echo '@TR<<Done>>'
}

reload_hotspot() {
	echo '@TR<<Reloading>> @TR<<hotspot settings>> ...'
	grep -v '^hs_cframe' config-hotspot | grep '^hs_' >&- 2>&- && {
	[ -e "/usr/sbin/chilli" ] && {
		/etc/init.d/S??chilli stop  >&- 2>&-
		/etc/init.d/S??chilli start >&- 2>&-
	}
	[ -e "/usr/bin/wdctl" ] && {
		wdctl stop >&- 2>&-
		/etc/init.d/S??wifidog start >&- 2>&-
	}
	}
	grep '^hs_cframe' config-hotspot >&- 2>&- && {
	[ -e /etc/init.d/S??cframe ] && {
		/etc/init.d/S??cframe stop  >&- 2>&-
		/etc/init.d/S??cframe start >&- 2>&-
	}
	}
}

reload_pptp() {
	echo '@TR<<Reloading>> @TR<<PPTP settings>> ...'
	grep '_cli' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptp ] && {
		/etc/init.d/S??pptp stop >&- 2>&-
		/etc/init.d/S??pptp start >&- 2>&-
	}
	grep '_srv' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptpd ] && {
		/etc/init.d/S??pptpd stop  >&- 2>&-
		/etc/init.d/S??pptpd start >&- 2>&-
	}
}

reload_log() {
	echo '@TR<<Reloading syslogd>> ...'
	killall syslogd >&- 2>&- <&-
	/sbin/runsyslogd >&- 2>&- <&-
}


# config-*		simple config files
(
	cd /proc/self
	cat /tmp/.webif/config-* 2>&- | grep '=' >&- 2>&- && {
		exists "/usr/sbin/nvram" && {
			cat /tmp/.webif/config-* 2>&- | tee fd/1 | xargs -n1 nvram set	
			echo "@TR<<Committing>> NVRAM ..."
			nvram commit
		}
	}
)

for config in $(ls config-* 2>&-); do
	name=${config#config-}
	eval 'case "$name" in
		'"$HANDLERS_config"'
	esac'
done

#
# now apply any UCI config changes
#
for package in $(ls /tmp/.uci/* 2>&-); do
	echo "@TR<<Committing>> ${package#/tmp/.uci/} ..."
	uci_commit "$package"
	case "$package" in
		"/tmp/.uci/qos") qos-start;;
		"/tmp/.uci/webif") init_theme;;
		"/tmp/.uci/upnpd") reload_upnpd;;
		"/tmp/.uci/network")
			# for kamikaze
			echo '@TR<<Reloading>> @TR<<network>> ...'
			ifdown wan
			ifup wan			
			ifdown lan
			ifup lan
			killall dnsmasq
			/etc/init.d/dnsmasq start ;;
		"/tmp/.uci/syslog")
			# for kamikaze
			echo '@TR<<Reloading>> @TR<<syslogd>> ...'
			killall syslogd >&- 2>&- <&-
			/sbin/runsyslogd >&- 2>&- <&- ;;
		"/tmp/.uci/openvpn")
			echo '@TR<<Reloading>> @TR<<OpenVPN>> ...'
			killall openvpn >&- 2>&- <&-
			/etc/rc.d/S??openvpn start ;;
	esac
done

#
# commit tarfs if exists
#
[ -f "/rom/local.tar" ] && config save

#
# cleanup
#
cd "$pushed_dir"
rm /tmp/.webif/* >&- 2>&-

