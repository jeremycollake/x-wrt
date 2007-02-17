#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings mn_pan
eval $(/usr/bin/megaparam)

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

header "Mesh" "PAN" "Private Area Network" '' "$SCRIPT_NAME"

if [ ".$mn_enable" = ".1" ]; then

echo "<P>PAN is the cable side of the network. All hosts on this side are protected both from the internet and the wireless side.<BR>
<BR>Addresses in use:<BR>
- 192.168.1.1 - 192.168.1.100 : free, use as you wish;<BR>
- 192.168.1.101 - 192.168.1.200 : reserved, DHCP autoconfiguration;<BR>
- 192.168.1.201 - 192.168.1.253 : reserved, various configuration options;<BR>
- 192.168.1.254 : reserved, router address.<BR>
</P><BR>"

display_form <<EOF
start_form|Static Routes
field|Import Routes
text|static_routes|$FORM_static_routes
helpitem|Import Routes
helptext|Configures static routes with the 'ip:netmask:gatewayip:metric:interface' notation. Example: '10.1.2.0:255.255.255.0:0.0.0.0:1:vlan1'. Separate multiple entries with space.
field|Export Routes
text|hna4|$FORM_hna4
helpitem|Export Routes
helptext|With this setting, a specific IP address range reachable via this device can be announced on the wireless side. This can be an internet gateway (0.0.0.0/0) or even a single IP address (e.g. 172.31.1.2/32) for a PDA with WLAN. Separated multiple IP address ranges with semicolon.
end_form
start_form|Expose hosts on wireless side
field|Demilitarized Hosts
text|dmz|$FORM_dmz
helpitem|Demilitarized Hosts
helptext|With this setting, an internal wired LAN client can be reached from the mesh network. Enter the source IP address and the destination LAN-IP address separated by colon. Separate multiple entries with semicolon.
end_form
EOF

else
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Mesh:2:PAN
-->
