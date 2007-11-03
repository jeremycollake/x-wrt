#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

# header "Network" "Hosts"...

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
ip|FORM_host_ip|@TR<<network_hosts_host_IP_invalid#Host's IP Address>>|required|$FORM_host_ip
hostname|FORM_host_name|@TR<<network_hosts_Host_Name#Host Name>>|required|$FORM_host_name
EOF
	equal "$?" 0 && {
		update_hosts add "$FORM_host_ip" "$FORM_host_name"
		unset FORM_host_ip FORM_host_name
	}
}
empty "$FORM_add_dhcp" || {
	# add a host to /etc/ethers
	validate <<EOF
mac|FORM_dhcp_mac|@TR<<network_hosts_MAC#MAC Address>>|required|$FORM_dhcp_mac
ip|FORM_dhcp_ip|@TR<<network_hosts_static_IP_invalid#Static IP Address>>|required|$FORM_dhcp_ip
EOF
	equal "$?" 0 && {
		update_ethers add "$FORM_dhcp_mac" "$FORM_dhcp_ip"
		unset FORM_dhcp_mac FORM_dhcp_ip
	}
}

empty "$FORM_remove_host" || update_hosts del "$FORM_remove_ip" "$FORM_remove_name"
empty "$FORM_remove_dhcp" || update_ethers del "$FORM_remove_mac"

header "Network" "Hosts" "@TR<<network_hosts_Configured_Hosts#Configured Hosts>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<network_hosts_Host_Names#Host Names>>
EOF

# Hosts in /etc/hosts
awk -v "url=$SCRIPT_NAME" \
	-v "ip=$FORM_host_ip" \
	-v "name=$FORM_host_name" \
	-f /usr/lib/webif/common.awk \
	-f - $HOSTS_FILE <<EOF
BEGIN {
	FS="[ \t]"
	odd=1
	print "	<tr>\n		<th>@TR<<network_hosts_IP#IP Address>></th>\n		<th>@TR<<network_hosts_Host_Name#Host Name>></th>\n		<th></th>\n	</tr>"
}
# only for valid IPv4 addresses
(\$1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/) {
	gsub(/#.*$/, "");
	output = ""
	names_found = 0
	n = split(\$0, names, "[ \\t]")
	first = 1
	for (i = 2; i <= n; i++) {
		if (names[i] != "") {
			if (first != 1) {
				if (odd == 1)
					output = output "\\n	<tr>\\n"
				else
					output = output "\\n	<tr class=\\"odd\\">\\n"
			}
			output = output "		<td>" names[i] "</td>\\n		<td align=\\"right\\" width=\\"10%\\"><a href=\\"" url "?remove_host=1&amp;remove_ip=" \$1 "&amp;remove_name=" names[i] "\\">@TR<<network_hosts_Remove#Remove>></a></td>\\n	</tr>"
			first = 0
			names_found++
		}
	}
	if (names_found > 0) {
		if (odd == 1) {
			print "	<tr>"
			odd--
		} else {
			print "	<tr class=\\"odd\\">"
			odd++
		}
		print "		<td rowspan=\\"" names_found "\\">" \$1 "</td>\\n" output
		print "	<tr>\\n		<td colspan=\\"3\\"><hr class=\\"separator\\" /></td>\\n	</tr>"
	}
}
END {
	print "	<tr>\\n		<td>" textinput("host_ip", ip) "</td>\\n		<td>" textinput("host_name", name) "</td>\\n		<td style=\\"width: 10em\\">" button("add_host", "network_hosts_Add#Add") "</td>\\n	</tr>"
}
EOF

display_form <<EOF
helpitem|network_hosts_Host_Names#Host Names
helptext|network_hosts_Host_Names_helptext#The file /etc/hosts is used to look up the IP address of a device connected to a computer network. The hosts file describes a many-to-one mapping of device names to IP addresses. When accessing a device by name, the networking system attempts to locate the name within the hosts file before accessing the Internet domain name system.
end_form

start_form|@TR<<network_hosts_DHCP_Static_IPs#Static IP addresses (for DHCP)>>
EOF

# Static DHCP mappings (/etc/ethers)
awk -v "url=$SCRIPT_NAME" \
	-v "mac=$FORM_dhcp_mac" \
	-v "ip=$FORM_dhcp_ip" -f /usr/lib/webif/common.awk -f - $ETHERS_FILE <<EOF

BEGIN {
	FS="[ \\t]"
	odd=1
	print "	<tr>\\n		<th>@TR<<network_hosts_MAC#MAC Address>></th>\\n		<th>@TR<<network_hosts_IP#IP Address>></th>\\n		<th></th>\\n	</tr>"
}
# only for valid MAC addresses
(\$1 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/) {
	gsub(/#.*$/, "");
	if (odd == 1) {
		print "	<tr>"
		odd--
	} else {
		print "	<tr class=\"odd\">"
		odd++
	}
	print "		<td>" \$1 "</td>"
	print "		<td>" \$2 "</td>"
	print "		<td align=\\"right\\" width=\\"10%\\"><a href=\\"" url "?remove_dhcp=1&amp;remove_mac=" \$1 "\\">@TR<<network_hosts_Remove#Remove>></a></td>"
	print "	</tr>"
	print "	<tr>"
	print "		<td colspan=\\"3\\"><hr class=\\"separator\\" /></td>"
	print "	</tr>"
}
END {
	print "	<tr>\\n		<td>" textinput("dhcp_mac", mac) "</td>\\n		<td>" textinput("dhcp_ip", ip) "</td>\\n		<td style=\\"width: 10em\\">" button("add_dhcp", "network_hosts_Add#Add") "</td>\\n	</tr>"
}
EOF

display_form <<EOF
helpitem|network_hosts_Static_IPs#Static IP addresses
helptext|network_hosts_Static_IPs_helptext#The file /etc/ethers contains database information regarding known 48-bit ethernet addresses of hosts on an Internetwork. The DHCP server uses the matching IP address instead of allocating a new one from the pool for any MAC address listed in this file.
end_form
EOF

?>
<hr class="separator" />
<h5><strong>@TR<<network_hosts_Active_Leases#Active DHCP Leases>></strong></h5>
<table style="width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;" border="0" cellpadding="3" cellspacing="2">
<tr>
	<th>@TR<<network_hosts_MAC#MAC Address>></th>
	<th>@TR<<network_hosts_IP#IP Address>></th>
	<th>@TR<<network_hosts_Name#Name>></th>
	<th>@TR<<network_hosts_Expires#Expires in>></th>
</tr>
<?
cat /tmp/dhcp.leases 2>/dev/null | awk -v date="$(date +%s)" '
BEGIN {
	odd=1
	counter = 0
}
$1 > 0 {
	counter++
	if (odd == 1)
	{
		print "	<tr>"
		odd--
	} else {
		print "	<tr class=\"odd\">"
		odd++
	}
	print "		<td>" $2 "</td>"
	print "		<td>" $3 "</td>"
	print "		<td>" $4 "</td>"
	print "		<td>"
	t = $1 - date
	h = int(t / 60 / 60)
	if (h > 0) printf h "@TR<<network_hosts_h#h>> "
	m = int(t / 60 % 60)
	if (m > 0) printf m "@TR<<network_hosts_min#min>> "
	s = int(t % 60)
	printf s "@TR<<network_hosts_sec#sec>> "
	print "		</td>"
	print "	</tr>"
}
END {
	if (counter == 0) {
		print "	<tr>"
		print "		<td colspan=\"4\">@TR<<network_hosts_No_leases#There are no known DHCP leases.>></td>"
		print "	</tr>"
	}
}'
?>
</table>
<hr class="separator" />
<h5><strong>@TR<<status_leases_arp_title#Address Resolution Protocol Cache (ARP)>></strong></h5>
<table style="width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;" border="0" cellpadding="3" cellspacing="2">
<tbody>
	<tr>
		<th>@TR<<status_leases_MAC#MAC Address>></th>
		<th>@TR<<status_leases_IP#IP Address>></th>
		<th>@TR<<status_leases_HW#HW Type>></th>
		<th>@TR<<status_leases_Flags#Flags>></th>
		<th>@TR<<status_leases_Mask#Mask>></th>
	</tr>
<?
excludeiface=$(nvram get wan_ifname)
cat /proc/net/arp 2>/dev/null | awk -v "exiface=$excludeiface" '
BEGIN {
	cntr=0
}
$1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/ && $4 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/ && $6 != exiface {
	print "		<tr>"
	print "		<td>" $4 "</td>"
	print "		<td>" $1 "</td>"
	if ($2 == "0x0") flags="NETROM"
	else if ($2 == "0x1") hwtype="ETHER"
	else if ($2 == "0x2") hwtype="EETHER"
	else if ($2 == "0x3") hwtype="AX25"
	else if ($2 == "0x4") hwtype="PRONET"
	else if ($2 == "0x5") hwtype="CHAOS"
	else if ($2 == "0x6") hwtype="IEEE802"
	else if ($2 == "0x7") hwtype="ARCNET"
	else if ($2 == "0x8") hwtype="APPLETLK"
	else if ($2 == "0xF") hwtype="DLCI"
	else if ($2 == "0x13") hwtype="ATM"
	else if ($2 == "0x17") hwtype="METRICOM"
	else if ($2 == "0x18") hwtype="IEEE1394"
	else if ($2 == "0x1B") hwtype="EUI64"
	else if ($2 == "0x20") hwtype="INFINIBAND"
	else hwtype=$2
	print "		<td>" hwtype "</td>"
	if ($3 == "0x2") flags="C (@TR<<status_leases_completed#completed>>)"
	else if ($3 == "0x4") flags="M (@TR<<status_leases_permanent#permanent>>)"
	else if ($3 == "0x8") flags="P (@TR<<status_leases_published#published>>)"
	else flags=$3
	print "		<td>" flags "</td>"
	print "		<td>" $5 "</td>"
	print "	</tr>"
	cntr++
}
END {
	if (cntr == 0) {
		print "	<tr>"
		print "		<td>@TR<<status_leases_no_arp_record#ARP Cache does not contain any correspondent record.>></td>"
		print "	</tr>"
	}
}'
?>
</tbody>
</table>
<br />
<? footer ?>
<!--
##WEBIF:name:Network:500:Hosts
-->
