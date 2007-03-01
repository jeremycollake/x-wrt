#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

DEVICES="/dev/usb/tts/2 /dev/noz2"
for DEV in $DEVICES
do
	[ -c $DEV ] && {
		INFO=$([ -f /tmp/wwan_cardinfo.txt ] && cat /tmp/wwan_cardinfo.txt)
		INFO=$(gcom -d $DEV -s /etc/gcom/getstrength.gcom 2>/dev/null)
		STRENGTH=$(gcom -d $DEV -s /etc/gcom/getstrength.gcom 2>/dev/null |
					grep "CSQ:" | cut -d: -f2 | cut -d, -f1)
		STRENGTH="$STRENGTH"
	}
done

header "Status" "UMTS" "@TR<<status_wwaninfo_UG_Status#UMTS/GPRS Status>>"

equal "$INFO" "" && equal "$INFO" "$STRENGTH" && {
	echo "<p>@TR<<status_wwaninfo_no_UG_device#UMTS / GPRS device not found.>></p>"
	footer
	exit
}

display_form <<EOF
start_form|@TR<<status_wwaninfo_Device_Information#Device Information>>
EOF

if ! equal "$INFO" ""; then
	echo "$INFO" | awk -F ":" '
		BEGIN {
			print "	<tr>"
			print "		<th>@TR<<status_wwaninfo_dev_th_Information#Information>></th>"
			print "		<th>@TR<<status_wwaninfo_dev_th_Reported_Value#Reported Value>></th>"
			print "	</tr>"
		}
		{
			print "	<tr>"
			print "		<td>" $1 "</td>"
			col2=$2
			for (i=3; i<=NF; i++)
				col2 = col2 ":" $i
			print "		<td>" col2 "</td>"
			print "	</tr>"
		}'
else
	echo "	<tr>"
	echo "		<td colspan=\"2\">@TR<<status_wwaninfo_No_device_info#No device information reported.>></td>"
	echo "	</tr>"
fi

display_form <<EOF
end_form
EOF

echo "<div class="settings">"
echo "<h3>@TR<<status_wwaninfo_Signal_Strength#Signal Strength>></h3>"
echo "<p>@TR<<status_wwaninfo_Signal_Strength#Signal Strength>>:"

# check if numeric
expr "$STRENGTH" + 0 >&- 2>&- && {
	if [ "$STRENGTH" -eq 99 ]; then
		echo "${STRENGTH} (@TR<<status_wwaninfo_rssi_unknown#unknown>>)</p>"
	else
		echo "${STRENGTH}</p>"
		echo "<div>"
		for index in $(seq 0 31)
		do
			COLOR='red'
			[ "$STRENGTH" -gt 10 ] && COLOR='yellow'
			[ "$STRENGTH" -gt 14 ] && COLOR='green'
			[ "$index" -ge "$STRENGTH" ] && COLOR='grey'
			echo "<div style=\"background-color:" $COLOR "; width: 20px; float:left;\">&nbsp;</div>"
		done
		echo "</div>"
		echo "<br />"
		echo "<div><span style=\"font-size: smaller\">(<span style=\"background-color: red;\">&nbsp;</span> 0-10: unreliable, <span style=\"background-color: yellow;\">&nbsp;</span> 11-14: OK, <span style=\"background-color: green;\">&nbsp;</span> 15-31: ideal)</span></div>"
	fi
} || {
	echo "${STRENGTH} (@TR<<status_wwaninfo_rssi_wrong_value#wrong value reported)>></p>"
}
echo "</div>"

footer
?>
<!--
##WEBIF:name:Status:170:UMTS
-->
