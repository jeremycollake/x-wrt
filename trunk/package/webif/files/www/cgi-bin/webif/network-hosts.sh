#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Network" "Hosts" "@TR<<Configured Hosts>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|
EOF

exists /tmp/.webif/file-hosts  && HOSTS_FILE=/tmp/.webif/file-hosts || HOSTS_FILE=/etc/hosts
exists /tmp/.webif/file-ethers  && ETHERS_FILE=/tmp/.webif/file-ethers || ETHERS_FILE=/etc/ethers
exists $HOSTS_FILE || touch $HOSTS_FILE >&- 2>&-
exists $ETHERS_FILE || touch $ETHERS_FILE >&- 2>&-

update_hosts() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	awk -v "mode=$1" -v "ip=$2" -v "name=$3" '
BEGIN {
	FS="[ \t]"
	host_added = 0
}
{ processed = 0 }
(mode == "del") && (ip == $1) {
	names_found = 0
	n = split($0, names, "[ \t]")
	output = $1 "	"
	for (i = 2; i <= n; i++) {
		if ((names[i] != "") && (names[i] != name)) {
			output = output names[i] " "
			names_found++
		}
	}
	if (names_found > 0) print output
	processed = 1
}
(mode == "add") && (ip == $1) {
	print $0 " " name
	host_added = 1
	processed = 1
}
processed == 0 {
	print $0
}
END {
	if ((mode == "add") && (host_added == 0)) print ip "	" name
}' "$HOSTS_FILE" > /tmp/.webif/file-hosts-new
	mv "/tmp/.webif/file-hosts-new" "/tmp/.webif/file-hosts"
	HOSTS_FILE=/tmp/.webif/file-hosts
}

update_ethers() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	case "$1" in
		add)
			grep -E -v "^[ \t]*$2" $ETHERS_FILE > /tmp/.webif/file-ethers-new
			echo "$2	$3" >> /tmp/.webif/file-ethers-new
			mv /tmp/.webif/file-ethers-new  /tmp/.webif/file-ethers
		;;
		del)
			grep -E -v "^[ \t]*$2" $ETHERS_FILE > /tmp/.webif/file-ethers-new
			mv /tmp/.webif/file-ethers-new  /tmp/.webif/file-ethers
		;;
	esac
	ETHERS_FILE=/tmp/.webif/file-ethers
}

empty "$FORM_add_host" || {
	# add a host to /etc/hosts
	validate <<EOF
ip|FORM_host_ip|@TR<<IP Address>>|required|$FORM_host_ip
hostname|FORM_host_name|@TR<<Host Name>>|required|$FORM_host_name
EOF
	equal "$?" 0 && update_hosts add "$FORM_host_ip" "$FORM_host_name"
}
empty "$FORM_add_dhcp" || {
	# add a host to /etc/ethers
	validate <<EOF
mac|FORM_dhcp_mac|@TR<<MAC Address>>|required|$FORM_dhcp_mac
ip|FORM_dhcp_ip|@TR<<IP Address>>|required|$FORM_dhcp_ip
EOF
	equal "$?" 0 && update_ethers add "$FORM_dhcp_mac" "$FORM_dhcp_ip"
}

empty "$FORM_remove_host" || update_hosts del "$FORM_remove_ip" "$FORM_remove_name"
empty "$FORM_remove_dhcp" || update_ethers del "$FORM_remove_mac"

?>

<?

# Hosts in /etc/hosts
awk -v "url=$SCRIPT_NAME" \
	-v "ip=$FORM_host_ip" \
	-v "name=$FORM_host_name" \
	-f /usr/lib/webif/common.awk \
	-f - $HOSTS_FILE <<EOF
BEGIN {
	FS="[ \t]"
	print "<div class=\"settings-title\"><h3>@TR<<Host Names>></h3></div>"
	print "<table style=\"text-align: left;\" border=\"0\" cellpadding=\"4\" cellspacing=\"4\" >"
	print "<tr><th>@TR<<IP Address>></th><th>@TR<<Host Name>></th><th></th></tr>"
	print "<tr><td colspan=\"3\"><hr class=\"separator\" /></td></tr>"
}

# only for valid IPv4 addresses
(\$1 ~ /^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/) {
	gsub(/#.*$/, "");
	output = ""
	names_found = 0
	n = split(\$0, names, "[ \\t]")
	first = 1
	for (i = 2; i <= n; i++) {
		if (names[i] != "") {
			if (first != 1) output = output "<tr>"
			output = output "<td>" names[i] "</td><td align=\\"right\\" width=\\"10%\\"><a href=\\"" url "?remove_host=1&amp;remove_ip=" \$1 "&amp;remove_name=" names[i] "\\">@TR<<Remove>></a></td></tr>"
			first = 0
			names_found++
		}
	}
	if (names_found > 0) {
		print "<tr><td rowspan=\\"" names_found "\\">" \$1 "</td>" output
		print "<tr><td colspan=\\"3\\"><hr class=\\"separator\\" /></td></tr>"
	}
}

END {
	print "<tr><td>" textinput("host_ip", ip) "</td><td>" textinput("host_name", name) "</td><td style=\\"width: 10em\\">" button("add_host", "Add") "</td></tr>"
	print "<tr><td><br /><br /></td></tr>"
	print "</table>"
}
EOF

# Static DHCP mappings (/etc/ethers)
awk -v "url=$SCRIPT_NAME" \
	-v "mac=$FORM_dhcp_mac" \
	-v "ip=$FORM_dhcp_ip" -f /usr/lib/webif/common.awk -f - $ETHERS_FILE <<EOF

BEGIN {
	FS="[ \\t]"
	print "<div class=\"settings-title\"><h3 style=\"text-align: left;\">@TR<<DHCP Static|Static IP addresses (for DHCP)>></h3></div>"
	print "<table style=\"text-align: left;\" border=\"0\" cellpadding=\"4\" cellspacing=\"4\">"
	print "<tr><th>@TR<<MAC Address>></th><th>@TR<<IP Address>></th><th></th></tr>"
}

# only for valid MAC addresses
(\$1 ~ /^[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]$/) {
	gsub(/#.*$/, "");
	print "<tr><td>" \$1 "</td><td>" \$2 "</td><td align=\\"right\\" width=\\"10%\\"><a href=\\"" url "?remove_dhcp=1&remove_mac=" \$1 "\\">@TR<<Remove>></a></td></tr>"
}

END {
	print "<tr><td>" textinput("dhcp_mac", mac) "</td><td>" textinput("dhcp_ip", ip) "</td><td style=\\"width: 10em\\">" button("add_dhcp", "Add") "</td></tr>"
	print "<tr><td><br /><br /></td></tr>"
	print "</table>"
}
EOF

?>
<table style="text-align: left;" border="0" cellpadding="2" cellspacing="20">
<th style="text-align: left;">@TR<<Active DHCP Leases>></th>
	<tr>
		<th>@TR<<MAC Address>></th>
		<th>@TR<<IP Address>></th>
		<th>@TR<<Name>></th>
		<th>@TR<<Expires in>></th>
	</tr>
<?
exists /tmp/dhcp.leases && awk -vdate="$(date +%s)" '
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
exists /tmp/dhcp.leases && grep -q "." /tmp/dhcp.leases
! equal "$?" "0" &&
{
	echo "<tr><td>There are no known DHCP leases.</td></tr>"
}
?>
<tr><td><br /><br /></td></tr>
</table>
<?
display_form <<EOF
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:500:Hosts
-->
