#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Netfilter status page
#
# Description:
#	Shows iptables' rules.
#
# Author(s) [in order of work date]:
#	Original webif developers
#	Lubos Stanek <lubek@users.berlios.de>
#
# Major revisions:
#
# NVRAM variables referenced:
#	none
#
# Configuration files referenced:
#	none
#

header "Status" "Iptables" "@TR<<status_iptables_IPTStatus#Iptables status>>"

?>
<div class="settings">
<table style="width: 96%; text-align: left; font-size: 0.8em;" border="0" cellpadding="3" cellspacing="3" align="center">
<tbody>
<?
parse_target() {
	equal "$1" "" && return
	equal "$2" "" && return

	echo "$1" | awk -v "heading=$2" '
	BEGIN {
		print "	<tr>"
		print "		<th colspan=\"11\"><h3>" heading "</h3></th>"
		print "	</tr>"
		rulecntr=-1
	}
	function blankline()
	{
		print "	<tr>"
		print "		<td colspan=\"11\"><br /></td>"
		print "	</tr>"
	}
	/^(#.*)?$/ {next}
	$1 == "Chain" {
		if (rulecntr >= 0 ) blankline()
		print "	<tr>"
		print "		<td colspan=\"11\"><h4>" $0 "</h4></td>"
		print "	</tr>"
	}
	$1 == "num" {
		print "	<tr>"
		for (i=1; i<=10; i++)
			printf "%s%02d%s%s%s\n", "		<th>@TR<<status_iptables_col", i, "#", $i, ">></th>"
		print "		<th>@TR<<status_iptables_col_options#options>></th>"
		print "	</tr>"
		rulecntr=0
		odd=1
	}
	$1 ~ /[[:digit:]]{1,4}/ {
		if (odd == 1) {
			print "	<tr>"
			odd--
		} else {
			print "	<tr class=\"odd\">"
			odd++
		}
		print "		<td align=\"right\">" $1 "</td>"
		print "		<td align=\"right\">" $2 "</td>"
		print "		<td align=\"right\">" $3 "</td>"
		print "		<td>" $4 "</td>"
		print "		<td>" $5 "</td>"
		print "		<td>" $6 "</td>"
		print "		<td>" $7 "</td>"
		print "		<td>" $8 "</td>"
		print "		<td>" $9 "</td>"
		print "		<td>" $10 "</td>"
		lastjoin=$11
		for (i=12; i <= NF; i++)
			lastjoin = lastjoin " " $i
		print "		<td>" lastjoin "</td>"
		print "	</tr>"
		rulecntr++
	}
	END {
		blankline()
	}'
}

parse_target "$(iptables -L -nv --line-numbers -t filter 2>/dev/null)" "@TR<<status_iptables_Target_Filter#Target Filter>>"
parse_target "$(iptables -L -nv --line-numbers -t nat 2>/dev/null)" "@TR<<status_iptables_Target_NAT#Target NAT>>"
parse_target "$(iptables -L -nv --line-numbers -t mangle 2>/dev/null)" "@TR<<status_iptables_Target_Mangle#Target Mangle>>"
parse_target "$(iptables -L -nv --line-numbers -t raw 2>/dev/null)" "@TR<<status_iptables_Target_Raw#Target Raw>>"
?>
</tbody>
</table>
<div class="clearfix">&nbsp;</div></div>
<br />

<? footer ?>
<!--
##WEBIF:name:Status:410:Iptables
-->
