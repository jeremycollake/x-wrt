#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"
###################################################################
# WAN and LAN configuration page
#
# Description:
#	Configures basic WAN and LAN interface settings.
#
# Author(s) [in order of work date]:
#       Original webif authors of wan.sh and lan.sh
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Travis Kemen <kemen04@gmail.com>
#
# Major revisions:
#
# UCI variables referenced:
#   todo
# Configuration files referenced:
#   /etc/config/network
#

#Add new network
if [ "$FORM_button_add_network" != "" ]; then
	if [ "$FORM_add_network" = "" ]; then
		append validate_error "string|<h3>@TR<<Please add a network name>></h3><br />"
	else
		uci_add "network" "interface" "$FORM_add_network"
		uci_set "network" "$FORM_add_network" "proto" "none"
		submit="0"
	fi
fi

config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
		interface)
			append network "$cfg_name" "$N"
		;;
		dhcp)
			option_cb() {
				case "$1" in
					interface)
						[ "$2" = "$FORM_remove_network" ] && uci_remove "dhcp" "$cfg_name";;
				esac
			}
		;;
	esac
}

#remove network
if ! empty "$FORM_remove_network"; then
	uci_remove "network" "$FORM_remove_network"
	uci_load dhcp
fi

uci_load network
network=$(echo "$network" |uniq)

WWAN_COUNTRY_LIST=$(
		awk '	BEGIN{FS=":"}
			$1 ~ /[ \t]*#/ {next}
			{print "option|" $1 "|@TR<<" $2 ">>"}' < /usr/lib/webif/apn.csv
	)
	JS_APN=$(
		awk '	BEGIN{FS=":"}
			$1 ~ /[ \t]*#/ {next}
			{print "	apnDB." $1 " = new Object;"
			 print "	apnDB." $1 ".name = \"" $3 "\";"
			 print "	apnDB." $1 ".user = \"" $4 "\";"
			 print "	apnDB." $1 ".pass = \"" $5 "\";\n"}' < /usr/lib/webif/apn.csv
	)
append JS_APN_DB "$JS_APN" "$N"

for interface in $network; do
	config_get delete_check $interface proto
	if [ "$interface" != "loopback" ]; then
	if [ "$delete_check" != "" ]; then
	if empty "$FORM_submit"; then
		config_get FORM_proto $interface proto
		config_get FORM_type $interface type
		config_get FORM_ipaddr $interface ipaddr
		config_get FORM_netmask $interface netmask
		config_get FORM_gateway $interface gateway
		config_get FORM_pptp_server $interface server
		config_get FORM_service $interface service
		config_get FORM_pincode $interface pincode
		config_get FORM_country $interface country
		config_get FORM_apn $interface apn
		config_get FORM_username $interface username
		config_get FORM_passwd $interface password
		config_get FORM_mtu $interface mtu
		config_get FORM_ppp_redial $interface ppp_redial
		config_get FORM_keepalive $interface keepalive
		config_get FORM_demand $interface demand
		config_get FORM_vci $interface vci
		config_get FORM_vpi $interface vpi
		config_get FORM_macaddr $interface macaddr
		config_get_bool FORM_defaultroute $interface defaultroute 1
	else
		eval FORM_proto="\$FORM_${interface}_proto"
		eval FORM_type="\$FORM_${interface}_type"
		eval FORM_ipaddr="\$FORM_${interface}_ipaddr"
		eval FORM_netmask="\$FORM_${interface}_netmask"
		eval FORM_gateway="\$FORM_${interface}_gateway"
		eval FORM_pptp_server="\$FORM_${interface}_pptp_server"
		eval FORM_service="\$FORM_${interface}_service"
		eval FORM_pincode="\$FORM_${interface}_pincode"
		eval FORM_country="\$FORM_${interface}_country"
		eval FORM_apn="\$FORM_${interface}_apn"
		eval FORM_username="\$FORM_${interface}_username"
		eval FORM_passwd="\$FORM_${interface}_passwd"
		eval FORM_mtu="\$FORM_${interface}_mtu"
		eval FORM_ppp_redial="\$FORM_${interface}_ppp_redial"
		eval FORM_demand="\$FORM_${interface}_demand"
		eval FORM_keepalive="\$FORM_${interface}_keepalive"
		eval FORM_vci="\$FORM_${interface}_vci"
		eval FORM_vpi="\$FORM_${interface}_vpi"
		eval FORM_macaddr="\$FORM_${interface}_macaddr"
		eval FORM_defaultroute="\$FORM_${interface}_defaultroute"
	fi
	config_get FORM_dns $interface dns
	eval FORM_dnsadd="\$FORM_${interface}_dnsadd"
	eval FORM_dnsremove="\$FORM_${interface}_dnsremove"
	eval FORM_dnssubmit="\$FORM_${interface}_dnssubmit"
	LISTVAL="$FORM_dns"
	handle_list "$FORM_dnsremove" "$FORM_dnsadd" "$FORM_dnssubmit" 'ip|FORM_dnsadd|@TR<<DNS Address>>|required' && {
		FORM_dns="$LISTVAL"
		[ " " = "$FORM_dns" ] && FORM_dns=""
		uci_set "network" "$interface" "dns" "$FORM_dns"
		FORM_dnsadd=""
	}

	network_options="start_form|$interface @TR<<Configuration>>
	field|@TR<<Connection Type>>
	select|${interface}_proto|$FORM_proto
	option|none|@TR<<Disabled>>
	option|static|@TR<<Static IP>>
	option|dhcp|@TR<<DHCP>>
	option|pppoe|@TR<<PPPOE>>
	option|pppoa|@TR<<PPPOA>>
	option|pptp|@TR<<PPTP>>
	option|wwan|@TR<<WWAN>>

	field|@TR<<Type>>
	select|${interface}_type|$FORM_type
	option||@TR<<None>>
	option|bridge|@TR<<Bridged>>
	field|@TR<<MAC Address>>
	text|${interface}_macaddr|$FORM_macaddr
	helpitem|MAC Address
	helptext|Helptext MAC Address#Used to enter a MAC address besides the default one.
	end_form

	start_form||${interface}_ip_settings|hidden
	field|@TR<<IP Address>>|field_${interface}_ipaddr|hidden
	text|${interface}_ipaddr|$FORM_ipaddr
	field|@TR<<Netmask>>|field_${interface}_netmask|hidden
	text|${interface}_netmask|$FORM_netmask
	field|@TR<<Default Gateway>>|field_${interface}_gateway|hidden
	text|${interface}_gateway|$FORM_gateway
	field|@TR<<PPTP Server IP>>|field_${interface}_pptp_server|hidden
	text|${interface}_pptp_server|$FORM_pptp_server
	helpitem|IP Settings
	helptext|Helptext IP Settings#IP Settings are optional for DHCP and PPTP. They are used as defaults in case the DHCP server is unavailable.
	end_form

	start_form||${interface}_ppp_settings|hidden
	field|@TR<<Connection Type>>|field_${interface}_service|hidden
	select|${interface}_service|$FORM_service
	option|umts_first|@TR<<UMTS first>>
	option|umts_only|@TR<<UMTS only>>
	option|gprs_only|@TR<<GPRS only>>
	field|@TR<<PIN Code>>|field_${interface}_pincode|hidden
	password|${interface}_pincode|$FORM_pincode
	field|@TR<<Select Network>>|field_${interface}_network|hidden
	onchange|setAPN
	select|${interface}_country|$FORM_country
	$WWAN_COUNTRY_LIST
	onchange|
	field|@TR<<APN Name>>|field_${interface}_apn|hidden
	text|${interface}_apn|$FORM_apn
	field|@TR<<Username>>|field_${interface}_username|hidden
	text|${interface}_username|$FORM_username
	field|@TR<<Password>>|field_${interface}_passwd|hidden
	password|${interface}_passwd|$FORM_passwd
	onchange|modechange
	field|@TR<<Redial Policy>>|${interface}_redial|hidden
	select|${interface}_ppp_redial|$FORM_ppp_redial
	option|demand|@TR<<Connect on Demand>>
	option|persist|@TR<<Keep Alive>>
	field|@TR<<Maximum Idle Time>>|${interface}_demand_idletime|hidden
	text|${interface}_demand|$FORM_demand
	helpitem|Maximum Idle Time
	helptext|Helptext Idle Time#The number of seconds without internet traffic that the router should wait before disconnecting from the Internet (Connect on Demand only)
	field|@TR<<Redial Timeout>>|${interface}_persist_redialperiod|hidden
	text|${interface}_keepalive|$FORM_keepalive
	helpitem|Redial Timeout
	helptext|Helptext Redial Timeout#The number of seconds to wait after receiving no response from the provider before trying to reconnect
	field|@TR<<MTU>>|field_${interface}_mtu|hidden
	text|${interface}_mtu|$FORM_mtu
	field|VCI|field_${interface}_vci|hidden
	text|${interface}_vci|$FORM_vci
	field|VPI|field_${interface}_vpi|hidden
	text|${interface}_vpi|$FORM_vpi
	field|@TR<<Default Route>>
	checkbox|${interface}_defaultroute|$FORM_defaultroute|1
	end_form

	start_form|$interface @TR<<DNS Servers>>|field_${interface}_dns|hidden
	listedit|${interface}_dns|$SCRIPT_NAME?${interface}_proto=static&amp;|$FORM_dns|$FORM_dnsadd
	end_form"

	append forms "$network_options" "$N"

	remove_network_form="string|<a href=\"$SCRIPT_NAME?remove_network=$interface\">@TR<<Remove Network>> $interface</a>"
	append forms "$remove_network_form" "$N"

	###################################################################
	# set JavaScript
	javascript_forms="
		v = (isset('${interface}_proto', 'pppoe') || isset('${interface}_proto', 'pptp') || isset('${interface}_proto', 'pppoa') || isset('${interface}_proto', 'wwan'));
		set_visible('${interface}_ppp_settings', v);
		set_visible('field_${interface}_username', v);
		set_visible('field_${interface}_passwd', v);
		set_visible('${interface}_redial', v);
		set_visible('field_${interface}_mtu', v);
		set_visible('${interface}_demand_idletime', v && isset('${interface}_ppp_redial', 'demand'));
		set_visible('${interface}_persist_redialperiod', v && !isset('${interface}_ppp_redial', 'demand'));

		v = (isset('${interface}_proto', 'static') || isset('${interface}_proto', 'pptp') || isset('${interface}_proto', 'dhcp'));
		set_visible('${interface}_ip_settings', v);
		set_visible('field_${interface}_ipaddr', v);
		set_visible('field_${interface}_netmask', v);

		v = (isset('${interface}_proto', 'static'));
		set_visible('field_${interface}_gateway', v);
		set_visible('field_${interface}_dns', v);

		v = (isset('${interface}_proto', 'pptp'));
		set_visible('field_${interface}_pptp_server', v);

		v = (isset('${interface}_proto', 'pppoa'));
		set_visible('field_${interface}_vci', v);
		set_visible('field_${interface}_vpi', v);

		v = (isset('${interface}_proto', 'wwan'));
		set_visible('field_${interface}_service', v);
		set_visible('field_${interface}_network', v);
		set_visible('field_${interface}_apn', v);
		set_visible('field_${interface}_pincode', v);"
	append js "$javascript_forms" "$N"

	wwan_js="document.getElementById(\"${interface}_apn\").value = apnDB[element.value].name;
	document.getElementById(\"${interface}_username\").value = apnDB[element.value].user;
	document.getElementById(\"${interface}_passwd\").value = apnDB[element.value].pass;"
	append JS_APN_DB "$wwan_js" "$N"

	append validate_forms "mac|FORM_${interface}_macaddr|$interface @TR<<MAC Address>>||$FORM_macaddr" "$N"
	append validate_forms "ip|FORM_${interface}_ipaddr|$interface @TR<<IP Address>>||$FORM_ipaddr" "$N"
	append validate_forms "netmask|FORM_${interface}_netmask|$interface @TR<<WAN Netmask>>||$FORM_netmask" "$N"
	append validate_forms "ip|FORM_${interface}_gateway|$interface @TR<<Default Gateway>>||$FORM_gateway" "$N"
	append validate_forms "ip|FORM_${interface}_pptp_server|$interface @TR<<PPTP Server IP>>||$FORM_pptp_server" "$N"
	fi
	fi
done

add_network_form="
start_form
field|@TR<<Add Network>>|field_add_network
text|add_network|$FORM_add_network
submit|button_add_network| @TR<<Add Network>> |
end_form"
append forms "$add_network_form" "$N"

if [ "$submit" = "0" ]; then
	FORM_submit=""
fi

if ! empty "$FORM_submit"; then
	SAVED=1
	validate <<EOF
$validate_forms
EOF
	equal "$?" 0 && {
		for interface in $network; do
			if [ "$interface" != "loopback" ]; then
				eval FORM_proto="\$FORM_${interface}_proto"
				eval FORM_type="\$FORM_${interface}_type"
				eval FORM_ipaddr="\$FORM_${interface}_ipaddr"
				eval FORM_netmask="\$FORM_${interface}_netmask"
				eval FORM_gateway="\$FORM_${interface}_gateway"
				eval FORM_pptp_server="\$FORM_${interface}_pptp_server"
				eval FORM_service="\$FORM_${interface}_service"
				eval FORM_pincode="\$FORM_${interface}_pincode"
				eval FORM_country="\$FORM_${interface}_country"
				eval FORM_apn="\$FORM_${interface}_apn"
				eval FORM_username="\$FORM_${interface}_username"
				eval FORM_passwd="\$FORM_${interface}_passwd"
				eval FORM_mtu="\$FORM_${interface}_mtu"
				eval FORM_ppp_redial="\$FORM_${interface}_ppp_redial"
				eval FORM_demand="\$FORM_${interface}_demand"
				eval FORM_keepalive="\$FORM_${interface}_keepalive"
				eval FORM_vci="\$FORM_${interface}_vci"
				eval FORM_vpi="\$FORM_${interface}_vpi"
				eval FORM_macaddr="\$FORM_${interface}_macaddr"
				eval FORM_defaultroute="\$FORM_${interface}_defaultroute"
				if [ "$FORM_defaultroute" = "" ]; then
					FORM_defaultroute=0
				fi

				uci_set "network" "$interface" "proto" "$FORM_proto"
				uci_set "network" "$interface" "type" "$FORM_type"
				uci_set "network" "$interface" "macaddr" "$FORM_macaddr"
				case "$FORM_proto" in
					pptp)
						uci_set "network" "$interface" "server" "$FORM_pptp_server" ;;
					wwan)
						if ! equal "$FORM_pincode" "-@@-"; then
							uci_set "network" "$interface" "pincode" "$FORM_pincode"
						fi
						uci_set "network" "$interface" "service" "$FORM_service"
						uci_set "network" "$interface" "country" "$FORM_country"
						uci_set "network" "$interface" "apn" "$FORM_apn" ;;
				esac
				case "$FORM_proto" in
					pppoe|pppoa|pptp|wwan)
						uci_set "network" "$interface" "username" "$FORM_username"
						uci_set "network" "$interface" "password" "$FORM_passwd"
						uci_set "network" "$interface" "vpi" "$FORM_vpi"
						uci_set "network" "$interface" "vci" "$FORM_vci"
						uci_set "network" "$interface" "mtu" "$FORM_mtu"
						uci_set "network" "$interface" "keepalive" "$FORM_keepalive"
						uci_set "network" "$interface" "demand" "$FORM_demand"
						uci_set "network" "$interface" "defaultroute" "$FORM_defaultroute"
						uci_set "network" "$interface" "ppp_redial" "$FORM_ppp_redial";;
				esac

				uci_set "network" "$interface" "ipaddr" "$FORM_ipaddr"
				uci_set "network" "$interface" "netmask" "$FORM_netmask"
				uci_set "network" "$interface" "gateway" "$FORM_gateway"

			fi
		done
	}
fi
header "Network" "Networks" "@TR<<Network Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"
#####################################################################
# modechange script
#
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function setAPN(element) {
	var apnDB = new Object();
	$JS_APN_DB
}
function modechange()
{
	var v;
	$js

	hide('save');
	show('save');
}
-->
</script>

EOF

display_form <<EOF
onchange|modechange
$validate_error
$forms
EOF

footer ?>
<!--
##WEBIF:name:Network:101:Networks
-->
