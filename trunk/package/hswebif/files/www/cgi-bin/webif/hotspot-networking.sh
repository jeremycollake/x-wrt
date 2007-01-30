#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/functions.sh

if empty "$FORM_submit"; then
	FORM_chilli_radiusserver1=${chilli_radiusserver1:-$(nvram get chilli_radiusserver1)}
	FORM_chilli_radiusserver2=${chilli_radiusserver2:-$(nvram get chilli_radiusserver2)}
	FORM_chilli_radiusauthport=${chilli_radiusauthport:-$(nvram get chilli_radiusauthport)}
	FORM_chilli_radiusacctport=${chilli_radiusacctport:-$(nvram get chilli_radiusacctport)}
	FORM_chilli_radiussecret=${chilli_radiussecret:-$(nvram get chilli_radiussecret)}
	FORM_chilli_radiusnasid=${chilli_radiusnasid:-$(nvram get chilli_radiusnasid)}
	FORM_chilli_proxylisten=${chilli_proxylisten:-$(nvram get chilli_proxylisten)}
	FORM_chilli_proxyport=${chilli_proxyport:-$(nvram get chilli_proxyport)}
	FORM_chilli_proxyclient=${chilli_proxyclient:-$(nvram get chilli_proxyclient)}
	FORM_chilli_proxysecret=${chilli_proxysecret:-$(nvram get chilli_proxysecret)}

else
	SAVED=1
	validate <<EOF
string|FORM_chilli_radiusserver1|RADIUS Server 1||$FORM_chilli_radiusserver1
string|FORM_chilli_radiusserver2|RADIUS Server 2||$FORM_chilli_radiusserver2
string|FORM_chilli_radiussecret|RADIUS Secret||$FORM_chilli_radiussecret
string|FORM_chilli_radiusauthport|RADIUS Auth Port||$FORM_chilli_radiusauthport
string|FORM_chilli_radiusacctport|RADIUS Acct Port||$FORM_chilli_radiusacctport
string|FORM_chilli_radiusnasid|RADIUS NAS Id||$FORM_chilli_radiusnasid
string|FORM_chilli_proxylisten|Proxy Listen||$FORM_chilli_proxylisten
string|FORM_chilli_proxyclient|Proxy Client||$FORM_chilli_proxyclient
string|FORM_chilli_proxyport|Proxy Port||$FORM_chilli_proxyport
string|FORM_chilli_proxysecret|Proxy Secret||$FORM_chilli_proxysecret
EOF
	equal "$?" 0 && {
		save_setting hotspot chilli_radiusserver1 $FORM_chilli_radiusserver1
		save_setting hotspot chilli_radiussecret $FORM_chilli_radiussecret
		save_setting hotspot chilli_radiusserver2 $FORM_chilli_radiusserver2
		save_setting hotspot chilli_radiusauthport $FORM_chilli_radiusauthport
		save_setting hotspot chilli_radiusacctport $FORM_chilli_radiusacctport
		save_setting hotspot chilli_radiusnasid $FORM_chilli_radiusnasid
		save_setting hotspot chilli_proxylisten $FORM_chilli_proxylisten
		save_setting hotspot chilli_proxyclient $FORM_chilli_proxyclient
		save_setting hotspot chilli_proxyport $FORM_chilli_proxyport
		save_setting hotspot chilli_proxysecret $FORM_chilli_proxysecret
	}
fi

header "HotSpot" "Networking" "@TR<<Network Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<Network Settings>>
field|@TR<<RADIUS Server 1>>|chilli_radiusserver1
text|chilli_radiusserver1|$FORM_chilli_radiusserver1
field|@TR<<RADIUS Server 2>>|chilli_radiusserver2
text|chilli_radiusserver2|$FORM_chilli_radiusserver2
field|@TR<<RADIUS Secret>>|chilli_radiussecret
text|chilli_radiussecret|$FORM_chilli_radiussecret
field|@TR<<RADIUS Auth Port>>|chilli_radiusauthport
text|chilli_radiusauthport|$FORM_chilli_radiusauthport
field|@TR<<RADIUS Acct Port>>|chilli_radiusacctport
text|chilli_radiusacctport|$FORM_chilli_radiusacctport
field|@TR<<RADIUS NAS Id>>|chilli_radiusnasid
text|chilli_radiusnasid|$FORM_chilli_radiusnasid
field|@TR<<Proxy Listen>>|chilli_proxylisten
text|chilli_proxylisten|$FORM_chilli_proxylisten
field|@TR<<Proxy Client>>|chilli_proxyclient
text|chilli_proxyclient|$FORM_chilli_proxyclient
field|@TR<<Proxy Port>>|chilli_proxyport
text|chilli_proxyport|$FORM_chilli_proxyport
field|@TR<<Proxy Secret>>|chilli_proxysecret
text|chilli_proxysecret|$FORM_chilli_proxysecret
end_form
EOF

footer ?>
<!--
##WEBIF:name:HotSpot:2:Networking
-->
