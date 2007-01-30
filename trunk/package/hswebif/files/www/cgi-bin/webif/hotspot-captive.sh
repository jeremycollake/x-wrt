#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/functions.sh

if empty "$FORM_submit"; then
	FORM_chilli_uamserver=${chilli_uamserver:-$(nvram get chilli_uamserver)}
	FORM_chilli_uamsecret=${chilli_uamsecret:-$(nvram get chilli_uamsecret)}
	FORM_chilli_uamhomepage=${chilli_uamhomepage:-$(nvram get chilli_uamhomepage)}
	FORM_chilli_uamlisten=${chilli_uamlisten:-$(nvram get chilli_uamlisten)}
	FORM_chilli_uamport=${chilli_uamport:-$(nvram get chilli_uamport)}
	FORM_chilli_uamallowed=${chilli_uamallowed:-$(nvram get chilli_uamallowed)}
	FORM_chilli_uamanydns=${chilli_uamanydns:-$(nvram get chilli_uamanydns)}
	FORM_chilli_macauth=${chilli_macauth:-$(nvram get chilli_macauth)}
	FORM_chilli_macallowed=${chilli_macallowed:-$(nvram get chilli_macallowed)}
	FORM_chilli_macpasswd=${chilli_macpasswd:-$(nvram get chilli_macpasswd)}
	FORM_chilli_macsuffix=${chilli_macsuffix:-$(nvram get chilli_macsuffix)}

else
	SAVED=1
	validate <<EOF
string|FORM_chilli_uamserver|UAM Server||$FORM_chilli_uamserver
string|FORM_chilli_uamsecret|UAM Secret||$FORM_chilli_uamsecret
string|FORM_chilli_uamhomepage|UAM Homepage||$FORM_chilli_uamhomepage
int|FORM_chilli_uamanydns|UAM Any DNS||$FORM_chilli_uamanydns
ip|FORM_chilli_uamlisten|UAM Listen||$FORM_chilli_uamlisten
ports|FORM_chilli_uamport|UAM Port||$FORM_chilli_uamport
string|FORM_chilli_uamallowed|UAM Allowed||$FORM_chilli_uamallowed
int|FORM_chilli_macauth|MAC Auth||$FORM_chilli_macauth
string|FORM_chilli_macallowed|MAC Allowed||$FORM_chilli_macallowed
string|FORM_chilli_macpasswd|MAC Password||$FORM_chilli_macpasswd
string|FORM_chilli_macsuffix|MAC Suffix||$FORM_chilli_macsuffix
EOF
	equal "$?" 0 && {
		save_setting hotspot chilli_uamserver $FORM_chilli_uamserver
		save_setting hotspot chilli_uamsecret $FORM_chilli_uamsecret
		save_setting hotspot chilli_uamhomepage $FORM_chilli_uamhomepage
		save_setting hotspot chilli_uamlisten $FORM_chilli_uamlisten
		save_setting hotspot chilli_uamport $FORM_chilli_uamport
		save_setting hotspot chilli_uamallowed $FORM_chilli_uamallowed
		save_setting hotspot chilli_uamanydns $FORM_chilli_uamanydns
		save_setting hotspot chilli_macallowed $FORM_chilli_macallowed
		save_setting hotspot chilli_macauth $FORM_chilli_macauth
		save_setting hotspot chilli_macsuffix $FORM_chilli_macsuffix
		save_setting hotspot chilli_macpasswd $FORM_chilli_macpasswd
	}
fi

header "HotSpot" "Captive Portal" "@TR<<Captive Portal Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<Captive Portal Settings>>
field|@TR<<UAM Server>>|chilli_uamserver
text|chilli_uamserver|$FORM_chilli_uamserver
field|@TR<<UAM Port>>|chilli_uamport
text|chilli_uamport|$FORM_chilli_uamport
field|@TR<<UAM Secret>>|chilli_uamsecret
text|chilli_uamsecret|$FORM_chilli_uamsecret
field|@TR<<UAM Homepage>>|chilli_homepage
text|chilli_homepage|$FORM_chilli_homepage
field|@TR<<UAM Allowed>>|chilli_uamallowed
text|chilli_uamallowed|$FORM_chilli_uamallowed
field|@TR<<UAM Listen>>|chilli_uamlisten
text|chilli_uamlisten|$FORM_chilli_uamlisten
field|@TR<<UAM Any DNS>>|chilli_uamanydns
checkbox|chilli_uamanydns|$FORM_chilli_uamanydns|1
field|@TR<<MAC Auth>>|chilli_macauth
checkbox|chilli_macauth|$FORM_chilli_macauth|1
field|@TR<<MAC Allowed>>|chilli_macallowed
text|chilli_macallowed|$FORM_chilli_macallowed
field|@TR<<MAC Password>>|chilli_macpasswd
text|chilli_macpasswd|$FORM_chilli_macpasswd
field|@TR<<MAC Suffix>>|chilli_macsuffix
text|chilli_macsuffix|$FORM_chilli_macsuffix
end_form
EOF

footer ?>
<!--
##WEBIF:name:HotSpot:3:Captive Portal
-->
