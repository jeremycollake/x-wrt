#!/usr/bin/webif-page
<? 
. "/usr/lib/webif/webif.sh"
load_settings wds
load_settings wireless



interface_num=49153
for mac in $(nvram get wl0_wds); do
wds_list=" $wds_list
          wds0.$interface_num=$mac"
let "interface_num+=1"
done


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

awk -v "name=@TR<<MAC Address>>" \
    -v "interface=@TR<<Bridge>>" \
    -v "action=@TR<<Action>>" \
    -f /usr/lib/webif/common.awk -f - /etc/dnsmasq.options <<EOF
BEGIN{
    start_form("@TR<<Active WDS Interfaces>>")
    print "<table style=\\"width: 70%\\">"
    print "<tr><th>" name "</th><th>" interface "</th><th>" action "</th></tr>"
    print "<tr><td colspan=\\"3\\"><hr class=\\"separator\\" /></td></tr>"
}
EOF

for mac in $(nvram get wl0_wds); do
	IFBRIDGE=LAN
        echo "<tr><td $style>$mac</td><td $style>$IFBRIDGE</td><td $style><a href=\"wds.sh?action=remove&amp;macremove=$mac\">@TR<<Remove>></a></td></tr><br />"
done
awk -f /usr/lib/webif/common.awk -f - /etc/dnsmasq.options <<EOF
BEGIN{
    print "</table><br />"
    end_form();
    }
EOF

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
##WEBIF:name:Network:415:WDS
-->