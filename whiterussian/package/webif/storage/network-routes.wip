#!/usr/bin/webif-page
<?
#
# Static routes page for X-WRT
# * still in-development
#
# Liran Tal <liran@enginx.com>
#           <liran.tal@gmail.com>

. /usr/lib/webif/webif.sh

header "Network" "Routes" "@TR<<Configured Routes>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|
EOF

exists /tmp/.webif/file-routes  && HOSTS_FILE=/tmp/.webif/file-routes || HOSTS_FILE=/etc/routes
exists $HOSTS_FILE || touch $HOSTS_FILE >&- 2>&-

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
	#equal "$?" 0 && update_hosts add "$FORM_host_ip" "$FORM_host_name"
}

empty "$FORM_remove_host" || update_hosts del "$FORM_remove_ip" "$FORM_remove_name"

?>

<?

# Routes in /etc/routes
awk -v "url=$SCRIPT_NAME" \
	-v "ip=$FORM_host_ip" \
	-v "name=$FORM_host_name" \
	-f /usr/lib/webif/common.awk \
	-f - $HOSTS_FILE <<EOF
BEGIN {
	FS="[ \t]"
	print "<div class=\"settings-title\"><h3>@TR<<Routes List>></h3></div>"
	print "<table style=\"text-align: left;\" border=\"0\" cellpadding=\"4\" cellspacing=\"4\" >"
	print "<tr><th>@TR<<IP Address>></th><th>@TR<<Netmask>></th><th>@TR<<Gateway>></th></tr>"
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
	print "<tr><td>" textinput("host_ip", ip) "</td><td>" textinput("host_name", name) "</td><td>" textinput("gateway", gw) "</td><td style=\\"width: 10em\\">" button("add_host", "Add") "</td></tr>"
	print "<tr><td><br /><br /></td></tr>"
	print "</table>"
}
EOF

?>
<table style="text-align: left;" border="0" cellpadding="2" cellspacing="20">
<th style="text-align: left;">@TR<<Kernel Routing Table>></th>
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
<?
display_form <<EOF
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:500:Routes
-->
