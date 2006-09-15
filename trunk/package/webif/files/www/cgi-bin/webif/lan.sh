#!/usr/bin/webif-page
<? 
. "/usr/lib/webif/webif.sh"
load_settings network

FORM_dns="${lan_dns:-$(nvram get lan_dns)}"
LISTVAL="$FORM_dns"
handle_list "$FORM_dnsremove" "$FORM_dnsadd" "$FORM_dnssubmit" 'ip|FORM_dnsadd|@TR<<DNS Address>>|required' && {
	FORM_dns="$LISTVAL"
	save_setting network lan_dns "$FORM_dns"
}
FORM_dnsadd=${FORM_dnsadd:-192.168.1.1}

if empty "$FORM_submit"; then 
	FORM_lan_ipaddr=${lan_ipaddr:-$(nvram get lan_ipaddr)}
	FORM_lan_netmask=${lan_netmask:-$(nvram get lan_netmask)}
	FORM_lan_gateway=${lan_gateway:-$(nvram get lan_gateway)}
else 
	SAVED=1
	validate <<EOF
ip|FORM_lan_ipaddr|@TR<<IP Address>>|required|$FORM_lan_ipaddr
netmask|FORM_lan_netmask|@TR<<Netmask>>|required|$FORM_lan_netmask
ip|FORM_lan_gateway|@TR<<Gateway>>||$FORM_lan_gateway
EOF
	equal "$?" 0 && {
		save_setting network lan_ipaddr $FORM_lan_ipaddr
		save_setting network lan_netmask $FORM_lan_netmask
		save_setting network lan_gateway $FORM_lan_gateway
	}
fi

header "Network" "LAN" "@TR<<LAN Configuration>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<LAN Configuration>>
field|@TR<<IP Address>>
text|lan_ipaddr|$FORM_lan_ipaddr
helpitem|IP Address
helptext|Helptext IP Address#This is the address you want this device to have on your LAN.
field|@TR<<Netmask>>
text|lan_netmask|$FORM_lan_netmask
helpitem|Netmask
helptext|Helptext Netmask#This bitmask indicates what addresses are included in your LAN. For those who don't know what a bitmask is, just think of "255" as 'match this part' and "0" as 'any number here'.
field|@TR<<Default Gateway>>
text|lan_gateway|$FORM_lan_gateway
end_form
start_form|@TR<<DNS Servers>>
listedit|dns|$SCRIPT_NAME?|$FORM_dns|$FORM_dnsadd
helpitem|Note
helptext|Helptext DNS save#You need save your settings on this page before adding/removing DNS servers
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:200:LAN
-->
