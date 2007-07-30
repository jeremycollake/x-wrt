#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "Interfaces" "@TR<<Interfaces>>"

display_interface() {
	local iface="$1"
	local iname="$2"
	local dns_servers=""
	local resconf
	equal "$iface" "" || equal "$iname" "" && return 1
	[ "$iname" = "WAN" ] && {
		resconf=$(cat /etc/dnsmasq.conf 2>/dev/null | grep "^resolv-file=" | cut -d'=' -f 2)
		resconf="${resconf:-"/etc/resolv.conf"}"
		dns_servers=$(cat "$resconf" 2>/dev/null | awk '/nameserver/ { printf $2 "|" }')
	}
	ifconfig "$iface" 2>/dev/null | awk -v "iname=$iname" -v "dns_servers=$dns_servers" '
function colonstr(strc, nparts, colparts) {
	if ((length(strc) == 0) || (strc !~ /:/)) return ""
	nparts = split(strc, colparts, ":")
	if (nparts != 2) return ""
	else return colparts[2]
}
function int2human(num, pref) {
	if (num == "") return num
	pref = 1000*1000*1000*1000
	if (int(num/pref) > 0) return sprintf("%.2f@TR<<int2human_tera#t>>", num/pref)
	pref = pref / 1000
	if (int(num/pref) > 0) return sprintf("%.2f@TR<<int2human_giga#g>>", num/pref)
	pref = pref / 1000
	if (int(num/pref) > 0) return sprintf("%.2f@TR<<int2human_mega#m>>", num/pref)
	pref = pref / 1000
	if (int(num/pref) > 0) return sprintf("%.2f@TR<<int2human_kilo#k>>", num/pref)
	return sprintf("%d", num)
}
function hardspace(parm) {
	if (parm == "") return "&nbsp;"
	else return parm
}
{
	if ($0 ~ /Link encap:/)	_if["mac"] = hardspace($5)
	else if ($0 ~ /inet addr:/) _if["ip"] = hardspace(colonstr($2))
	else if ($0 ~ /RX packets:/) _if["rxp"] = hardspace(int2human(colonstr($2)))
	else if ($0 ~ /TX packets:/) _if["txp"] = hardspace(int2human(colonstr($2)))
	else if ($0 ~ /RX bytes:/) {
		_if["rxh"] = $3" "$4
		_if["txh"] = $7" "$8
	}
}
END {
	if (_if["mac"] || _if["ip"]) {
		print "start_form|@TR<<" iname ">>"
		print "field|@TR<<MAC Address>>|" iname "_mac_addr"
		print "string|" _if["mac"]
		print "field|@TR<<IP Address>>|" iname "_ip_addr"
		print "string|" _if["ip"]
		if (dns_servers != "") {
			dnscount = split(dns_servers, dns, "|")
			for (i = 1; i <= dnscount; i++) {
				if (dns[i] != "") {
					print "field|@TR<<DNS Server>> " i "|dns_server_" i
					print "string|" dns[i]
				}
			}
		}
		print "field|@TR<<Received>>|" iname "_rx"
		print "string|" _if["rxp"] " @TR<<status_interfaces_pkts#pkts>>&nbsp;" _if["rxh"]
		print "field|@TR<<Transmitted>>|" iname "_tx"
		print "string|" _if["txp"] " @TR<<status_interfaces_pkts#pkts>>&nbsp;" _if["txh"]
		if (iname == "WAN") {
			print "helpitem|WAN"
			print "helptext|WAN WAN#WAN stands for Wide Area Network and is usually the upstream connection to the internet."
		} else if (iname == "LAN") {
			print "helpitem|LAN"
			print "helptext|LAN LAN#LAN stands for Local Area Network."
		} else if (iname == "LOOPBACK") {
			print "helpitem|LOOPBACK"
			print "helptext|LOOPBACK_helptext#A loopback interface is a type of '\''circuitless IP address'\'' or '\''virtual IP'\'' address, as the IP address is not associated with any one particular interface (or circuit) on the host or router. Any traffic that a computer program sends on the loopback network is addressed to the same computer."
		}
		print "end_form"
	}
}' | display_form
}

display_wlans() {
	iwconfig 2>/dev/null | grep -v 'no wireless' | grep '\w' | awk '
BEGIN {
	wlan_counter = 0
}
function print_wlan() {
	if (_wlan["essid"]) {
		print "start_form|@TR<<WLAN>>"; if (wlan_counter > 1) print " " wlan_counter - 1
		print "field|@TR<<Access Point>>|wlan_"wlan_counter"_ap"
		print "string|" _wlan["ap"]
		print "field|@TR<<Mode>>|wlan_"wlan_counter"_mode"
		print "string|" _wlan["mode"]
		print "field|@TR<<ESSID>>|wlan_"wlan_counter"_ssid"
		print "string|" _wlan["essid"]
		print "field|@TR<<Frequency>>|wlan_"wlan_counter"_freq"
		print "string|" _wlan["freq"] " @TR<<units_GHz#GHz>>"
		print "field|@TR<<Transmit Power>>|wlan_"wlan_counter"_txpwr"
		print "string|" _wlan["txpwr"] " @TR<<units_dBm#dBm>>"
		print "field|@TR<<Noise Level>>|wlan_"wlan_counter"_noise"
		print "string|" _wlan["noise"] " @TR<<units_dBm#dBm>>"
		print "field|@TR<<Encryption Key>>|wlan_"wlan_counter"_key"
		print "string|<div class=\"smalltext\">" _wlan["key"] "</div>"
		if (_wlan["rxinvnwid"] || _wlan["rxinvcrypt"] || _wlan["txretries"] || _wlan["txinvalid"] || _wlan["txinvalid"]) {
			print "field|@TR<<Rx Invalid nwid>>|wlan_"wlan_counter"_rx_invalid_nwid"
			print "string|" _wlan["rxinvnwid"]
			print "field|@TR<<Rx Invalid Encryption>>|wlan_"wlan_counter"_rx_invalid_crypt"
			print "string|" _wlan["rxinvcrypt"]
			print "field|@TR<<Tx Retries in Excess>>|wlan_"wlan_counter"_tx_retries"
			print "string|" _wlan["txretries"]
			print "field|@TR<<Tx Invalid>>|wlan_"wlan_counter"_tx_invalid"
			print "string|" _wlan["txinvalid"]
			print "field|@TR<<Tx Missed Beacon>>|wlan_"wlan_counter"_tx_missed"
			print "string|" _wlan["txmissed"]
		}
		if (wlan_counter == 1) {
			print "helpitem|WLAN"
			print "helptext|WLAN LAN#WLAN stands for Wireless Local Area Network."
		}
		print "end_form"
	}
	delete _wlan
}
function colonstr(strc, nparts, colparts) {
	if ((length(strc) == 0) || (strc !~ /:/)) return ""
	nparts = split(strc, colparts, ":")
	if (nparts != 2) return ""
	else return colparts[2]
}
function hardspace(parm) {
	if (parm == "") return "&nbsp;"
	else return parm
}
{
	if ($0 !~ /^[[:space:]]/) {
		print_wlan()
		wlan_counter++
		for (i = 1; i <= NF; i++) {
			if ($i ~ /ESSID:/) {
				_wlan["essid"] = hardspace(colonstr($i))
				sub(/^"/, "", _wlan["essid"])
				sub(/"$/, "", _wlan["essid"])
				_wlan["essid"] = hardspace(_wlan["essid"])
				break
			}
		}
	} else {
		if ($0 ~ /Mode:/) {
			_wlan["mode"] = hardspace(colonstr($1))
			_wlan["freq"] = colonstr($2); if (_wlan["freq"] == "") _wlan["freq"] = 0
			_wlan["ap"] = hardspace($6)
		} else if ($0 ~ /Tx-Power:/) {
			_wlan["txpwr"] = colonstr($1)
			if (_wlan["txpwr"] == "") _wlan["txpwr"] = 0
		} else if ($0 ~ /Encryption key:/) {
			_wlan["key"] = colonstr($2) " " $3
		} else if ($0 ~ /Link Noise level:/) {
			_wlan["noise"] = colonstr($3)
			if (_wlan["noise"] == "") _wlan["noise"] = 0
		} else if ($0 ~ /Rx invalid nwid:/) {
			_wlan["rxinvnwid"] = colonstr($3); if (_wlan["rxinvnwid"] == "") _wlan["rxinvnwid"] = 0
			_wlan["rxinvcrypt"] = colonstr($6); if (_wlan["rxinvcrypt"] == "") _wlan["rxinvcrypt"] = 0
		} else if ($0 ~ /Tx excessive retries:/) {
			_wlan["txretries"] = colonstr($3); if (_wlan["txretries"] == "") _wlan["txretries"] = 0
			_wlan["txinvalid"] = colonstr($5); if (_wlan["txinvalid"] == "") _wlan["txinvalid"] = 0
			_wlan["txmissed"] = colonstr($7); if (_wlan["txmissed"] == "") _wlan["txmissed"] = 0
		}
	}
}
END {
	print_wlan()
}
' | display_form
}

display_interface "$(nvram get wan_ifname)" "WAN"
display_interface "$(nvram get lan_ifname)" "LAN"
display_wlans


#########################################
# raw stats
preinterface() {
	local iface="$1"
	local iname="$2"
	equal "$iface" "" || equal "$iname" "" && return 1
	echo "<tr>"
	case "$iname" in
		WAN) echo "	<th><b>@TR<<Interfaces Status WAN|WAN Interface>></b></th>" ;;
		LAN) echo "	<th><b>@TR<<Interfaces Status LAN|LAN Interface>></b></th>" ;;
	esac
	echo "</tr>"
	echo "<tr>"
	echo "	<td><div class=\"smalltext\"><pre>"
	ifconfig "$iface" 2>/dev/null
	echo "</pre></div></td>"
	echo "</tr>"
}

prewlans() {
	echo "<tr>"
	echo "	<th><b>@TR<<Interfaces Status WLAN|Wireless Interface>></b></th>"
	echo "</tr>"
	echo "<tr>"
	echo "	<td><div class=\"smalltext\"><pre>"
	iwconfig  2>/dev/null | grep -v "no wireless"
	echo "</pre></div></td>"
	echo "</tr>"
}

display_form <<EOF
start_form|@TR<<Raw Information>>
EOF
if empty "$FORM_show_raw_stats"; then
	display_form <<EOF
field||show_raw
formtag_begin|raw_stats|$SCRIPT_NAME
submit|show_raw_stats| @TR<<&nbsp;Show raw statistics&nbsp;>>
formtag_end
end_form
EOF
else
	preinterface "$(nvram get wan_ifname)" "WAN"
	preinterface "$(nvram get lan_ifname)" "LAN"
	prewlans
	display_form <<EOF
end_form
EOF
fi

footer ?>
<!--
##WEBIF:name:Status:150:Interfaces
-->
