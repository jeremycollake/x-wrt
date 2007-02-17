#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
eval $(/usr/bin/megaparam)

header "Status" "Mesh-Topology" "Mesh monitor"

if [ ".$mn_enable" = ".1" ]; then

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
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Status:994:Mesh-Topology
-->
