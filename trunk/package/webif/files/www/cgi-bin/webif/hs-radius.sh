#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings hotspot
. /usr/lib/webif/hs.sh

hs_radconf=${hs_radconf:-$HS_RADCONF}
if empty "$FORM_submit"; then 
    FORM_hs_radius=${hs_radius:-$HS_RADIUS}
    FORM_hs_radauth=${hs_radauth:-$HS_RADAUTH}
    FORM_hs_radacct=${hs_radacct:-$HS_RADACCT}
    FORM_hs_radsecret=${hs_radsecret:-$HS_RADSECRET}
    FORM_hs_macauth=${hs_macauth:-$HS_MACAUTH}
    FORM_hs_macauth=${FORM_hs_macauth:-off}
    FORM_hs_admusr=${hs_admusr:-$HS_ADMUSR}
    FORM_hs_admpwd=${hs_admpwd:-$HS_ADMPWD}
    FORM_hs_adminterval=${hs_adminterval:-$HS_ADMINTERVAL}
else 
    SAVED=1
    validate <<EOF
hostname|FORM_hs_radius|$HS_PROVIDER RADIUS Hostname|required|$FORM_hs_radius
string|FORM_hs_radsecret|Shared Secret|required|$FORM_hs_radsecret
port|FORM_hs_radauth|Auth Port|required|$FORM_hs_radauth
port|FORM_hs_radacct|Acct Port|required|$FORM_hs_radacct
int|FORM_hs_adminterval|Admin Reauth Interval|required|$FORM_hs_adminterval
EOF
    equal "$?" 0 && {
	[ "$FORM_hs_radius" = "$HS_RADIUS" ] || \
	    save_setting hotspot hs_radius "$FORM_hs_radius"
	[ "$FORM_hs_radauth" = "$HS_RADAUTH" ] || \
	    save_setting hotspot hs_radauth "$FORM_hs_radauth"
	[ "$FORM_hs_radacct" = "$HS_RADACCT" ] || \
	    save_setting hotspot hs_radacct "$FORM_hs_radacct"
	[ "$FORM_hs_radsecret" = "$HS_RADSECRET" ] || \
	    save_setting hotspot hs_radsecret "$FORM_hs_radsecret"
	save_setting hotspot hs_macauth "$FORM_hs_macauth"
	save_setting hotspot hs_admusr "$FORM_hs_admusr"
	save_setting hotspot hs_admpwd "$FORM_hs_admpwd"
	save_setting hotspot hs_adminterval "$FORM_hs_adminterval"
    }
fi

header "HotSpot" "RADIUS" "RADIUS Config $HS_USING" '' "$SCRIPT_NAME"

has_required_pkg && {

equal "$pkg" "chillispot" && {
if equal "$hs_radconf" "on"; then
    echo "<p><b>Auto-Configure</b> is enabled (<a href=\"hs.sh\">here</a>) so these settings are not needed.</p>"
else
display_form <<EOF
start_form|RADIUS Configurations
field|RADIUS Hostname
text|hs_radius|$FORM_hs_radius
field|RADIUS Auth Port
text|hs_radauth|$FORM_hs_radauth
field|RADIUS Acct Port
text|hs_radacct|$FORM_hs_radacct
field|Shared Secret
text|hs_radsecret|$FORM_hs_radsecret
field|MAC Address Authentication
select|hs_macauth|$FORM_hs_macauth
option|on|@TR<<Enabled>>
option|off|@TR<<Disabled>>
field|RADIUS Admin Username
text|hs_admusr|$FORM_hs_admusr
field|RADIUS Admin Password
text|hs_admpwd|$FORM_hs_admpwd
field|Admin Reauth Interval
int|hs_adminterval|$FORM_hs_adminterval|(in minutes; 0 = off)
end_form
EOF
fi
}
equal "$pkg" "wifidog" && {
    echo "<p>No RADIUS settings for WiFiDog access controller.</p>"
}
}
footer ?>
<!--
##WEBIF:name:HotSpot:4:RADIUS
-->
