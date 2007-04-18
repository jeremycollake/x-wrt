#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
is_kamikaze && {
	local _val
	uci_load "hotspot"
	eval "_val=\$CONFIG_chilli_TYPE" 2>/dev/null
	! equal "$_val" "hotspot" && {
		uci_add "hotspot" "hotspot" "chilli"
		uci_commit "hotspot"
		uci_load "hotspot"
	}
}

if empty "$FORM_submit"; then
	is_kamikaze && {
		FORM_chilli_radiusserver1="$CONFIG_chilli_radiusserver1"
		FORM_chilli_radiusserver2="$CONFIG_chilli_radiusserver2"
		FORM_chilli_radiussecret="$CONFIG_chilli_radiussecret"
		FORM_chilli_radiusauthport="$CONFIG_chilli_radiusauthport"
		FORM_chilli_radiusacctport="$CONFIG_chilli_radiusacctport"
		FORM_chilli_radiusnasid="$CONFIG_chilli_radiusnasid"
		FORM_chilli_proxylisten="$CONFIG_chilli_proxylisten"
		FORM_chilli_proxyport="$CONFIG_chilli_proxyport"
		FORM_chilli_proxyclient="$CONFIG_chilli_proxyclient"
		FORM_chilli_proxysecret="$CONFIG_chilli_proxysecret"
	} || {
		FORM_chilli_radiusserver1="${chilli_radiusserver1:-$(nvram get chilli_radiusserver1)}"
		FORM_chilli_radiusserver2="${chilli_radiusserver2:-$(nvram get chilli_radiusserver2)}"
		FORM_chilli_radiussecret="${chilli_radiussecret:-$(nvram get chilli_radiussecret)}"
		FORM_chilli_radiusauthport="${chilli_radiusauthport:-$(nvram get chilli_radiusauthport)}"
		FORM_chilli_radiusacctport="${chilli_radiusacctport:-$(nvram get chilli_radiusacctport)}"
		FORM_chilli_radiusnasid="${chilli_radiusnasid:-$(nvram get chilli_radiusnasid)}"
		FORM_chilli_proxylisten="${chilli_proxylisten:-$(nvram get chilli_proxylisten)}"
		FORM_chilli_proxyport="${chilli_proxyport:-$(nvram get chilli_proxyport)}"
		FORM_chilli_proxyclient="${chilli_proxyclient:-$(nvram get chilli_proxyclient)}"
		FORM_chilli_proxysecret="${chilli_proxysecret:-$(nvram get chilli_proxysecret)}"
	}
else
	SAVED=1
	validate <<EOF
string|FORM_chilli_radiusserver1|@TR<<hotspot_networking_RADIUS_Server_1#RADIUS Server 1||$FORM_chilli_radiusserver1
string|FORM_chilli_radiusserver2|@TR<<hotspot_networking_RADIUS_Server_2#RADIUS Server 2||$FORM_chilli_radiusserver2
string|FORM_chilli_radiussecret|@TR<<hotspot_networking_RADIUS_Secret#RADIUS Secret>>||$FORM_chilli_radiussecret
ports|FORM_chilli_radiusauthport|@TR<<hotspot_networking_RADIUS_Auth_Port#RADIUS Auth Port>>||$FORM_chilli_radiusauthport
ports|FORM_chilli_radiusacctport|@TR<<hotspot_networking_RADIUS Acct Port#RADIUS Acct Port>>||$FORM_chilli_radiusacctport
string|FORM_chilli_radiusnasid|@TR<<hotspot_networking_RADIUS_NAS_Id#RADIUS NAS Id>>||$FORM_chilli_radiusnasid
string|FORM_chilli_proxylisten|@TR<<hotspot_networking_Proxy_Listen#Proxy Listen>>||$FORM_chilli_proxylisten
string|FORM_chilli_proxyclient|@TR<<hotspot_networking_Proxy Client#Proxy Client>>||$FORM_chilli_proxyclient
string|FORM_chilli_proxyport|@TR<<hotspot_networking_Proxy_Port#Proxy Port>>||$FORM_chilli_proxyport
string|FORM_chilli_proxysecret|@TR<<hotspot_networking_Proxy_Secret#Proxy Secret>>||$FORM_chilli_proxysecret
EOF
	equal "$?" 0 && {
		is_kamikaze && {
			uci_set hotspot chilli radiusserver1 "$FORM_chilli_radiusserver1"
			uci_set hotspot chilli radiusserver2 "$FORM_chilli_radiusserver2"
			uci_set hotspot chilli radiussecret "$FORM_chilli_radiussecret"
			uci_set hotspot chilli radiusauthport "$FORM_chilli_radiusauthport"
			uci_set hotspot chilli radiusacctport "$FORM_chilli_radiusacctport"
			uci_set hotspot chilli radiusnasid "$FORM_chilli_radiusnasid"
			uci_set hotspot chilli proxylisten "$FORM_chilli_proxylisten"
			uci_set hotspot chilli proxyclient "$FORM_chilli_proxyclient"
			uci_set hotspot chilli proxyport "$FORM_chilli_proxyport"
			uci_set hotspot chilli proxysecret "$FORM_chilli_proxysecret"
		} || {
			save_setting hotspot chilli_radiusserver1 "$FORM_chilli_radiusserver1"
			save_setting hotspot chilli_radiusserver2 "$FORM_chilli_radiusserver2"
			save_setting hotspot chilli_radiussecret "$FORM_chilli_radiussecret"
			save_setting hotspot chilli_radiusauthport "$FORM_chilli_radiusauthport"
			save_setting hotspot chilli_radiusacctport "$FORM_chilli_radiusacctport"
			save_setting hotspot chilli_radiusnasid "$FORM_chilli_radiusnasid"
			save_setting hotspot chilli_proxylisten "$FORM_chilli_proxylisten"
			save_setting hotspot chilli_proxyclient "$FORM_chilli_proxyclient"
			save_setting hotspot chilli_proxyport "$FORM_chilli_proxyport"
			save_setting hotspot chilli_proxysecret "$FORM_chilli_proxysecret"
		}
	}
fi

header "HotSpot" "hotspot_networking_Networking#Networking" "@TR<<hotspot_networking_Network_Settings#Network Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<hotspot_networking_Network_Settings#Network Settings>>
field|@TR<<hotspot_networking_RADIUS_Server_1#RADIUS Server 1>>
text|chilli_radiusserver1|$FORM_chilli_radiusserver1
field|@TR<<hotspot_networking_RADIUS_Server_2#RADIUS Server 2>>
text|chilli_radiusserver2|$FORM_chilli_radiusserver2
helpitem|hotspot_networking_RADIUS_Server#RADIUS Server
helptext|hotspot_networking_RADIUS_Server_helptext#Primary and Secondary RADIUS Server.
field|@TR<<hotspot_networking_RADIUS_Secret#RADIUS Secret>>
text|chilli_radiussecret|$FORM_chilli_radiussecret
helpitem|hotspot_networking_RADIUS_Secret#RADIUS Secret
helptext|hotspot_networking_RADIUS_Secret_helptext#RADIUS Shared Secret.
field|@TR<<hotspot_networking_RADIUS_Auth_Port#RADIUS Auth Port>>
text|chilli_radiusauthport|$FORM_chilli_radiusauthport
field|@TR<<hotspot_networking_RADIUS Acct Port#RADIUS Acct Port>>
text|chilli_radiusacctport|$FORM_chilli_radiusacctport
field|@TR<<hotspot_networking_RADIUS_NAS_Id#RADIUS NAS Id>>
text|chilli_radiusnasid|$FORM_chilli_radiusnasid
helpitem|hotspot_networking_RADIUS_NAS_Id#RADIUS NAS Id
helptext|hotspot_networking_RADIUS_NAS_Id_helptext#RADIUS NAS Id.
field|@TR<<hotspot_networking_Proxy_Listen#Proxy Listen>>
text|chilli_proxylisten|$FORM_chilli_proxylisten
helpitem|hotspot_networking_Proxy_Listen#Proxy Listen
helptext|hotspot_networking_Proxy_Listen_helptext#IP Address to listen to (advanced uses only).
field|@TR<<hotspot_networking_Proxy Client#Proxy Client>>
text|chilli_proxyclient|$FORM_chilli_proxyclient
helpitem|hotspot_networking_Proxy Client#Proxy Client
helptext|hotspot_networking_Proxy Client_helptext#Clients from which we accept RADIUS Requests.
field|@TR<<hotspot_networking_Proxy_Port#Proxy Port>>
text|chilli_proxyport|$FORM_chilli_proxyport
helpitem|hotspot_networking_Proxy_Port#Proxy Port
helptext|hotspot_networking_Proxy_Port_heltext#UDP port to listen to.
field|@TR<<hotspot_networking_Proxy_Secret#Proxy Secret>>
text|chilli_proxysecret|$FORM_chilli_proxysecret
helpitem|hotspot_networking_Proxy_Secret#Proxy Secret
helptext|hotspot_networking_Proxy_Secret_helptext#RADIUS Shared Secret to accept for all clients.
end_form
EOF

footer ?>
<!--
##WEBIF:name:HotSpot:2:hotspot_networking_Networking#Networking
-->
