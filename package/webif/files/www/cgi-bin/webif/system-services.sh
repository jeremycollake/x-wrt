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
	/etc/init.d/$FORM_service $FORM_action > /dev/null 2>&1
fi

ls /etc/rc.d > /tmp/rc.d 2>/dev/null
ls /etc/init.d > /tmp/init.d 2>/dev/null

echo "<table class=\"packages\" border=\"0\" width=\"100%\">"
echo "<tr>"
echo "<td>"

echo "<table border=\"0\">"

rowselect="true"

for service in `cat /tmp/init.d`; do
	
	if [ "$rowselect" == "false" ]; then
		color="#E5E7E9"
		rowselect="true"
	else
		color="#FFFFFF"
		rowselect="false"
	fi
	
	echo "<tr bgcolor=\"$color\">"

	if [ "`cat /tmp/rc.d | grep $service`" != "" ]; then
		echo "<td><img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td>"
	else
		echo "<td><img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td>"
	fi

	echo "<td>&nbsp;</td>"
	echo "<td>$service</td>"
	echo "<td><img height=\"1\" width=\"100\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$service&action=enable\"><img width=\"13\" src=\"/images/service_enable.png\" alt=\"Enable Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=enable\">Enable</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$service&action=disable\"><img width=\"13\" src=\"/images/service_disable.png\" alt=\"Disable Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=disable\">Disable</a></td>"

	echo "<td><img height=\"1\" width=\"60\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$service&action=start\"><img width=\"13\" src=\"/images/service_start.png\" alt=\"Start Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=start\">Start</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$service&action=restart\"><img width=\"13\" src=\"/images/service_restart.png\" alt=\"Restart Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=restart\">Restart</a></td>"
	echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
	echo "<td><a href=\"system-services.sh?service=$service&action=stop\"><img width=\"13\" src=\"/images/service_stop.png\" alt=\"Stop Service\" /></a></td>"
	echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=stop\">Stop</a></td>"

	echo "</tr>"

done

echo "</table>"
echo "</td>"

echo "<td valign=\"top\">"
echo "<table border=\"0\">"
echo "<tr>"
echo "<td><img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td>"
echo "<td>Service Enabled</td>"
echo "</tr>"
echo "<tr>"
echo "<td><img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td>"
echo "<td>Service Disabled</td>"
echo "</tr>"

echo "<tr><td colspan=\"2\">&nbsp;</td></tr>"

if [ "$FORM_service" != "" ] && [ "$FORM_action" != "" ]; then
	
	case $FORM_action in
		enable)		status="enabled";;
		disable)	status="disabled";;
		start)		status="started";;
		restart)	status="restarted";;
		stop)		status="stopped";;
	esac
	
	echo "<tr>"
	echo "<td colspan=\"2\">"

	echo "<strong>Service $FORM_service was $status</strong>"
	echo "</td>"
	echo "</tr>"
fi


echo "</table>"
echo "</td>"



echo "</tr>"
echo "</table>"


rm /tmp/rc.d > /dev/null 2>&1
rm /tmp/init.d > /dev/null 2>&1

footer ?>
<!--
##WEBIF:name:System:126:Services
-->
