#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

DEVICES="/dev/usb/tts/2 /dev/noz2"
for DEV in $DEVICES
do
	[ -c $DEV ] && {
		INFO=$(gcom -d $DEV info 2>/dev/null | grep -v "^####")
		STRENGTH=$(gcom -d $DEV -s /etc/gcom/getstrength.gcom 2>/dev/null | grep "CSQ:" |
			cut -d: -f2 | cut -d, -f1 | sed 's/[^[:digit:]]\{1,\}\([[:digit:]]\{1,2\}\)$/\1/')
	}
done

header "Status" "UMTS" "@TR<<status_wwaninfo_UG_Status#UMTS/GPRS Status>>"

equal "$INFO" "" && equal "$INFO" "$STRENGTH" && {
	echo "<p>@TR<<status_wwaninfo_no_UG_device#UMTS / GPRS device not found.>></p>"
	footer
	exit
}

display_form <<EOF
start_form|@TR<<status_wwaninfo_device_info#Device Information>>
EOF

if ! empty "$INFO"; then
	echo "$INFO" | awk -F ":" '
		BEGIN {
			print "	<tr>"
			print "		<th>@TR<<status_wwaninfo_dev_th_Information#Information>></th>"
			print "		<th>@TR<<status_wwaninfo_dev_th_Value#Value>></th>"
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
	echo "		<td colspan=\"2\">@TR<<status_wwaninfo_no_UG_device_info#No device information reported.>></td>"
	echo "	</tr>"
fi

display_form <<EOF
end_form
EOF

! empty "$STRENGTH" && {
	cat <<EOF
<h3>@TR<<status_wwaninfo_Signal_Quality#Signal Quality>></h3>
EOF

	# check if numeric
	expr "$STRENGTH" + 1 >&- 2>&- && {
		if [ "$STRENGTH" -gt 31 ]; then
			echo "<p>@TR<<status_wwaninfo_quality_unknown#Signal quality is invalid/unknown>>: ${STRENGTH}</p>"
		else
			progress_type="unreliable"
			[ "$STRENGTH" -gt 9 ] && progress_type="workable"
			[ "$STRENGTH" -gt 14 ] && progress_type="good"
			[ "$STRENGTH" -gt 19 ] && progress_type="excellent"
			cat << EOF
<style type="text/css">
/*<![CDATA[*/
<!--

#wwanbars * { padding: 0; margin: 0; }

#wwanbars body {
	font-family: Verdana;
	font-size: 1em;
	line-height: 1em;
	padding: 1em;
}

#wwanbars .wwan_status { padding-top: 5em; }

#wwanbars ul { list-style-type: none; }

#wwanbars ul li { clear: both; height: 1.2em; }

#wwanbars .title { width: 10em; float: left; }

#wwanbars .progress {
	text-align: right;
	display: block;
	float: left;
	clear: right;
	font-size: 0.964em;
	padding: 0.1em;
	margin-bottom: 0.2em;
}

#wwanbars h4 { display: none; }

/* Legend */

#wwanbars .legend {
	position: absolute;
	margin-top: -5.3em;
	margin-left: 10em;
	clear: both;
	width: 30em;
	border-left: 1px solid Gray;
	border-right: 1px solid Gray;
}

#wwanbars dl {
	float: left;
	text-align: center;
	width: 30%;
	font-size: 0.8em;
	line-height: 1.5em;
}

#wwanbars dl.workable { width: 16%; }

#wwanbars dl.good { width: 16%; }

#wwanbars dl.excellent { width: 38%; }

#wwanbars dl+dl dt, dl+dl dd { border-left: 1px solid Gray; }

#wwanbars dd .title { display: none; }

#wwanbars dd.dbm { margin-top: 4em; }

/* Colors for status health */

#wwanbars dl.unreliable dt, span.progress.unreliable { background-color: #ff7474; }

#wwanbars dl.workable dt, span.progress.workable { background-color: #fffa74; }

#wwanbars dl.good dt, span.progress.good { background-color: #ace4ff; }

#wwanbars dl.excellent dt, span.progress.excellent { background-color: #6fff6c; }

-->
/*]]>*/
</style>
<div id="wwanbars"><div class="wwan_status">
	<ul>
		<li>
			<span class="title">@TR<<status_wwaninfo_Signal_Quality#Signal Quality>>:</span> <span class="progress ${progress_type}" style="width: ${STRENGTH}em;">${STRENGTH}</span>
		</li>
		<li>
			<span class="title">@TR<<status_wwaninfo_Power_Ratio#Power Ratio (dBm)>>:</span> <span class="progress ${progress_type}" style="width: ${STRENGTH}em;">$((-113 + $STRENGTH * 2))</span>
		</li>
	</ul>
	<h4>@TR<<status_wwaninfo_Legend#Legend>>:</h4>
	<div class="legend">
		<dl class="unreliable">
EOF
			if equal "$progress_type" "unreliable"; then
				echo "			<dt><strong>@TR<<status_wwaninfo_quality_Unreliable#Unreliable>></strong></dt>"
			else
				echo "			<dt>@TR<<status_wwaninfo_quality_Unreliable#Unreliable>></dt>"
			fi
			cat << EOF
			<dd><span class="title">@TR<<status_wwaninfo_Signal_Quality#Signal Quality>>:</span> 0..9</dd>
			<dd class="dbm"><span class="title">@TR<<status_wwaninfo_Power_Ratio#Power Ratio (dBm)>>:</span> -113..-95</dd>
		</dl>
		<dl class="workable">
EOF
			if equal "$progress_type" "workable"; then
				echo "			<dt><strong>@TR<<status_wwaninfo_quality_Workable#Workable>></strong></dt>"
			else
				echo "			<dt>@TR<<status_wwaninfo_quality_Workable#Workable>></dt>"
			fi
			cat << EOF
 			<dd><span class="title">@TR<<status_wwaninfo_Signal_Quality#Signal Quality>>:</span> 10..14</dd>
			<dd class="dbm"><span class="title">@TR<<status_wwaninfo_Power_Ratio#Power Ratio (dBm)>>:</span> -93..-85</dd>
		</dl>
		<dl class="good">
EOF
			if equal "$progress_type" "good"; then
				echo "			<dt><strong>@TR<<status_wwaninfo_quality_Good#Good>></strong></dt>"
			else
				echo "			<dt>@TR<<status_wwaninfo_quality_Good#Good>></dt>"
			fi
			cat << EOF
			<dd><span class="title">@TR<<status_wwaninfo_Signal_Quality#Signal Quality>>:</span> 15..19</dd>
			<dd class="dbm"><span class="title">@TR<<status_wwaninfo_Power_Ratio#Power Ratio (dBm)>>:</span> -83..-75</dd>
		</dl>
		<dl class="excellent">
EOF
			if equal "$progress_type" "excellent"; then
				echo "			<dt><strong>@TR<<status_wwaninfo_quality_Excellent#Excellent>></strong></dt>"
			else
				echo "			<dt>@TR<<status_wwaninfo_quality_Excellent#Excellent>></dt>"
			fi
			cat << EOF
			<dd><span class="title">@TR<<status_wwaninfo_Signal_Quality#Signal Quality>>:</span> 20..31</dd>
			<dd class="dbm"><span class="title">@TR<<status_wwaninfo_Power_Ratio#Power Ratio (dBm)>>:</span> -73..-51</dd>
		</dl>
	</div>
</div></div>
<br />
EOF
		fi
	} || {
		echo "<p>@TR<<status_wwaninfo_wrong_value#Wrong signal quality value>>: ${STRENGTH}</p>"
	}
}

footer
?>
<!--
##WEBIF:name:Status:170:UMTS
-->
