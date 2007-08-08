#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		hotspot)
			chili_cfg="$CONFIG_SECTION"
		;;
	esac
}

uci_load "hotspot"

if empty "$FORM_submit"; then
	eval "FORM_chilli_uamserver=\"\$CONFIG_${chilli_cfg}_uamserver\""
	eval "FORM_chilli_uamsecret=\"\$CONFIG_${chilli_cfg}_uamsecret\""
	eval "FORM_chilli_uamhomepage=\"\$CONFIG_${chilli_cfg}_uamhomepage\""
	eval "FORM_chilli_uamlisten=\"\$CONFIG_${chilli_cfg}_uamlisten\""
	eval "FORM_chilli_uamport=\"\$CONFIG_${chilli_cfg}_uamport\""
	eval "FORM_chilli_uamallowed=\"\$CONFIG_${chilli_cfg}_uamallowed\""
	eval "FORM_chilli_uamanydns=\"\$CONFIG_${chilli_cfg}_uamanydns\""
	eval "FORM_chilli_macauth=\"\$CONFIG_${chilli_cfg}_macauth\""
	eval "FORM_chilli_macallowed=\"\$CONFIG_${chilli_cfg}_macallowed\""
	eval "FORM_chilli_macpasswd=\"\$CONFIG_${chilli_cfg}_macpasswd\""
	eval "FORM_chilli_macsuffix=\"\$CONFIG_${chilli_cfg}_macsuffix\""
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
		[ "$chilli_cfg" = "" ] && {
			uci_add hotspot chilli
			chilli_cfg="chilli"
		}
		uci_set hotspot "$chilli_cfg" uamserver "$FORM_chilli_uamserver"
		uci_set hotspot "$chilli_cfg" uamsecret "$FORM_chilli_uamsecret"
		uci_set hotspot "$chilli_cfg" uamhomepage "$FORM_chilli_uamhomepage"
		uci_set hotspot "$chilli_cfg" uamlisten "$FORM_chilli_uamlisten"
		uci_set hotspot "$chilli_cfg" uamport "$FORM_chilli_uamport"
		uci_set hotspot "$chilli_cfg" uamallowed "$FORM_chilli_uamallowed"
		uci_set hotspot "$chilli_cfg" uamanydns "$FORM_chilli_uamanydns"
		uci_set hotspot "$chilli_cfg" macallowed "$FORM_chilli_macallowed"
		uci_set hotspot "$chilli_cfg" macauth "$FORM_chilli_macauth"
		uci_set hotspot "$chilli_cfg" macsuffix "$FORM_chilli_macsuffix"
		uci_set hotspot "$chilli_cfg" macpasswd "$FORM_chilli_macpasswd"
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
