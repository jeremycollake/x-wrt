#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

#header_inject_head="<meta http-equiv=\"refresh\" content=\"20;url=$SCRIPT_NAME\" />"

wan_stop() {
	echo "@TR<<status_pppoe_Stopping_wan#Stopping wan connection>>..."
	ifdown wan
}
wan_start() {
	echo "@TR<<status_pppoe_Starting_wan#Starting wan connection>>..."
	ifup wan
}

header "Status" "PPPoE" "@TR<<PPPoE Status>>"

FORM_xaction=$(set | sed '/^FORM_pppoe_[^=]*=/!d; s/^FORM_pppoe_//; s/=.*$//')
[ -n "$FORM_xaction" ] && {
	echo "<pre class=\"smalltext\">"
	case "$FORM_xaction" in
		connect)	wan_start ;;
		disconnect)	wan_stop ;;
		reconnect)	wan_stop; wan_start ;;
		*) echo "@TR<<status_pppoe_Unknown_action#Unknown action>>" ;;
	esac
	echo "</pre><br />"
}

wan_proto=$(nvram get wan_proto)
wan_ifname=$(nvram get wan_ifname)
if [ "$wan_proto" = "pppoe" -a "${wan_ifname%%[0-9]*}" = "ppp" ]; then
	pifconfig=$(ifconfig ppp0 2>/dev/null)
	[ -n "$pifconfig" ] && {
		conn_status="@TR<<status_pppoe_Connected#Connected>>"
		action_buttons="submit|pppoe_disconnect|@TR<<status_pppoe_Disconnect#Disconnect>>
string|&nbsp;
submit|pppoe_reconnect|@TR<<status_pppoe_Reconnect#Reconnect>>"
	} || {
		conn_status="@TR<<status_pppoe_Disconnected#Disconnected>>"
		action_buttons="submit|pppoe_connect|@TR<<status_pppoe_Connect#Connect>>"
	}
	display_form <<EOF
start_form|@TR<<status_pppoe_Connection_Status#Connection Status>>
field|$conn_status
formtag_begin|pppoe_action|$SCRIPT_NAME
$action_buttons
formtag_end
end_form
EOF
	resconf=$(cat /etc/dnsmasq.conf 2>/dev/null | grep "^resolv-file=" | cut -d'=' -f 2)
	resconf="${resconf:-"/etc/resolv.conf"}"
	dns_servers=$(cat "$resconf" 2>/dev/null | awk '/nameserver/ { printf $2 "|" }')
	wan_timestamp=$(cat /tmp/.wan_timestamp 2>/dev/null)
	echo "$pifconfig" | awk -v "dns_servers=$dns_servers" -v "wan_timestamp=$wan_timestamp" '
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
function fmtime(seconds, secs, fstring, y, d, h, m ,s) {
	if (seconds >= 0) {
		secs = seconds
		y = int(secs / (60 * 60 * 24 * 365))
		if (y > 0) {
			fstring = sprintf("%d@TR<<units_short_year_y#y>> ", y)
			secs = secs % (60 * 60 * 24 * 365)
		}
		d = int(secs / 60 / 60 / 24)
		if (d > 0) {
			fstring = fstring sprintf("%d@TR<<units_short_day_d#d>> ", d)
			secs = secs % (60 * 60 * 24)
		}
		h = int(secs / 60 / 60)
		m = int(secs / 60 % 60)
		s = int(secs % 60)
		fstring = fstring "%02d:%02d:%02d"
		return sprintf(fstring, h, m, s)
	} else return "&nbsp;"
}
{
	if ($0 ~ /inet addr:/) _if["ip"] = hardspace(colonstr($2))
	else if ($0 ~ /RX packets:/) _if["rxp"] = hardspace(int2human(colonstr($2)))
	else if ($0 ~ /TX packets:/) _if["txp"] = hardspace(int2human(colonstr($2)))
	else if ($0 ~ /RX bytes:/) {
		_if["rxh"] = $3" "$4
		_if["txh"] = $7" "$8
	}
}
END {
	if (_if["ip"]) {
		print "start_form|@TR<<status_pppoe_Additional_Information#Additional Information>>"
		print "field|@TR<<IP Address>>"
		print "string|" _if["ip"]
		if (dns_servers != "") {
			dnscount = split(dns_servers, dns, "|")
			for (i = 1; i <= dnscount; i++) {
				if (dns[i] != "") {
					print "field|@TR<<DNS Server>>"
					print "string|" dns[i]
				}
			}
		}
		print "field|@TR<<Received>>"
		print "string|" _if["rxp"] " @TR<<units_packets_pkts#pkts>>&nbsp;" _if["rxh"]
		print "field|@TR<<Transmitted>>"
		print "string|" _if["txp"] " @TR<<units_packets_pkts#pkts>>&nbsp;" _if["txh"]
		if (wan_timestamp != "") {
			print "field|@TR<<Duration>>"
			print "string|" fmtime(systime() - wan_timestamp)
		}
		print "end_form"
	}
}' | display_form
	cat <<EOF
<div class="settings">
<h3><strong>@TR<<status_pppoe_Connection_Log#Connection Log>></strong></h3>
<pre style="margin: 0.2em auto 1em auto; padding: 3px; width: 94%; margin: auto; height: 200px; overflow: scroll; border: 1px solid; ">
EOF
	logread | egrep "(ppp0|pppd|pppoe)" |tail -n 500 -|sort -r | sed ' s/\&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
	echo
	echo "</pre></div>"

else
	display_form <<EOF
start_form|@TR<<status_pppoe_Connection_Status#Connection Status>>
field|
string|@TR<<status_pppoe_not_used#The PPPoE network protocol is not used for the wan connection.>>
end_form
EOF
fi

footer ?>
<!--
##WEBIF:name:Status:500:PPPoE
-->
