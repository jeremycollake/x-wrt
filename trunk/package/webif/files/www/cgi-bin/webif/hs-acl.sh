#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings hotspot
. /usr/lib/webif/hs.sh

FORM_uamallow="${hs_uamallow:-$HS_UAMALLOW}"
LISTVAL="$FORM_uamallow"
handle_list "$FORM_uamallowremove" "$FORM_uamallowadd" "$FORM_uamallowsubmit" 'hostname|FORM_uamallowadd|Walled-Garden Hostname|required' && {
	FORM_uamallow="$LISTVAL"
	save_setting hotspot hs_uamallow "$FORM_uamallow"
}

FORM_macallow="${hs_macallow:-$HS_MACALLOW}"
LISTVAL="$FORM_macallow"
handle_list "$FORM_macallowremove" "$FORM_macallowadd" "$FORM_macallowsubmit" 'mac|FORM_macallowadd|Walled-Garden Hostname|required' && {
	FORM_macallow="$LISTVAL"
	save_setting hotspot hs_macallow "$FORM_macallow"
}
FORM_macallowadd=${FORM_macallowadd:-00:00:00:00:00:00}

header "HotSpot" "Access Lists" "HotSpot Config $HS_USING" '' "$SCRIPT_NAME"

has_required_pkg && {

display_form <<EOF
start_form|@TR<<Walled-Garden Hosts>>
listedit|uamallow|$SCRIPT_NAME?|$FORM_uamallow|$FORM_uamallowadd
end_form
EOF

equal "$pkg" "chillispot" && {
display_form <<EOF
start_form|@TR<<Authorized MAC Addresses>>
listedit|macallow|$SCRIPT_NAME?|$FORM_macallow|$FORM_macallowadd
message|<b>Note</b>: MAC authentication always requires a RADIUS server for the actual authorization.
end_form
EOF
}

}

footer ?>
<!--
##WEBIF:name:HotSpot:2:Access Lists
-->
