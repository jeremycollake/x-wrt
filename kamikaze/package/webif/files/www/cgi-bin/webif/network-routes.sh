#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

# header "Network" "Hosts"...

exists /tmp/.webif/file-routes  && ROUTES_FILE=/tmp/.webif/file-routes || ROUTES_FILE=/etc/routes
exists $ROUTES_FILE || touch $ROUTES_FILE >&- 2>&-

update_hosts() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	awk -v "mode=$1" -v "ip=$2" -v "name=$3" -v "gw=$4" '
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
	print $0 " " name " " gw
	host_added = 1
	processed = 1
}
processed == 0 {
	print $0
}
END {
	if ((mode == "add") && (host_added == 0)) print ip "	" name
}' "$ROUTES_FILE" > /tmp/.webif/file-routes-new
	mv "/tmp/.webif/file-routes-new" "/etc/routes"
	ROUTES_FILE=/etc/routes
}

empty "$FORM_add_host" || {
	# add a host to /etc/hosts
	validate <<EOF
ip|FORM_host_ip|@TR<<network_hosts_host_IP_invalid#Host's IP Address>>|required|$FORM_host_ip
hostname|FORM_host_name|@TR<<network_hosts_Host_Name#Host Name>>|required|$FORM_host_name
gateway|FORM_gw|@TR<<network_hosts_Host_Name#Gateway>>|required|$FORM_gw
EOF
	equal "$?" 0 && {
		update_hosts add "$FORM_host_ip" "$FORM_host_name" "$FORM_gw"
		unset FORM_host_ip FORM_host_name FORM_gw
	}
}

empty "$FORM_remove_host" || update_hosts del "$FORM_remove_ip" "$FORM_remove_name"

header "Network" "Routes" "@TR<<Configured Routes>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<network_hosts_Host_Names#Host Names>>
EOF

# Hosts in /etc/hosts
awk -v "url=$SCRIPT_NAME" \
	-v "ip=$FORM_host_ip" \
	-v "name=$FORM_host_name" \
	-v "gw=$FORM_gw" \
	-f /usr/lib/webif/common.awk \
	-f - $ROUTES_FILE <<EOF
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
	print "	<tr>\\n		<td>" textinput("host_ip", ip) "</td>\\n		<td>" textinput("host_name", name) "</td>\\n  <td>" textinput("gateway", gw) "</td>\\n		<td style=\\"width: 10em\\">" button("add_host", "network_hosts_Add#Add") "</td>\\n	</tr>"
}
EOF

display_form <<EOF
helpitem|network_hosts_Host_Names#Host Names
helptext|network_hosts_Host_Names_helptext#The file /etc/hosts is used to look up the IP address of a device connected to a computer network. The hosts file describes a many-to-one mapping of device names to IP addresses. When accessing a device by name, the networking system attempts to locate the name within the hosts file before accessing the Internet domain name system.
end_form

EOF
?>
<hr class="separator" />
<h5><strong>@TR<<network_routes_routing_table#Kernel Routing Table>></strong></h5>

<table style="text-align: left;" border="0" cellpadding="2" cellspacing="20">
        <tr>
                <th>@TR<<Destination>></th>
                <th>@TR<<Gateway>></th>
                <th>@TR<<Flags>></th>
                <th>@TR<<Interface>></th>
        </tr>
<?
        route -n | awk 'NR > 2 {print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $4 "</td><td>" $8 "</td></tr>"}'
?>
<tr><td><br /><br /></td></tr>
</table>
                                                                                

<? footer ?>
<!--
##WEBIF:name:Network:500:Routes
-->
