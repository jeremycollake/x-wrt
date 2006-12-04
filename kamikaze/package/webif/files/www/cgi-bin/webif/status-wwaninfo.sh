#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

STRENGTH="n/a"

DEVICES="/dev/usb/tts/2 /dev/noz2"
for DEV in $DEVICES
do
        [ -c $DEV ] && {
                INFO=$([ -f /tmp/wwan_cardinfo.txt ] && cat /tmp/wwan_cardinfo.txt)
                STRENGTH=$(gcom -d $DEV -s /etc/gcom/getstrength.gcom |
                        grep "CSQ:" | cut -d: -f2 | cut -d, -f1)
                STRENGTH="$STRENGTH"
        }
done

header "Status" "UMTS" "@TR<<UMTS/GPRS Status>>"

cat << EOF
<pre>
$INFO
</pre>

Signalstrength:
<div>
EOF

# check if numeric
expr "$STRENGTH" + 0 >&- 2>&- && {
	echo "${STRENGTH}/31"
	echo "<div>"
	for index in $(seq 0 31)
	do
		COLOR='red'
		[ "$STRENGTH" -gt 10 ] && COLOR='yellow'
		[ "$STRENGTH" -gt 14 ] && COLOR='green'
		[ "$index" -ge "$STRENGTH" ] && COLOR='grey'
		echo '<div style="background-color:' $COLOR '; width: 25px; float:left;">&nbsp;</div>'
	done
	echo "&nbsp</div>"
	echo '<span style="font-size:smaller">(0-10: unreliable, 11-14: OK, 15-31: ideal)</span>'
} || {
	echo "${STRENGTH}"
}

footer
?>
<!--
##WEBIF:name:Status:170:UMTS
-->