#!/usr/bin/webif-page
<?

. /usr/lib/webif/webif.sh

header "Network" "QoS" "@TR<<QOS Configuration>>" ' onLoad="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_rudy"; then	
	echo "Installing Rudy's QoS scripts (HSFC) ...<pre>"	
	! install_package "qos-re-hfsc" && {
		install_package "http://ftp.berlios.de/pub/xwrt/packages/qos-re-hfsc_1.02_all.ipk"	
	}
	echo "</pre>"
fi

if ! empty "$FORM_install_nbd"; then	
	echo "Installing Nbd's QoS scripts ...<pre>"		
	! install_package "qos-scripts" && {
		install_package "http://ftp.berlios.de/pub/xwrt/packages/qos-scripts_0.9.1-1_mipsel.ipk"
	}
	echo "</pre>"
fi

if is_package_installed "qos-scripts"; then
	#
	# nbd's QoS scripts
	#	
	echo "nbd's QoS scripts found installed. We haven't written code yet for this."
. ./qos-nbd.inc
elif is_package_installed "qos-re"; then
	#
	# Rudy's QoS scripts
	#
. ./qos-rudy.inc
else
	echo "<div class=\"warning\">A compatible QOS package was not found to be installed. Currently this page supports Rudy's QoS scripts.</div>"	
	
display_form <<EOF
onchange|modechange
start_form|@TR<<QoS Packages>>
field|Rudy's QoS Scripts|rudy_qos
submit|install_rudy|Install
field|Nbd's QoS Scripts (unsupported by webif)|nbd_qos
submit|install_nbd|Install
end_form
EOF
fi

footer ?>
<!--
##WEBIF:name:Network:600:QoS
-->
