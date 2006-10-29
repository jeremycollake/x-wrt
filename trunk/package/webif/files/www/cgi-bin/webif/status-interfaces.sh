#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "Interfaces" "@TR<<Interfaces>>"

# TODO: some of this code can be abstracted a bit into a function.. not sure its worth doing.
# get WAN stats
wan_config=$(ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`")
wan_ip_addr=$(echo "$wan_config" | grep "inet addr" | cut -d: -f 2 | sed s/Bcast//g)
wan_mac_addr=$(echo "$wan_config" | grep "HWaddr" | cut -d' ' -f 10)
wan_tx_packets=$(echo "$wan_config" | grep "TX packets" | sed s/'TX packets:'//g | cut -d' ' -f 11)
wan_rx_packets=$(echo "$wan_config" | grep "RX packets" | sed s/'RX packets:'//g | cut -d' ' -f 11)
wan_tx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 3)
wan_rx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 2 | cut -d ')' -f 1) 
# get LAN stats
lan_config=$(ifconfig 2>&1 | grep -A 6 "`nvram get lan_ifname`")
lan_ip_addr=$(echo "$lan_config" | grep "inet addr" | cut -d: -f 2 | sed s/Bcast//g)
lan_mac_addr=$(echo "$lan_config" | grep "HWaddr" | cut -d' ' -f 12)
lan_tx_packets=$(echo "$lan_config" | grep "TX packets" | sed s/'TX packets:'//g | cut -d' ' -f 11)
lan_rx_packets=$(echo "$lan_config" | grep "RX packets" | sed s/'RX packets:'//g | cut -d' ' -f 11)
lan_tx_bytes=$(echo "$lan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 3)
lan_rx_bytes=$(echo "$lan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 2 | cut -d ')' -f 1)  
# get wifi stats
wlan_config=$(iwconfig 2>&1 | grep -v 'no wireless' | grep '\w')
wlan_ssid=$(echo "$wlan_config" | grep 'ESSID' | cut -d':' -f 2 | sed s/'"'//g)
wlan_mode=$(echo "$wlan_config" | grep "Mode:" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_freq="$(echo "$wlan_config" | grep "Mode:" | cut -d':' -f 3 | cut -d' ' -f 1) <div class=\"kb\">Ghz</div>"
wlan_ap=$(echo "$wlan_config" | grep "Mode:" | cut -d' ' -f 18)
wlan_txpwr="$(echo "$wlan_config" | grep Tx-Power | cut -d':' -f 2 | sed s/"dBm"//g) <div class=\"kb\">dBm</div>"
wlan_key=$(echo "$wlan_config" | grep "Encryption key:" | sed s/"Encryption key:"//)
wlan_tx_retries=$(echo "$wlan_config" | grep "Tx excessive retries" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_tx_invalid=$(echo "$wlan_config" | grep "Tx excessive retries" | cut -d':' -f 3 | cut -d' ' -f 1)
wlan_tx_missed=$(echo "$wlan_config" | grep "Missed beacon" | cut -d':' -f 4 | cut -d' ' -f 1)
wlan_rx_invalid_nwid=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 2 | cut -d' ' -f 1)
wlan_rx_invalid_crypt=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 3 | cut -d' ' -f 1)
wlan_rx_invalid_frag=$(echo "$wlan_config" | grep "Rx invalid nwid:" | cut -d':' -f 4 | cut -d' ' -f 1)
wlan_noise="$(echo "$wlan_config" | grep "Link Noise level:" | cut -d':' -f 2 | cut -d' ' -f 1) <div class=\"kb\">dBm</div>"

# enumerate WAN nameservers
form_dns_servers=$(awk '
	BEGIN { counter=1 }
	/nameserver/ {print "field|@TR<<DNS Server>> " counter "|dns_server_" counter "\n string|" $2 "\n" ;counter+=1}
	' /etc/resolv.conf)
 
display_form <<EOF

start_form|@TR<<WAN>>
field|@TR<<MAC Address>>|wan_mac_addr
string|<div class="mac-address">$wan_mac_addr</div>
field|@TR<<IP Address>>|wan_ip_addr
string|$wan_ip_addr
$form_dns_servers
field|@TR<<Received>>|wan_rx
string|$wan_rx_packets <div class="kb">pkts</div>&nbsp;<div class="numeric-small">($wan_rx_bytes</div>)
field|@TR<<Transmitted>>|wan_tx
string|$wan_tx_packets <div class="kb">pkts</div>&nbsp;<div class="numeric-small">($wan_tx_bytes</div>
helpitem|WAN
helptext|WAN WAN#WAN stands for Wide Area Network and is usually the upstream connection to the internet.
end_form

start_form|@TR<<LAN>>
field|@TR<<MAC Address>>|lan_mac_addr
string|<div class="mac-address">$lan_mac_addr</div>
field|@TR<<IP Address>>|lan_ip_addr
string|$lan_ip_addr
field|@TR<<Received>>|lan_rx
string|$lan_rx_packets <div class="kb">pkts</div>&nbsp;<div class="numeric-small">($lan_rx_bytes</div>)
field|@TR<<Transmitted>>|lan_tx
string|$lan_tx_packets <div class="kb">pkts</div>&nbsp;<div class="numeric-small">($lan_tx_bytes</div>
helpitem|LAN
helptext|LAN LAN#LAN stands for Local Area Network.
end_form

start_form|@TR<<WLAN>>
field|@TR<<Access Point>>|wlan_ap
string|<div class="mac-address">$wlan_ap</div>
field|@TR<<Mode>>|wlan_mode
string|$wlan_mode
field|@TR<<ESSID>>|wlan_ssid
string|$wlan_ssid
field|@TR<<Frequency>>|wlan_freq
string|$wlan_freq
field|@TR<<Transmit Power>>|wlan_txpwr
string|$wlan_txpwr
field|@TR<<Noise Level>>|wlan_noise
string|$wlan_noise
field|@TR<<Encryption Key>>|wlan_key
string|<div class="numeric-small">$wlan_key</div>
field|@TR<<Receive Invalid NWID>>|wlan_rx_invalid_nwid
string|$wlan_rx_invalid_nwid
field|@TR<<Receive Invalid Crypt>>|wlan_rx_invalid_crypt
string|$wlan_rx_invalid_crypt
field|@TR<<Transmit Retries>>|wan_tx_retries
string|$wlan_tx_retries in excess
field|@TR<<Transmit Invalid>>|wan_tx_invalid
string|$wlan_tx_invalid
field|@TR<<Transmit Missed Beacon>>|wan_tx_missed
string|$wlan_tx_missed
helpitem|WLAN
helptext|WLAN LAN#LAN stands for Wireless Local Area Network.
end_form


start_form|@TR<<Raw Information>>
EOF
?>
	<tr><td><br /></td></tr>
	<div class="smalltext">               
        <tr>
        <th><b>@TR<<Interfaces Status|WAN Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`" ?></pre></td>
        </tr>
        <tr><td><br /><br /></td></tr>
        <tr>
        <th><b>@TR<<Interfaces Status|LAN Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? ifconfig 2>&1 | grep -A 6 "`nvram get lan_ifname`" ?></pre></td>
        </tr>
         <tr><td><br /><br /></td></tr>
        <tr>
        <th><b>@TR<<Interfaces Status|Wireless Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? iwconfig 2>&1 | grep -v 'no wireless' | grep '\w' ?></pre></td>
        </tr>                   
        </div>         
<? 

display_form <<EOF
end_form
EOF

show_validated_logo

footer ?>
<!--
##WEBIF:name:Status:150:Interfaces
-->