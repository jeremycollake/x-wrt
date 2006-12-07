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

header "Network" "Services" "@TR<<Services Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

load_settings services
uci_load upnpd

if ! empty "$FORM_install_upnp"; then
	echo "Installing UPNP package ...<pre>"	
	install_package miniupnpd
	uci_set "upnpd" "general" "enable" "1"
	echo "</pre>"	
fi

if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_upnp_enable="$CONFIG_general_enable"
	FORM_upnpd_log_output="$CONFIG_general_log_output"
	FORM_upnpd_up_bitspeed="$CONFIG_general_up_bitspeed"
	FORM_upnpd_down_bitspeed="$CONFIG_general_down_bitspeed"
else
	# save form
	is_kamikaze && {
		# TODO: This should be moved to apply.sh shouldn't it?
		if [ "$FORM_upnp_enable" = "1" ]; then
			/etc/init.d/miniupnpd enable 2>&-
		else
			/etc/init.d/miniupnpd disable 2>&-
		fi
	}
	uci_set "upnpd" "general" "enable" "$FORM_upnp_enable"
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
	select|upnp_enable|$FORM_upnp_enable
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
