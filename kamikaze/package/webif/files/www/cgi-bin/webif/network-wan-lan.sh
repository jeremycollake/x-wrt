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
#   none
#

#Load settings from the network config file.	
uci_load "network"

FORM_wandns="$CONFIG_wan_dns"
LISTVAL="$FORM_wandns"
handle_list "$FORM_wandnsremove" "$FORM_wandnsadd" "$FORM_wandnssubmit" 'ip|FORM_dnsadd|@TR<<WAN DNS Address>>|required' && {
	FORM_wandns="$LISTVAL"
	uci_set "network" "wan" "dns" "$FORM_wandns"
}
FORM_wandnsadd=${FORM_wandnsadd:-""}

FORM_landns="$CONFIG_lan_dns"
LISTVAL="$FORM_landns"
handle_list "$FORM_landnsremove" "$FORM_landnsadd" "$FORM_landnssubmit" 'ip|FORM_dnsadd|@TR<<LAN DNS Address>>|required' && {
	FORM_landns="$LISTVAL"
	uci_set "network" "lan" "dns" "$FORM_landns"
}
FORM_landnsadd=${FORM_landnsadd:-192.168.1.1}

if empty "$FORM_submit"; then	
	FORM_wan_proto="$CONFIG_wan_proto"
	case "$FORM_wan_proto" in
		# supported types
		static|dhcp|pptp|pppoe|pppoa|wwan) ;;
		# otherwise select "none"
		*) FORM_wan_proto="none";;
	esac

	# pptp, dhcp and static common
	FORM_wan_ipaddr="$CONFIG_wan_ipaddr"
	FORM_wan_netmask="$CONFIG_wan_netmask"
	FORM_wan_gateway="$CONFIG_wan_gateway"
	FORM_wan_ifname="$CONFIG_wan_ifname"

	# ppp common
	#TODO: verify all ppp variables still work under kamikaze.
	FORM_ppp_username="$CONFIG_wan_username"
	FORM_ppp_passwd="$CONFIG_wan_passwd"
	FORM_ppp_idletime="$CONFIG_wan_idletime"
	FORM_ppp_redialperiod="$CONFIG_wan_redialperiod"
	FORM_ppp_mtu="$CONFIG_wan_mtu"

	redial="$CONFIG_wan_demand"
	case "$redial" in
		1|enabled|on) FORM_ppp_redial="demand";;
		*) FORM_ppp_redial="persist";;
	esac

	FORM_pptp_server_ip="$CONFIG_wan_server"
	
	# pppoa
	FORM_pppoa_vpi="CONFIG_wan_vpi"
	FORM_pppoa_vci="CONFIG_wan_vci"
	
	# umts apn
	FORM_wwan_service="$CONFIG_wan_service"
	FORM_wwan_pincode="-@@-"
	FORM_wwan_country="$CONFIG_wan_country"
	FORM_wwan_apn="$CONFIG_wan_apn"
	FORM_wwan_username="$CONFIG_wan_username"
	FORM_wwan_passwd="$CONFIG_wan_passwd"
	
	# lan
	FORM_lan_ipaddr="$CONFIG_lan_ipaddr"
	FORM_lan_netmask="$CONFIG_lan_netmask"
	FORM_lan_gateway="$CONFIG_lan_gateway"
else
	SAVED=1

	empty "$FORM_wan_proto" && {
		ERROR="@TR<<No WAN Proto|No WAN protocol has been selected>>"
		return 255
	}

	case "$FORM_wan_proto" in
		static)
			V_IP="required"
			V_NM="required"
			;;
		pptp)
			V_PPTP="required"
			;;
	esac

validate <<EOF
ip|FORM_wan_ipaddr|@TR<<WAN IP Address>>|$V_IP|$FORM_wan_ipaddr
netmask|FORM_wan_netmask|@TR<<WAN Netmask>>|$V_NM|$FORM_wan_netmask
ip|FORM_wan_gateway|@TR<<WAN Default Gateway>>||$FORM_wan_gateway
ip|FORM_pptp_server_ip|@TR<<WAN PPTP Server IP>>|$V_PPTP|$FORM_pptp_server_ip
ip|FORM_lan_ipaddr|@TR<<LAN IP Address>>|required|$FORM_lan_ipaddr
netmask|FORM_lan_netmask|@TR<<LAN Netmask>>|required|$FORM_lan_netmask
ip|FORM_lan_gateway|@TR<<LAN Gateway>>||$FORM_lan_gateway
EOF
	equal "$?" 0 && {
		uci_set "network" "wan" "proto" "$FORM_wan_proto"
		uci_set "network" "wan" "ifname" "$FORM_wan_ifname"

		# Settings specific to one protocol type
		case "$FORM_wan_proto" in
			static) uci_set "network" "wan" "gateway" "$FORM_wan_gateway" ;;
			pptp) uci_set "network" "wan" "server" "$FORM_pptp_server_ip" ;;
			wwan)
			uci_set "network" "wan" "service" "$FORM_wwan_service"
			if ! equal "$FORM_wwan_pincode" "-@@-"; then
				uci_set "network" "wan" "pincode" "$FORM_wwan_pincode"
			fi
			uci_set "network" "wan" "country" "$FORM_wwan_country"
			uci_set "network" "wan" "apn" "$FORM_wwan_apn"
			uci_set "network" "wan" "username" "$FORM_wwan_username"
			uci_set "network" "wan" "passwd" "$FORM_wwan_passwd"
			;;
			pppoa)
			uci_set "network" "wan" "vpi" "$FORM_wan_vpi"
			uci_set "network" "wan" "vci" "$FORM_wan_vci" ;;
		esac

		# Common settings for PPTP, Static and DHCP
		case "$FORM_wan_proto" in
			pptp|static|dhcp)
				uci_set "network" "wan" "ipaddr" "$FORM_wan_ipaddr"
				uci_set "network" "wan" "netmask" "$FORM_wan_netmask"
			;;
		esac

		# Common PPP settings
		case "$FORM_wan_proto" in
			pppoe|pptp|wwan)
				empty "$FORM_ppp_username" || uci_set "network" "wan" "username" "$FORM_ppp_username"
				empty "$FORM_ppp_passwd" || uci_set "network" "wan" "passwd" "$FORM_ppp_passwd"

				# These can be blank
				uci_set "network" "wan" "idletime" "$FORM_ppp_idletime"
				uci_set "network" "wan" "redialperiod" "$FORM_ppp_redialperiod"
				uci_set "network" "wan" "mtu" "$FORM_ppp_mtu"

				case "$FORM_ppp_redial" in
					demand)
						uci_set "network" "wan" "demand" "1"
						;;
					persist)
						uci_set "network" "wan" "demand" ""
						;;
				esac
			;;
			*)
				wan_ifname=${wan_ifname:-$(uci get network wan ifname)}
				[ -z "$wan_ifname" -o "${wan_ifname%%[0-9]*}" = "ppp" ] && {
					wan_device=${wan_device:-$(uci get nework wan device)}
					wan_device=${wan_device:-vlan1}
					uci_set "network" "wan" "ifname" "$wan_device"
				}
			;;
		esac

		# lan settings
		uci_set "network" "lan" "ipaddr" "$FORM_lan_ipaddr"
		uci_set "network" "lan" "netmask" "$FORM_lan_netmask"
		uci_set "network" "lan" "gateway" "$FORM_lan_gateway"
	}
fi

# detect pptp package and compile option
[ -x "/sbin/ifup.pptp" ] && {
	PPTP_OPTION="option|pptp|@TR<<PPTP>>"
	PPTP_SERVER_OPTION="field|@TR<<PPTP Server IP>>|pptp_server|hidden
text|pptp_server_ip|$FORM_pptp_server_ip"
}
[ -x "/lib/network/pppoe.sh" ] && {
	PPPOE_OPTION="option|pppoe|@TR<<PPPoE>>"
}
[ -x "/lib/network/pppoa.sh" ] && {
	PPPOA_OPTION="option|pppoa|@TR<<PPPoA>>"
}

[ -x /sbin/ifup.wwan ] && {
	WWAN_OPTION="option|wwan|@TR<<UMTS/GPRS>>"
	WWAN_COUNTRY_LIST=$(
		awk '	BEGIN{FS=":"}
			$1 ~ /[ \t]*#/ {next}
			{print "option|" $1 "|@TR<<" $2 ">>"}' < /usr/lib/webif/apn.csv
	)
	JS_APN_DB=$(
		awk '	BEGIN{FS=":"}
			$1 ~ /[ \t]*#/ {next}
			{print "	apnDB." $1 " = new Object;"
			 print "	apnDB." $1 ".name = \"" $3 "\";"
			 print "	apnDB." $1 ".user = \"" $4 "\";"
			 print "	apnDB." $1 ".pass = \"" $5 "\";\n"}' < /usr/lib/webif/apn.csv
	)
}

header "Network" "WAN-LAN" "@TR<<WAN-LAN Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function setAPN(element) {
	var apnDB = new Object();

$JS_APN_DB

	document.getElementById("wwan_apn").value = apnDB[element.value].name;
	document.getElementById("wwan_username").value = apnDB[element.value].user;
	document.getElementById("wwan_passwd").value = apnDB[element.value].pass;
}

function modechange()
{
	var v;
	v = (isset('wan_proto', 'static') || isset('wan_proto', 'pptp') || isset('wan_proto', 'dhcp') || isset('wan_proto', 'pppoe') || isset('wan_proto', 'pppoa'));
	set_visible('ifname', v);
	
	v = (isset('wan_proto', 'pppoe') || isset('wan_proto', 'pptp') || isset('wan_proto', 'pppoa'));
	set_visible('ppp_settings', v);
	set_visible('username', v);
	set_visible('passwd', v);
	set_visible('redial', v);
	set_visible('mtu', v);
	set_visible('demand_idletime', v && isset('ppp_redial', 'demand'));
	set_visible('persist_redialperiod', v && !isset('ppp_redial', 'demand'));

	v = (isset('wan_proto', 'static') || isset('wan_proto', 'pptp') || isset('wan_proto', 'dhcp'));
	set_visible('wan_ip_settings', v);
	set_visible('field_wan_ipaddr', v);
	set_visible('field_wan_netmask', v);

	v = isset('wan_proto', 'static');
	set_visible('field_wan_gateway', v);
	set_visible('wan_dns', v);

	v = isset('wan_proto', 'pptp');
	set_visible('pptp_server', v);
	
	v = isset('wan_proto', 'pppoa');
	set_visible('vci', v);
	set_visible('vpi', v);
	
	v = isset('wan_proto', 'wwan');
	set_visible('wwan_service_field', v);
	set_visible('wwan_sim_settings', v);
	set_visible('apn_settings', v);

	hide('save');
	show('save');
}
-->
</script>
EOF

display_form <<EOF
onchange|modechange
start_form|@TR<<WAN Configuration>>
field|@TR<<Connection Type>>
select|wan_proto|$FORM_wan_proto
option|none|@TR<<No WAN#None>>
option|dhcp|@TR<<DHCP>>
option|static|@TR<<Static IP>>
$PPPOE_OPTION
$PPPOA_OPTION
$WWAN_OPTION
$PPTP_OPTION
field|@TR<<Interface>>|ifname|hidden
text|wan_ifname|$FORM_wan_ifname
helpitem|Interface
helptext|Helptext Interface#Your WAN interface(eth0,eth1,...)
helplink|http://wiki.openwrt.org/OpenWrtDocs/Configuration#head-b62c144b9886b221e0c4b870edb0dd23a7b6acab
end_form

start_form|@TR<<IP Settings>>|wan_ip_settings|hidden
field|@TR<<WAN IP Address>>|field_wan_ipaddr|hidden
text|wan_ipaddr|$FORM_wan_ipaddr
field|@TR<<Netmask>>|field_wan_netmask|hidden
text|wan_netmask|$FORM_wan_netmask
field|@TR<<Default Gateway>>|field_wan_gateway|hidden
text|wan_gateway|$FORM_wan_gateway
$PPTP_SERVER_OPTION
$PPPOA_VCI_OPTION
helpitem|WAN IP Settings
helptext|Helptext WAN IP Settings#IP Settings are optional for DHCP and PPTP. They are used as defaults in case the DHCP server is unavailable.
end_form

start_form|@TR<<WAN DNS Servers>>|wan_dns|hidden
listedit|wandns|$SCRIPT_NAME?wan_proto=static&amp;|$FORM_wandns|$FORM_wandnsadd
helpitem|Note
helptext|Helptext WAN DNS save#You should save your settings on this page before adding/removing DNS servers
end_form

start_form|@TR<<Preferred Connection Type>>|wwan_service_field|hidden
field|@TR<<Connection Type>>
select|wwan_service|$FORM_wwan_service
option|umts_first|@TR<<UMTS first>>
option|umts_only|@TR<<UMTS only>>
option|gprs_only|@TR<<GPRS only>>
end_form

start_form|@TR<<SIM Configuration>>|wwan_sim_settings|hidden
field|@TR<<PIN Code>>
password|wwan_pincode|$FORM_wwan_pincode
end_form

start_form|@TR<<APN Settings>>|apn_settings|hidden
field|@TR<<Select Network>>
onchange|setAPN
select|wwan_country|$FORM_wwan_country
$WWAN_COUNTRY_LIST
onchange|
field|@TR<<APN Name>>
text|wwan_apn|$FORM_wwan_apn
field|@TR<<Username>>
text|wwan_username|$FORM_wwan_username
field|@TR<<Password>>
text|wwan_passwd|$FORM_wwan_passwd
end_form

start_form|@TR<<PPP Settings>>|ppp_settings|hidden
field|@TR<<Redial Policy>>|redial|hidden
select|ppp_redial|$FORM_ppp_redial
option|demand|@TR<<Connect on Demand>>
option|persist|@TR<<Keep Alive>>
field|@TR<<Maximum Idle Time>>|demand_idletime|hidden
text|ppp_idletime|$FORM_ppp_idletime
helpitem|Maximum Idle Time
helptext|Helptext Idle Time#The number of seconds without internet traffic that the router should wait before disconnecting from the Internet (Connect on Demand only)
field|@TR<<Redial Timeout>>|persist_redialperiod|hidden
text|ppp_redialperiod|$FORM_ppp_redialperiod
helpitem|Redial Timeout
helptext|Helptext Redial Timeout#The number of seconds to wait after receiving no response from the provider before trying to reconnect
field|@TR<<Username>>|username|hidden
text|ppp_username|$FORM_ppp_username
field|@TR<<Password>>|passwd|hidden
password|ppp_passwd|$FORM_ppp_passwd
field|@TR<<MTU>>|mtu|hidden
text|ppp_mtu|$FORM_ppp_mtu
field|VCI|vci|hidden
text|wan_vci|$FORM_wan_vci
field|VPI|vpi|hidden
text|wan_vpi|$FORM_wan_vpi
end_form
EOF

display_form <<EOF
start_form|@TR<<LAN Configuration>>
field|@TR<<LAN IP Address>>
text|lan_ipaddr|$FORM_lan_ipaddr
helpitem|IP Address
helptext|Helptext LAN IP Address#This is the address you want this device to have on your LAN.
field|@TR<<Netmask>>
text|lan_netmask|$FORM_lan_netmask
helpitem|Netmask
helptext|Helptext Netmask#This bitmask indicates what addresses are included in your LAN.
field|@TR<<Default Gateway>>
text|lan_gateway|$FORM_lan_gateway
end_form
start_form|@TR<<LAN DNS Servers>>
listedit|landns|$SCRIPT_NAME?|$FORM_landns|$FORM_landnsadd
helpitem|Note
helptext|Helptext LAN DNS save#You need save your settings on this page before adding/removing DNS servers
end_form
EOF

footer ?>

<!--
##WEBIF:name:Network:100:WAN-LAN
-->
