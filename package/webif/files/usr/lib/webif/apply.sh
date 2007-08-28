#!/bin/ash
#
#
# Handler for config application of all types.
#
#   Types supported:
#	uci-*		UCI config files
#	file-*		Undefined format for whatever
#	edited-files-*  raw edited files
#
#
. /usr/lib/webif/functions.sh
. /lib/config/uci.sh

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		timezone)
			timezone_cfg="$CONFIG_SECTION"
		;;
		ntp_client)
			config_get hostname     $CONFIG_SECTION hostname
			config_get port         $CONFIG_SECTION port
			config_get count        $CONFIG_SECTION count
	
			[ "$DONE" = "1" ] && exit 0
			ps x | grep 'bin/[n]tpclient' >&- || {
				route -n 2>&- | grep '^0.0.0.0' >&- && {
					/usr/sbin/ntpclient -c ${count:-1} -s -h $hostname -p ${port:-123} 2>&- >&- && DONE=1
				}
			}
                ;;
                system)
                	config_get hostname $CONFIG_SECTION hostname
                	echo "${hostname:-OpenWrt}" > /proc/sys/kernel/hostname
                ;;
	esac
}

HANDLERS_file='
	hosts) rm -f /etc/hosts; mv $config /etc/hosts; killall -HUP dnsmasq ;;
	ethers) rm -f /etc/ethers; mv $config /etc/ethers; killall -HUP dnsmasq ;;
	firewall) mv /tmp/.webif/file-firewall /etc/config/firewall && /etc/init.d/firewall restart && reload_upnpd;;
	dnsmasq.conf) mv /tmp/.webif/file-dnsmasq.conf /etc/dnsmasq.conf && /etc/init.d/dnsmasq restart;;
'

# for some reason a for loop with "." doesn't work
eval "$(cat /usr/lib/webif/apply-*.sh 2>&-)"

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

reload_upnpd() {
	config_load upnpd
	config_get_bool test config enabled 0
	if [ 1 -eq "$test" ]; then
		echo '@TR<<Starting>> @TR<<upnpd>> ...'
		[ -f /etc/init.d/miniupnpd ] && {
			/etc/init.d/miniupnpd enable >&- 2>&- <&-
			/etc/init.d/miniupnpd start >&- 2>&- <&-
		}
		[ -f /etc/init.d/upnpd ] && {
			/etc/init.d/upnpd enable >&- 2>&- <&-
			/etc/init.d/upnpd restart >&- 2>&- <&-
		}
	else
		echo '@TR<<Stopping>> @TR<<upnpd>> ...'
		[ -f /etc/init.d/miniupnpd ] && {
			/etc/init.d/miniupnpd stop >&- 2>&- <&-
			/etc/init.d/miniupnpd disable >&- 2>&- <&-
		}
		[ -f /etc/init.d/upnpd ] && {
			/etc/init.d/upnpd stop >&- 2>&- <&-
			/etc/init.d/upnpd disable >&- 2>&- <&-
		}
	fi
	config_clear config
}

# switch_language (old_lang)  - switches language if changed
switch_language() {
	oldlang="$1"
	uci_load "webif"
	newlang="$CONFIG_general_lang"
	! equal "$newlang" "$oldlang" && {
		echo '@TR<<Applying>> @TR<<Installing language pack>> ...'
		# if not English then we install language pack
		! equal "$newlang" "en" && {
			# build URL for package
			#  since the original webif may be installed to, have to make sure we get latest ver
			webif_version=$(ipkg status webif | awk '/Version:/ { print $2 }')
			xwrt_repo_url=$(cat /etc/ipkg.conf | grep X-Wrt | cut -d' ' -f3)
			# always install language pack, since it may have been updated without package version change
			ipkg install "${xwrt_repo_url}/webif-lang-${newlang}_${webif_version}_all.ipk" -force-reinstall -force-overwrite | uniq
			# switch to it if installed, even old one, otherwise return to previous
			if equal "$(ipkg status "webif-lang-${newlang}" |grep "Status:" |grep " installed" )" ""; then
				echo '@TR<<Error installing language pack>>!'
			fi
		}
		echo '@TR<<Done>>'
	}
}

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

#
# now apply any UCI config changes
#
for ucifile in $(ls /tmp/.uci/* 2>&-); do
	# do not process lock files
	[ "${ucifile%.lock}" != "${ucifile}" ] && continue
	# store original language before committing new one so we know if changed
	equal "$ucifile" "/tmp/.uci/webif" && {
		uci_load_originals "webif"
		oldlang="$CONFIG_orig_general_lang"
		uci_unset_originals "webif"
		uci_load "webif"
	}
	package=${ucifile#/tmp/.uci/}
	echo "@TR<<Committing>> $package ..."
	uci_commit "$package"
	case "$ucifile" in
		"/tmp/.uci/qos") qos-start;;
		"/tmp/.uci/webif") 
			switch_language "$oldlang"
			init_theme
			/etc/init.d/webif start
			;;
		"/tmp/.uci/upnpd")
			reload_upnpd
			;;
		"/tmp/.uci/network")
			echo '@TR<<Reloading>> @TR<<network>> ...'
			/etc/init.d/network restart
			killall dnsmasq
			if exists "/etc/rc.d/S??dnsmasq"; then
				/etc/init.d/dnsmasq start
			fi
			;;
		"/tmp/.uci/ntp_client")
			killall ntpclient
			config_load ntp_client&
			;;
		"/tmp/.uci/dhcp")
			killall dnsmasq
			[ -z "$(ps | grep "[d]nsmasq ")" ] && /etc/init.d/dnsmasq start
			;;
		"/tmp/.uci/wireless")
			echo '@TR<<Reloading>> @TR<<wireless>> ...'
			wifi ;;
		"/tmp/.uci/syslog")
			echo '@TR<<Reloading>> @TR<<syslogd>> ...'
			/etc/init.d/syslog restart >&- 2>&- ;;
		"/tmp/.uci/openvpn")
			echo '@TR<<Reloading>> @TR<<OpenVPN>> ...'
			killall openvpn >&- 2>&- <&-
			/etc/init.d/openvpn start ;;
		"/tmp/.uci/system")
			config_load system ;;
		"/tmp/.uci/snmp")
			echo '@TR<<Exporting>> @TR<<snmp settings>> ...'
			[ -e "/sbin/save_snmp" ] && {
				/sbin/save_snmp >&- 2>&-
			}
			
			echo '@TR<<Reloading>> @TR<<snmp settings>> ...'
			[ ! -e "/etc/init.d/snmpd" ] && {
				ln -s "/etc/init.d/snmpd" "/etc/init.d/S92snmpd" 2>/dev/null
			}
			/etc/init.d/S??snmpd restart >&- 2>&-
			;;
		"/tmp/.uci/l2tpns")
			echo '@TR<<Exporting>> @TR<<l2tpns server settings>> ...'
			[ -e "/usr/lib/webif/l2tpns_apply.sh" ] && {
				/usr/lib/webif/l2tpns_apply.sh >&- 2>&-
			}

			echo '@TR<<Reloading>> @TR<<l2tpns server>> ...'
			/etc/init.d/l2tpns restart >&- 2>&-
			;;
		"/tmp/.uci/updatedd")
			uci_load "updatedd"
			if [ "$CONFIG_ddns_update" = "1" ]; then
				/etc/init.d/ddns enable >&- 2>&- <&-
				/etc/init.d/ddns stop >&- 2>&- <&-
				/etc/init.d/ddns start >&- 2>&- <&-
			else
				/etc/init.d/ddns disable >&- 2>&- <&-
				/etc/init.d/ddns stop >&- 2>&- <&-
			fi
		 	;;
		"/tmp/.uci/timezone")
			echo '@TR<<Exporting>> @TR<<TZ setting>> ...'
			[ ! -f /etc/rc.d/S??timezone ] && /etc/init.d/timezone enable >&- 2>&- <&-
			/etc/init.d/timezone restart
			;;
		"/tmp/.uci/webifssl")
			config_load webifssl
			config_get_bool test matrixtunnel enable 0
			if [ 1 -eq "$test" ]; then
				[ -f /etc/init.d/webifssl ] && {
					#echo '@TR<<Starting>> @TR<<webif^2 ssl tunnel>> ...'
					/etc/init.d/webifssl enable >&- 2>&- <&-
					/etc/init.d/webifssl start
				}
			else
				[ -f /etc/init.d/webifssl ] && {
					#echo '@TR<<Stopping>> @TR<<webif^2 ssl tunnel>> ...'
					/etc/init.d/webifssl stop
					/etc/init.d/webifssl disable >&- 2>&- <&-
				}
			fi
			;;
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
rm /tmp/.uci/* >&- 2>&-

