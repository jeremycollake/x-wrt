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
# 	Jeremy Collake <jeremy.collake@gmail.com>
#
# NVRAM variables referenced:
#	upnp_enabled
#
# Configuration files referenced: 
#   	none
#

header "Network" "Services" "@TR<<Services Configuration>>" ' onLoad="modechange()" ' "$SCRIPT_NAME"

load_settings services

if ! empty "$FORM_install_upnp"; then	
	echo "Installing UPNP package ...<pre>"	
	install_package "http://ftp.berlios.de/pub/xwrt/packages/libupnp_1.2.1a_mipsel.ipk"
	install_package "http://ftp.berlios.de/pub/xwrt/packages/linux-igd_1.0.1.ipk"
	echo "</pre>"
	#echo "<br /><br /><a href="services.sh">Refresh this page to configure newly installed service(s)..</a><br />"
fi

if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_upnp_enabled="${upnp_enabled:-$(nvram get upnp_enabled)}"	
else
	# save form				
	save_setting services upnp_enabled "$FORM_upnp_enabled"
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
equal "$?" "0" && upnp_installed="1"


if equal "$upnp_installed" "1" ; then
	install_upnp_button="field|@TR<<UPNP Enabled>>
	select|upnp_enabled|$FORM_upnp_enabled
	option|0|@TR<<Disabled>>
	option|1|@TR<<Enabled>>"	
else
	install_upnp_button="submit|install_upnp| Install UPNP Package |"
	
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
