#!/usr/bin/webif-page
<? 
can_prefix=`syslogd --help 2>&1 | grep -e 'PREFIX' `

. /usr/lib/webif/webif.sh

load_settings "syslog"

[ -z $FORM_submit ] && {
	
    FORM_log_ipaddr=${log_ipaddr:-$(nvram get log_ipaddr)}
    FORM_log_port=${log_port:-$(nvram get log_port)}
    
    FORM_log_mark=${log_mark:-$(nvram get log_mark)}
    FORM_log_mark=${FORM_log_mark:-0}
    
    if [ -n "$can_prefix" ]; then
        FORM_log_prefix=${log_prefix:-$(nvram get log_prefix)}
    fi
    
} || {
	SAVED=1
    validate "
ip|FORM_log_ipaddr|Remote Server||$FORM_log_ipaddr
int|FORM_log_port|Remote Port|min=0 max=65535|$FORM_log_port
int|FORM_log_mark|Minutes Between Marks||$FORM_log_mark
" && {
        save_setting syslog log_ipaddr $FORM_log_ipaddr
        save_setting syslog log_port   $FORM_log_port
        save_setting syslog log_mark   $FORM_log_mark
     }
    
    if [ -n "$can_prefix" -a -z "$ERROR" ]; then
            validate "
string|FORM_log_prefix|Message Prefix||$FORM_log_prefix
" && {
        save_setting syslog log_prefix $FORM_log_prefix
      }
    fi
}

header "System" "Syslog" "@TR<<Syslog>>" ' onLoad="pageload()" ' "$SCRIPT_NAME" 

prefix_fields=""
if [ -n "$can_prefix" ]; then
    prefix_fields="field|Prefix
text|log_prefix|$FORM_log_prefix"
fi

display_form "start_form|Remote Syslog
field|Server IP Address
text|log_ipaddr|$FORM_log_ipaddr
field|Server Port
text|log_port|$FORM_log_port
end_form

start_form|Messages
field|Minutes Between Marks
text|log_mark|$FORM_log_mark
$prefix_fields
end_form"
?>

<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function pageload()
{	
 	/* don't do anything */
}
-->
</script>


<a href="logread.sh">View Syslog</a>

<? footer ?>
<!--
##WEBIF:name:System:125:Syslog
-->
