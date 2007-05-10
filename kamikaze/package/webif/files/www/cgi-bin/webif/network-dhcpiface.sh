#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Network" "DHCP" "@TR<<DHCP Interfaces>>" '' "$SCRIPT_NAME"
ShowNotUpdatedWarning

config_cb() {
config_get TYPE "$CONFIG_SECTION" TYPE
case "$TYPE" in
        interface)
	        append network_devices "$CONFIG_SECTION"
        ;;
esac
}

uci_load network
uci_load dhcp

exists /tmp/.webif/file-dnsmasq.conf  && DNSMASQ_FILE=/tmp/.webif/file-dnsmasq.conf || DNSMASQ_FILE=/etc/dnsmasq.conf
exists $DNSMASQ_FILE || touch $DNSMASQ_FILE >&- 2>&-

update_dnsmasq() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	awk -v "mode=$1" -v "iface=$2" -v "value=$3" -v "options=$4" '
BEGIN {
	FS="[=]"
	line_added = 0
}
{ processed = 0 }
(mode == "del") && ($0 == value) {
	if ($0 != value) {
		print $2
	}
	processed = 1
}
(mode == "_add") {
	print $0 " " name
	host_added = 1
	processed = 1
}
processed == 0 {
	print $0
}
END {
	if ((mode == "add") && (line_added == 0)) print "dhcp-option=" iface "," value "," options
}' "$DNSMASQ_FILE" > /tmp/.webif/file-dnsmasq.conf-new
	mv "/tmp/.webif/file-dnsmasq.conf-new" "/tmp/.webif/file-dnsmasq.conf"
	DNSMASQ_FILE=/tmp/.webif/file-dnsmasq.conf
}


empty "$FORM_add_line" || {
	update_dnsmasq add "$FORM_iface" "$FORM_hop" "$FORM_values"
}

empty "$FORM_remove_line" || update_dnsmasq del "$FORM_iface" "$FORM_line"

	if [ -n "$FORM_iface" ]; then
		if empty "$FORM_submit"; then
			config_get FORM_dhcp_enabled ${FORM_iface} ignore
			config_get FORM_dhcp_start ${FORM_iface} start
			config_get FORM_dhcp_num ${FORM_iface} limit
			config_get FORM_dhcp_lease= ${FORM_iface} lease
		fi
		
		FORM_dhcp_lease=${FORM_dhcp_lease:-12h}
		# cut is to fix for cases where an IP address got stuck in this instead of mere integer
		FORM_dhcp_start=$(echo "$FORM_dhcp_start" | cut -d '.' -f 4)
		
		# convert lease time to minutes
		lease_int=$(echo "$FORM_dhcp_lease" | tr -d [a-z][A-Z])			
		time_units=$(echo "$FORM_dhcp_lease" | tr -d [1-9])
		case "$time_units" in
			"h" | "H" ) let "FORM_dhcp_lease=$lease_int*60";;
			"d" | "D" ) let "FORM_dhcp_lease=$lease_int*24*60";;
			"s" | "S" ) let "FORM_dhcp_lease=$lease_int/60";;
			"w" | "W" ) let "FORM_dhcp_lease=$lease_int*7*24*60";;
			"m" | "M" | "" ) FORM_dhcp_lease="$lease_int";;  # minutes 			
			*) FORM_dhcp_lease="$lease_int"; echo "<br />WARNING: Unknown suffix found on dhcp lease time: $FORM_dhcp_lease";;
		esac					
			
	fi
if [ -n "$FORM_submit" ]; then
	validate <<EOF
int|FORM_${FORM_iface}_dhcp_enabled|DHCP enabled||$FORM_dhcp_enabled
string|FORM_${FORM_iface}_dhcp_iface|DHCP iface||$FORM_dhcp_iface
int|FORM_${FORM_iface}_dhcp_start|DHCP start||$FORM_dhcp_start
int|FORM_${FORM_iface}_dhcp_num|DHCP num||$FORM_dhcp_num
int|FORM_${FORM_iface}_dhcp_lease|DHCP lease time|min=1 max=2147483647 required|$FORM_dhcp_lease
EOF
	if equal "$?" 0; then
		SAVED=1
		uci_set "dhcp" "${FORM_iface}" "enabled" "$FORM_dhcp_enabled"
		uci_set "dhcp" "${FORM_iface}" "interface" "$FORM_dhcp_iface"
		uci_set "dhcp" "${FORM_iface}" "start" "$FORM_dhcp_start"
		uci_set "dhcp" "${FORM_iface}" "limit" "$FORM_dhcp_num"
		uci_set "dhcp" "${FORM_iface}" "lease" "${FORM_dhcp_lease}m"
	else
		echo "<div class=\"failed-validation\">Validation failed on one or more variables. On this page a common error is putting an IP address in \"DHCP Start\" instead of a simple number.</div>"
	fi
fi

awk -v "name=@TR<<Name>>" \
	-v "interface=@TR<<Interface>>" \
	-v "interfaces=@TR<<Interfaces>>" \
	-v "action=@TR<<Action>>" \
	-f /usr/lib/webif/common.awk -f - /etc/dnsmasq.options <<EOF
BEGIN{
	start_form("@TR<<Interfaces>>")
	print "<table style=\\"width: 90%\\">"
	print "<tr><th>" name "</th><th>" interface "</th><th>" interfaces "</th><th>" action "</th></tr>"
	print "<tr><td colspan=\\"4\\"><hr class=\\"separator\\" /></td></tr>"
}
EOF

	pppoa_ifname="atm0" # hack for ppp over atm, which has no ${proto}_ifname
	for ifname in $network_devices; do
		config_get type $ifname type
		if [ "$type" = "bridge" ]; then
			IFACE="br-$ifname"
		fi
		config_get IFACES $ifname ifname
		if [ "$ifname" = "$FORM_iface" ]; then
			style="class=\"settings-title\""
		else
			style=""
		fi
		echo "<tr><td $style>$ifname</td><td $style>$IFACE</td><td $style>$IFACES</td><td $style><a href=\"network-dhcpiface.sh?action=modify&amp;iface=$ifname\">@TR<<Modify>></a></td></tr>"
	done

awk -f /usr/lib/webif/common.awk -f - /etc/dnsmasq.options <<EOF
BEGIN{
	print "</table><br />"
	end_form();
}
EOF

if [ -n "$FORM_iface" ]; then
	config_get ipaddr ${FORM_iface} ipaddr
	if [ -n "$ipaddr" ]; then
		config_get netmask ${FORM_iface} netmask
		config_get start ${FORM_iface} start
		config_get num ${FORM_iface} limit
		
		eval $(ipcalc.sh $ipaddr $netmask ${start:-100} ${num:-150})

		# Static DHCP mappings (/etc/ethers)
		awk -v "url=$SCRIPT_NAME" \
			-v "mac=$FORM_dhcp_mac" \
			-v "remove=@TR<<Remove>>" \
			-v "add=@TR<<Add>>" \
			-v "param=@TR<<Parameters>>" \
			-v "value=@TR<<Value>>" \
			-v "action=@TR<<Action>>" \
			-v "macaddress=@TR<<MAC Address>>" \
			-v "iface=$FORM_iface" \
			-v "ip=$FORM_dhcp_ip" -f /usr/lib/webif/common.awk -f - $DNSMASQ_FILE <<EOF
BEGIN {
	FS=","
	start_form("@TR<<Options For>> $FORM_iface")
	print "<table style=\"width: 90%\"><tr><th>" param "</th><th>" value "</th><th>" action "</th></tr>"
	print "<tr><td colspan=\"4\"><hr class=\"separator\" /></td></tr>"
}

# only for type not empty
{
	n = split(\$1, value, "[=]")
	option = value[2];
}
(\$1 ~ /^dhcp-option/ && option == iface) {
	gsub(/#.*$/, "");
	print "<tr><td>" \$2 "</td><td>"
	# first = 1
	for (i = 3; i <= NF; i++) {
		print \$i "<br />"
	}
	print "</td><td><a href=\\"network-dhcpiface.sh?remove_line=1&mod=del&iface=" iface "&line=" \$0 "\\">" remove "</a></td></tr>"
	print "<tr><td colspan=\\"3\\"><hr class=\\"separator\\" /></td></tr>"
}

END {
	print ""
}
EOF
		awk -v "url=$SCRIPT_NAME" \
			-v "mac=$FORM_dhcp_mac" \
			-v "remove=@TR<<Remove>>" \
			-v "add=@TR<<Add>>" \
			-v "param=@TR<<Parameters>>" \
			-v "value=@TR<<Value>>" \
			-v "action=@TR<<Action>>" \
			-v "macaddress=@TR<<MAC Address>>" \
			-v "iface=$FORM_iface" \
			-v "ip=$FORM_dhcp_ip" -f /usr/lib/webif/common.awk -f - /etc/dnsmasq.options <<EOF
BEGIN {
	FS=":"
	print "<tr><td><select id=\\"hop\\" name=\\"hop\\">"
}

# only for type not empty
(\$3 != "") {
	gsub(/#.*$/, "");
	print "<option value=\\"@TR<<" \$1 "\>>\">" \$1 " - " \$2 " - (" \$3 ")</option>"
}

END {
	print "</select></td><td><input type=\\"text\\" name=\\"values\\" value=\\"" values "\\" /></td>"
	print "<td><input type=\\"hidden\\" value=\\"" iface "\\" name=\\"iface\\" /><input type=\\"submit\\" value=\\"" add "\\" name=\\"add_line\\" /></td></tr></table>"
	end_form();
}
EOF

		display_form<<EOF
start_form|@TR<<DHCP Server For $FORM_iface>>
field|@TR<<Interface>>|iface_field|hidden
text|iface|$FORM_iface
field|@TR<<DHCP Service>>|dhcp_enabled_field
select|dhcp_enabled|$FORM_dhcp_enabled
option|1|@TR<<Disabled>>
option|0|@TR<<Enabled>>
field|@TR<<DHCP Start>>|dhcp_start_field
text|dhcp_start|$FORM_dhcp_start|$NETWORK+x
field|@TR<<DHCP Num>>|dhcp_num_field
text|dhcp_num|$FORM_dhcp_num
field|@TR<<DHCP Lease Minutes>>
text|dhcp_lease|$FORM_dhcp_lease
end_form
EOF
	fi
fi

footer ?>
<!--
##WEBIF:name:Network:425:DHCP
-->
