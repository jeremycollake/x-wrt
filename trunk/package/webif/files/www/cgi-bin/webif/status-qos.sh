#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
.qostable table {
	margin-left: 2em;
	margin-right: 2em;
	border-style: none;
	border-spacing: 0;
	padding: 0.5em;
	padding-bottom: 1em;
}
.qostable th,
.qostable td {
	text-align: right;
	padding-top: 0.30em;
	padding-bottom: 0.30em;
	padding-left: 0.30em;
	padding-right: 0.30em;
}
.qostable th.text,
.qostable td.text {
	text-align: left;
}
.qosraw table {
	width: 90%;
	border-style: none;
	border-spacing: 0;
}
.qosraw th,
.qosraw td {
	text-align: left;
}
-->
</style>

EOF
)


header "Status" "QoS" "@TR<<Quality of Service Statistics>>"
###################################################################
# TCP/IP status page
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
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

uci_load "qos"
if equal "$CONFIG_wan_enabled" "1"; then

# todo: don't do these statically..
root_class="1:"
parent_class="1:1"
priority_class="1:10"
express_class="1:20"
normal_class="1:30"
bulk_class="1:40"

qos_status=$(qos-stat 2>&-)
if ! empty "$qos_status" && exists "/usr/bin/qos-stat"; then
ingress_start_line=$(echo "$qos_status" | grep INGRESS -n | cut -d ':' -f 1)
ingress_start_line=$(( $ingress_start_line - 2 )) 2>/dev/null
egress_status=$(echo "$qos_status" | sed "$ingress_start_line,\$ d")
ingress_status=$(echo "$qos_status" | sed "1,$ingress_start_line d")
ingress_stats_table=$(echo -e "$ingress_status\n" | 
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
				getline
				if (length($0) > 0) {
					print "<tr>"
					print "	<td class=\"text\">" class "</td>"
					print "	<td>" $4 "</td>"
					printf "	<td>%d</td>\n", $2
					if ($2 >= 2 ** 30) {
						printf "	<td>(%.1f @TR<<GiB>>)</td>\n", $2 / (2 ** 30)
					} else if ($2 >= 2 ** 20) {
						printf "	<td>(%.1f @TR<<MiB>>)</td>\n", $2 / (2 ** 20)
					} else if ($2 >= 2 ** 10) {
						printf "	<td>(%.1f @TR<<KiB>>)</td>\n", $2 / (2 ** 10)
					} else {
						print "	<td>&nbsp;</td>"
					}
					print "</tr>"
				}
			}
		}'))

cat <<EOF
<div class="settings">
<h3><strong>@TR<<Incoming Traffic>></strong></h3>
<div id="qostable1" class="qostable">
<table summary="@TR<<Incoming Traffic>>">
<tbody>
<tr>
	<th class="text">@TR<<Class>></th>
	<th>@TR<<Packets>></th>
	<th>@TR<<Bytes>></th>
	<th>&nbsp;</th>
</tr>
$ingress_stats_table
</tbody>
</table>
</div>
EOF


egress_stats_table=$(echo -e "$egress_status\n" | 
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
				getline
				if (length($0) > 0) {
					print "<tr>"
					print "	<td class=\"text\">" class "</td>"
					print "	<td>" $4 "</td>"
					printf "	<td>%d</td>\n", $2
					if ($2 >= 2 ** 30) {
						printf "	<td>(%.1f @TR<<GiB>>)</td>\n", $2 / (2 ** 30)
					} else if ($2 >= 2 ** 20) {
						printf "	<td>(%.1f @TR<<MiB>>)</td>\n", $2 / (2 ** 20)
					} else if ($2 >= 2 ** 10) {
						printf "	<td>(%.1f @TR<<KiB>>)</td>\n", $2 / (2 ** 10)
					} else {
						print "	<td>&nbsp;</td>"
					}
					print "</tr>"
				}
			}
		}'))

cat <<EOF
<h3><strong>@TR<<Outgoing Traffic>></strong></h3>
<div id="qostable2" class="qostable">
<table summary="@TR<<Outgoing Traffic>>">
<tbody>
<tr>
	<th class="text">@TR<<Class>></th>
	<th>@TR<<Packets>></th>
	<th>@TR<<Bytes>></th>
	<th>&nbsp;</th>
</tr>
$egress_stats_table
</tbody>
</table>
</div>
<div class="settings-content">
<table>
EOF

display_form <<EOF
field||spacer1
string|<br /><br />
field||show_raw
formtag_begin|raw_stats|$SCRIPT_NAME
submit|show_raw_stats| @TR<<&nbsp;Show raw statistics&nbsp;>>
formtag_end
end_form
EOF

#########################################
# raw stats
! empty "$FORM_show_raw_stats" && {
	echo "<br />"
	echo "<div id=\"qostable3\" class=\"qosraw\">"
	echo "<table>"
	echo "<tbody>"
	echo "<tr>"
	echo "	<th>@TR<<QoS Packets | Raw Stats>></th>"
	echo "</tr>"
	echo "<tr>"
	echo "	<td><br /><div class=\"smalltext\"><pre>"
	qos-stat
	echo "</pre></div></td>"
	echo "</tr>"
	echo "<tr>"
	echo "<td><br /></td>"
	echo "</tr>"
	echo "</tbody>"
	echo "</table>"
	echo "</div>"
}
else
#########################################
# no QoS Service
	echo "<br />@TR<<no_qos#No QoS Service found running so no parsed QoS statistics can be shown! We recommend to install nbd's QoS scripts.>><br />"	
fi
else	
	echo "@TR<<qos_scripts_disabled#The qos-scripts package is not active. Visit the <a href=\"./network-qos.sh\">QoS page</a> to install and/or enable it.>>"
fi

footer ?>
<!--
##WEBIF:name:Status:425:QoS
-->
