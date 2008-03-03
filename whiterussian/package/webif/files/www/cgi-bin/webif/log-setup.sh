#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
[ -f /etc/syslog.default ] && . /etc/syslog.default

load_settings log

if empty "$FORM_submit" ; then
	FORM_ipaddr="${log_ipaddr:-$(nvram get log_ipaddr)}"
	FORM_ipaddr="${FORM_ipaddr:-$DEFAULT_log_ipaddr}"
	empty "$FORM_ipaddr" && FORM_ipaddr=""
	FORM_port="${log_port:-$(nvram get log_port)}"
	FORM_port="${FORM_port:-$DEFAULT_log_port}"
	empty "$FORM_port" && FORM_port=""
	#FORM_mark="${log_mark:-$(nvram get log_mark)}"
	#FORM_mark="${FORM_mark:-$DEFAULT_log_mark}"
	FORM_mark="0"
	FORM_type="${log_type:-$(nvram get log_type)}"
	FORM_type="${FORM_type:-$DEFAULT_log_type}"
	FORM_file="${log_file:-$(nvram get log_file)}"
	FORM_file="${FORM_file:-$DEFAULT_log_file}"
	FORM_size="${log_size:-$(nvram get log_size)}"
	FORM_size="${FORM_size:-$DEFAULT_log_size}"
	FORM_conloglevel="${klog_conloglevel:-$(nvram get klog_conloglevel)}"
	FORM_conloglevel="${FORM_conloglevel:-$DEFAULT_klog_conloglevel}"
	FORM_buffersize="${klog_buffersize:-$(nvram get klog_buffersize)}"
	FORM_buffersize="${FORM_buffersize:-$DEFAULT_klog_buffersize}"
	FORM_enabled="${klog_enabled:-$(nvram get klog_enabled)}"
	FORM_enabled="${FORM_enabled:-$DEFAULT_klog_enabled}"
	FORM_kfile="${klog_file:-$(nvram get klog_file)}"
	FORM_kfile="${FORM_kfile:-$DEFAULT_klog_file}"
	FORM_gzip="${klog_gzip:-$(nvram get klog_gzip)}"
	FORM_gzip="${FORM_gzip:-$DEFAULT_klog_gzip}"
else
	SAVED=1
	[ "$FORM_type" = "file" ] && file_required="required"
	[ 1 -eq "$FORM_enabled" ] && kfile_required="required"
	validate <<EOF
ip|FORM_ipaddr|@TR<<Server IP Address>>||$FORM_ipaddr
int|FORM_port|@TR<<Server Port>>|min=0 max=65535|$FORM_port
int|FORM_mark|@TR<<Minutes Between Marks>>|min=0 max=0|$FORM_mark
string|FORM_type|@TR<<Log type>>|nospaces|$FORM_type
string|FORM_file|@TR<<Log File>>|$file_required|$FORM_file
int|FORM_size|@TR<<Log Size>>|min=1 max=9999 required|$FORM_size
int|FORM_conloglevel|@TR<<Messages Priority>>|min=0 max=9|$FORM_conloglevel
int|FORM_buffersize|@TR<<Ring Buffer Size>>|min=1 max=9999|$FORM_buffersize
int|FORM_enabled|@TR<<Backup Boot Time Messages>>||$FORM_enabled
string|FORM_kfile|@TR<<Backup File>>|$kfile_required|$FORM_kfile
int|FORM_gzip|@TR<<Compress Backup>>||$FORM_gzip
EOF
	equal "$?" 0 && {
		[ -z "$FORM_ipaddr" ] && FORM_port=""
		save_setting log log_ipaddr "$FORM_ipaddr"
		save_setting log log_port "$FORM_port"
		save_setting log log_mark "$FORM_mark"
		save_setting log log_type "$FORM_type"
		save_setting log log_file "$FORM_file"
		save_setting log log_size "$FORM_size"
		save_setting log klog_conloglevel "$FORM_conloglevel"
		save_setting log klog_buffersize "$FORM_buffersize"
		save_setting log klog_enabled "$FORM_enabled"
		save_setting log klog_file "$FORM_kfile"
		save_setting log klog_gzip "$FORM_gzip"
	}
fi

header "Log" "Log Settings" "@TR<<Log Settings>>" ' onload="modechange()" ' "$SCRIPT_NAME"

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
start_form|@TR<<Remote Syslog>>
field|@TR<<Server IP Address>>
text|ipaddr|$FORM_ipaddr
field|@TR<<Server Port>>
text|port|$FORM_port
helpitem|Remote Syslog
helptext|HelpText Remote Syslog#IP address and port of the remote logging host. Leave this address blank for no remote logging.
end_form

start_form|@TR<<Syslog Marks>>
field|@TR<<Minutes Between Marks>>
text|mark|$FORM_mark||readonly="readonly"
helpitem|Syslog Marks
helptext|HelpText Syslog Marks#Periodic marks in your log. This parameter sets the time in minutes between the marks. A value of 0 means no mark.
helptext|HelpText Syslog Marks_disabled#This feature is currently disabled to prevent system hangs with intensive logging. Use a cron job to reach the similar functionality.
end_form

start_form|@TR<<Local Log>>
onchange|modechange
field|@TR<<Log type>>
select|type|$FORM_type
option|circular|@TR<<Circular>>
option|file|@TR<<File>>
field|@TR<<Log File>>|logname|hidden
text|file|$FORM_file
field|@TR<<Log Size>>
text|size|$FORM_size|&nbsp;@TR<<KiB>>
helpitem|Log type
helptext|HelpText Log Type#Whether your log will be stored in a memory circular buffer or in a file. Beware that files are stored in a memory filesystem which will be lost if you reboot your router.
helpitem|Log File
helptext|HelpText Log File#The path and name of your log file. It can be set on any writable filesystem. CAUTION: DO NOT USE A JFFS filesystem because syslog will write A LOT to it. You can use /tmp or any filesystem on an external storage unit.
helpitem|Log Size
helptext|HelpText Log Size#The size of your log in kibibytes. Be carefull with the size of the circular buffer as it is taken from your main memory.
end_form

start_form|@TR<<Kernel Log>>
field|@TR<<Messages Priority>>
text|conloglevel|$FORM_conloglevel
field|@TR<<Ring Buffer Size>>
text|buffersize|$FORM_buffersize|&nbsp;@TR<<KiB>>
helpitem|Messages Priority
helptext|Messages Priority_helptext#Log messages up to the defined priority, the default priority level is 7 (debug).
helpitem|Ring Buffer Size
helptext|Ring Buffer Size_helptext#How much space will kernel reserve for messages in memory. The default size is 16 KiB.
end_form

start_form|@TR<<Boot Time Log>>
field|@TR<<Backup Boot Time Messages>>
checkbox|enabled|$FORM_enabled|1
field|@TR<<Backup File>>
text|kfile|$FORM_kfile
field|@TR<<Compress Backup>>
checkbox|gzip|$FORM_gzip|1
helpitem|Backup Boot Time Messages
helptext|Backup Boot Time Messages_helptext#The boot time messages will get overwritten by other events. You can save them for the later reference.
end_form
EOF

footer ?>

<!--
##WEBIF:name:Log:001:Log Settings
-->
