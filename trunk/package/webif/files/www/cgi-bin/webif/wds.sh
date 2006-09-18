#!/usr/bin/webif-page
<? 
. "/usr/lib/webif/webif.sh"
load_settings network

if empty "$FORM_submit"; then 
	FORM_lazywds=${wl0_lazywds:-$(nvram get wl0_lazywds)}
	case "$FORM_lazywds" in
		1|on|enabled) FORM_lazywds=1;;
		*) FORM_lazywds=0;;
	esac
	FORM_wdsmac=${FORM_wdsmac:-00:00:00:00:00:00}
	#FORM_lan_ipaddr=${lan_ipaddr:-$(nvram get lan_ipaddr)}
	#FORM_lan_netmask=${lan_netmask:-$(nvram get lan_netmask)}
	#FORM_lan_gateway=${lan_gateway:-$(nvram get lan_gateway)}
else 
	SAVED=1
	validate <<EOF
mac|FORM_wds_mac|@TR<<IP Address>>||$FORM_wds_mac
EOF
	equal "$?" 0 && {
		save_setting wireless wl0_lazywds "$FORM_lazywds"

	}
fi

header "Network" "WDS" "@TR<<WDS Configuration>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<WDS Configuration>>
field|@TR<<WDS>>
text|wds_mac|$FORM_wds_mac
select|wdsmode|$FORM_macmode
option|bridged|@TR<<Bridged>>
option|p2p|@TR<<Point To Point>>
helpitem|WDS
helptext|Helptext WDS#This page does not work yet!!!!!!

end_form

start_form|@TR<<Automatic WDS>>
field|@TR<<Automatic WDS>>
select|lazywds|$FORM_lazywds
option|1|@TR<<Enabled>>
option|0|@TR<<Disabled>>
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:200:WDS
-->
