#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "Diagnostics" "@TR<<Diagnostics>>" '' "$SCRIPT_NAME"

diag_command_output=""
diag_command=""
please_wait_msg="@TR<<Please wait>> ...<br />"

! empty "$FORM_ping_button" && {
	echo "$please_wait_msg"
	sanitized=$(echo "$FORM_ping_hostname" | awk -f "/usr/lib/webif/sanitize.awk")	
	! empty "$sanitized" && {
		diag_command="ping -c 4 $sanitized"
		diag_command_output=$($diag_command)
	}
}

! empty "$FORM_tracert_button" && {
	echo "$please_wait_msg"
	sanitized=$(echo "$FORM_tracert_hostname" | awk -f "/usr/lib/webif/sanitize.awk")	
	! empty "$sanitized" && {
		diag_command="traceroute $sanitized"
		diag_command_output=$($diag_command)
	}
}

FORM_ping_hostname=${FORM_ping_hostname:-google.com}
FORM_tracert_hostname=${FORM_tracert_hostname:-google.com}

display_form <<EOF
start_form|@TR<<Network Diagnostics>>
field|
text|ping_hostname|$FORM_ping_hostname
submit|ping_button|@TR<<Ping>>
field|
text|tracert_hostname|$FORM_tracert_hostname
submit|tracert_button|@TR<<TraceRoute>>
end_form
EOF

! empty "$diag_command" && {
cat <<EOF
<br />Output of "$diag_command"<br /><br />
<pre>
$diag_command_output
</pre>
EOF
}

 footer ?>
<!--
##WEBIF:name:Status:990:Diagnostics
-->
