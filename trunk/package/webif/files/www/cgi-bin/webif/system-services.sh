#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Services
#
# Description:
#	Services control page.
#       This page enables the user to enable/disabled/start 
#		and stop the services in the directory /etc/init.d
#       should be synchronized between branches
#
# Author(s) [in order of work date]:
#       m4rc0 <jansssenmaj@gmail.com>
#
# Major revisions:
#       2008-11-08 - Initial release
#
# NVRAM variables referenced:
#       none
#
# Configuration files referenced:
#       none
#
# Required components:
# 

header "System" "Service" "@TR<<Services>>" '' "$SCRIPT_NAME"

if [ "$FORM_service" != "" ] && [ "$FORM_action" != "" ]; then
	/etc/init.d/$FORM_service $FORM_action
fi

ls /etc/rc.d > /tmp/rc.d 2>/dev/null
ls /etc/init.d > /tmp/init.d 2>/dev/null

echo "<table class=\"packages\" border=\"0\">"

rowselect="true"

for line in `cat /tmp/init.d`; do
	
	if [ "$rowselect" == "false" ]; then
		color="#E5E7E9"
		rowselect="true"
	else
		color="#FFFFFF"
		rowselect="false"
	fi

	echo "<tr bgcolor=\"$color\" class=\"packages\">"

	if [ "`cat /tmp/rc.d | grep $line`" != "" ]; then
		echo "<td><img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td>"
	else
		echo "<td><img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td>"
	fi

	echo "<td>&nbsp;</td>"
	echo "<td>$line</td>"
	echo "<td><img height=\"1\" width=\"100\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$line&action=enable\"><img width=\"13\" src=\"/images/service_enable.png\" alt=\"Enable Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$line&action=enable\">Enable</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$line&action=disable\"><img width=\"13\" src=\"/images/service_disable.png\" alt=\"Disable Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$line&action=disable\">Disable</a></td>"

	echo "<td><img height=\"1\" width=\"60\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$line&action=start\"><img width=\"13\" src=\"/images/service_start.png\" alt=\"Start Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$line&action=start\">Start</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$line&action=restart\"><img width=\"13\" src=\"/images/service_restart.png\" alt=\"Restart Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$line&action=restart\">Restart</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$line&action=stop\"><img width=\"13\" src=\"/images/service_stop.png\" alt=\"Stop Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$line&action=stop\">Stop</a></td>"

	echo "</tr>"

done

echo "</table>"

rm /tmp/rc.d > /dev/null 2>&1
rm /tmp/init.d > /dev/null 2>&1

footer ?>
<!--
##WEBIF:name:System:126:Services
-->
