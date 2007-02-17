#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "MegaStatus" "Overview" "System overview"
WAN=$(uci show network.wan.ifname)
PAN=$(uci show network.lan.ifname)
WIFI=$(uci show network.wifi.ifname)
?>

<SCRIPT LANGUAGE="JavaScript"><!--
function fold(id) {
obj = document.getElementById(id);
obj.style.display = ('none'==obj.style.display?'block':'none');
return false;
}
//--></SCRIPT>

<div><table border=1 cellpadding=0 cellspacing=0 width=\"90%\">
<tr><td align=center><b>uptime</b></td><td colspan=2><pre><? uptime ?></pre></td></tr>
<tr><td align=center><b>free</b></td><td colspan=2><pre><? free ?></pre></td></tr>
<tr><td align=center><b>df</b></td><td colspan=2><pre><? df ?></pre></td></tr>
<tr><td align=center><b>Kernel log</b></td><td colspan=2 align=center><A HREF="#" ONCLICK="return fold('dmesg')">Show / Hide</A></td></tr>
<tr><td colspan="3"><PRE STYLE="display:none" ID="dmesg">
<?
dmesg
?>
</PRE></td></tr>

<tr><td align=center><b>System log</b></td><td colspan=2 align=center><A HREF="#" ONCLICK="return fold('syslog')">Show / Hide</A></td></tr>
<tr><td colspan="3"><PRE STYLE="display:none" ID="syslog">
<?
logread
?>
</PRE></td></tr>

<tr><td align=center><b>Interfaces</b></td><td colspan=2 align=center><A HREF="#" ONCLICK="return fold('interfaces')">Show / Hide</A></td></tr>
<tr><td colspan="3"><PRE STYLE="display:none" ID="interfaces">
<?
echo "lan_ifnames=$(uci show network.lan.ifnames)"
echo "lan_ifname=$(uci show network.lan.ifname)"
echo "wl0_ifname=$(nvram get wl0_ifname)"
echo "wifi_ifname=$(uci show network.wifi.ifname)"
echo "wan_ifname=$(nvram get wan_ifname)"
echo
brctl show 2>&1
echo
ifconfig 2>&1
?>
</PRE></td></tr>

<tr><td align=center><b>Routes</b></td><td colspan=2 align=center><A HREF="#" ONCLICK="return fold('routes')">Show / Hide</A></td></tr>
<tr><td colspan="3"><PRE STYLE="display:none" ID="routes">
<?
route -n|awk '
function td(s) {
	printf("<TD>%s</TD>", s);
}
function ip(s, m) {
	if(m=="255.255.255.255"&&s!="0.0.0.0") {
		td(sprintf("<A HREF=\"http://%s/\">%s</A>", s, s));
	} else {
		td(s);
	}
}
BEGIN {
	print "<""TABLE BORDER=1 CELLSPACING=0 CELLPADDING=0 WIDTH=\"90%\">";
}
/^[0-9]/ {
	printf "<TR>";
	ip($1, $3);
	ip($2, $3);
	for(i=3;i<=NF;i++) td($i);
		printf "</TR>\n";
	}
/^Destination/ {
	printf "<TR>";
	for(i=1;i<=NF;i++) printf("<TH>%s</TH>", $i);
		printf "</TR>\n";
	}
END {
	print "<""/TABLE>";
}'
?>
</PRE></td></tr>

</table></div>

<? footer ?>
<!--
##WEBIF:name:MegaStatus:1:Overview
-->
