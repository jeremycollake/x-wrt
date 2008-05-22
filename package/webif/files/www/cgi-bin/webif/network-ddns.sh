#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

# todo:
#  add /enable/disable for mx and wildcard / connection type.

uci_load "webif"
config_get revision general firmware_version
if [ "$revision" = "7.07" ]; then
	config_username="user"
	config_password="passwd"
else
	config_username="username"
	config_password="password"
fi

if empty "$FORM_submit"; then
	uci_load "updatedd"
	config_get FORM_service cfg1 service 
	config_get FORM_username cfg1 "$config_username"
	config_get FORM_password cfg1 "$config_password"
	config_get FORM_host cfg1 host
	config_get FORM_update cfg1 update
else
	SAVED=1
	validate <<EOF
string|FORM_service|@TR<<Service Type>>|required|$FORM_service
string|FORM_username|@TR<<User Name>>|required|$FORM_username
string|FORM_password|@TR<<Password>>|required|$FORM_password
string|FORM_host|@TR<<Host Name>>|required|$FORM_host
EOF
	equal "$?" 0 && {
		uci_set updatedd cfg1 update "$FORM_update"
		uci_set updatedd cfg1 service "$FORM_service"
		uci_set updatedd cfg1 "$config_username" "$FORM_username"
		uci_set updatedd cfg1 "$config_password" "$FORM_password"
		uci_set updatedd cfg1 host "$FORM_host"
	}
fi

header "Network" "DynDNS" "@TR<<DynDNS Settings>>" '' "$SCRIPT_NAME"

#define supported services
services="changeip dyndns eurodyndns ovh noip ods hn regfish tzo zoneedit"

#generate fields for supported services
for service in $services; do
	service_option="$service_option
option|$service"
	
	ipkg list_installed | grep -q "$service"
	! equal "$?" 0 && {
		package_checker="$package_checker
field|@TR<<Dynamic DNS Package>>|install_$service|hidden
string|<div class=\"warning\">$service will not work until you install the $service package. </div>
submit|install_$service|@TR<<Install>> $service @TR<<Package>>|"

		js="$js
v = isset('service','$service');
set_visible('install_$service', v);"

		eval FORM_installer="\$FORM_install_$service"

		if ! empty "$FORM_installer"; then
			echo "Installing $service package ...<pre>"
			install_package "updatedd-mod-$service"
			echo "</pre>"
		fi
	}
done

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
radio|update|$FORM_update|1|@TR<<Enable>>
radio|update|$FORM_update|0|@TR<<Disable>>
field|@TR<<Service Type>>
select|service|$FORM_service
$service_option
$package_checker
end_form

start_form|@TR<<Account>>
field|@TR<<User Name>>
text|username|$FORM_username
field|@TR<<Password>>
password|password|$FORM_password
end_form

start_form|@TR<<Host>>
field|@TR<<Host Name>>
text|host|$FORM_host
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:651:DynDNS
-->
