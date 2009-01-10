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

header "System" "Services" "@TR<<Services>>" '' "$SCRIPT_NAME"


# change rowcolors
get_tr() {
	if equal "$cur_color" "odd"; then
		cur_color="even"
		tr="<tr>"
	else
		cur_color="odd"
		tr="<tr class=\"odd\">"
	fi
}


#check if a service with an action is selected
if [ "$FORM_service" != "" ] && [ "$FORM_action" != "" ]; then
	/etc/init.d/$FORM_service $FORM_action > /dev/null 2>&1
fi

#create the service in init.d and rc.d
ls /etc/rc.d > /tmp/rc.d 2>/dev/null
ls /etc/init.d > /tmp/init.d 2>/dev/null

echo "<h3><strong>@TR<<Available services>></strong></h3>"
echo "<table style=\"width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"2\" cellspacing=\"1\" summary=\"@TR<<Services>>\">"
echo "<tr>"
echo "<td>"

echo "<table style=\"margin-left: 2.5em; text-align: left;\" border=\"0\" cellpadding=\"2\" cellspacing=\"1\" summary=\"@TR<<Services>>\">"

# set the color-switch
cur_color="odd"

#for each service in init.d.....
for service in `cat /tmp/init.d`; do
	
	#if service is rcS then do nothing
	if [ "$service" != "rcS" ]; then
		
		# select the right color
		get_tr
		echo $tr

		#check if current $service is in the rc.d list
		if [ "`cat /tmp/rc.d | grep $service`" != "" ]; then
			echo "<td><img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td>"
		else
			echo "<td><img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td>"
		fi

		echo "<td>&nbsp;</td>"
		echo "<td>$service</td>"
		echo "<td><img height=\"1\" width=\"100\" src=\"/images/pixel.gif\" /></td>" 
		echo "<td><a href=\"system-services.sh?service=$service&action=enable\"><img width=\"13\" src=\"/images/service_enable.png\" alt=\"Enable Service\" /></a></td>"
		echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=enable\">@TR<<system_services_service_enable#Enable>></a></td>"
		echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
		echo "<td><a href=\"system-services.sh?service=$service&action=disable\"><img width=\"13\" src=\"/images/service_disable.png\" alt=\"Disable Service\" /></a></td>"
		echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=disable\">@TR<<system_services_service_disable#Disable>></a></td>"

		echo "<td><img height=\"1\" width=\"60\" src=\"/images/pixel.gif\" /></td>" 
		echo "<td><a href=\"system-services.sh?service=$service&action=start\"><img width=\"13\" src=\"/images/service_start.png\" alt=\"Start Service\" /></a></td>"
		echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=start\">@TR<<system_services_sevice_start#Start>></a></td>"
		echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
		echo "<td><a href=\"system-services.sh?service=$service&action=restart\"><img width=\"13\" src=\"/images/service_restart.png\" alt=\"Restart Service\" /></a></td>"
		echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=restart\">@TR<<system_services_service_restart#Restart>></a></td>"
		echo "<td><img height=\"1\" width=\"5\" src=\"/images/pixel.gif\" /></td>" 
		echo "<td><a href=\"system-services.sh?service=$service&action=stop\"><img width=\"13\" src=\"/images/service_stop.png\" alt=\"Stop Service\" /></a></td>"
		echo "<td valign=\"middle\"><a href=\"system-services.sh?service=$service&action=stop\">@TR<<system_services_service_stop#Stop>></a></td>"

		echo "</tr>"
	fi
done

echo "</table>"
echo "</td>"

echo "<td valign=\"top\">"
echo "<table style=\"margin-left: 2.5em; text-align: left;\" border=\"0\" cellpadding=\"2\" cellspacing=\"1\" summary=\"@TR<<Services>>\">"
echo "<tr>"
echo "<td><img width=\"17\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td>"
echo "<td>@TR<<system_services_service_enabled#Service Enabled>></td>"
echo "</tr>"
echo "<tr>"
echo "<td><img width=\"17\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td>"
echo "<td>@TR<<system_services_service_disabled#Service Disabled>></td>"
echo "</tr>"

echo "<tr><td colspan=\"2\">&nbsp;</td></tr>"

#if there is a service and an action selected... display status
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

#remove the lists
rm /tmp/rc.d > /dev/null 2>&1
rm /tmp/init.d > /dev/null 2>&1

footer ?>
<!--
##WEBIF:name:System:126:Services
-->
