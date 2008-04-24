#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
#################################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Travis Kemen <thepeople@berlios.de>
#
# TODO:
#   I originally wrote this before I had bothered to learn much about
#   awk, so it uses 'pure' shell scripting. It would be much simpler
#   and probably more efficient to use awk. Maybe recode someday, but
#   why fix what's isn't broken...
#

header "Status" "Site Survey" "@TR<<Site Survey>>"
config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
	        wifi-device)
	                append DEVICES "$cfg_name"
	        ;;
	        wifi-iface)
	                append vface "$cfg_name" "$N"
	        ;;
	esac
}
uci_load wireless
for DEVICE in $DEVICES; do
	config_get type $DEVICE type
	echo "$type" |grep -q broadcom
	[ "$?" = 0 ] && {
		config_get disabled $DEVICE disabled
		[ "$disabled" = "0" ] && scan_iface=1
	}
	echo "$type" |grep -q atheros
	[ "$?" = 0 ] && {
		config_get disabled $DEVICE disabled
		[ "$disabled" = "0" ] && atheros_devices="$atheros_devices $DEVICE"
	}
done
for ath_device in $atheros_devices; do
	for i in $vface; do
		config_get iface $i device
		if [ "$iface" = "$ath_device" ]; then
			config_get mode $i mode
			echo "$mode" |grep -q sta
			[ "$?" = 0 ] && scan_iface=1
		fi
	done
done

if [ "$FORM_clientswitch" != "" ]; then
	for DEVICE in $DEVICES; do
		config_get type $DEVICE type
		echo "$type" |grep -q broadcom
		[ "$?" = 0 ] && {
			wifi down
			wlc stdin <<EOF
down
vif 0
enabled 0
vif 1
enabled 0
vif 2
enabled 0
vif 3
enabled 0

ap 1
mssid 1
apsta 0
infra 1

802.11d 0
802.11h 0
rxant 3
txant 3

radio 1
macfilter 0
maclist none
wds none

country IL0
channel 5
maxassoc 128
slottime -1

vif 0
closed 0
ap_isolate 0
up
vif 0
vlan_mode 0
ssid OpenWrt
enabled 1
EOF
			scan_iface=1
			break
		}
		echo "$type" |grep -q atheros
		[ "$?" = 0 ] && {
			wifi down
			wlanconfig ath0 create wlandev wifi0 wlanmode sta
			scan_iface=1
			ifconfig ath0 up
		}
			
	done
fi

if [ "$scan_iface" != "1" ]; then
	cat <<EOF
<div class="settings">
<form enctype="multipart/form-data" method="post" action="$SCRIPT_NAME">
<h3><strong>@TR<<Wireless Survey>></strong></h3>
<p>@TR<<HelpText WLAN Survey#Your wireless adaptor is not in client mode. To do a scan it must be put into client mode for a few seconds. Your WLAN traffic will be interrupted during this brief period. Please commit any wireless changes as this will remove anything not yet committed>></p>
<input type="submit" value=" @TR<<Scan>> " name="clientswitch" />
</form>
<div class="clearfix">&nbsp;</div></div>
EOF
fi

##### Variables

MAX_TRIES=4
MAX_CELLS=100
tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)

if [ "$scan_iface" = "1" ]; then
#echo " Please wait while scan is performed ... <br /><br />"
counter=0
for counter in $(seq 1 $MAX_TRIES); do
	#echo "."
	iwlist scan > $tempfile 2> /dev/null
	grep -i "Address" < $tempfile >> /dev/null
	equal "$?" "0" && break
	sleep 1
done

first_hit=1
if [ $counter -gt $MAX_TRIES ]; then
	echo "<tr><td>@TR<<Sorry, no scan results.>></td></tr>"
else
	current=0
	counter=0
	for counter in $(seq 1 $MAX_CELLS); do
		current_line=$(sed '2,$ d' < $tempfile)
		empty "$current_line" && break
		# line must contain both "Cell" and "Address" to be considered
		#  start of a new cell..
		echo "$current_line" | grep "Cell" >> /dev/null
		result_one=$?
		echo "$current_line" | grep "Address" >> /dev/null
		result_two=$?
		equal "$result_one" "0" && equal "$result_two" "0" && {
			equal "$first_hit" "0" && {
				let "current+=1"
			}
			first_hit=0
		}
		equal "$first_hit" "0" && {
			echo "$current_line" >> "$tempfile"_"${current}"
		}

		sed 1d < $tempfile > $tempfile2
		rm $tempfile
		mv $tempfile2 $tempfile
	done

	current=0
	counter=0
	for counter in $(seq 1 $MAX_CELLS); do
		! exists "$tempfile"_"${current}" && break
		####################################################
		# parse out MAC
		address_pre=$(sed '2,$ d' < "$tempfile"_"${current}" | sed -e s/'Cell'//g -e s/'Address'//g -e s/'-'//g)
		count=0
		for i in $address_pre; do
			case $count in
				0) CELL_ID=$i;;
				2) MAC_ID=$i;;
				3) break;;
			esac
			let "count+=1"
		done

		####################################################
		# parse out essid
		ESSID=$(grep -i "ESSID" < "$tempfile"_"${current}" | sed -e s/'ESSID:'//g -e s/'"'//g)

		grep -q "Frequency:" < "$tempfile"_"${current}"
		if [ "$?" = "0" ]; then
			####################################################
			# parse out channel
			CHANNEL_ID=$(grep -i "Frequency:" < "$tempfile"_"${current}" | sed -e s/'Frequency:'//g -e s/' '//g)

			####################################################
			# parse out signal
			quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality='//g -e s/'Signal level='//g  -e s/'dBm'//g -e s/'Noise level='//g)
		else
			####################################################
			# parse out channel
			CHANNEL_ID=$(grep -i "Channel" < "$tempfile"_"${current}" | sed -e s/'Channel:'//g -e s/' '//g)

			####################################################
			# parse out signal
			quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality:'//g -e s/'Signal level:'//g  -e s/'dBm'//g -e s/'Noise level:'//g)
		fi
		count=0
		for i in $quality_pre; do
			case $count in
				0) QUALITY=$i;;
				1) SIGNAL_DBM=$i;;
				2) NOISE_DBM=$i
					break;;
			esac
			let "count+=1"
		done

		#
		# only show quality if it's not 0/0
		#
		if ! equal "$QUALITY" "0/0"; then
			QUALITY_STRING="string|<tr><td>@TR<<Quality>> $QUALITY</tr></td>"
		fi

		NOISE_BASE=-99
		NOISE_DELTA=$(expr $NOISE_BASE - $NOISE_DBM)

		SIGNAL_INTEGRITY=$(expr $SIGNAL_DBM + $NOISE_DELTA)
		MAC_DASHES=$(echo "$MAC_ID" | sed s/':'/'-'/g)
		MAC_FIRST_THREE=$(echo "$MAC_DASHES" | cut -c1-8)
		SNR_PERCENT=$(expr 100 + $SIGNAL_INTEGRITY)

		FORM_cells="$FORM_cells
			string|<tr><td><strong>@TR<<Cell>></strong> $CELL_ID</td></tr>
			string|<tr><td><strong>@TR<<SSID>></strong> $ESSID (<a href=\"http://standards.ieee.org/cgi-bin/ouisearch?$MAC_FIRST_THREE\" target=\"_blank\">$MAC_DASHES</a>)</td></tr>
			string|<tr><td><strong>@TR<<Channel>></strong> $CHANNEL_ID</td></tr>
			$QUALITY_STRING
			string|<tr><td><strong>@TR<<Signal>></strong> $SIGNAL_DBM dBm / <strong>@TR<<Noise>></strong> $NOISE_DBM dBm</td></tr><tr><td>
			progressbar|SNR|<strong>@TR<<SNR>></strong> $SIGNAL_INTEGRITY dBm|200|$SNR_PERCENT|$SIGNAL_INTEGRITY dBm
			string|</td></tr><tr><td>&nbsp;</td></tr>"

		rm -f "$tempfile"_"${current}"
		let "found_networks+=1"
		let "current+=1"
	done
fi # end if were scan results

rm -f "$tempfile"
rm -f "$tempfile2"

if ! empty "$FORM_clientswitch"; then
	#echo "<tr><td>Restoring settings...</tr></td>"
	# restore radio to its original state
	wifi
fi
fi # end if is in 'allowed to scan' mode

if [ "$scan_iface" = "1" ]; then
	if equal "$found_networks" "0"; then
		echo "@TR<<No wireless networks were found>>."
	else
		display_form <<EOF
		start_form|@TR<<Survey Results>>
		$FORM_cells
		end_form|
EOF
	fi
fi

footer ?>
<!--
##WEBIF:name:Status:980:Site Survey
-->
