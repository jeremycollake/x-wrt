#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"
###################################################################
# Services configuration page
#
# Description:
#	Configures services not configured elsewhere.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# NVRAM variables referenced:
#	upnp_enabled
#
# Configuration files referenced:
#		none
#

header "Network" "Services" "@TR<<Services Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

load_settings services
load_settings upnpd

if ! empty "$FORM_install_upnp"; then
	echo "Installing UPNP package ...<pre>"	
	install_package miniupnpd
	uci_set "upnpd" "general" "enabled" "1"
	echo "</pre>"	
fi

if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_upnp_enabled="${upnp_enabled:-$(uci get upnpd.general.enabled)}"
	FORM_upnpd_log_output="${upnpd_log_output:-$(uci get upnpd.general.log_output)}"
	FORM_upnpd_up_bitspeed="${upnpd_up_bitspeed:-$(uci get upnpd.general.up_bitspeed)}"
	FORM_upnpd_down_bitspeed="${upnpd_down_bitspeed:-$(uci get upnpd.general.down_bitspeed)}"
else
	# save form
	uci_set "upnpd" "general" "enabled" "$FORM_upnp_enabled"
	uci_set "upnpd" "general" "log_output" "$FORM_upnpd_log_output"
	uci_set "upnpd" "general" "down_bitspeed" "$FORM_upnpd_down_bitspeed"
	uci_set "upnpd" "general" "up_bitspeed" "$FORM_upnpd_up_bitspeed"
fi

#####################################################################s
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

function modechange()
{
	/* nothing here.. yet */
}
</script>
EOF

#####################################################################

upnp_installed="0"
ipkg list_installed | grep linux-igd >> /dev/null
equal "$?" "0" && {
	upnp_installed="1"
	echo "<div class=\"warning\">You are using an old upnpd. We now recommend to use miniupnpd. To uninstall your old own remove the 'linux-igd' and 'libupnp' packages.</div>"
}
ipkg list_installed | grep miniupnpd >> /dev/null
equal "$?" "0" && upnp_installed="1"

if equal "$upnp_installed" "1" ; then
	install_upnp_button="field|@TR<<UPNP Daemon>>
	select|upnp_enabled|$FORM_upnp_enabled
	option|0|@TR<<Disabled>>
	option|1|@TR<<Enabled>>
	field|@TR<<WAN Upload (bits/sec)>>
	text|upnpd_up_bitspeed|$FORM_upnpd_up_bitspeed| @TR<<kilobits>>
	field|@TR<<WAN Download (bits/sec)>>
	text|upnpd_down_bitspeed|$FORM_upnpd_down_bitspeed| @TR<<kilobits>>
	helpitem|WAN Upload Speed
	helptext|HelpText upnpd_wan_upload#This option setting represents the WAN line upload speed in kilobits per second.
	helpitem|WAN Download Speed
	helptext|HelpText upnpd_wan_download#This option setting represents the WAN line download speed in kilobits per second.	
	field|@TR<<Log Debug Output>>
	select|upnpd_log_output|$FORM_upnpd_log_output
	option|0|@TR<<Disabled>>
	option|1|@TR<<Enabled>>"
else
	install_upnp_button="submit|install_upnp| Install UPNP daemon |"
fi

display_form <<EOF
onchange|modechange
start_form|@TR<<UPNP>>
$install_upnp_button
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:550:Services
-->
