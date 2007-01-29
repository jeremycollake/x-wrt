#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "HotSpot" "Configuration" "HotSpot Management" ' onLoad="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_submit" && ! empty "$FORM_install_hswebif"; then
	# install_package uses -force-overwrite, which will be necessary for hswebif
	# over-write this very file.
	! install_package "hswebif" && {
		echo "<br /><div class=\"warning\">Error installing package!</div>"
	}
	echo "<br />Package installed successfully! You should now refresh this page."
else
	display_form <<EOF
	start_form|Hotspot Webif Extension Pack
	submit|install_hswebif| @TR<<Install Hotspot Extension Pack>> 
	end_form
EOF
fi

footer ?>
<!--
##WEBIF:name:HotSpot:1:Configuration
-->
