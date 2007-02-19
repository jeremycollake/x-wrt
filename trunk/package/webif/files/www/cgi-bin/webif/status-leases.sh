#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "DHCP Clients" "@TR<<DHCP Leases>>"
?>
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
	<tr>
		<th>@TR<<MAC Address>></th>
		<th>@TR<<IP Address>></th>
		<th>@TR<<Name>></th>
		<th>@TR<<Expires in>></th>
	</tr>
<? exists /tmp/dhcp.leases && awk -vdate="$(date +%s)" '
$1 > 0 {
	print "<tr>"
	print "<td>" $2 "</td>"
	print "<td>" $3 "</td>"
	print "<td>" $4 "</td>"
	print "<td>"
	t = $1 - date
	h = int(t / 60 / 60)
	if (h > 0) printf h "h "
	m = int(t / 60 % 60)
	if (m > 0) printf m "min "
	s = int(t % 60)
	printf s "sec "
	printf "</td>"
	print "</tr>"
}
' /tmp/dhcp.leases
exists /tmp/dhcp.leases && grep -q "." /tmp/dhcp.leases > /dev/null
! equal "$?" "0" &&
{
	echo "<tr><td>@TR<<There are no known DHCP leases.>></td></tr>"
}
?>
</tbody></table>
<br />
<table width="100%"><tbody>
<tr><td><font size="-1"><strong>@TR<<DHCP Leases>>:</strong>&nbsp; @TR<<HelpText DHCP Leases#DHCP leases are assigned to network clients that request an IP address from the DHCP server of the router. Clients that requested their IP lease before this router was last rebooted may not be listed until they request a renewal of their lease.>></font></td></tr>
</tbody>
</table>

<h2>@TR<<Address Resolution Protocol Cache (ARP)>></h2>
<table style="width: 90%; text-align: left;" border="0" cellpadding="4" cellspacing="4" align="center">
<tbody>
	<tr>
		<th>@TR<<MAC Address>></th>
		<th>@TR<<IP Address>></th>
		<th>@TR<<HW Type>></th>
		<th>@TR<<Flags>></th>
		<th>@TR<<Mask>></th>
	</tr>
<? cat /proc/net/arp | awk '
BEGIN {
	cntr=0
}
$1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/ && $4 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/ && $6 == "br0" {
	print "<tr>"
	print "<td>" $4 "</td>"
	print "<td>" $1 "</td>"
	print "<td>" $2 "</td>"
	print "<td>" $3 "</td>"
	print "<td>" $5 "</td>"
	print "</tr>"
	cntr++
}
END {
	if (cntr == 0)
	print "<tr><td>@TR<<ARP Cache does not contain any correspondent record.>></td></tr>"
}
'
# should we decode these fields?
#Flags
#0x02 Completed
#0x04 Permanent
#0x08 Published
#
#HW type
#NETROM   0
#ETHER    1
#EETHER   2
#AX25     3
#PRONET   4
#CHAOS    5
#IEEE802  6
#ARCNET   7
#APPLETLK 8
#DLCI     15
#ATM      19
#METRICOM 23
#IEEE1394 24
#EUI64    27
#INFINIBAND       32
?>
</tbody></table>

<h2>@TR<<Ethernet Address to IP Number Database (/etc/ethers)>></h2>
<table style="width: 90%; text-align: left;" border="0" cellpadding="4" cellspacing="4" align="center">
<tbody>
	<tr>
		<th>@TR<<MAC Address>></th>
		<th>@TR<<IP Address>></th>
	</tr>
<? exists /etc/ethers && awk '
BEGIN {
	cntr=0
}
(($1 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/) && ($2 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/)) {
	print "<tr>"
	print "<td>" $1 "</td>"
	print "<td>" $2 "</td>"
	print "</tr>"
	cntr++
}
END {
	if (cntr == 0)
	print "<tr><td>@TR<<File /etc/ethers does not contain any Ethernet address/IP address pair.>></td></tr>"
}
' /etc/ethers
! exists /etc/ethers && {
	echo "<tr><td>@TR<<File /etc/ethers does not exist.>></td></tr>"
}
?>
</tbody></table>

<? footer ?>
<!--
##WEBIF:name:Status:200:DHCP Clients
-->
