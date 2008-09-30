#!/usr/bin/webif-page "-U /tmp -u 16384"
<?
. /usr/lib/webif/webif.sh

board_type=$(cat /proc/cpuinfo 2>/dev/null | sed 2,20d | cut -c16-)
machinfo=$(uname -a 2>/dev/null)
if $(echo "$machinfo" | grep -q "mips"); then
	if $(echo "$board_type" | grep -q "Atheros"); then
		target="atheros-2.6"
	elif $(echo "$board_type" | grep -q "WP54"); then
		target="adm5120-2.6"
	elif $(echo "$machinfo" | grep -q "2\.4"); then
		target="brcm"
	elif $(echo "$machinfo" | grep -q "2\.6"); then
		target="brcm"
	fi
elif $(echo "$machinfo" | grep -q " i[0-9]86 "); then
	target="x86-2.6"
elif $(echo "$machinfo" | grep -q " avr32 "); then
	target="avr32-2.6"
elif $(cat /proc/cpuinfo 2>/dev/null | grep -q "IXP4"); then
	target="ixp4xx-2.6"
fi

header "System" "Upgrade" "<img src=\"/images/upd.jpg\" alt=\"@TR<<Firmware Upgrade>>\" />&nbsp;@TR<<Firmware Upgrade>>" '' "$SCRIPT_NAME"

if [ "$target" = "x86-2.6" -o "$target" = "brcm" ]; then
	if empty "$FORM_submit"; then
display_form <<EOF
start_form
field|@TR<<Firmware Image>>
upload|upgradefile
submit|upgrade| @TR<<Upgrade>> |
end_form
EOF
	else
		echo "<br />Upgrading firmware, please wait ... <br />"
		sysupgrade $FORM_upgradefile
		echo "@TR<<done>>."
	fi
else
	echo "<br />The ability to upgrade your platform has not been implemented.<br />"
fi

footer
?>
<!--
##WEBIF:name:System:900:Upgrade
-->
