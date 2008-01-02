#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"
###################################################################
# Services configuration page
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must*
# be followed by running the webif-sync.sh script.
#
# Description:
#	Configures services not configured elsewhere.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# NVRAM variables referenced:
#	none
#
# Configuration files referenced:
#	none
#

header "Network" "UPnP" "@TR<<UPnP Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

uci_load "upnpd"

if ! empty "$FORM_install_miniupnp"; then
	echo "@TR<<Installing>> miniUPNPd ...<pre>"
	install_package miniupnpd
	uci_set "upnpd" "general" "enable" "1"
	echo "</pre>"
fi

if ! empty "$FORM_install_linuxigd"; then
	echo "@TR<<Installing>> linux-igd ...<pre>"
	install_package "http://ftp.berlios.de/pub/xwrt/packages/libupnp_1.2.1a_mipsel.ipk"
	install_package "http://ftp.berlios.de/pub/xwrt/packages/linux-igd_1.0.1.ipk"
	# if config file doesn't exist, create it since it doesn't come with above pkg at present
	! exists "/etc/config/upnpd" && {
		uci_load "upnpd"
		uci_add "upnpd" "settings" "general"
		uci_set "upnpd" "general" "enable" "1"
	}
	echo "</pre>"
fi

if ! empty "$FORM_remove_miniupnpd"; then
	echo "@TR<<Removing>> miniUPNPd ...<pre>"
	remove_package miniupnpd
	#uci_set "upnpd" "general" "enable" "0"
	echo "</pre>"
fi

if ! empty "$FORM_remove_linuxigd"; then
	echo "@TR<<Removing>> linux-igd UPNPd ...<pre>"
	remove_package linux-igd
	remove_package libupnp
	#uci_set "upnpd" "general" "enable" "0"
	echo "</pre>"
fi

ipkg_listinst=$(ipkg list_installed 2>/dev/null | grep "^\(miniupnpd \|linuxigd \)")
upnp_installed="0"

echo "$ipkg_listinst" | grep -q "^miniupnpd "
equal "$?" "0" && {
	upnp_installed="1"
	remove_upnpd_button="field|@TR<<Remove miniupnpd>>
	submit|remove_miniupnpd| @TR<<Remove>> |"
}

echo "$ipkg_listinst" | grep -q "^linuxigd "
equal "$?" "0" && {
	upnp_installed="1"
	remove_upnpd_button="field|@TR<<Remove linuxigd>>
	submit|remove_linuxigd| @TR<<Remove>> |"
}

# check to see if user has old nvram based miniupnp package
# todo: remove this check after a while, assuming everyone got new one
exists "/etc/init.d/S95miniupnpd" && ! grep -iq "uci.sh" "/etc/init.d/S95miniupnpd" && {
 	echo "<div class=\"warning\">You have an old version of miniupnpd incompatible with this webif version. You must upgrade to a newer miniupnpd package, else this page will not work properly.</div>"
	display_form <<EOF
	start_form
	submit|upgrade_upnpd| @TR<<Upgrade UPNPd>>
	end_form
EOF
}

if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_upnp_enable="$CONFIG_general_enable"
	FORM_upnpd_log_output="$CONFIG_general_log_output"
	FORM_upnpd_up_bitspeed="$CONFIG_general_up_bitspeed"
	FORM_upnpd_down_bitspeed="$CONFIG_general_down_bitspeed"
else
	if ! empty "$FORM_upgrade_upnpd"; then
		# upgrade miniupnpd
		echo "@TR<<Please wait>> ...<br />"
		ipkg remove miniupnpd 2>&1 >> /dev/null
		# todo: force to use latest package - but since this is a temporary kludge to get
		#  users upgraded, no big deal.
		if ipkg install "http://ftp.berlios.de/pub/xwrt/packages/miniupnpd_1.0-RC3-2_mipsel.ipk"  2>&1 >> /dev/null; then
			echo " @TR<<Completed successfully>>!<br />"
		else
			echo " @TR<<Failed to install>>!<br />"
		fi
	else
		# save form
		uci_set "upnpd" "general" "enable" "$FORM_upnp_enable"
		uci_set "upnpd" "general" "log_output" "$FORM_upnpd_log_output"
		uci_set "upnpd" "general" "down_bitspeed" "$FORM_upnpd_down_bitspeed"
		uci_set "upnpd" "general" "up_bitspeed" "$FORM_upnpd_up_bitspeed"
	fi
fi

#####################################################################s
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

function modechange()
{
	if(isset('upnp_enable','1'))
	{
		document.getElementById('upnpd_up_bitspeed').disabled = false;
		document.getElementById('upnpd_down_bitspeed').disabled = false;
		document.getElementById('upnpd_log_output').disabled = false;
	}
	else
	{
		document.getElementById('upnpd_up_bitspeed').disabled = true;
		document.getElementById('upnpd_down_bitspeed').disabled = true;
		document.getElementById('upnpd_log_output').disabled = true;
	}
}
</script>
EOF

#####################################################################

if equal "$upnp_installed" "1" ; then
	primary_upnpd_form="field|@TR<<UPNP Daemon>>
	select|upnp_enable|$FORM_upnp_enable
	option|0|@TR<<Disabled>>
	option|1|@TR<<Enabled>>
	field|@TR<<WAN Upload (bits/sec)>>
	text|upnpd_up_bitspeed|$FORM_upnpd_up_bitspeed| @TR<<kilobits>>
	field|@TR<<WAN Download (bits/sec)>>
	text|upnpd_down_bitspeed|$FORM_upnpd_down_bitspeed| @TR<<kilobits>>
	helpitem|WAN Speeds
	helptext|HelpText upnpd_wan_speeds#Set your WAN speeds here, in kilobits. This is for reporting to upnp clients that request it only.
	field|@TR<<Log Debug Output>>
	select|upnpd_log_output|$FORM_upnpd_log_output
	option|0|@TR<<Disabled>>
	option|1|@TR<<Enabled>>
	$remove_upnpd_button
	helpitem|Remove UPNPd
	helptext|HelpText remove_upnpd_help#If you have problems you can remove your current UPNPd and try the other one to see if it works better for you."
else
	install_miniupnp_button="field|@TR<<miniupnpd>>
submit|install_miniupnp| @TR<<Install>> |"
	install_linuxigd_button="field|@TR<<linux-igd>>
submit|install_linuxigd| @TR<<Install>> |"
	install_help="helpitem|Which UPNPd to choose
helptext|HelPText install_upnpd_help#There are two UPNP daemons to choose from: miniupnpd and linux-igd. Try miniupnpd first, but it if does not work for you, then remove that package and try linux-igd."
fi

display_form <<EOF
onchange|modechange
start_form|@TR<<UPNP>>
$primary_upnpd_form
$install_miniupnp_button
$install_linuxigd_button
$install_help
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:550:UPnP
-->
