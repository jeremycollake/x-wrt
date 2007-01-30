#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/runsyslogd.conf

uci_load "syslogd"

if empty "$FORM_submit" ; then
	FORM_size="$CONFIG_general_size"
	FORM_size=${FORM_size:-$DEFAULT_log_size}
	FORM_type="$CONFIG_general_type"
	FORM_type=${FORM_type:-$DEFAULT_log_type}
	FORM_ipaddr="$CONFIG_general_ipaddr"
	if equal $FORM_ipaddr 0 ; then
		FORM_ipaddr=""
	fi
	FORM_log_port="$CONFIG_general_port"
	if empty "$FORM_ipaddr" ; then
		FORM_log_port=""
	fi
	FORM_log_mark="$CONFIG_general_mark"
	FORM_log_mark=${FORM_log_mark:-$DEFAULT_log_mark}
	FORM_filename="$CONFIG_general_file)}"
	FORM_filename=${FORM_filename:-$DEFAULT_log_file}
else
validate <<EOF
ip|FORM_ipaddr|@TR<<Remote host>>||$FORM_ipaddr
int|FORM_log_port|@TR<<Remote Port>>|min=0 max=65535|$FORM_log_port
int|FORM_log_mark|@TR<<Minutes Between Marks>>||$FORM_log_mark
int|FORM_size|@TR<<Log Size>>||$FORM_size
EOF
	
	if equal "$?" 0 ; then
		[ -z $FORM_ipaddr ] && FORM_log_port=""
		uci_set "syslogd" "general" "size" "$FORM_size"
		uci_set "syslogd" "general" "type" "$FORM_type"
		uci_set "syslogd" "general" "ipaddr" "$FORM_ipaddr"
		uci_set "syslogd" "general" "port" "$FORM_log_port"
		uci_set "syslogd" "general" "mark" "$FORM_log_mark"
		uci_set "syslogd" "general" "file" "$FORM_filename"
	fi
fi


header "Log" "Syslog Settings" "@TR<<syslog Settings>>"  ' onload="modechange()" ' "$SCRIPT_NAME"
ShowUntestedWarning

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
start_form|@TR<<Remote Syslog>>
field|@TR<<Server IP Address>>
text|ipaddr|$FORM_ipaddr
helpitem|@TR<<Remote Syslog>>
helptext|@TR<<Remote Syslog#IP address and port of the remote logging host. Leave this address blank for no remote logging. The port is set to $DEFAULT_log_port by default>>
field|@TR<<Server Port>>
text|log_port|$FORM_log_port
end_form

start_form|@TR<<Syslog Marks>>
field|@TR<<Minutes Between Marks>>
text|log_mark|$FORM_log_mark
helpitem|@TR<<Syslog Marks>>
helptext|@TR<<Syslog Marks#Periodic marks in your log. This parameter sets the time in minutes between the marks. A value of 0 means no mark. Default value: $DEFAULT_log_mark.>>
end_form

start_form|@TR<<Local Log>>
field|@TR<<Log type>>
select|type|$FORM_type
option|circular|@TR<<Circular>>
option|file|@TR<<File>>
helpitem|@TR<<Log Type>>
helptext|@TR<<Log Type#Wether your log will be stored in a memory circular buffer or in a file. Beware that files are stored in a memory filesystem wich will be lost if you reboot your router. Default value: $DEFAULT_log_type.>>
field|@TR<<Log File>>|logname|hidden
text|filename|$FORM_filename
helpitem|@TR<<Log File>>
helptext|@TR<<Log File#The path and name of your log file. It can be set on any writable filesystem. CAUTION: DO NOT USE A JFFS filesystem because syslog will write A LOT to it. You can use /tmp or any filesystem on an external storage unit. Default value: $DEFAULT_log_file.>>
field|@TR<<Log Size>>
text|size|$FORM_size
helpitem|@TR<<Log Size>>
helptext|@TR<<Log Size#The size of your log in kilo-bytes. Be carefull with the size of the circular buffer as it is taken from your main memory. Default value: $DEFAULT_log_size kB.>>
end_form
EOF


footer ?>

<!--
##WEBIF:name:Log:1:Syslog Settings
-->
