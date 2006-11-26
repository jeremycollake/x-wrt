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
	save_setting upnpd upnp_enabled "1"
	echo "</pre>"	
fi

if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_upnp_enabled="${upnp_enabled:-$(nvram get upnp_enabled)}"
	FORM_upnp_log_output="${upnp_log_output:-$(nvram get upnpd_log_output)}"
else
	# save form
	save_setting upnpd upnp_enabled "$FORM_upnp_enabled"
	save_setting upnpd upnpd_log_output "$FORM_upnp_log_output"
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
	field|@TR<<Log Debug Output>>
	select|upnp_log_output|$FORM_upnp_log_output
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
