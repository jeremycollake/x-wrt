#!/usr/bin/webif-page "-U /tmp -u 4096"
<? 

. /usr/lib/webif/webif.sh
uci_load "mesh"

header "Mesh" "Start" "@TR<<Mesh Start>>" ' onload="modechange()" ' "$SCRIPT_NAME"

echo "<div class=warning>Mesh pages are very alpha state: nothing is working and they can brick your router, explore at your own risk!<br></div>"
echo "<p>Mesh networks are a revolutionary networking architecture that allows direct connection between users (remember that once mesh mode is enabled some networking options are forced).</p>"

if equal "$mesh_installed" "1" ; then
	echo "TODO: write the basic options form"
else
	echo "<p>Please choose one of the following mesh technologies.</p><br>"
	install_olsr_button="field|@TR<<olsr>>
submit|install_olsr| @TR<<Install>> |"
	install_batman_button="field|@TR<<batman>>
submit|install_batman| @TR<<Install>> |"
	install_netsukuku_button="field|@TR<<netsukuku>>
submit|install_netsukuku| @TR<<Install>> |"
	install_meganetwork_button="field|@TR<<meganetwork>>
submit|install_meganetwork| @TR<<Install>> |"
	install_help="helpitem|Technologies description
helptext|HelpText install_mesh_help#OLSR is a pretty mature routing protocol mainly developed at Berlin Freifunk project and some other german wireless communities. Batman is the young protocol born to superseed OLSR. Netsukuku is a completely decentralized fractal protocol developed by the italian Freaknet Medialab. Meganetwork is an easy to use customized OLSR mesh platform."
fi

display_form <<EOF
onchange|modechange
start_form|@TR<<Mesh>>
$primary_mesh_form
$install_olsr_button
$install_batman_button
$install_netsukuku_button
$install_meganetwork_button
$install_help
end_form
EOF

footer ?>
<!--
##WEBIF:name:Mesh:100:Start
-->
