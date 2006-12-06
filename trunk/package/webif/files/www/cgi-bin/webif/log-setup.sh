#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/runsyslogd.conf

load_settings log

#header "Log" "Syslog Settings" "@TR<<syslog Settings>>"  ' onload="modechange()" ' "$SCRIPT_NAME"

if empty "$FORM_submit" ; then
	FORM_size="${log_size:-$(nvram get log_size)}"
	FORM_size=${FORM_size:-$DEFAULT_log_size}
	FORM_type="${log_type:-$(nvram get log_type)}"
	FORM_type=${FORM_type:-$DEFAULT_log_type}
	FORM_ipaddr="${log_ipaddr:-$(nvram get log_ipaddr)}"
	if equal $FORM_ipaddr 0 ; then
		FORM_ipaddr=""
	fi
	FORM_log_port=${log_port:-$(nvram get log_port)}
	if empty "$FORM_ipaddr" ; then
		FORM_log_port=""
	fi
	FORM_log_mark=${log_mark:-$(nvram get log_mark)}
	FORM_log_mark=${FORM_log_mark:-$DEFAULT_log_mark}
	FORM_filename="${log_file:-$(nvram get log_file)}"
	FORM_filename=${FORM_filename:-$DEFAULT_log_file}
else
validate <<EOF
ip|FORM_ipaddr|@TR<<Remote host>>||$FORM_ipaddr
int|FORM_log_port|Remote Port|min=0 max=65535|$FORM_log_port
int|FORM_log_mark|Minutes Between Marks||$FORM_log_mark
int|FORM_size|Log Size||$FORM_size
EOF
	
	if equal "$?" 0 ; then
		[ -z $FORM_ipaddr ] && FORM_log_port=""
		save_setting log log_size $FORM_size
		save_setting log log_type $FORM_type
		save_setting log log_ipaddr $FORM_ipaddr
		save_setting log log_port $FORM_log_port
		save_setting log log_mark $FORM_log_mark
		save_setting log log_file $FORM_filename
	fi
fi


header "Log" "Syslog Settings" "@TR<<syslog Settings>>"  ' onload="modechange()" ' "$SCRIPT_NAME"

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
function modechange()
{
	var v;
	v = isset('type', 'file');
	set_visible('logname', v);
}
</script>
EOF


display_form <<EOF
onchange|modechange
start_form|Remote Syslog
field|Server IP Address
text|ipaddr|$FORM_ipaddr
helpitem|Remote Syslog
helptext|Remote Syslog#IP address and port of the remote logging host. Leave this address blank for no remote logging. The port is set to $DEFAULT_log_port by default
field|Server Port
text|log_port|$FORM_log_port
end_form

start_form|Syslog Marks
field|Minutes Between Marks
text|log_mark|$FORM_log_mark
helpitem|Syslog Marks
helptext|Syslog Marks#Periodic marks in your log. This parameter sets the time in minutes between the marks. A value of 0 means no mark. Default value: $DEFAULT_log_mark.
end_form

start_form|@TR<<Local Log>>
field|Log type
select|type|$FORM_type
option|circular|@TR<<Circular>>
option|file|@TR<<File>>
helpitem|Log Type
helptext|Log Type#Wether your log will be stored in a memory circular buffer or in a file. Beware that files are stored in a memory filesystem wich will be lost if you reboot your router. Default value: $DEFAULT_log_type.
field|@TR<<Log File>>|logname|hidden
text|filename|$FORM_filename
helpitem|Log File
helptext|Log File#The path and name of your log file. It can be set on any writable filesystem. CAUTION: DO NOT USE A JFFS filesystem because syslog will write A LOT to it. You can use /tmp or any filesystem on an external storage unit. Default value: $DEFAULT_log_file.
field|Log Size
text|size|$FORM_size
helpitem|Log Size
helptext|Log Size#The size of your log in kilo-bytes. Be carefull with the size of the circular buffer as it is taken from your main memory. Default value: $DEFAULT_log_size kB.
end_form
EOF


footer ?>

<!--
##WEBIF:name:Log:2:Syslog Settings
-->
