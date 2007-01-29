#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "Interfaces" "@TR<<Interfaces>>"

# get WAN stats
wan_config=$(ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`")
if [ -n "$wan_config" ]; then
wan_ip_addr=$(echo "$wan_config" | grep "inet addr" | cut -d: -f 2 | sed s/Bcast//g)
wan_mac_addr=$(echo "$wan_config" | grep "HWaddr" | cut -d' ' -f 10)
wan_tx_packets=$(echo "$wan_config" | grep "TX packets" | sed s/'TX packets:'//g | cut -d' ' -f 11 | int2human)
wan_rx_packets=$(echo "$wan_config" | grep "RX packets" | sed s/'RX packets:'//g | cut -d' ' -f 11 | int2human)
wan_tx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 3)
wan_rx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 2 | cut -d ')' -f 1)
fi
# get LAN stats
lan_config=$(ifconfig 2>&1 | grep -A 6 "`nvram get lan_ifname`")
lan_ip_addr=$(echo "$lan_config" | grep "inet addr" | cut -d: -f 2 | sed s/Bcast//g)
lan_mac_addr=$(echo "$lan_config" | grep "HWaddr" | cut -d' ' -f 12)
lan_tx_packets=$(echo "$lan_config" | grep "TX packets" | sed s/'TX packets:'//g | cut -d' ' -f 11 | int2human)
lan_rx_packets=$(echo "$lan_config" | grep "RX packets" | sed s/'RX packets:'//g | cut -d' ' -f 11 | int2human)
lan_tx_bytes=$(echo "$lan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 3)
lan_rx_bytes=$(echo "$lan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 2 | cut -d ')' -f 1)
# get wifi stats
wlan_config=$(iwconfig 2>&1 | grep -v 'no wireless' | grep '\w')
wlan_ssid=$(echo "$wlan_config" | grep 'ESSID' | cut -d':' -f 2 | sed s/'"'//g)
wlan_mode=$(echo "$wlan_config" | grep "Mode:" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_freq=$(echo "$wlan_config" | grep "Mode:" | cut -d':' -f 3 | cut -d' ' -f 1)
wlan_ap=$(echo "$wlan_config" | grep "Mode:" | cut -d' ' -f 18)
wlan_txpwr=$(echo "$wlan_config" | grep Tx-Power | cut -d'-' -f2 | cut -d':' -f 2 | sed s/"dBm"//g)
wlan_key=$(echo "$wlan_config" | grep "Encryption key:" | sed s/"Encryption key:"//)
wlan_tx_retries=$(echo "$wlan_config" | grep "Tx excessive retries" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_tx_invalid=$(echo "$wlan_config" | grep "Tx excessive retries" | cut -d':' -f 3 | cut -d' ' -f 1)
wlan_tx_missed=$(echo "$wlan_config" | grep "Missed beacon" | cut -d':' -f 4 | cut -d' ' -f 1)
wlan_rx_invalid_nwid=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_rx_invalid_crypt=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 3 | cut -d' ' -f 1)
wlan_rx_invalid_frag=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 4 | cut -d' ' -f 1)
wlan_noise=$(echo "$wlan_config" | grep "Link Noise level:" | cut -d':' -f 2 | cut -d' ' -f 1)

# set unset vars
wlan_freq="${wlan_freq:-0}"
wlan_noise="${wlan_noise:-0}"
wlan_txpwr="${wlan_txpwr:-0}"

# enumerate WAN nameservers
form_dns_servers=$(awk '
	BEGIN { counter=1 }
	/nameserver/ {print "field|@TR<<DNS Server>> " counter "|dns_server_" counter "\n string|" $2 "\n" ;counter+=1}
	' /etc/resolv.conf 2> /dev/null)

if [ -n "$wan_config" ]; then
display_form <<EOF

start_form|@TR<<WAN>>
field|@TR<<MAC Address>>|wan_mac_addr
string|$wan_mac_addr
field|@TR<<IP Address>>|wan_ip_addr
string|$wan_ip_addr
$form_dns_servers
field|@TR<<Received>>|wan_rx
string|$wan_rx_packets pkts ($wan_rx_bytes)
field|@TR<<Transmitted>>|wan_tx
string|$wan_tx_packets pkts ($wan_tx_bytes
helpitem|WAN
helptext|WAN WAN#WAN stands for Wide Area Network and is usually the upstream connection to the internet.
end_form
EOF
fi

display_form <<EOF
start_form|@TR<<LAN>>
field|@TR<<MAC Address>>|lan_mac_addr
string|$lan_mac_addr
field|@TR<<IP Address>>|lan_ip_addr
string|$lan_ip_addr
field|@TR<<Received>>|lan_rx
string|$lan_rx_packets pkts ($lan_rx_bytes)
field|@TR<<Transmitted>>|lan_tx
string|$lan_tx_packets pkts ($lan_tx_bytes
helpitem|LAN
helptext|LAN LAN#LAN stands for Local Area Network.
end_form

start_form|@TR<<WLAN>>
field|@TR<<Access Point>>|wlan_ap
string|$wlan_ap
field|@TR<<Mode>>|wlan_mode
string|$wlan_mode
field|@TR<<ESSID>>|wlan_ssid
string|$wlan_ssid
field|@TR<<Frequency>>|wlan_freq
string|$wlan_freq Ghz
field|@TR<<Transmit Power>>|wlan_txpwr
string|$wlan_txpwr dBm
field|@TR<<Noise Level>>|wlan_noise
string|$wlan_noise dBm
field|@TR<<Encryption Key>>|wlan_key
string|<div class="numeric-small">$wlan_key</div>
field|@TR<<Rx Invalid nwid>>|wlan_rx_invalid_nwid
string|$wlan_rx_invalid_nwid
field|@TR<<Rx Invalid Encryption>>|wlan_rx_invalid_crypt
string|$wlan_rx_invalid_crypt
field|@TR<<Tx Retries in Excess>>|wan_tx_retries
string|$wlan_tx_retries
field|@TR<<Tx Invalid>>|wan_tx_invalid
string|$wlan_tx_invalid
field|@TR<<Tx Missed Beacon>>|wan_tx_missed
string|$wlan_tx_missed
helpitem|WLAN
helptext|WLAN LAN#WLAN stands for Wireless Local Area Network.
field||spacer1
string|<br /><br />
field||show_raw
formtag_begin|raw_stats|$SCRIPT_NAME
submit|show_raw_stats| @TR<< Show raw statistics >>
formtag_end
end_form
EOF

#########################################
# raw stats
! empty "$FORM_show_raw_stats" && {

display_form <<EOF
start_form|@TR<<Raw Information>>
EOF

echo "<tr><td><br /></td></tr>
	<div class=\"smalltext\">
		<tr>
			<th><b>@TR<<Interfaces Status WAN|WAN Interface>></b></th>
		</tr>
		<tr>
			<td><pre>"
ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`"
echo "</pre></td>
		</tr>
		<tr><td><br /><br /></td></tr>
		<tr>
			<th><b>@TR<<Interfaces Status LAN|LAN Interface>></b></th>
		</tr>
		<tr>
			<td><pre>"
ifconfig 2>&1 | grep -A 6 "`nvram get lan_ifname`"
echo "</pre></td>
		</tr>
		<tr><td><br /><br /></td></tr>
		<tr>
			<th><b>@TR<<Interfaces Status WLAN|Wireless Interface>></b></th>
		</tr>
		<tr>
			<td><pre>"
iwconfig 2>&1 | grep -v 'no wireless' | grep '\w'
echo "</pre></td>
		</tr>
		</div>"

display_form <<EOF
end_form
EOF
}

show_validated_logo

footer ?>
<!--
##WEBIF:name:Status:150:Interfaces
-->
