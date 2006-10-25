#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings hotspot
. /usr/lib/webif/hs.sh

FORM_hs_uamformat=$(echo $FORM_hs_uamformat|sed 's/[$]/\\$/g')
FORM_hs_uamhomepage=$(echo $FORM_hs_uamhomepage|sed 's/[$]/\\$/g')
FORM_hs_type=${hs_type:-$HS_TYPE}
hs_radconf=${hs_radconf:-$HS_RADCONF}

if empty "$FORM_submit"; then 
    FORM_hs_uamport=${hs_uamport:-$HS_UAMPORT}
    FORM_hs_uamformat=${hs_uamformat:-$HS_UAMFORMAT}
    FORM_hs_uamhomepage=${hs_uamhomepage:-$HS_UAMHOMEPAGE}
    FORM_hs_provider=${hs_provider:-$HS_PROVIDER}
    FORM_hs_provider_link=${hs_provider_link:-$HS_PROVIDER_LINK}
    FORM_hs_wwwdir=${hs_wwwdir:-$HS_WWWDIR}
else 
    SAVED=1
    case "$FORM_hs_type" in
	chillispot)
	    validate <<EOF
string|FORM_hs_uamformat|UAM URL Format|required|$FORM_hs_uamformat
string|FORM_hs_uamhomepage|UAM Homepage||$FORM_hs_uamhomepage
int|FORM_hs_uamport|UAM Port|required|$FORM_hs_uamport
EOF
	    equal "$?" 0 && {
		save_setting hotspot hs_uamport "$FORM_hs_uamport"
		save_setting hotspot hs_uamformat "$FORM_hs_uamformat"
		save_setting hotspot hs_uamhomepage "$FORM_hs_uamhomepage"
		save_setting hotspot hs_provider "$FORM_hs_provider"
		save_setting hotspot hs_provider_link "$FORM_hs_provider_link"
		save_setting hotspot hs_wwwdir "$FORM_hs_wwwdir"
	    }
	    ;;
	wifidog)
	    rm /etc/wifidog/rule-global
	    echo -n "$FORM_wifidog_global" > /etc/wifidog/rule-global
	    rm /etc/wifidog/rule-known-users
	    echo -n "$FORM_wifidog_known_users" > /etc/wifidog/rule-known-users
	    rm /etc/wifidog/rule-validating-users
	    echo -n "$FORM_wifidog_validating_users" > /etc/wifidog/rule-validating-users
	    rm /etc/wifidog/rule-unknown-users
	    echo -n "$FORM_wifidog_unknown_users" > /etc/wifidog/rule-unknown-users
	    rm /etc/wifidog/rule-locked-users
	    echo -n "$FORM_wifidog_locked_users" > /etc/wifidog/rule-locked-users
	    ;;
    esac
fi

header "HotSpot" "Advanced" "HotSpot Advanced Configs $HS_USING" '' "$SCRIPT_NAME"
ShowUntestedWarning

has_required_pkg && {

equal "$pkg" "chillispot" && {
if equal "$hs_radconf" "on"; then
    echo "<p><b>Auto-Configure</b> is enabled (<a href=\"hs.sh\">here</a>) so these settings are not needed.</p>"
else
display_form <<EOF
start_form|Advanced ChilliSpot Configurations
field|Internal UAM Port
int|hs_uamport|$FORM_hs_uamport
field|HotSpot Services Provider
text|hs_provider|$FORM_hs_provider
field|HotSpot Services Provider URL
text|hs_provider_link|$FORM_hs_provider_link
field|$HS_PROVIDER UAM URL Format
text|hs_uamformat|$FORM_hs_uamformat
field|UAM Homepage (splash page)
text|hs_uamhomepage|$FORM_hs_uamhomepage
field|Local Content Directory
text|hs_wwwdir|$FORM_hs_wwwdir
end_form
EOF
fi
}

equal "$pkg" "wifidog" && {
display_form <<EOF
start_form|Advanced WifiDog Configurations
message|<h3>Firewall Rules</h3>
field|<b>Global</b>
string|Used for rules to be applied to all other rulesets except locked.
field|
txtfile|wifidog_global|/etc/wifidog/rule-global
field|<b>Validating Users</b>
string|Used for new users validating their account.
field|
txtfile|wifidog_validating_users|/etc/wifidog/rule-validating-users
field|<b>Known Users</b>
string|Used for normal validated users.
field|
txtfile|wifidog_known_users|/etc/wifidog/rule-known-users
field|<b>Unknown Users</b>
string|Used for unvalidated users, this is the ruleset that gets redirected.
field|
txtfile|wifidog_unknown_users|/etc/wifidog/rule-unknown-users
field|<b>Locked Users</b>
string|Used for users that have been locked out.
field|
txtfile|wifidog_locked_users|/etc/wifidog/rule-locked-users
end_form
EOF
}

}

footer ?>
<!--
##WEBIF:name:HotSpot:5:Advanced
-->
