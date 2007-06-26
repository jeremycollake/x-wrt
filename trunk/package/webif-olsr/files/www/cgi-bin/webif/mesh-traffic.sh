#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
# eval $(/usr/bin/megaparam)

header "Mesh" "Traffic" "Mesh traffic counters"

echo "<div class=warning>This page is actually at very alpha state, few functinalities are working, explore at your own risk!</div><br><br>"

if [ ".$mn_enable" = ".1" ]; then

echo "<p>In this page you can get some statistics about the traffic flowing trough your node.</p><br>"

echo "<PRE>"
iptables -nv -t mangle -L
echo "</PRE>"

else
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

 footer ?>
<!--
##WEBIF:name:Mesh:500:Traffic
-->
