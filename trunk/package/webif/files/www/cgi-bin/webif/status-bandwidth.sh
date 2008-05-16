#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "Bandwidth" "@TR<<Bandwidth>>"
has_pkgs bandwidthd
display_form <<EOF
formtag_begin|filterform|$SCRIPT_NAME
start_form
field|@TR<<Mode>>
select|timeline|$FORM_timeline
option|1|@TR<<Daily>>
option|2|@TR<<Weekly>>
option|3|@TR<<Monthly>>
option|4|@TR<<Yearly>>
string|</td></tr><tr><td>
submit|timelinesubmit|@TR<<Submit>>
end_form
EOF
if [ "$FORM_timeline" = "1" ]; then
	cat /www/bandwidthd/index.html |grep -q "bandwidthd has nothing to graph."
else
	cat /www/bandwidthd/index${FORM_timeline}.html |grep -q "bandwidthd has nothing to graph."
fi
if [ "$?" != "0" ]; then
	echo "<center><table width="100%" border=1 cellspacing=0>"
	if [ "$FORM_timeline" = "1" ]; then
		cat /www/bandwidthd/index.html |grep "TR"
	else
		cat /www/bandwidthd/index${FORM_timeline}.html |grep "TR"
	fi
	echo "</table></center><br/>"
	ips="`ls /www/bandwidthd/ |cut -d"-" -f1|egrep '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'|uniq`"

	cat <<EOF
<a name="Total-${FORM_timeline}">
<H2>Total</H2><BR>
Send:<br>
<img src=/bandwidthd/Total-${FORM_timeline}-S.png ALT="Sent traffic for Total"><BR>
<img src=/bandwidthd/legend.gif ALT="Legend"><br>
Received:<br>
<img src=/bandwidthd/Total-${FORM_timeline}-R.png ALT="Sent traffic for Total"><BR>
<img src=/bandwidthd/legend.gif ALT="Legend"><br>
<BR>
EOF

	for ip in $ips; do
		if [ -e /tmp/bandwidthd/${ip}-${FORM_timeline}-R.png ]; then
		cat <<EOF
<a name="${ip}-${FORM_timeline}">
<a name="/bandwidthd/${ip}-${FORM_timeline}"></a><H2> ${ip}</H2><BR>
Send:<br>
<img src=/bandwidthd/${ip}-${FORM_timeline}-S.png ALT="Sent traffic for ${ip}"><BR>
<img src=/bandwidthd/legend.gif ALT="Legend"><br>
Received:<br>
<img src=/bandwidthd/${ip}-${FORM_timeline}-R.png ALT="Sent traffic for ${ip}"><BR>
<img src=/bandwidthd/legend.gif ALT="Legend"><br>
<BR>
EOF
		fi
	done
else
	echo "@TR<<Bandwidth chart has not yet been generated, please try again later.>>"
fi
footer ?>
<!--
##WEBIF:name:Status:160:Bandwidth
-->
