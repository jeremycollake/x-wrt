#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Routes page
#
# Description:
#	Route status page. It enables deleting the actual route.
#	Partial IPv6 support.
#
# Author(s) [in order of work date]:
#	Lubos Stanek <lubek@users.berlios.de>
#

for ifname in lan wan wifi $(nvram get ifnames 2>/dev/null ); do
	iface=$(nvram get ${ifname}_ifname 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
	[ -n "$iface" ] && ifaces="$ifaces $ifname:$iface"
done

DELETE_FLAG=0

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
table {
	text-align: left;
	margin: 0px;
	padding: 0px;
}
td, th {
	padding: 1px;
	vertical-align: center;
}
.rightcell {
	text-align: right;
}
-->
</style>
EOF
)

header "Status" "Routes" "@TR<<Routes>>"

[ -n "$FORM_final_remove" ] && {
	[ "$FORM_route_netmask" = "255.255.255.255" ] && {
		hostnet="-host"
		FORM_route_netmask="0.0.0.0"
	}
	echo "@TR<<network_routes_Deleting_route#Deleting the route>>...<pre>"
	echo "del ${hostnet:-"-net"} $FORM_route_target netmask $FORM_route_netmask gw $FORM_route_gateway metric $FORM_route_metric"
	route del ${hostnet:-"-net"} $FORM_route_target netmask $FORM_route_netmask gw $FORM_route_gateway metric $FORM_route_metric
	hostnet=$?
	echo "</pre>"
	[ "$hostnet" -eq 0 ] && echo "@TR<<network_routes_delete_Ok#OK>>." || echo "@TR<<network_routes_delete_Failed#Failed>>."
	echo "<br /><br />"
}

if [ -n "$FORM_deleteroute" ]; then
	DELETE_FLAG=1
	display_form <<EOF
formtag_begin|deletefinal|$SCRIPT_NAME
start_form|@TR<<network_routes_Delete_Route#Delete Route>>
field|@TR<<network_routes_edit_Target_IP#Target IP Address>>
text|route_target|$FORM_route_target||readonly="readonly"
field|@TR<<network_routes_edit_Gateway#Gateway>>
text|route_gateway|$FORM_route_gateway||readonly="readonly"
field|@TR<<network_routes_edit_Netmask#Netmask>>
text|route_netmask|$FORM_route_netmask||readonly="readonly"
field|@TR<<network_routes_edit_Metric#Metric>>
text|route_metric|$FORM_route_metric||readonly="readonly"
field|@TR<<network_routes_edit_Interface#Interface>>
text|route_interface|$FORM_route_interface||readonly="readonly"
field|<input type="submit" name="cancel" value="@TR<<network_routes_action_Cancel#Cancel>>" />
string|<input type="submit" name="final_remove" value="@TR<<network_routes_action_Delete#Delete>>" />
helpitem|network_routes_Delete_Route#Delete Route
helptext|network_routes_Delete_Route_helptext#You can delete the particular route from the kernel routing table when necessary. The route will be deleted imediatelly. You can restore static and default routes only by restarting the particular network interface.<br /><b>Warning!</b> You can lose access to your device by deleting the incorrect route.
end_form
formtag_end
EOF
fi

cat <<EOF
<div class="settings">
<h3><strong>@TR<<network_routes_routing_table#Kernel Routing Table>></strong></h3>
<table>
<tbody>
<tr>
	<th>@TR<<network_routes_static_th_Destination#Destination>></th>
	<th>@TR<<network_routes_static_th_Gateway#Gateway>></th>
	<th>@TR<<network_routes_static_th_Genmask#Genmask>></th>
	<th>@TR<<network_routes_static_th_Flags#Flags>></th>
	<th>@TR<<network_routes_static_th_Metric#Metric>></th>
	<th>@TR<<network_routes_static_th_Ref#Ref>></th>
	<th>@TR<<network_routes_static_th_Use#Use>></th>
	<th>@TR<<network_routes_static_th_Interface#Interface>></th>
EOF
[ "$DELETE_FLAG" != "1" ] && {
	cat <<EOF
	<th>@TR<<network_routes_static_th_Action#Action>></th>
EOF
}
echo "</tr>"

route -n | awk -v "ifaces=$ifaces"  -v "url=$SCRIPT_NAME" -v "_deleteflag=$DELETE_FLAG" '
BEGIN {
	nic = split(ifaces, pairs)
	for (i = 1; i <= nic; i++) {
		npt = split(pairs[i], parts, ":")
		if (npt > 1) _ifaceifs[parts[2]] = parts[1]
	}
	odd = 1
	count = 0
}
/^[[:digit:]]/ {
	if (odd == 1) {
		print "<tr>"
		odd--
	} else {
		print "<tr class=\"odd\">"
		odd++
	}
	for (i = 1; i <= NF; i++) {
		if (i == 8) {
			print "<td>" ((_ifaceifs[$(i)] == "") ? "@TR<<network_routes_unknown_iface#unknown>>" : _ifaceifs[$(i)]) " (" $(i) ")</td>"
		} else printf "<td>" $(i) "</td>"
	}
	# delete route form
	if (_deleteflag != 1) {
		printf "<td class=\"rightcell\">"
		printf "<form enctype=\"multipart/form-data\" name=\"deleteroute_" count "\" method=\"post\" action=\"" url "\">"
		printf "<input type=\"hidden\" name=\"route_target\" value=\""$1"\" />"
		printf "<input type=\"hidden\" name=\"route_netmask\" value=\""$3"\" />"
		printf "<input type=\"hidden\" name=\"route_gateway\" value=\""$2"\" />"
		printf "<input type=\"hidden\" name=\"route_metric\" value=\""$5"\" />"
		printf "<input type=\"hidden\" name=\"route_interface\" value=\""$8"\" />"
		printf "<input type=\"submit\" name=\"deleteroute\" value=\"@TR<<network_routes_action_Delete#Delete>>\" />"
		printf "</form>"
		print "</td>"
	}
	count++
	print "</tr>"
}
END {
	if (count == 0) print "<tr>\n" td_ind "<td colspan=\"" (_deleteflag != 1 ? 9 : 8) "\">@TR<<network_routes_No_kernel_routes#There are no IP routes in the kernel'\''s table?!>></td>\n</tr>"
}'
cat <<EOF
</tbody>
</table>
</div>
EOF

[ -f /proc/net/ipv6_route ] && {
	cat <<EOF
<div class="clearfix">&nbsp;</div>
<div class="settings">
<h3><strong>@TR<<network_routes_ipv6_routing_table#Kernel IPv6 Routing Table>></strong></h3>
<table>
<tbody>
<tr>
	<th>@TR<<network_routes_static_th_Destination#Destination>></th>
	<th>@TR<<network_routes_static_th_Next_Hop#Next Hop>></th>
	<th>@TR<<network_routes_static_th_Flags#Flags>></th>
	<th>@TR<<network_routes_static_th_Metric#Metric>></th>
	<th>@TR<<network_routes_static_th_Ref#Ref>></th>
	<th>@TR<<network_routes_static_th_Use#Use>></th>
	<th>@TR<<network_routes_static_th_Interface#Interface>></th>
EOF
#	[ "$DELETE_FLAG" != "1" ] && {
#		cat <<EOF
#	<th>@TR<<network_routes_static_th_Action#Action>></th>
#EOF
#	}
	echo "</tr>"
	route -n -A inet6 | awk -v "ifaces=$ifaces"  -v "url=$SCRIPT_NAME" -v "_deleteflag=$DELETE_FLAG" '
BEGIN {
	nic = split(ifaces, pairs)
	for (i = 1; i <= nic; i++) {
		npt = split(pairs[i], parts, ":")
		if (npt > 1) _ifaceifs[parts[2]] = parts[1]
	}
	odd = 1
	count = 0
}
($1 !~ /Kernel|Destination/) {
	if (odd == 1) {
		print "<tr>"
		odd--
	} else {
		print "<tr class=\"odd\">"
		odd++
	}
	for (i = 1; i <= NF; i++) {
		if (i == 7) {
			print "<td>" ((_ifaceifs[$(i)] == "") ? "@TR<<network_routes_unknown_iface#unknown>>" : _ifaceifs[$(i)]) " (" $(i) ")</td>"
		} else printf "<td>" $(i) "</td>"
	}
	# delete route form
	#if (_deleteflag != 1) {
	#	printf "<td class=\"rightcell\">"
	#	printf "<form enctype=\"multipart/form-data\" name=\"deleteroute6_" count "\" method=\"post\" action=\"" url "\">"
	#	printf "<input type=\"hidden\" name=\"route_target\" value=\""$1"\" />"
	#	printf "<input type=\"hidden\" name=\"route_metric\" value=\""$4"\" />"
	#	printf "<input type=\"hidden\" name=\"route_interface\" value=\""$7"\" />"
	#	printf "<input type=\"submit\" name=\"deleteroute6\" value=\"@TR<<network_routes_action_Delete#Delete>>\" />"
	#	printf "</form>"
	#	print "</td>"
	#}
	count++
	print "</tr>"
}
END {
	if (count == 0) print "<tr>\n" td_ind "<td colspan=\"" (_deleteflag != 1 ? 7 : 7) "\">@TR<<network_routes_No_kernel_routes#There are no IP routes in the kernel'\''s table?!>></td>\n</tr>"
}'
	cat <<EOF
</tbody>
</table>
</div>
EOF
}

footer ?>
<!--
##WEBIF:name:Status:155:Routes
-->
