#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
eval $(/usr/bin/megaparam)

header "MegaStatus" "Wireless" "Wireless monitor"

if [ ".$mn_enable" = ".1" ]; then

WLDEV=$(nvram get wifi_ifname)

echo "<table border=1 cellspacing=0 cellpadding=0 width=\"90%\">"
echo "<tr><td colspan=\"7\"><b>Wireless status:</b></td></tr>"
echo "<tr><td colspan=\"7\"><pre>$(wl -i $WLDEV status 2>&1)</pre></td></tr>"
echo "<tr><td colspan=\"7\"><b>Wireless Bandwidth Usage:</b> (NOTE: graph draws CPU power, so please use it as less as possible)</td></tr>"
echo "<tr><td colspan=\"7\" align="center"><object data=\"/images/graph_if.svg?/cgi-bin/webif/megautility.sh%3Fcontext%3Dgraph%26command%3Dwifi\" width=\"500\" height=\"250\"/></td></tr>"
wl -i $WLDEV scan
sleep 2
wl -i $WLDEV scanresults|awk '
BEGIN {
	print "<tr><td colspan=\"7\"><b>Scan results:</b></td></tr>"
	print "<tr>";
	print "<td align=center><b>SSID</b></td>";
	print "<td align=center><b>Channel</b></td>";
	print "<td align=center><b>Ad-Hoc</b></td>";
	print "<td align=center><b>Open</b></td>";
	print "<td align=center><b>Signal</b></td>";
	print "<td align=center><b>Max.</b></td>";
	print "<td align=center><b>BSSID</b></td>";
	print "</tr>";
}
/^SSID:/ {
	ssid=substr($2, 2, length($2) - 2);
	chan="&nbsp;";
	adhoc="no";
	open="yes";
	rssi="0";
	titl=" ";
	rate="&nbsp;";
	bssid="&nbsp;";
	do {
		if(!(getline))break;
		if (/Channel:/) {
			chan=$NF;
		}
		if (/Mode:/) {
			adhoc=($2~/Managed/?"no":"yes");
		}
		if (/RSSI:/) {
			rssi=int(($(4+($3~/Hoc/))-$(7+($3~/Hoc/)))/4);
			for(i=3; i<=8; i++) {
				titl=titl$(i+($3~/Hoc/))" ";
			}
			if (0 > rssi) rssi = 0;
			if (5 < rssi) rssi = 5;
		}
		if (/Capability:/) {
			for(i = 4; i <= NF; i++) {
				if ($i~/^WEP/) open="no";
			}
		}
		if (/Supported Rates:/) {
			rate=$(NF - 1);
		}
		if (/BSSID:/) {
			bssid=$2;
		}
	} while(/\S/);
	print "<tr>"
	print "<td align=center>"ssid"</td>"
	print "<td align=center>"chan"</td>"
	print "<td align=center>"adhoc"</td>"
	print "<td align=center>"open"</td>"
	print "<td align=center title=\""titl"\">"rssi"/5</td>"
	print "<td align=center>"rate"</td>"
	print "<td align=center>"bssid"</td>"
	print "</tr>";
	print "<tr><td colspan=\"7\" align=\"center\">NOTE: keep mouse over Signal field to get rssi/noise values.</td></tr>"
}
END {
	print "</table>";
}'

else
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:MegaStatus:3:Wireless
-->
