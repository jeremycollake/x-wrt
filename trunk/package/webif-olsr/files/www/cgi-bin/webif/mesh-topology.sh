#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

header "Mesh" "Topology" "Mesh Topology"

echo "<div class=warning>This page is actually at very alpha state, few functinalities are working, explore at your own risk!</div><br><br>"

if [ ".$(uci get mesh.general.enable)" = ".1" ]; then

echo "<p>This page shows you the \"shape\" of the wireless network you are part of.</p><br>"

echo "<DIV><TABLE><TR><TD>"
wget -O - http://127.0.0.1:8080/all|awk '
/<h2>/, /<\/div>/ {
gsub("border=0", "border=1 cellspacing=0 cellpadding=0")
gsub("BORDER=0", "BORDER=1")
gsub("<select", "<select name=none")
print
}'
echo "</TD></TR></TABLE></DIV>"

else
	echo "<P>In order to use this page you must enable mesh mode; go to Mesh --> Start page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Mesh:400:Topology
-->
