#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

exists "/tmp/.webif/file-routes" && ROUTES_FILE="/tmp/.webif/file-routes" || {
	ROUTES_FILE="/etc/routes"
	exists "$ROUTES_FILE" || touch "$ROUTES_FILE" >&- 2>&-
}

EDIT_FLAG=0

update_routes() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	[ "$ROUTES_FILE" = "/etc/routes" ] && {
		cp -f "$ROUTES_FILE" "/tmp/.webif/file-routes" 2>/dev/null
		ROUTES_FILE="/tmp/.webif/file-routes"
	}
	local temp_line
	! empty "$FORM_netmask" && temp_line="-net $FORM_ipaddr" || temp_line="-host $FORM_ipaddr"
	! empty "$FORM_netmask" && temp_line="$temp_line netmask $FORM_netmask"
	! empty "$FORM_gateway" && temp_line="$temp_line gw $FORM_gateway"
	! empty "$FORM_metric" && temp_line="$temp_line metric $FORM_metric"
	! empty "$FORM_interface" && temp_line="$temp_line dev $FORM_interface"
	! empty "$FORM_additional" && temp_line="$temp_line $FORM_additional"
	[ "$1" = "add" ] && {
		echo "$temp_line" >> "$ROUTES_FILE" 2>/dev/null
	}
	[ "$1" = "del" ] && {
		sed_line=$(echo "$temp_line" | sed 's/ /[[:space:]]/g; s/\./\\./')
		sed -e "/$sed_line/d" -i "$ROUTES_FILE" 2>/dev/null
	}
}

! empty "$FORM_action" && {
	#unsanitize
	! empty "$FORM_additional" && {
		FORM_additional=$(echo "$FORM_additional" | sed 's/%20/ /g')
	}
	equal "$FORM_action" "editroute" && {
		EDIT_FLAG=1
		update_routes del
	}
	equal "$FORM_action" "addroute" && {
		EDIT_FLAG=1
	}
	equal "$FORM_action" "removeroute" && {
		update_routes del
	}
}

! empty "$FORM_submit" && {
	validate <<EOF
ip|FORM_ipaddr|@TR<<network_routes_IP_Address#IP Address>>|required|$FORM_ipaddr
netmask|FORM_netmask|@TR<<network_routes_Netmask#Netmask>>||$FORM_netmask
ip|FORM_gateway|@TR<<network_routes_Gateway#Gateway>>||$FORM_gateway
int|FORM_metric|@TR<<network_routes_Metric#Metric>>||$FORM_metric
string|FORM_interface|@TR<<network_routes_Interface#Interface>>||$FORM_interface
string|FORM_additional|@TR<<network_routes_Additional_commands#Additional commands>>||$FORM_additional
EOF
	equal "$?" 0 && {
		# maybe also check with route command?
		update_routes add
		unset FORM_ipaddr FORM_netmask FORM_gateway FORM_metric FORM_interface FORM_additional
	} || {
		EDIT_FLAG=1
	}
}

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
#stylebuttons .cssbutton {
	background-color: #f6f4f1;
	border: 2px #888785 outset;
	border-color: #c6c4c1 #888785 #888785 #c6c4c1;
	padding: 1px 3px 1px 2px;
	font-size: 0.83em;
	text-decoration: none;
}
#stylebuttons .cssbutton, .cssbutton:visited, .cssbutton:active {
	color: #000000;
}
#stylebuttons .delbut, .delbut:visited, .delbut:active {
	color: #d44533;
}
#stylebuttons .cssbutton:active {
	border-style: inset;
	border-color: #f6f4f1 #f6f4f1 #888785 #888785;
	background-color: #f6f4f1;
	padding: 1px 2px 1px 3px;
}
#stylebuttons span {
	display: none;
}
td {
	padding-top: 1px;
	padding-bottom: 2px;
}
-->
</style>

EOF
)

header "Network" "Routes" "@TR<<network_routes_Static_Routes#Static Routes>>" '' "$SCRIPT_NAME"

[ "$EDIT_FLAG" == "1" ] && {
	display_form <<EOF
start_form|@TR<<network_routes_Add_route#Add route>>
field|@TR<<network_routes_IP_Address#IP Address>>|field_ipaddr|
text|ipaddr|$FORM_ipaddr
field|@TR<<network_routes_Netmask#Netmask>>|field_wan_netmask|
text|netmask|$FORM_netmask
field|@TR<<network_routes_Gateway#Gateway>>|field_gateway|
text|gateway|$FORM_gateway
field|@TR<<network_routes_Metric#Metric>>|field_metric|
text|metric|$FORM_metric
field|@TR<<network_routes_Interface#Interface>>|field_interface|
text|interface|$FORM_interface
field|@TR<<network_routes_Additional_commands#Additional commands>>|field_additional|
text|additional|$FORM_additional
helpitem|network_routes_IP_Address_netmask#IP Address/Netmask
helptext|network_routes_IP_Address_helptext#Helptext.
helpitem|network_routes_Gateway#Gateway
helptext|network_routes_Gateway_helptext#Helptext.
helpitem|network_routes_Metric#Metric
helptext|network_routes_Metric_helptext#Helptext.
helpitem|network_routes_Interface#Interface
helptext|network_routes_Interface_helptext#Helptext.
helpitem|network_routes_Additional_commands#Additional commands
helptext|network_routes_Additional_commands_helptext#Helptext.
end_form
EOF
}

?>
<div class="settings">
<h3><strong>@TR<<network_routes_Configured_Static_Routes#Configured Static Routes>></strong></h3>
<div id="stylebuttons">
<table style="text-align: left;" border="0" cellpadding="1" cellspacing="3">
<tbody>
<tr>
<th>@TR<<network_routes_IP_Address#IP Address>></th>
<th>@TR<<network_routes_Gateway#Gateway>></th>
<th>@TR<<network_routes_Netmask#Netmask>></th>
<th>@TR<<network_routes_Metric#Metric>></th>
<th>@TR<<network_routes_Interface#Interface>></th>
<th>@TR<<network_routes_Additional_commands#Additional commands>></th>
<th>@TR<<network_routes_Action#Action>></th>
</tr>
<?
# static routes in /etc/routes
cat "$ROUTES_FILE" 2>/dev/null | awk -v "url=$SCRIPT_NAME" -v "editflag=$EDIT_FLAG" '
BEGIN {
	records=0
	odd=1
}
(($1 == "-host") || ($1 == "-net")) {
	href="mode=" $1
	records=records+1
	if (odd == 1) {
		print "	<tr>"
		odd--
	} else {
		print "	<tr class=\"odd\">"
		odd++
	}
	href=href "&amp;ipaddr=" $2
	print "<td>" $2 "</td>"
	# scan for known parameters
	netmask=""
	gateway=""
	for (i=3; i<NF; i=i+2) {
		if ($i == "netmask") {
			netmask=$(i+1)
			$i=""
			$(i+1)=""
			href=href "&amp;netmask=" netmask
		} else if ($i == "gw") {
			gateway=$(i+1)
			$i=""
			$(i+1)=""
			href=href "&amp;gateway=" gateway
		} else if ($i == "metric") {
			metric=$(i+1)
			$i=""
			$(i+1)=""
			href=href "&amp;metric=" metric
		} else if ($i == "dev") {
			interface=$(i+1)
			$i=""
			$(i+1)=""
			href=href "&amp;interface=" interface
		}
	}
	if (gateway != "")
		print "<td>" gateway "</td>"
	else
		print "<td>&nbsp;</td>"
	if (netmask != "")
		print "<td>" netmask "</td>"
	else
		print "<td>&nbsp;</td>"
	if (metric != "")
		print "<td>" metric "</td>"
	else
		print "<td>&nbsp;</td>"
	if (interface != "")
		print "<td>" interface "</td>"
	else
		print "<td>&nbsp;</td>"
	additional=""
	for (i=3; i<=NF; i++) {
		if ($i != "")
			additional=additional ((additional == "") ? "" : " ") $i
	}
	if (additional != "") {
		print "<td>" additional "</td>"
		href=href "&amp;additional=" additional
	} else
		print "<td>&nbsp;</td>"
	gsub(/ /, "%20", href)
	# buttons
	print "<td>"
	if (editflag == 0)
		print "<a class=\"cssbutton\" href=\"" url "?action=editroute&amp;" href "\">@TR<<network_routes_Edit#Edit>></a>"
	print "&nbsp;"
	if (editflag == 0)
		print "<a class=\"cssbutton delbut\" href=\"" url "?action=removeroute&amp;" href "\">@TR<<network_routes_Delete#Delete>></a>"
	print "</td>"
	print "</tr>"
}
END {
	if (records == 0)
		print "<tr><td colspan=\"7\">@TR<<network_routes_No_configured_routes#No configured static routes exist.>></td></tr>"
	if (editflag == 0)
		print "<tr><td colspan=\"7\" align=\"right\"><a class=\"cssbutton\" href=\"" url "?action=addroute\">@TR<<network_routes_Add_new_route#Add new route>></a></td></tr>"
}'
?>
</tbody>
</table>
</div>
</div>

<br />

<div class="settings">
<h3><strong>@TR<<network_routes_routing_table#Kernel Routing Table>></strong></h3>
<table style="text-align: left;" border="0" cellpadding="1" cellspacing="3">
<tbody>
<tr>
<th>@TR<<Destination>></th>
<th>@TR<<Gateway>></th>
<th>@TR<<Genmask>></th>
<th>@TR<<Flags>></th>
<th>@TR<<Metric>></th>
<th>@TR<<Ref>></th>
<th>@TR<<Use>></th>
<th>@TR<<Interface>></th>
</tr>
<?
        route -n | awk '
BEGIN {
	odd=1
}
NR > 2 {
	if (odd == 1) {
		print "	<tr>"
		odd--
	} else {
		print "	<tr class=\"odd\">"
		odd++
	}
	for (i=1; i<=NF; i++) printf "<td>" $i "</td>"
	print "</tr>"
}
'
?>
</table>
</div>

<? footer ?>
<!--
##WEBIF:name:Network:500:Routes
-->
