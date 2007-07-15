#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

# todo add /enable/disable for mx and wildcard / connection type. Add packages checker depending on on service type
#ezip            { "server", "user", "address", "wildcard", "mx", "url", "host", NULL };
#pgpow           { "server", "host", NULL };
#dhs             { "server", "user", "address", "wildcard", "mx", "url", "host", NULL };
#dyndns          { "server", "user", "address", "wildcard", "mx", "host", NULL };
#dyndns-static, dyndns-custom { "server", "user", "address", "wildcard", "mx", "host", NULL };
#ods             { "server", "host", "address", NULL };
#tzo             { "server", "user", "address", "host", "connection-type", NULL };
#easydns         { "server", "user", "address", "wildcard", "mx", "host", NULL };
#easydns-partner { "server", "partner", "user", "address", "wildcard", "host", NULL };
#gnudip          { "server", "user", "host", "address", NULL };
#justlinux       { "server", "user", "host", NULL };
#dyns            { "server", "user", "host", NULL };
#hn              { "server", "user", "address", NULL };
#zoneedit        { "server", "user", "address", "mx", "host", NULL };
#heipv6tb        { "server", "user", NULL };

header "Network" "DynDNS" "@TR<<DynDNS Settings>>" 'onload="modechange()"' "$SCRIPT_NAME"

#define supported services
services="changeip dyndns eurodyndns ovh noip ods hn regfish tzo zoneedit"

#generate fields for supported services
for service in $services; do
	service_option="$service_option
option|$service"
	
	ipkg list_installed | grep -q $service
	! equal "$?" 0 && {
		package_checker="$package_checker
field|@TR<<Dynamic DNS Package>>|install_$service|hidden
string|<div class=\"warning\">$service will not work until you install the $service package. </div>
submit|install_$service|@TR<<Install>> $service @TR<<Package>>|"

		js="$js
v = isset('ddns_service','$service');
set_visible('install_$service', v);"

		eval FORM_installer="\$FORM_install_$service"

		if ! empty "$FORM_installer"; then
			echo "Installing $service package ...<pre>"
			install_package "updatedd-mod-$service"
			echo "</pre>"
		fi
	}
done

if empty "$FORM_submit"; then
	uci_load "updatedd"
	config_get FORM_ddns_service cfg1 ddns_service 
	config_get FORM_ddns_user    cfg1 ddns_user
	config_get FORM_ddns_passwd  cfg1 ddns_passwd
	config_get FORM_ddns_host    cfg1 ddns_host
	config_get FORM_ddns_update  cfg1 ddns_update
else
	SAVED=1
	validate <<EOF
string|FORM_ddns_service|@TR<<Service Type>>|required|$FORM_ddns_service
string|FORM_ddns_user|@TR<<User Name>>|required|$FORM_ddns_user
string|FORM_ddns_passwd|@TR<<Password>>|required|$FORM_ddns_passwd
string|FORM_ddns_host|@TR<<Host Name>>||$FORM_ddns_host
#hostname|FORM_ddns_server|@TR<<Server Name>>||$FORM_ddns_server
#int|FORM_ddns_max_interval|@TR<<Max Interval (sec)>>|min=86400 max=2196000|$FORM_ddns_max_interval
EOF
	equal "$?" 0 && {
		uci_set "updatedd" "cfg1" "ddns_update" "$FORM_ddns_update"
		uci_set "updatedd" "cfg1" "ddns_service" "$FORM_ddns_service"
		uci_set "updatedd" "cfg1" "ddns_user" "$FORM_ddns_user"
		uci_set "updatedd" "cfg1" "ddns_passwd" "$FORM_ddns_passwd"
		uci_set "updatedd" "cfg1" "ddns_host" "$FORM_ddns_host"
	}
fi

cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	$js

	hide('save');
	show('save');
}
-->
</script>

EOF

display_form <<EOF
onchange|modechange
start_form|@TR<<DynDNS>>
field|@TR<<Dynamic DNS Update>>
radio|ddns_update|$FORM_ddns_update|1|@TR<<Enable>>
radio|ddns_update|$FORM_ddns_update|0|@TR<<Disable>>
field|@TR<<Service Type>>
select|ddns_service|$FORM_ddns_service
$service_option
$package_checker
end_form

start_form|@TR<<Account>>
field|@TR<<User Name>>
text|ddns_user|$FORM_ddns_user
field|@TR<<Password>>
password|ddns_passwd|$FORM_ddns_passwd
end_form

start_form|@TR<<Host>>
field|@TR<<Host Name>>
text|ddns_host|$FORM_ddns_host

#field|@TR<<Wildcard>>
#radio|ddns_wildcard|$FORM_ddns_wildcard|1|@TR<<Enable>>
#radio|ddns_wildcard|$FORM_ddns_wildcard|0|@TR<<Disable>>
end_form

#start_form|@TR<<Server>>
#field|@TR<<Server Name>
#text|ddns_server|$FORM_ddns_server
#field|@TR<<Max Interval (sec)>>
#text|ddns_max_interval|$FORM_ddns_max_interval
#end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:651:DynDNS
-->
