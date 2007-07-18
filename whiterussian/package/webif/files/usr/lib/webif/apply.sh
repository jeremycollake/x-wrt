#!/bin/ash
#
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
cron_init="/etc/init.d/S60cron"

# log apply messages to syslog
apply_enable_logging="0"

HANDLERS_config='
	cron) restart_cron;;
	ezipupdate) reload_ezipupdate;;
	log) reload_log;;
	network) reload_network;;
	pptp) reload_pptp;;
	snmp) reload_snmp;;
	syslog) reload_syslog;;
	system) reload_system;;
	timezone) reload_timezone;;
	wifi-disable) reload_wifi_disable;;
	wifi-enable) reload_wifi_enable;;
	wireless) reload_wireless;;
'

HANDLERS_file='
	dnsmasq.conf) mv /tmp/.webif/file-dnsmasq.conf /etc/dnsmasq.conf && restart_dnsmasq;;
	ethers) rm -f /etc/ethers; mv $config /etc/ethers; reload_dnsmasq;;
	firewall) mv /tmp/.webif/file-firewall /etc/config/firewall && reload_firewall;;
	hosts) rm -f /etc/hosts; mv $config /etc/hosts; reload_dnsmasq;;
'

HANDLERS_edited_file='
	/etc/dnsmasq.conf) restart_dnsmasq;;
	/etc/ethers) reload_dnsmasq;;
	/etc/firewall.user) reload_firewall;;
	/etc/hosts) reload_dnsmasq;;
	/etc/config/firewall) reload_firewall;;
	/etc/crontabs/root) restart_cron;;
'

HANDLERS_uci='
	qos) apply_uci_qos;;
	upnpd) reload_upnpd;;
	webif) apply_uci_webif;;
'

# common messaging functions
log_message() {
	[ -z "$2" ] && {
		echo "$1"
	} || {
		echo -n "$1"
	}
	[ "$apply_enable_logging" = "1" ] && logger -t "webif^2-apply" "$(echo "$1" | sed 's/@TR<<\([^#>]\)*#//g; s/@TR<<//g; s/>>//g;')"
}
echo_reloading_settings() {
	log_message "@TR<<apply_Reloading_settings_for#Reloading settings for>>: $1" "$2"
}
echo_exporting_settings() {
	log_message "@TR<<apply_Exporting_settings_for#Exporting settings for>>: $1" "$2"
}
echo_applying_settings() {
	log_message "@TR<<apply_Applying_settings_for#Applying settings for>>: $1" "$2"
}
echo_restarting_service() {
	log_message "@TR<<apply_Restarting_service#Restarting service>>: $1" "$2"
}
echo_stopping_service() {
	log_message "@TR<<apply_Stopping_service#Stopping service>>: $1" "$2"
}
echo_processing_file() {
	log_message "@TR<<apply_Processing_file#Processing file>>: $1" "$2"
}
echo_processing_config() {
	log_message "@TR<<apply_Processing_config_file#Processing config file>>: $1" "$2"
}
echo_action_done() {
	log_message "@TR<<apply_Done#Done>>." "$2"
}

# for some reason a for loop with "." doesn't work
eval "$(cat /usr/lib/webif/apply-*.sh 2>&-)"

reload_dnsmasq() {
	echo_reloading_settings "@TR<<apply_dnsmasq#dnsmasq>>"
	killall -q -HUP dnsmasq
	[ -z "$(ps | grep "[d]nsmasq ")" ] && /etc/init.d/S??dnsmasq
	echo_action_done
}
restart_dnsmasq() {
	echo_restarting_service "@TR<<apply_dnsmasq#dnsmasq>>"
	killall -q dnsmasq
	/etc/init.d/S??dnsmasq
	echo_action_done
}
reload_wifi_enable() {
	echo_applying_settings "@TR<<apply_wifi_enable#splitting the wifi>>"
	ifdown wifi
	ifdown lan
	ifup lan
	ifup wifi
	reload_wireless
	reload_firewall
	restart_dnsmasq
	echo_action_done
}

reload_wifi_disable() {
	echo_applying_settings "@TR<<apply_wifi_disable#unsplitting the wifi>>"
	ifdown wifi
	ifdown lan
	ifup lan
	reload_wireless
	reload_firewall
	restart_dnsmasq
	echo_action_done
}

reload_network() {
	echo_reloading_settings "@TR<<apply_network#network>>"
	local wl0_ifname="$(nvram get wl0_ifname | sed 's/[[:space:]]//g')"
	grep '^wan_' config-network >&- 2>&- && {
		ifdown wan
		ifup wan
		[ -n "$wl0_ifname" ] && [ -n "$(nvram get wan_ifnames | grep "$wl0_ifname")" ] && reload_wireless
		reload_firewall
		reload_dnsmasq
	}

	grep '^lan_' config-network >&- 2>&- && {
		ifdown lan
		ifup lan
		[ -n "$wl0_ifname" ] && [ -n "$(nvram get lan_ifnames | grep "$wl0_ifname")" ] && reload_wireless
		reload_firewall
		restart_dnsmasq
	}
	echo_action_done
}

reload_wireless() {
	echo_reloading_settings "@TR<<apply_wireless#wireless>>"
	killall nas >&- 2>&- && sleep 2
	(
		/sbin/wifi
		[ -f /etc/init.d/S41wpa ] && /etc/init.d/S41wpa
	) >&- 2>&- <&-
	echo_action_done
}

reload_firewall() {
	echo_applying_settings "@TR<<apply_firewall#firewall>>"
	/etc/init.d/S??firewall
	echo_action_done
}

restart_cron() {
	# (re)start crond
	if [ -x "$cron_init" ]; then
		echo_restarting_service "@TR<<apply_cron#cron>>"
		$cron_init restart
		echo_action_done
	fi
}

reload_syslog() {
	getPID(){
		echo `ps -elf | grep '[s]yslogd' | awk '{ print $1 }'`
	}
	# (re)start syslogd
	echo_restarting_service "@TR<<apply_syslogd#syslogd>>"
	pid=$(getPID)
	[ -n "$pid" ] && kill $pid >/dev/null 2>&1
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
	echo_action_done
}

reload_system() {
	echo_applying_settings "@TR<<apply_system#system>>"
	echo "$(nvram get wan_hostname)" > /proc/sys/kernel/hostname
	grep '_admin' config-system >&- 2>&- && {
		reload_firewall
	}
	echo_action_done
}

reload_timezone() {
	# create symlink to /tmp/TZ if /etc/TZ doesn't exist
	# todo: -e | -f | -d didn't seem to work here, so I used find
	if [ -z $(find "/etc/TZ" 2>/dev/null) ]; then 
		ln -s /tmp/TZ /etc/TZ
	fi
	# eJunky: set timezone
	TZ=$(nvram get time_zone | cut -f 2)
	[ "$TZ" ] && echo $TZ > /etc/TZ
}

reload_upnpd() {
	echo_restarting_service "@TR<<apply_upnpd#upnpd>>"
	killall miniupnpd upnpd 2>&- >&-
	exists "/etc/init.d/S95miniupnpd" && /etc/init.d/S95miniupnpd
	exists "/etc/init.d/S65upnpd" && {
		/etc/init.d/S65upnpd stop 2>&- >&-
		/etc/init.d/S65upnpd start
	}
	echo_action_done
}

reload_ezipupdate() {
	ezipupdate_name="ez-ipupdate"
	[ -f "/etc/${ezipupdate_name}.conf" ] && mv -f "/etc/${ezipupdate_name}.conf" "/etc/${ezipupdate_name}.conf.sample"
	ezipupdate_init="/etc/init.d/S62$ezipupdate_name"
	[ -x $ezipupdate_init ] && {
		ddns_dir="/etc/$ezipupdate_name"
		ddns_conf="$ddns_dir/${ezipupdate_name}.conf"
		ddns_cache="$ddns_dir/${ezipupdate_name}.cache"
		ddns_msg="$ddns_dir/${ezipupdate_name}.msg"
		ezipupdate_pid="/var/run/${ezipupdate_name}.pid"
		ddns_exec_ok="$ddns_dir/${ezipupdate_name}-ok.sh"

		ddns_enable=$(nvram get ddns_enable)
		ddns_service_type=$(nvram get ddns_service_type)
		ddns_username=$(nvram get ddns_username)
		ddns_passwd=$(nvram get ddns_passwd)
		ddns_hostname=$(nvram get ddns_hostname)
		ddns_server=$(nvram get ddns_server)
		ddns_max_interval=$(nvram get ddns_max_interval)
		ddns_wildcard=$(nvram get ddns_wildcard)

		# (re)start ez-ipupdated
		if [ "$ddns_enable" = "1" ]; then
			mkdir -p $ddns_dir
			echo "# this file is automatically generated" > $ddns_conf
			echo "service-type=$ddns_service_type" >> $ddns_conf
			echo "user=$ddns_username:$ddns_passwd" >> $ddns_conf
			echo "host=$ddns_hostname" >> $ddns_conf
			[ -z "$ddns_server" ] || echo "server=$ddns_server" >> $ddns_conf
			[ -z "$ddns_max_interval" ] || echo "max-interval=$ddns_max_interval" >> $ddns_conf
			if [ "$ddns_wildcard" = "1" ]; then
				echo "wildcard" >> $ddns_conf
			fi
			echo "" >> $ddns_conf
			echo "# Do not change the lines below" >> $ddns_conf
			echo "cache-file=$ddns_cache" >> $ddns_conf
			echo "pid-file=$ezipupdate_pid" >> $ddns_conf
			echo "execute=$ddns_exec_ok" >> $ddns_conf

			echo_restarting_service "@TR<<apply_ez-ipupdate#ez-ipupdate>>"
			$ezipupdate_init restart >&- 2>&- &
			echo_action_done
		else		
			echo_stopping_service "@TR<<apply_ez-ipupdate#ez-ipupdate>>"
			$ezipupdate_init stop >&- 2>&- &
			echo_action_done
		fi
	}
}

mkdir -p "/tmp/.webif"
_pushed_dir=$(pwd)
cd "/tmp/.webif"

# edited-files/*		user edited files - stored with directory tree in-tact
for edited_file in $(find "/tmp/.webif/edited-files/" -type f 2>&-); do
	target_file=$(echo "$edited_file" | sed s/'\/tmp\/.webif\/edited-files'//g)
	echo_processing_file "$target_file"
	fix_symlink_hack "$target_file"
	if tr -d '\r' <"$edited_file" >"$target_file"; then
		rm "$edited_file" 2>&-
		echo_action_done
		eval 'case "$target_file" in
			'"$HANDLERS_edited_file"'
		esac'
	else
		log_message "@TR<<aplly_Error#Error>>: @TR<<apply_Could_not_replace#Could not replace>> $target_file. @TR<<apply_Media_full#Media full>>?"
	fi
done
# leave if some files not applied
rm -r "/tmp/.webif/edited-files" 2>&-

# file-*		other config files
for config in $(ls file-* 2>&-); do
	name=${config#file-}
	echo_processing_config "$name"
	eval 'case "$name" in
		'"$HANDLERS_file"'
	esac'
	echo_action_done
done

# config-conntrack	  Conntrack Config file
for config in $(ls config-conntrack 2>&-); do
	echo_applying_settings "@TR<<apply_conntrack#conntrack>>"
	fix_symlink_hack "/etc/sysctl.conf"
	# set any and all net.ipv4.netfilter settings.
	for conntrack in $(grep ip_ /tmp/.webif/config-conntrack); do
		variable_name=$(echo "$conntrack" | cut -d '=' -f1)
		variable_value=$(echo "$conntrack" | cut -d '"' -f2)
		echo "&nbsp;$variable_name=$variable_value"
		remove_lines_from_file "/etc/sysctl.conf" "net.ipv4.netfilter.$variable_name"
		echo "net.ipv4.netfilter.$variable_name=$variable_value" >> /etc/sysctl.conf
	done
	sysctl -p 2>&- 1>&- # reload sysctl.conf
	rm -f /tmp/.webif/config-conntrack
	echo_action_done
done

reload_snmp() {
	[ -e "/bin/save_snmp" ] && {
		echo_exporting_settings "@TR<<apply_snmp#snmp>>"
		/bin/save_snmp >&- 2>&-
		echo_action_done
	}

	echo_restarting_service "@TR<<apply_snmp#snmp>>"
	[ ! -e /etc/init.d/S??snmpd ] && {
		ln -s "/etc/init.d/snmpd" "/etc/init.d/S92snmpd" 2>/dev/null
	}
	/etc/init.d/S??snmpd restart >&- 2>&-
	echo_action_done
}

reload_pptp() {
	grep '_cli' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptp ] && {
		echo_restarting_service "@TR<<apply_pptp#pptp>>"
		/etc/init.d/S??pptp stop >&- 2>&-
		/etc/init.d/S??pptp start >&- 2>&-
		echo_action_done
	}
	grep '_srv' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptpd ] && {
		echo_restarting_service "@TR<<apply_pptpd#pptpd>>"
		/etc/init.d/S??pptpd stop  >&- 2>&-
		/etc/init.d/S??pptpd start >&- 2>&-
		echo_action_done
	}
}

reload_log() {
	echo_restarting_service "@TR<<apply_syslogd#syslogd>>"
	killall syslogd >&- 2>&- <&-
	/sbin/runsyslogd >&- 2>&- <&-
	echo_action_done
}

# config-*		simple config files
(
	cd /proc/self
	cat /tmp/.webif/config-* 2>&- | grep '=' >&- 2>&- && {
		log_message "@TR<<apply_Committing_NVRAM#Committing NVRAM>>"
		exists "/usr/sbin/nvram" && {
			cat /tmp/.webif/config-* 2>&- | tee fd/1 | xargs -n1 nvram set	
			nvram commit
		}
		echo_action_done
	}
)

for config in $(ls config-* 2>&-); do
	name=${config#config-}
	eval 'case "$name" in
		'"$HANDLERS_config"'
	esac'
done

uci_load_originals() {
	local cfsection
	config_load "$1"
	for cfsection in $CONFIG_SECTIONS; do
		config_rename "$cfsection" "orig_$cfsection"
	done
	CONFIG_orig_SECTION="$CONFIG_SECTIONS"
}

uci_unset_originals() {
	local cfsection
	local oldvar
	for cfsection in $CONFIG_orig_SECTION; do
		for oldvar in $(set | grep "^CONFIG_${cfsection}_" | sed -e 's/\(.*\)=.*$/\1/'); do
			unset "$oldvar"
		done
	done
	unset CONFIG_orig_SECTION
}

# switch languages if changed
switch_language() {
	! empty "$CONFIG_general_lang" && ! equal "$CONFIG_general_lang" "$CONFIG_orig_general_lang" && {
		# if not English then we install language pack
		! equal "$CONFIG_general_lang" "en" && {
			log_message "@TR<<apply_Installing_language_pack#Installing language pack>>"
			# build URL for package
			#  since the original webif may be installed to, have to make sure we get latest ver
			webif_version=$(ipkg status webif | awk '/Version:/ { print $2 }')
			xwrt_repo_url=$(cat /etc/ipkg.conf | grep -i "^src[[:space:]]*X-Wrt[[:space:]]*" | cut -d' ' -f3)
			# always install language pack, since it may have been updated without package version change
			ipkg install "${xwrt_repo_url}/webif-lang-${CONFIG_general_lang}_${webif_version}_mipsel.ipk" -force-reinstall -force-overwrite | uniq
			if equal "$(ipkg status "webif-lang-${CONFIG_general_lang}" |grep "Status:" |grep " installed" )" ""; then
				log_message "@TR<<apply_Error_installing_language#Error installing language pack>>!"
				uci_set "webif" "general" "lang" "${CONFIG_orig_general_lang:-en}"
				uci_commit "webif"
			else
				# always update language packs for the webif^2 jewelry
				for ajewel in $(ipkg list_installed "webif*" | cut -d' ' -f1 | sed '/^webif-/!d; /-lang-/d'); do
					! empty "$(ipkg list "${ajewel}-lang-${CONFIG_general_lang}" | grep "^${ajewel}-lang-${CONFIG_general_lang}\>")" && {
						log_message "@TR<<apply_Installing_additional_language_pack#Installing additional language pack>>"
						ipkg install "${ajewel}-lang-${CONFIG_general_lang}" -force-reinstall -force-overwrite | uniq
					}
				done
			fi
			echo_action_done
		}
	}
}

# init_theme - initialize a new theme
init_theme() {
	! equal "$CONFIG_theme_id" "$CONFIG_orig_theme_id" && {
		log_message "@TR<<apply_Initializing_theme#Initializing theme>>"
		# if theme isn't present, then install it		
		! exists "/www/themes/$CONFIG_theme_id/webif.css" && {
			install_package "webif-theme-$CONFIG_theme_id"	
		}
		if ! exists "/www/themes/$CONFIG_theme_id/webif.css"; then
			# if theme still not installed, there was an error
			log_message "@TR<<aplly_Error#Error>>: @TR<<aplly_theme_installation_failed#theme package installation failed>>."
		else
			# create symlink to new active theme if its not already set right
			current_theme=$(ls /www/themes/active -l | cut -d '>' -f 2 | sed s/'\/www\/themes\/'//g)
			! equal "$current_theme" "$CONFIG_theme_id" && {
				rm /www/themes/active
				ln -s /www/themes/$CONFIG_theme_id /www/themes/active
			}
		fi		
		echo_action_done
	}
}

apply_uci_webif() {
	switch_language
	init_theme
	[ -x /etc/init.d/S??webif_deviceid ] && {
		/etc/init.d/S??webif_deviceid
	}
	[ -x /etc/init.d/S??opendns ] && {
		/etc/init.d/S??opendns restart
	}
}

apply_uci_qos() {
	echo_applying_settings "@TR<<apply_qos#qos>>"
	qos-start
	echo_action_done
}

#
# now apply any UCI config changes
#
for packagefile in $(ls /tmp/.uci/* 2>&-); do
	# do not process lock files
	[ "${packagefile%.lock}" != "${packagefile}" ] && continue
	package="${packagefile#/tmp/.uci/}"
	log_message "@TR<<apply_Committing_settings#Committing settings>>: $package"
	uci_load_originals "$package"
	uci_commit "$package"
	uci_load "$package"
	eval 'case "$package" in
		'"$HANDLERS_uci"'
	esac'
	uci_unset_originals "$package"
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
rm /tmp/.uci/* >&- 2>&-

