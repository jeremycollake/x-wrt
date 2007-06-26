#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings mn_pan

if empty "$FORM_submit"; then 
	FORM_static_routes=${static_route:-$(route -n | awk ' /\./ {ORS=" ";print $1":"$3":"$2":"$5":"$8} END {printf"\n"}')}
	FORM_hna4=$mn_hna4
	FORM_dmz=$mn_dmz
else
	SAVED=1
	validate <<EOF
EOF
	equal "$?" 0 && {
		save_setting mn_pan static_route $FORM_static_routes
		save_setting mn_pan mn_hna4 "$FORM_hna4"
		save_setting mn_pan mn_dmz "$FORM_dmz"
		/usr/bin/megaset /tmp/.webif/config-mn_pan
	}
fi

header "Mesh" "Private" "Private network" '' "$SCRIPT_NAME"

echo "<div class=warning>This page is actually at very alpha state, few functinalities are working, explore at your own risk!</div><br><br>"

if [ ".$(uci get mesh.general.enable)" = ".1" ]; then

echo "<P>The \"private network\" is the cable side of the network.</P><br>"

display_form <<EOF
start_form|Static Routes
field|Import Routes
text|static_routes|$FORM_static_routes
helpitem|Import Routes
helptext|Helptext mesh_import_routes#Configures static routes with the 'ip:netmask:gatewayip:metric:interface' notation. Example: '10.1.2.0:255.255.255.0:0.0.0.0:1:vlan1'. Separate multiple entries with space.
field|Export Routes
text|hna4|$FORM_hna4
helpitem|Export Routes
helptext|Helptext mesh_export_routes#With this setting, a specific IP address range reachable via this device can be announced on the wireless side. This can be an internet gateway (0.0.0.0/0) or even a single IP address (e.g. 172.31.1.2/32) for a PDA with WLAN. Separated multiple IP address ranges with semicolon.
end_form
start_form|Expose hosts on wireless side
field|Demilitarized Hosts
text|dmz|$FORM_dmz
helpitem|Demilitarized Hosts
helptext|Helptext mesh_dmz_hosts#With this setting, an internal wired LAN client can be reached from the mesh network. Enter the source IP address and the destination LAN-IP address separated by colon. Separate multiple entries with semicolon.
end_form
EOF

else
	echo "<P>In order to use this page you must enable mesh mode; go to Mesh --> Start page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Mesh:200:Private
-->
