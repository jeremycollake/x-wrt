#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings mn_wan
eval $(/usr/bin/megaparam)

if empty "$FORM_submit"; then
	FORM_wandown=$mn_wandown
	FORM_wanup=$mn_wanup
	FORM_wandmz=$mn_wandmz
else
	SAVED=1
	validate <<EOF
EOF
	equal "$?" 0 && {
		save_setting mn_wan mn_wandown $FORM_wandown
		save_setting mn_wan mn_wanup $FORM_wanup
		save_setting mn_wan mn_wandmz $FORM_wandmz
		/usr/bin/megaset /tmp/.webif/config-mn_wan
	}
fi

header "Mesh" "Gateway" "Internet port (TODO)" '' "$SCRIPT_NAME"

if [ ".$mn_enable" = ".1" ]; then

if [ ".$(uci show network.wan.proto)" != "." ] && [ ".$(uci show network.wan.proto)" != ".none" ]; then
	echo "<p>You can now configure download/upload speed and the DMZ of the WAN side.</p><br>"
	display_form <<EOF
start_form|Line speed and DMZ
field|Internet download speed
textarea|wandown|$FORM_wandown
helpitem|Internet download speed
helptext|Incoming bandwidth of your internet connection.
field|Internet upload speed
textarea|wanup|$FORM_wanup
helpitem|Internet upload speed
helptext|Outgoing bandwidth of your internet connection.
field|WAN DMZ
textarea|wandmz|$FORM_wandmz
helpitem|WAN DMZ
helptext|With this setting, an internal wired or wireless host can be reached from the internet. Enter the IP address of the host that you want to be reached from the internet (be carefull, the host will be unprotected).
end_form
EOF
else
	echo "<H3>WAN port disabled.</H3>"
	echo "<P>If you need to use this router as Internet Gateway enable and configure it in Network-->WAN, then come back to this page for further configuration options. NOTE: Remember to come back to this page, or the Network-->WAN settings will be resetted on reboot.</P>"
fi

else
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Mesh:4:Gateway
-->
