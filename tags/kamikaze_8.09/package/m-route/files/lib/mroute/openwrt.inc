. "/usr/lib/webif/webif.sh"

config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
		interface)
			append network "$cfg_name" "$N"
		;;
		wanif)
			append WAN_DEV_LIST "$cfg_name" "$N"
		;;
		lanif)
			append LAN_DEV_LIST "$cfg_name" "$N"
		;;
#		mroute)
#			append Rforwarding_cfgs "$cfg_name"
#		;;
	esac
}

load_settings () {
	uci_load mroute
	OS="$CONFIG_settings_os"
	DEBUG="$CONFIG_settings_debug"
	SLEEPTIME="$CONFIG_settings_sleeptime"
	TESTIP="$CONFIG_settings_testip"
	TIMEOUT="$CONFIG_settings_timeout"
	SUCCESSREPEATCOUNT="$CONFIG_settings_success"
	FAILUREREPEATCOUNT="$CONFIG_settings_failure"
	RESETIFACE="$CONFIG_settings_resetif"
}

get_WAN_DEV () {
	i=0
	for iface in $WAN_DEV_LIST; do
		i=`expr $i + 1`
		eval COUNT$i=0
		config_get NAME $iface name
		config_get WEIGHT $iface weight
		set_up_wan_iface $iface $i
	done
	WAN_DEVCOUNT=$i
}

get_if_data () {
	uci_load network
	config_get ifname $1 ifname
	config_get INET $1 proto
	config_get calc_IP $1 ipaddr
	config_get calc_MASK $1 netmask
	config_get GW $1 gateway
	calc_NET=`ipcalc.sh $calc_IP $calc_MASK | grep NETWORK | egrep -o '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'`
	calc_PREFIX=`ipcalc.sh $calc_IP $calc_MASK | grep PREFIX | egrep -o '\b[0-9]{1,2}\b'`
	if [[ "$calc_NET" != "" && "$calc_PREFIX" != "" ]]; then
		calc_NET="$calc_NET/$calc_PREFIX"
	fi
	calc_NETWORK=${calc_NET:-$GW}
}

#check_duplicate_rt_openwrt () {
#### Time on time OpenWrt add by it self default route
#### so, this function is for delete all routing that exists in balanced routing
#### the better way is modify /usr/share/default.script, thanks xMff of openwrt-devel chanel
#	CRGW=`ip route list | grep "nexthop via $1" | awk '{ print $3}'`
#	if [ "$CRGW" != "" ]; then
#		if [ "`ip route list default via $CRGW`" != "" ]; then
#			ip route del default via $CRGW
#		fi 
#	fi
#}

################################################################################
