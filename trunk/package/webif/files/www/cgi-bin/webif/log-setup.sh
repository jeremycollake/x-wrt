#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

load_settings log

if empty "$FORM_submit" ; then
	FORM_size="${log_size:-$(nvram get log_size)}"
	FORM_size=${FORM_size:-16}
	FORM_type="${log_type:-$(nvram get log_type)}"
	FORM_type=${FORM_type:-"circular"}
	FORM_ipaddr="${log_ipaddr:-$(nvram get log_ipaddr)}"
	FORM_log_port=${log_port:-$(nvram get log_port)}
       	FORM_log_mark=${log_mark:-$(nvram get log_mark)}
    	FORM_log_mark=${FORM_log_mark:-0}
else
validate <<EOF
ip|FORM_ipaddr|@TR<<Remote host>>||$FORM_ipaddr
int|FORM_log_port|Remote Port|min=0 max=65535|$FORM_log_port
int|FORM_log_mark|Minutes Between Marks||$FORM_log_mark
int|FORM_size|Log Size||$FORM_size
EOF

	if equal "$?" 0 ; then
		save_setting log log_size $FORM_size
		save_setting log log_type $FORM_type
		save_setting log log_ipaddr $FORM_ipaddr
		save_setting log log_port $FORM_log_port
		save_setting log log_mark $FORM_log_mark
	fi
fi

header "Log" "Syslog Settings" "@TR<<syslog Settings>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|Remote Syslog
field|Server IP Address
text|ipaddr|$FORM_ipaddr
field|Server Port
text|log_port|$FORM_log_port
end_form

start_form|Messages
field|Minutes Between Marks
text|log_mark|$FORM_log_mark
$prefix_fields
end_form

start_form|@TR<<Local Log>>
field|Log type
select|type|$FORM_type
option|circular|@TR<<Circular>>
option|file|@TR<<File>>
field|Log Size
text|size|$FORM_size
end_form
EOF


footer ?>

<!--
##WEBIF:name:Log:2:Syslog Settings
-->