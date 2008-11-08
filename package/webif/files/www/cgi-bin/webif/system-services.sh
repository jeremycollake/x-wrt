#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# system-editor
#
# Description:
#	Filesystem browser/File editor.
#       This file is compatible with both branches and
#       should be synchronized between branches
#
# Author(s) [in order of work date]:
#       unknown
#       Lubos Stanek <lubek@users.berlios.de>
#
# Major revisions (ISO 8601):
#       2007-04-14 - major update with enhancements
#                    and port to Kamikaze
#
# NVRAM variables referenced:
#       none
#
# Configuration files referenced:
#       none
#
# Required components:
#       /usr/lib/webif/common.awk
#       /usr/lib/webif/browser.awk
#       /usr/lib/webif/editor.awk
# 


ls /etc/rc.d > /tmp/rc.d 2>/dev/null
ls /etc/init.d > /tmp/init.d 2>/dev/null


header "System" "Service" "@TR<<Services>>" '' "$SCRIPT_NAME"


echo "<table class=\"packages\">"


for line in `cat /tmp/init.d`; do

	if [ "`cat /tmp/rc.d | grep $line`" != "" ]; then
		echo "<tr class=\"packages\"><td><img width=\"15\" src=\"/images/service_enabled.png\" alt=\"Service Enabled\" /></td><td>&nbsp;</td><td>$line</td>" 
	else
		echo "<tr class=\"packages\"><td><img width=\"15\" src=\"/images/service_disabled.png\" alt=\"Service Disabled\" /></td><td>&nbsp;</td><td>$line</td>" 
	fi

done



echo "</table>"



rm /tmp/rc.d > /dev/null 2>&1
rm /tmp/init.d > /dev/null 2>&1

footer ?>
<!--
##WEBIF:name:System:126:Services
-->
