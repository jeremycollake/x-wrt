#!/usr/bin/webif-page
<?

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
