#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "Interfaces" "@TR<<Interfaces Status>>"

# get WAN IP
wan_config=$(ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`")
wan_ip_addr=$(echo "$wan_config" | grep "inet addr" | cut -d: -f 2 | sed s/Bcast//g)
wan_mac_addr=$(echo "$wan_config" | grep "HWaddr" | cut -d' ' -f 10)
wan_tx_packets=$(echo "$wan_config" | grep "TX packets" | sed s/'TX packets:'//g | cut -d' ' -f 11)
wan_rx_packets=$(echo "$wan_config" | grep "RX packets" | sed s/'RX packets:'//g | cut -d' ' -f 11)
wan_tx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d')' -f 2) 
wan_rx_bytes=$(echo "$wan_config" | grep "TX bytes" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d')' -f 1) 
 
# enumerate WAN nameservers
form_dns_servers=$(awk '
	BEGIN { counter=1 }
	/nameserver/ {print "field|@TR<<DNS Server>> " counter "|dns_server_" counter "\n string|" $2 "\n" ;counter+=1}
	' /etc/resolv.conf)
 
display_form <<EOF
start_form|@TR<<WAN Status>>
field|@TR<<MAC Address>>|wan_mac_addr
string|$wan_mac_addr
field|@TR<<IP Address>>|wan_ip_addr
string|$wan_ip_addr
$form_dns_servers
field|@TR<<Received>>|wan_rx
string|$wan_rx_packets packets<br />$wan_rx_bytes)
field|@TR<<Transmitted>>|wan_tx
string|$wan_tx_packets packets<br />$wan_tx_bytes)
end_form
start_form|@TR<<Raw Interface Status Info>>
EOF
?>
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
<? 

display_form <<EOF
end_form
EOF

show_validated_logo

footer ?>
<!--
##WEBIF:name:Status:150:Interfaces
-->