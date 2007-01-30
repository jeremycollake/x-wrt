#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/functions.sh

if empty "$FORM_submit"; then
	FORM_chilli_debug=${chilli_debug:-$(nvram get chilli_debug)}
	FORM_chilli_net=${chilli_net:-$(nvram get chilli_net)}
	FORM_chilli_dns1=${chilli_dns1:-$(nvram get chilli_dns1)}
	FORM_chilli_dns2=${chilli_dns2:-$(nvram get chilli_dns2)}
	FORM_chilli_dhcpif=${chilli_dhcpif:-$(nvram get chilli_dhcpif)}
	FORM_chilli_dhcpmac=${chilli_dhcpmac:-$(nvram get chilli_dhcpmac)}
	FORM_chilli_lease=${chilli_lease:-$(nvram get chilli_lease)}
	FORM_chilli_pidfile=${chilli_pidfile:-$(nvram get chilli_pidfile)}
	FORM_chilli_interval=${chilli_interval:-$(nvram get chilli_interval)}
	FORM_chilli_domain=${chilli_domain:-$(nvram get chilli_domain)}
	FORM_chilli_dynip=${chilli_dynip:-$(nvram get chilli_dynip)}
	FORM_chilli_statip=${chilli_statip:-$(nvram get chilli_statip)}

else
	SAVED=1
	validate <<EOF
int|FORM_chilli_debug|Debug||$FORM_chilli_debug
string|FORM_chilli_net|DHCP Network||$FORM_chilli_net
string|FORM_chilli_dns1|DNS 1||$FORM_chilli_dns1
string|FORM_chilli_dns2|DNS 2||$FORM_chilli_dns2
string|FORM_chilli_dhcpif|DHCP Iface||$FORM_chilli_dhcpif
string|FORM_chilli_dhcpmac|DHCP MAC||$FORM_chilli_dhcpmac
string|FORM_chilli_lease|DHCP Lease||$FORM_chilli_lease
string|FORM_chilli_interval|Interval||$FORM_chilli_interval
string|FORM_chilli_domain|Domain||$FORM_chilli_domain
string|FORM_chilli_pidfile|Pidfile||$FORM_chilli_pidfile
string|FORM_chilli_dynip|Dynamic IP Pool||$FORM_chilli_dynip
string|FORM_chilli_statip|Static IP Pool||$FORM_chilli_statip
EOF
	equal "$?" 0 && {
		save_setting hotspot chilli_debug $FORM_chilli_debug
		save_setting hotspot chilli_dns1 $FORM_chilli_dns1
		save_setting hotspot chilli_dns2 $FORM_chilli_dns2
		save_setting hotspot chilli_lease $FORM_chilli_lease
		save_setting hotspot chilli_interval $FORM_chilli_interval
		save_setting hotspot chilli_domain $FORM_chilli_domain
		save_setting hotspot chilli_pidfile $FORM_chilli_pidfile
		save_setting hotspot chilli_statip $FORM_chilli_statip
		save_setting hotspot chilli_dynip $FORM_chilli_dynip
		save_setting hotspot chilli_dhcpif $FORM_chilli_dhcpif
		save_setting hotspot chilli_dhcpmac $FORM_chilli_dhcpmac
	}
fi

header "HotSpot" "Core" "@TR<<Core Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<Core Settings>>
field|@TR<<Debug>>|chilli_debug
checkbox|chilli_debug|$FORM_chilli_debug|1
field|@TR<<DHCP Network>>|chilli_net
text|chilli_net|$FORM_chilli_net
field|@TR<<DHCP Iface>>|chilli_dhcpif
text|chilli_dhcpif|$FORM_chilli_dhcpif
field|@TR<<DHCP MAC>>|chilli_dhcpmac
text|chilli_dhcpmac|$FORM_chilli_dhcpmac
field|@TR<<DHCP Lease>>|chilli_lease
text|chilli_lease|$FORM_chilli_lease
field|@TR<<DNS1>>|chilli_dns1
text|chilli_dns1|$FORM_chilli_dns1
field|@TR<<DNS2>>|chilli_dns2
text|chilli_dns2|$FORM_chilli_dns2
field|@TR<<Domain>>|chilli_domain
text|chilli_domain|$FORM_chilli_domain
field|@TR<<Interval>>|chilli_interval
text|chilli_interval|$FORM_chilli_interval
field|@TR<<Pidfile>>|chilli_pidfile
text|chilli_pidfile|$FORM_chilli_pidfile
field|@TR<<Dynamic IP Pool>>|chilli_dynip
text|chilli_dynip|$FORM_chilli_dynip
field|@TR<<Static IP Pool>>|chilli_statip
text|chilli_statip|$FORM_chilli_statip
end_form
EOF

footer ?>
<!--
##WEBIF:name:HotSpot:1:Core
-->
