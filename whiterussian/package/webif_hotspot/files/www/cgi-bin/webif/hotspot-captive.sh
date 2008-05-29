#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

if empty "$FORM_submit"; then
	load_settings hotspot
	FORM_chilli_uamserver="${chilli_uamserver:-$(nvram get chilli_uamserver)}"
	FORM_chilli_uamsecret="${chilli_uamsecret:-$(nvram get chilli_uamsecret)}"
	FORM_chilli_uamhomepage="${chilli_uamhomepage:-$(nvram get chilli_uamhomepage)}"
	FORM_chilli_uamlisten="${chilli_uamlisten:-$(nvram get chilli_uamlisten)}"
	FORM_chilli_uamport="${chilli_uamport:-$(nvram get chilli_uamport)}"
	FORM_chilli_uamallowed="${chilli_uamallowed:-$(nvram get chilli_uamallowed)}"
	FORM_chilli_uamanydns="${chilli_uamanydns:-$(nvram get chilli_uamanydns)}"
	FORM_chilli_macauth="${chilli_macauth:-$(nvram get chilli_macauth)}"
	FORM_chilli_macallowed="${chilli_macallowed:-$(nvram get chilli_macallowed)}"
	FORM_chilli_macpasswd="${chilli_macpasswd:-$(nvram get chilli_macpasswd)}"
	FORM_chilli_macsuffix="${chilli_macsuffix:-$(nvram get chilli_macsuffix)}"
else
	SAVED=1
	validate <<EOF
string|FORM_chilli_uamserver|@TR<<hotspot_captive_UAM_Server#UAM Server>>||$FORM_chilli_uamserver
ports|FORM_chilli_uamport|@TR<<hotspot_captive_UAM_Port#UAM Port>>||$FORM_chilli_uamport
string|FORM_chilli_uamsecret|@TR<<hotspot_captive_UAM_Secret#UAM Secret>>||$FORM_chilli_uamsecret
string|FORM_chilli_uamhomepage|@TR<<hotspot_captive_UAM_Homepage#UAM Homepage>>||$FORM_chilli_uamhomepage
string|FORM_chilli_uamallowed|@TR<<hotspot_captive_UAM_Allowed#UAM Allowed>>||$FORM_chilli_uamallowed
ip|FORM_chilli_uamlisten|@TR<<hotspot_captive_UAM_Listen#UAM Listen>>||$FORM_chilli_uamlisten
int|FORM_chilli_uamanydns|@TR<<hotspot_captive_UAM_Any_DNS#UAM Any DNS>>||$FORM_chilli_uamanydns
int|FORM_chilli_macauth|@TR<<hotspot_captive_MAC_Auth#MAC Authentication>>||$FORM_chilli_macauth
string|FORM_chilli_macallowed|@TR<<hotspot_captive_MAC_Allowed#MAC Allowed>>||$FORM_chilli_macallowed
string|FORM_chilli_macpasswd|@TR<<hotspot_captive_MAC_Password#MAC Password>>||$FORM_chilli_macpasswd
string|FORM_chilli_macsuffix|@TR<<hotspot_captive_MAC_Suffix#MAC Suffix>>||$FORM_chilli_macsuffix
EOF
	equal "$?" 0 && {
			save_setting hotspot chilli_uamserver "$FORM_chilli_uamserver"
			save_setting hotspot chilli_uamsecret "$FORM_chilli_uamsecret"
			save_setting hotspot chilli_uamhomepage "$FORM_chilli_uamhomepage"
			save_setting hotspot chilli_uamlisten "$FORM_chilli_uamlisten"
			save_setting hotspot chilli_uamport "$FORM_chilli_uamport"
			save_setting hotspot chilli_uamallowed "$FORM_chilli_uamallowed"
			save_setting hotspot chilli_uamanydns "$FORM_chilli_uamanydns"
			save_setting hotspot chilli_macallowed "$FORM_chilli_macallowed"
			save_setting hotspot chilli_macauth "$FORM_chilli_macauth"
			save_setting hotspot chilli_macsuffix "$FORM_chilli_macsuffix"
			save_setting hotspot chilli_macpasswd "$FORM_chilli_macpasswd"
	}
fi

header "HotSpot" "hotspot_captive_Captive_Portal#Captive Portal" "@TR<<hotspot_captive_Captive_Portal_Settings#Captive Portal Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<hotspot_captive_Captive_Portal_Settings#Captive Portal Settings>>
field|@TR<<hotspot_captive_UAM_Server#UAM Server>>
text|chilli_uamserver|$FORM_chilli_uamserver
helpitem|hotspot_captive_UAM_Server#UAM Server
helptext|hotspot_captive_UAM_Server_helptext#URL of a Webserver handling the authentication.
field|@TR<<hotspot_captive_UAM_Port#UAM Port>>
text|chilli_uamport|$FORM_chilli_uamport
helpitem|hotspot_captive_UAM_Port#UAM Port
helptext|hotspot_captive_UAM_Port_helptext#TCP port to listen to for authentication requests.
field|@TR<<hotspot_captive_UAM_Secret#UAM Secret>>
text|chilli_uamsecret|$FORM_chilli_uamsecret
helpitem|hotspot_captive_UAM_Secret#UAM Secret
helptext|hotspot_captive_UAM_Secret_helptext#Shared secret between HotSpot and Webserver (UAM Server).
field|@TR<<hotspot_captive_UAM_Homepage#UAM Homepage>>
text|chilli_homepage|$FORM_chilli_homepage
helpitem|hotspot_captive_UAM_Homepage#UAM Homepage
helptext|hotspot_captive_UAM_Homepage_helptext#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead.
field|@TR<<hotspot_captive_UAM_Allowed#UAM Allowed>>
text|chilli_uamallowed|$FORM_chilli_uamallowed
helpitem|hotspot_captive_UAM_Allowed#UAM Allowed
helptext|hotspot_captive_UAM_Allowed_helptext#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened).
field|@TR<<hotspot_captive_UAM_Listen#UAM Listen>>
text|chilli_uamlisten|$FORM_chilli_uamlisten
helpitem|hotspot_captive_UAM_Listen#UAM Listen
helptext|hotspot_captive_UAM_Listen_helptext#IP Address to listen to for authentication requests.
field|@TR<<hotspot_captive_UAM_Any_DNS#UAM Any DNS>>
checkbox|chilli_uamanydns|$FORM_chilli_uamanydns|1
helpitem|hotspot_captive_UAM_Any_DNS#UAM Any DNS
helptext|hotspot_captive_UAM_Any_DNS_helptext#If enabled, users will be allowed to user any other dns server they specify.
field|@TR<<hotspot_captive_MAC_Auth#MAC Authentication>>
checkbox|chilli_macauth|$FORM_chilli_macauth|1
helpitem|hotspot_captive_MAC_Auth#MAC Authentication
helptext|hotspot_captive_MAC_Auth_helptext#If enabled, users will be authenticated only based on their MAC Address.
field|@TR<<hotspot_captive_MAC_Allowed#MAC Allowed>>
text|chilli_macallowed|$FORM_chilli_macallowed
helpitem|hotspot_captive_MAC_Allowed#MAC Allowed
helptext|hotspot_captive_MAC_Allowed_helptext#List of allowed MAC Addresses.
field|@TR<<hotspot_captive_MAC_Password#MAC Password>>
text|chilli_macpasswd|$FORM_chilli_macpasswd
helpitem|hotspot_captive_MAC_Password#MAC Password
helptext|hotspot_captive_MAC_Password_helptext#Password to use for MAC authentication.
field|@TR<<hotspot_captive_MAC_Suffix#MAC Suffix>>
text|chilli_macsuffix|$FORM_chilli_macsuffix
helpitem|hotspot_captive_MAC_Suffix#MAC Suffix
helptext|hotspot_captive_MAC_Suffix_helptext#Suffix to add to the username in-order to form the username.
end_form
EOF

footer ?>
<!--
##WEBIF:name:HotSpot:3:hotspot_captive_Captive_Portal#Captive Portal
-->
