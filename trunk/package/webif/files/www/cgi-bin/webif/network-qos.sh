#!/usr/bin/webif-page
<?
# Author: Travis Kemen <kemen04@gmail.com>
# Version 0.001
##FIXME: edonkey-dl shows up as -dl for Layer 7 rules
##FIXME: L7 Save rules need to be dynamic
##FIXME: fix javascript hidden start_form workaround
##FIXME: L7 checkboxes need to display nicely
##Possible FIXME: Should the save function be changed?
##TODO: Finish Layer 7 Functions
##TODO: Combine some of the functions
##TODO: Figure out a different way to list and remove existing items
##FIXME: Finish Save Button
##TODO: Proper nameing of variables.

. /usr/lib/webif/webif.sh

header "Network" "QoS" "@TR<<QOS Configuration>>" ' onLoad="modechange()" ' "$SCRIPT_NAME"

if is_package_installed "qos-fw"; then
#
# nbd's QoS scripts
#	
	echo "nbd QoS scripts found installed. We haven't written code yet for this."
	
elif is_package_installed "qos-re"; then
#
# Rudy's QoS scripts
#
. ./qos-rudy.inc

else
	echo "A compatible QOS package was not found to be installed."
fi

footer ?>
<!--
##WEBIF:name:Network:600:QoS
-->
