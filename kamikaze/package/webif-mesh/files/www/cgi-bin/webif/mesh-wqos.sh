#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings mn_wan

header "Mesh" "wQoS" "Wireless QoS" '' "$SCRIPT_NAME"

if [ 1 ]; then

echo "<p>Please adjust the wireless performances depending on your environment.</p><br>"
	display_form <<EOF
start_form|wQoS
field|Maximum troughput
helpitem|Maximum troughput
helptext|Maximum troughput depends on the amount of nodes in your area and the distance of your peers. If you are experiencing choppy telephone calls or high pings itry lowering this value. 
end_form
EOF

else
	echo "<P>In order to use this page you must enable mesh mode; go to Mesh --> Intro page first.</P>"
fi

footer ?>
<!--
##WEBIF:name:Mesh:800:wQoS
-->
