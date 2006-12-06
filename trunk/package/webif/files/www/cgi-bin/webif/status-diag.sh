#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Diagnostics
#
# Description:
#	Provide some diagnostic tools.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#  none
#
# Configuration files referenced:
#   none
#
header "Status" "Diagnostics" "@TR<<Diagnostics>>" '' "$SCRIPT_NAME"

OUTPUT_CHECK_DELAY=1  # secs in pseudo-tail check
diag_command_output=""
diag_command=""

FORM_ping_hostname=${FORM_ping_hostname:-google.com}
FORM_tracert_hostname=${FORM_tracert_hostname:-google.com}

display_form <<EOF
start_form|@TR<<Network Utilities>>
field|
text|ping_hostname|$FORM_ping_hostname
submit|ping_button|@TR<<Ping>>
field|
text|tracert_hostname|$FORM_tracert_hostname
submit|tracert_button|@TR<<TraceRoute>>
end_form
EOF

# determine if a process exists, by PID
does_process_exist() {
	# $1=PID
	ps | cut -c 1-6 | grep -q "$1 "
}

! empty "$FORM_ping_button" || ! empty "$FORM_tracert_button" && {
	! empty "$FORM_ping_button" && {		
		sanitized=$(echo "$FORM_ping_hostname" | awk -f "/usr/lib/webif/sanitize.awk")	
		! empty "$sanitized" && {
			diag_command="ping -c 4 $sanitized"		
		}
	}

	! empty "$FORM_tracert_button" && {
		echo "$please_wait_msg"
		sanitized=$(echo "$FORM_tracert_hostname" | awk -f "/usr/lib/webif/sanitize.awk")	
		! empty "$sanitized" && {
			diag_command="traceroute $sanitized"		
		}
	}

	#
	# every one second take a snapshot of the output file and output new lines since last snapshot.	
	# we force synchronization by stopping the outputting process while taking a snapshot
	# of its output file.
	#
	# TODO: Bug.. occasisionally lines can get skipped with this method, look into.
	#	
	echo "<br />@TR<<Please wait for output of>> \"$diag_command\" ...<br /><br />"
	tmpfile=$(mktemp /tmp/.webif-diag-XXXXXX)
	tmpfile2=$(mktemp /tmp/.webif-diag-XXXXXX)
	$diag_command 2>&1 > "$tmpfile" &
	ps_search=$(echo "$diag_command" | cut -c 1-15) # todo: limitation, X char match resolution
	_pid=$(ps | grep "$ps_search" | grep -v "grep" | cut -d ' ' -f 1 | sed 2,99d)	
	output_snapshot_file() {
		# output file
		# tmpfile2
		# PID		
		# stop process..	
		kill -23 $3 2>&- >&-
		exists "$1" && {
			linecount_1=$(cat "$1" | wc -l | tr -d ' ') # current snapshot size
			linecount_2=$(cat "$2" | wc -l | tr -d ' ') # last snapshot size
			cp "$1" "$2"
			let new_lines=$linecount_1-$linecount_2
			! equal "$new_lines" "0" && {
				echo "<pre>"
				tail -n $new_lines "$2"
				echo "</pre>"
			}
		}
		# continue process..	
		kill -25 $3 2>&- >&-
	}
	touch "$tmpfile2" # force to exist first iter
	while sleep $OUTPUT_CHECK_DELAY; do
		! does_process_exist "$_pid" && {
			break;
		}
		output_snapshot_file "$tmpfile" "$tmpfile2"
	done	
	output_snapshot_file "$tmpfile" "$tmpfile2"
	rm -f "$tmpfile2"	
	rm -f "$tmpfile"	
}

 footer ?>
<!--
##WEBIF:name:Status:990:Diagnostics
-->
