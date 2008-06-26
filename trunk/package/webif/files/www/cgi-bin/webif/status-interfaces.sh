#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "Interfaces" "@TR<<Interfaces>>"

config_load network
for cfgsec in $CONFIG_SECTIONS; do
	eval "cfgtype=\$CONFIG_${cfgsec}_TYPE"
	[ "$cfgtype" = "interface" ] && {
		iflow=$(echo "$cfgsec" | tr [A-Z] [a-z])
		ifupr=$(echo "$cfgsec" | tr [a-z] [A-Z])
		eval "${iflow}_namen=\"$ifupr\""
		eval "typebr=\"\$CONFIG_${cfgsec}_type\""
		if [ "$typebr" =  "bridge" ]; then
			eval "${iflow}_ifacen=\"br-${cfgsec}\""
			eval "${iflow}_bridgen=\"1\""
		else
			eval "${iflow}_ifacen=\"\$CONFIG_${cfgsec}_ifname\""
		fi
		if [ "$iflow" != "wan" -a "$iflow" != "lan" ]; then
			frm_ifaces="$frm_ifaces $iflow"
		fi
	}
done

config_load wireless
for cfgsec in $CONFIG_SECTIONS; do
	eval "cfgtype=\$CONFIG_${cfgsec}_TYPE"
	[ "$cfgtype" = "wifi-iface" ] && {
		eval "wdevice=\"\$CONFIG_${cfgsec}_device\""
		eval "manuf=\"\$CONFIG_${wdevice}_type\""
		case "$manuf" in
			atheros)
				ath_cnt=$(( $ath_cnt + 1 ))
				cur_iface=$(printf "ath%d" "$(( $ath_cnt - 1))")
			;;
			*)
				eval "wdcnt=\$${wdevice}_cnt"
				wdcnt=$(( $wdcnt + 1 ))
				eval "${wdevice}_cnt=$wdcnt"
				if [ "$wdcnt" -gt 1 ]; then
					cur_iface=$(printf "$wdevice.%d" "$(( $wdcnt - 1))")
				else
					cur_iface="$wdevice"
				fi
			;;
		esac
		eval "cfgnet=\"\$CONFIG_${cfgsec}_network\""
		eval "isbridge=\"\$${cfgnet}_bridgen\""
		if [ "$isbridge" != "1" ]; then
			eval "${cfgnet}_ifacen=\"${cur_iface}\""
		fi
		frm_wifaces="$frm_wifaces $cur_iface"
	}
done

displaydns() {
	local resconf form_dns_servers
	resconf=$(cat /etc/dnsmasq.conf 2>/dev/null | grep "^resolv-file=" | cut -d'=' -f 2)
	resconf="${resconf:-"/etc/resolv.conf /tmp/resolv.conf.auto"}"
	resconf="`cat $resconf |grep nameserver |cut -d' ' -f2`"
	counter=1
	for dns_server in $resconf; do
		form_dns_servers="$form_dns_servers
field|@TR<<DNS Server>> ${counter}
string|$dns_server"
		let "counter+=1"
	done
	display_form <<EOF
start_form|@TR<<DNS Servers>>
$form_dns_servers
end_form
EOF
}

displayiface() {
	local ifpar="$1"
	local config ip_addr mac_addr form_mac tx_packets rx_packets tx_bytes rx_bytes
	eval "iface=\$${ifpar}_ifacen"
	if [ -n "$iface" ]; then
		config=$(ifconfig "$iface" 2>/dev/null)
		[ -n "$config" ] && {
			ip_addr=$(echo "$config" | grep "inet addr:" | cut -d: -f 2 | cut -d' ' -f 1)
			ip_addr="${ip_addr:-"&nbsp;"}"
			ip6_addr=$(echo "$config" |grep "inet6 addr:" | grep "Global" |cut -d' ' -f 13)
			[ "$ip6_addr" != "" ] && ip6_form="field|@TR<<IP6 Address>>|${ifpar}_ip6_addr
string|$ip6_addr"
			mac_addr=$(echo "$config" | grep "HWaddr" | cut -d'H' -f 2 | cut -d' ' -f 2)
			[ -n "$mac_addr" ] && form_mac="field|@TR<<MAC Address>>|${ifpar}_mac_addr
string|$mac_addr"
			tx_packets=$(echo "$config" | grep "TX packets:" | sed s/'TX packets:'//g | cut -d' ' -f 11 | int2human)
			tx_packets="${tx_packets:-0}"
			rx_packets=$(echo "$config" | grep "RX packets:" | sed s/'RX packets:'//g | cut -d' ' -f 11 | int2human)
			rx_packets="${rx_packets:-0}"
			tx_bytes=$(echo "$config" | grep "TX bytes:" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 3 | cut -d ')' -f 1)
			tx_bytes="${tx_bytes:-0}"
			rx_bytes=$(echo "$config" | grep "TX bytes:" | sed s/'TX bytes:'//g | sed s/'RX bytes:'//g | cut -d'(' -f 2 | cut -d ')' -f 1)
			rx_bytes="${rx_bytes:-0}"
			eval "if_name=\"\$${ifpar}_namen\""
			case "$ifpar" in
				wan)
					form_help="helpitem|WAN
helptext|WAN WAN#WAN stands for Wide Area Network and is usually the upstream connection to the internet."
				;;
				lan)
					form_help="helpitem|LAN
helptext|LAN LAN#LAN stands for Local Area Network."
				;;
				loopback)
					form_help="helpitem|LOOPBACK
helptext|LOOPBACK_helptext#A loopback interface is a type of 'circuitless IP address' or 'virtual IP' address, as the IP address is not associated with any one particular interface (or circuit) on the host or router. Any traffic that a computer program sends on the loopback network is addressed to the same computer."
				;;
				*)
					form_help=""
				;;
			esac
			display_form <<EOF
start_form|$if_name
$form_mac
$form_help
field|@TR<<IP Address>>|${ifpar}_ip_addr
string|$ip_addr
$ip6_form
field|@TR<<Received>>|${ifpar}_rx
string|$rx_packets @TR<<status_interfaces_pkts#pkts>>&nbsp;($rx_bytes)
field|@TR<<Transmitted>>|${ifpar}_tx
string|$tx_packets @TR<<status_interfaces_pkts#pkts>>&nbsp;($tx_bytes)
end_form
EOF
		}
	fi
}

displaywiface() {
	local wifpar="$1"
	local wconfig wlan_ssid wlan_mode wlan_freq wlan_ap wlan_txpwr wlan_key	wlan_tx_retries
	local wlan_tx_invalid wlan_tx_missed wlan_rx_invalid_nwid wlan_rx_invalid_crypt
	local wlan_rx_invalid_frag wlan_noise
	if [ -n "$wifpar" ]; then
		local wnum="$2"
		wnum="${wnum:-0}"
		wconfig=$(iwconfig "$wifpar" 2>/dev/null)
		[ -n "$wconfig" ] && {
			wlan_ssid=$(echo "$wconfig" | grep "ESSID:" | cut -d'"' -f 2 | cut -d'"' -f 1)
			wlan_mode=$(echo "$wconfig" | grep "Mode:" | cut -d':' -f 2 | cut -d' ' -f 1)
			wlan_freq=$(echo "$wconfig" | grep "Frequency:" | cut -d':' -f 3 | cut -d' ' -f 1)
			wlan_freq="${wlan_freq:-0}"
			wlan_ap=$(echo "$wconfig" | sed '/Access Point:/!d; s/^.*Access Point://; s/[[:space:]]//')
			wlan_txpwr=$(echo "$wconfig" | sed '/Tx-Power=/!d; s/^.*Tx-Power=//; s/[[:space:]].*$//')
			wlan_txpwr="${wlan_txpwr:-0}"
			wlan_key=$(echo "$wconfig" | sed '/Encryption key:/!d; s/^.*Encryption key://; s/[[:space:]].*$//')
			wlan_secmode=$(echo "$wconfig" | sed '/Security mode:/!d; s/^.*Security mode://')
			wlan_tx_retries=$(echo "$wconfig" | sed '/Tx excessive retries:/!d; s/^.*Tx excessive retries://; s/[[:space:]].*$//')
			wlan_tx_retries="${wlan_tx_retries:-0}"
			wlan_tx_invalid=$(echo "$wconfig" | sed '/Invalid misc:/!d; s/^.*Invalid misc://; s/[[:space:]].*$//')
			wlan_tx_invalid="${wlan_tx_invalid:-0}"
			wlan_tx_missed=$(echo "$wconfig" | sed '/Missed beacon:/!d; s/^.*Missed beacon://; s/[[:space:]].*$//')
			wlan_tx_missed="${wlan_tx_missed:-0}"
			wlan_rx_invalid_nwid=$(echo "$wconfig" | sed '/Rx invalid nwid:/!d s/^.*Rx invalid nwid://; s/[[:space:]].*$//')
			wlan_rx_invalid_nwid="${wlan_rx_invalid_nwid:-0}"
			wlan_rx_invalid_crypt=$(echo "$wconfig" | sed '/Rx invalid crypt:/!d; s/^.*Rx invalid crypt://; s/[[:space:]].*$//')
			wlan_rx_invalid_crypt="${wlan_rx_invalid_crypt:-0}"
			wlan_rx_invalid_frag=$(echo "$wconfig" | sed '/Rx invalid frag:/!d; s/^.*Rx invalid frag://; s/[[:space:]].*$//')
			wlan_rx_invalid_frag="${wlan_rx_invalid_frag:-0}"
			wlan_noise=$(echo "$wconfig" | sed '/Link Noise level:/!d; s/^.*Link Noise level://; s/[[:space:]].*$//')
			if [ -z "$wlan_noise" ]; then
				wlan_noise=$(echo "$wconfig" | sed '/Noise level=/!d; s/^.*Noise level=//; s/[[:space:]].*$//')
			fi
			wlan_noise="${wlan_noise:-0}"
			[ "$wnum" = "0" ] && wnum=""
			display_form <<EOF
start_form|@TR<<WLAN>> $wnum
field|@TR<<Access Point>>|wlan_ap
string|$wlan_ap
field|@TR<<Mode>>|wlan_mode
string|$wlan_mode
field|@TR<<ESSID>>|wlan_ssid
string|$wlan_ssid
field|@TR<<Frequency>>|wlan_freq
string|$wlan_freq @TR<<GHz>>
field|@TR<<Transmit Power>>|wlan_txpwr
string|$wlan_txpwr @TR<<dBm>>
field|@TR<<Noise Level>>|wlan_noise
string|$wlan_noise @TR<<dBm>>
field|@TR<<Encryption Key>>|wlan_key
string|$wlan_key
field|@TR<<Security mode>>|wlan_secmode
string|$wlan_secmode
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
end_form
EOF

		}
	fi
}

displayiface wan
displaydns
displayiface lan
for iface in $frm_ifaces; do
	displayiface $iface
done
cntr=0
for wiface in $frm_wifaces; do
	displaywiface $wiface $cntr
	cntr=$(( $cntr +1 ))
done


#########################################
# raw stats
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
	cat <<EOF

<tr>
	<th><b>@TR<<Interfaces Status WAN|WAN Interface>></b></th>
</tr>
<tr>
	<td><div class="smalltext"><pre>
EOF
	[ -n "$wan_ifacen" ] && {
		ifconfig "$wan_ifacen" 2>/dev/null
	}
	cat <<EOF
</pre></div></td>
</tr>
<tr>
	<th><b>@TR<<Interfaces Status LAN|LAN Interface>></b></th>
</tr>
<tr>
	<td><div class="smalltext"><pre>
EOF
	[ -n "$lan_ifacen" ] && {
		ifconfig "$lan_ifacen" 2>/dev/null
	}
	cat <<EOF
</pre></div></td>
</tr>
EOF
	for iface in $frm_ifaces; do
		eval "dispiface=\$${iface}_ifacen"
		[ -n "$dispiface" ] && {
			eval "if_name=\"\$${iface}_namen\""
		cat <<EOF
<tr>
	<th><b>@TR<<Interfaces Status Other|Interface>> $if_name</th>
</tr>
<tr>
	<td><div class="smalltext"><pre>
EOF
		ifconfig "$dispiface" 2>/dev/null
		cat <<EOF
</pre></div></td>
</tr>
EOF
		}
	done
	cntr=0
	for wiface in $frm_wifaces; do
		[ -n "$wiface" ] && {
			[ "$cntr" -eq 0 ] && dcntr="" || dcntr=" $cntr"
			cat <<EOF
<tr>
	<th><b>@TR<<Interfaces Status WLAN nr|Wireless Interface>>$dcntr</b></th>
</tr>
<tr>
	<td><div class="smalltext"><pre>
EOF
			iwconfig "$wiface" 2>/dev/null
	cat <<EOF
</pre></div></td>
</tr>
EOF
		}
		cntr=$(( $cntr +1 ))
	done
	display_form <<EOF
end_form
EOF
fi

footer ?>
<!--
##WEBIF:name:Status:150:Interfaces
-->
