#!/usr/bin/webif-page
<?
###################################################################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	wl0_ifname
#	wl0_mode
#	wl0_infra  (unnecessary to be 1? -- seems so in tests so far)
#
# Configuration files referenced:
#   none
#
# TODO:
#   I originally wrote this before I had bothered to learn much about
#   awk, so it uses 'pure' shell scripting. It would be much simpler
#   and probably more efficient to use awk. Maybe recode someday, but
#   why fix what's isn't broken...
#
#
#

. "/usr/lib/webif/webif.sh"
header "Status" "Site Survey" "@TR<<Wireless survey>>"

is_kamikaze && ShowNotUpdatedWarning

MAX_TRIES=4
MAX_CELLS=100
WL0_IFNAME=$(nvram get wl0_ifname)
##################################################
# Handle switch to sta mode at user request
#
if empty "$FORM_clientswitch"; then
	CLIENT_SWITCH_BUTTON="<form enctype=\"multipart/form-data\" method=\"post\"><input type=\"submit\" value=\" @TR<<Scan>> \" name=\"clientswitch\" /></form>"
else
	ORIGINAL_WL_MODE=$(nvram get wl0_mode)
	nvram set wl0_mode="sta"
	# tests show scan works in infra or ad-hoc mode, but we'll do this to be safe
	ORIGINAL_INFRA=$(nvram get wl0_infra)
	nvram set wl0_infra="1"
	wifi up 2>/dev/null >/dev/null </dev/null
fi
WL_MODE=$(nvram get wl0_mode)
?>
<table style="width: 90%; text-align: center;" border="0" cellpadding="2" cellspacing="2">
<tbody>
<?
##################################################
#
if equal $WL_MODE "ap" ; then
	echo "<table><tbody><tr><td>@TR<<HelpText WLAN Survey#Your wireless adaptor is not in client mode. To do a scan it must be put into client mode for a few seconds. Your WLAN traffic will be interrupted during this brief period.>>" \
	"<tr><td><br /></td></tr><tr><td>$CLIENT_SWITCH_BUTTON</td></tr></tbody></table>"
else

tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)

#echo " Please wait while scan is performed ... <br /><br />"
found_networks=0
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

		####################################################
		# parse out channel
		CHANNEL_ID=$(grep -i "Channel" < "$tempfile"_"${current}" | sed -e s/'Channel:'//g -e s/' '//g)

		####################################################
		# parse out signal
		quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality:'//g -e s/'Signal level:'//g  -e s/'dBm'//g -e s/'Noise level:'//g)
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
			string|<tr><td><strong>@TR<<SSID>></strong> $ESSID (<a href=\"http://standards.ieee.org/cgi-bin/ouisearch?$MAC_FIRST_THREE\" target=\"_new\">$MAC_DASHES</a>)</td></tr>
			string|<tr><td><strong>@TR<<Channel>></strong> $CHANNEL_ID</td></tr>
			$QUALITY_STRING
			string|<tr><td><strong>@TR<<Signal>></strong> $SIGNAL_DBM dBm / <strong>Noise</strong> $NOISE_DBM dBm</td></tr><tr><td>
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
	nvram set wl0_mode=$ORIGINAL_WL_MODE
	nvram set wl0_infra=$ORIGINAL_INFRA
	wifi up 2>/dev/null >/dev/null </dev/null
fi
fi # end if is in 'allowed to scan' mode
?>

</tbody></table>

<?
if equal "$found_networks" "0"; then
	echo "@TR<<No wireless networks were found>>."
else
	if ! empty "$FORM_clientswitch"; then
		display_form <<EOF
		start_form|@TR<<Survey Results>>
		$FORM_cells
		end_form|
EOF
	fi
fi
?>

<? footer ?>
<!--
##WEBIF:name:Status:980:Site Survey
-->
