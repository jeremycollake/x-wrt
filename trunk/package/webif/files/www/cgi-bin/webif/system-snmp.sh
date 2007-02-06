#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/functions.sh

if empty "$FORM_submit"; then
	FORM_snmp_private_name=${snmp_private_name:-$(nvram get snmp_private_name)}
	FORM_snmp_private_src=${snmp_private_src:-$(nvram get snmp_private_src)}
	FORM_snmp_public_name=${snmp_public_name:-$(nvram get snmp_public_name)}
	FORM_snmp_public_src=${snmp_public_src:-$(nvram get snmp_public_src)}

else
	SAVED=1
	validate <<EOF
string|FORM_snmp_private_name|SNMP Private Community||$FORM_snmp_private_name
string|FORM_snmp_private_src|SNMP Private Source||$FORM_snmp_private_src
string|FORM_snmp_public_name|SNMP Public Community||$FORM_snmp_public_name
string|FORM_snmp_public_src|SNMP Public Source||$FORM_snmp_public_src
EOF
	equal "$?" 0 && {
		save_setting snmp snmp_private_name $FORM_snmp_private_name
		save_setting snmp snmp_private_src $FORM_snmp_private_src
		save_setting snmp snmp_public_name $FORM_snmp_public_name
		save_setting snmp snmp_public_src $FORM_snmp_public_src
	}
fi

header "System" "SNMP" "@TR<<SNMP Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<SNMP Settings>>
field|@TR<<SNMP Public Community Name>>|snmp_public_name
text|snmp_public_name|$FORM_snmp_public_name
helpitem|SNMP Community String
helptext|Helptext SNMP Community String#Community string for public and private communities
field|@TR<<SNMP Public Source>>|snmp_public_src
text|snmp_public_src|$FORM_snmp_public_src
helpitem|SNMP Source
helptext|Helptext SNMP Source#Community source address, hostname or network mask.
field|@TR<<SNMP Private Community Name>>|snmp_private_name
text|snmp_private_name|$FORM_snmp_private_name
field|@TR<<SNMP Private Source>>|snmp_private_src
text|snmp_private_src|$FORM_snmp_private_src
end_form
EOF
footer ?>
<!--
##WEBIF:name:System:320:SNMP
-->
