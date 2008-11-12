#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Mount points
#
# Description:
#		Mountpoints
#			Add mount points to the fstab 
#
# Author(s) [in order of work date]:
#       m4rc0 <jansssenmaj@gmail.com>
#
# Major revisions:
#		2008-11-12	Initial release
#
# NVRAM variables referenced:
#       none
#
# Configuration files referenced:
#		/etc/config/fstab
#
# Required components:
# 

header "System" "Mountpoints" "@TR<<Mountpoints>>" '' "$SCRIPT_NAME"


config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
	        mount)
	                append MOUNTPOINTS "$cfg_name"
	        ;;
	        swap)
	                append SWAP "$cfg_name"
	        ;;	esac
}

get_tr() {
	if equal "$cur_color" "odd"; then
		cur_color="even"
		tr="<tr>"
	else
		cur_color="odd"
		tr="<tr class=\"odd\">"
	fi
}


uci_load fstab

cur_color="odd"
echo "<h3><strong>@TR<<Mountpoints>></strong></h3>"
echo "<table style=\"width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"2\" cellspacing=\"1\" summary=\"@TR<<Mountpoints>>\">"
for mountpoint in $MOUNTPOINTS; do
	
	config_get TARGET $mountpoint target
	config_get DEVICE $mountpoint device
	config_get FSTYPE $mountpoint fstype
	config_get OPTIONS $mountpoint options
	config_get ENABLED $mountpoint enabled

	#check if mountpoint is enabled
	if [ "$ENABLED" != "0" ]; then
		ENABLEDIMAGE="<img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Mountpoint Enabled\" />"
	else
		ENABLEDIMAGE="<img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Mountpoint Disabled\" />"
	fi

	
	get_tr
	echo $tr"<td width=\"35\" align=\"center\" valign=\"middle\" rowspan=\"5\">$ENABLEDIMAGE</td><td width=\"100\"><strong>Target</strong></td><td>$TARGET</td></tr>"
	echo $tr"<td width=\"100\"><strong>Device</strong></td><td>$DEVICE</td></tr>"
	echo $tr"<td width=\"100\"><strong>FStype</strong></td><td>$FSTYPE</td></tr>"
	echo $tr"<td width=\"100\"><strong>Options</strong></td><td>$OPTIONS</td></tr>"
	echo $tr"<td width=\"100\"><strong>Enabled</strong></td><td>$ENABLED</td></tr>"
	echo "<tr><td colspan=\"3\"><img height=\"5\" width=\"1\" src=\"/images/pixel.gif\" /></td></tr>"
done
echo "</table><br />"

cur_color="odd"
echo "<h3><strong>@TR<<Swap>></strong></h3>"
echo "<table style=\"width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"2\" cellspacing=\"1\" summary=\"@TR<<Swap>>\">"
for swap in $SWAP; do
	
	config_get DEVICE $mountpoint device
	config_get ENABLED $mountpoint enabled

	#check if swap is enabled
	if [ "$ENABLED" != "0" ]; then
		ENABLEDIMAGE="<img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Swap Enabled\" />"
	else
		ENABLEDIMAGE="<img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Swap Disabled\" />"
	fi

	get_tr
	echo $tr"<td width=\"35\" align=\"center\" valign=\"middle\" rowspan=\"2\">$ENABLEDIMAGE</td><td width=\"100\"><strong>Device</strong></td><td>$DEVICE</td></tr>"
	echo $tr"<td width=\"100\"><strong>Enabled</strong></td><td>$ENABLED</td></tr>"
	echo "<tr><td colspan=\"3\"><img height=\"5\" width=\"1\" src=\"/images/pixel.gif\" /></td></tr>"
done
echo "</table>"
footer ?>
<!--
##WEBIF:name:System:330:Mountpoints
-->
