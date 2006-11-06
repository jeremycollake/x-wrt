#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "QoS" "@TR<<Quality of Service Statistics>>"
###################################################################
# TCP/IP status page
#
# Description:
#	Shows connections to the router, netstat stuff, routing table..
#
# Author(s) [in order of work date]:
#	Original webif developers
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	todo
#
# Configuration files referenced:
#		none
#

# todo: don't do these statically..
root_class="1:"
parent_class="1:1"
priority_class="1:10"
express_class="1:20"
normal_class="1:30"
bulk_class="1:40"

qos_status=$(qos-stat)
ingress_start_line=$(echo "$qos_status" | grep INGRESS -n | cut -d ':' -f 1)
egress_status=$(echo "$qos_status" | sed "$ingress_start_line,\$ d")
ingress_status=$(echo "$qos_status" | sed "1,$ingress_start_line d")

ingress_stats_table=$(echo "$ingress_status" | 
	(awk \
		-v root_class="$root_class" \
		-v parent_class="$parent_class" \
		-v priority_class="$priority_class" \
		-v express_class="$express_class" \
		-v normal_class="$normal_class" \
		-v bulk_class="$bulk_class" \
		'/class/ {
			if ($3 != root_class && $3 != parent_class) {
				if ($3 == priority_class) {
					class="Priority"
				} else if ($3 == express_class) {
					class="Express"
				} else if ($3 == normal_class) {
					class="Normal"
				} else if ($3 == bulk_class) {
					class="Bulk"
				} else {
					class="Unknown" $3
				}										
				getline;
				sent_bytes=$2;
				sent_packets=$4;
				print "<tr><td>" class "</td><td>" sent_packets "</td><td>" sent_bytes "</td></tr>";
			}
		}'))

display_form <<EOF
start_form|@TR<<Incoming Traffic>>
EOF

echo "<table cellspacing=\"10\" cellpadding=\"10\">
	<tbody>	
	<tr><th>@TR<<Class>></th><th>@TR<<Packets>></th><th>@TR<<Bytes>></th></tr>
	$ingress_stats_table</tbody></table>"

display_form <<EOF
end_form
EOF



egress_stats_table=$(echo "$egress_status" | 
	(awk \
		-v root_class="$root_class" \
		-v parent_class="$parent_class" \
		-v priority_class="$priority_class" \
		-v express_class="$express_class" \
		-v normal_class="$normal_class" \
		-v bulk_class="$bulk_class" \
		'/class/ {
			if ($3 != root_class && $3 != parent_class) {
				if ($3 == priority_class) {
					class="Priority"
				} else if ($3 == express_class) {
					class="Express"
				} else if ($3 == normal_class) {
					class="Normal"
				} else if ($3 == bulk_class) {
					class="Bulk"
				} else {
					class="Unknown" $3
				}										
				getline;
				sent_bytes=$2;
				sent_packets=$4;
				print "<tr><td>" class "</td><td>" sent_packets "</td><td>" sent_bytes "</td></tr>";
			}
		}'))

display_form <<EOF
start_form|@TR<<Outgoing Traffic>>
EOF

echo "<table cellspacing=\"10\" cellpadding=\"10\">
	<tbody>	
	<tr><th>@TR<<Class>></th><th>@TR<<Packets>></th><th>@TR<<Bytes>></th></tr>
	$egress_stats_table</tbody></table>"

display_form <<EOF
end_form
EOF

?>
<br />
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
	<tr>
		<th>@TR<<QoS Packets | Raw Stats>></th>
	</tr>
	<tr>
		<td>
<?
	if [ -f "/etc/config/qos" ] || [ -f "/etc/qos.conf" ]; then
		echo "<br /><div class=\"smalltext\"><pre>"
		qos-stat
		echo "</pre></div>"
	else
		echo "Compatible QOS package was not found to be installed. Try nbd's or Rudy's QOS scripts."
	fi
?></td>
	</tr>
	<tr><td><br /><br /></td></tr>

</tbody>
</table>

<br />
<?
show_validated_logo
footer ?>
<!--
##WEBIF:name:Status:425:QoS
-->
