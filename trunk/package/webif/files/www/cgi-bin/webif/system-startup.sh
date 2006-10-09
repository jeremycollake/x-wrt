#!/usr/bin/webif-page
<? 
###################################################################
# startup
#
# Description:
#	Custom startup configuration. 
#
# Author(s) [in order of work date]: 
#       Jeremy Collake
#
# Major revisions:
#
# NVRAM variables referenced:
#	
#
# Configuration files referenced: 
#   none
#
. /usr/lib/webif/webif.sh

header "System" "Custom Startup" "@TR<<Custom Startup>>" '' "$SCRIPT_NAME" 

# defaults
custom_script_name="/etc/init.d/S95webif-custom-default"
tmp_script_name="/tmp/.webif/file-S95webif-custom-default"

! empty "$FORM_submit" &&
{
 	SAVED=1
 	# todo: don't be lazy, no ,9999d - use until end - look it up
 	echo "$FORM_custom_script" | sed 2,9999d | grep "\#\!/bin/sh" >> /dev/null
 	if equal "$?" "0"; then 	
 		mkdir -p "/tmp/.webif"
 		echo "$FORM_custom_script" > "$tmp_script_name"
 	else 		
 		echo '<div class=\"warning\">You must include #!/bin/sh as the first line of the script. Not saved.</div>'
 	fi
}



#
# NOTE: had issues getting multi-line form data to initialize in textarea implemented by form.awk
#       so am using static html for now. TODO
#
?>				
<div class="settings">
<div class="settings-title"><h3><strong>Custom Startup Script</strong></h3></div>
<div class="settings-content">
<table width="100%" summary="Settings">
<tr id="custom_startup">
<td>
<textarea id="custom_script" name="custom_script" rows=24 cols=80>
<? 
if exists "$tmp_script_name"; then
	cat "$tmp_script_name"
else
	cat "$custom_script_name" 
fi
?>
</textarea>
</td></tr></table></div></div>

<? footer ?>
<!--
##WEBIF:name:System:125:Custom Startup
-->
