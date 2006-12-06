#!/usr/bin/webif-page
<?
ddns_dir="/etc/ez-ipupdate"
ddns_msg="$ddns_dir/ez-ipupdate.msg"

. /usr/lib/webif/webif.sh

load_settings "ezipupdate"

# todo add javascript /enable/disable for mx and wildcard / connection type
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

[ -z $FORM_submit ] && {

	FORM_ddns_enable=${ddns_enable:-$(uci get ez-ipupdate.general.enable)}
	FORM_ddns_enable=${FORM_ddns_enable:-'0'}

	FORM_ddns_service_type=${ddns_service_type:-$(uci get ez-ipupdate.general.service)}
	FORM_ddns_service_type=${FORM_ddns_service_type:-"dyndns"}

	FORM_ddns_username=${ddns_username:-$(uci get ez-ipupdate.general.username)}
	FORM_ddns_passwd=${ddns_passwd:-$(uci get ez-ipupdate.general.passwd)}
	FORM_ddns_hostname=${ddns_hostname:-$(uci get ez-ipupdate.general.hostname)}

	FORM_ddns_wildcard=${ddns_wildcard:-$(uci get ez-ipupdate.general.wildcard)}
	FORM_ddns_wildcard=${FORM_ddns_wildcard:-'0'}

	FORM_ddns_server=${ddns_server:-$(uci get ez-ipupdate.general.server)}

	FORM_ddns_max_interval=${ddns_max_interval:-$(uci get ez-ipupdate.general.max_interval)}
	FORM_ddns_max_interval=${FORM_ddns_max_interval:-'86400'}

#    FORM_ddns_tzo_ctype=${ddns_tzo_ctype:-$(uci get ez-ipupdate.general.tzo_ctype)}
#    FORM_ddns_tzo_ctype=${FORM_ddns_tzo_ctype:-"1"}

} || {
	SAVED=1

	#int|FORM_ddns_tzo_ctype|@TR<<Connection Type>>||$FORM_ddns_tzo_ctype

	validate "
string|FORM_ddns_service_type|@TR<<Service Type>>|required|$FORM_ddns_service_type
string|FORM_ddns_username|@TR<<User Name>>|required|$FORM_ddns_username
string|FORM_ddns_passwd|@TR<<Password>>|required|$FORM_ddns_passwd
string|FORM_ddns_hostname|@TR<<Host Name>>||$FORM_ddns_hostname
hostname|FORM_ddns_server|@TR<<Server Name>>||$FORM_ddns_server
int|FORM_ddns_max_interval|@TR<<Max Interval (sec)>>|min=86400 max=2196000|$FORM_ddns_max_interval
" && {
	uci_set "ez-ipupdate" "general" "enable" "$FORM_ddns_enable"
	uci_set "ez-ipupdate" "general" "service" "$FORM_ddns_service_type"
	uci_set "ez-ipupdate" "general" "username" "$FORM_ddns_username"
	uci_set "ez-ipupdate" "general" "passwd" "$FORM_ddns_passwd"
	uci_set "ez-ipupdate" "general" "hostname" "$FORM_ddns_hostname"
	uci_set "ez-ipupdate" "general" "wildcard" "$FORM_ddns_wildcard"
	#uci_set "ez-ipupdate" "general" "tzo_ctype" "$FORM_ddns_tzo_ctype"
	uci_set "ez-ipupdate" "general" "server" "$FORM_ddns_server"
	uci_set "ez-ipupdate" "general" "max_interval" "$FORM_ddns_max_interval"
	}
}

header "Network" "DynDNS" "@TR<<DynDNS Settings>>" '' "$SCRIPT_NAME"

has_pkgs ez-ipupdate

#show message from last update
#field|Connection Type (only for TZO)
#text|ddns_tzo_ctype|$FORM_ddns_tzo_ctype

display_form "start_form|@TR<<DynDNS>>
field|@TR<<ez-ipupdate>>
radio|ddns_enable|$FORM_ddns_enable|1|@TR<<Enable>>
radio|ddns_enable|$FORM_ddns_enable|0|@TR<<Disable>>
field|@TR<<Service Type>>
select|ddns_service_type|$FORM_ddns_service_type
option|ezip|@TR<<ez-ip>>
option|dyndns|@TR<<dyndns>>
option|ods|@TR<<ods>>
option|tzo|@TR<<tzo>>
option|easydns|@TR<<easydns>>
option|gnudip|@TR<<gnudip>>
option|pgpow|@TR<<justlinux v1.0 (penguinpowered)>>
option|justlinux|@TR<<justlinux v2.0 (penguinpowered)>>
option|dyns|@TR<<dyns>>
option|hn|@TR<<hammer node>>
option|zoneedit|@TR<<zoneedit>>
option|heipv6tb|@TR<<heipv6tb>>
option|dyndns-static|@TR<<dyndns-static>>
option|dyndns-custom|@TR<<dyndns-custom>>
option|easydns-partner|@TR<<easydns-partner>>
option|dhs|@TR<<dhs>>
end_form

start_form|@TR<<Account>>
field|@TR<<User Name>>
text|ddns_username|$FORM_ddns_username
field|@TR<<Password>>
password|ddns_passwd|$FORM_ddns_passwd
end_form

start_form|@TR<<Host>>
field|@TR<<Host Name>>
text|ddns_hostname|$FORM_ddns_hostname
field|@TR<<Wildcard>>
radio|ddns_wildcard|$FORM_ddns_wildcard|1|@TR<<Enable>>
radio|ddns_wildcard|$FORM_ddns_wildcard|0|@TR<<Disable>>
end_form

start_form|@TR<<Server>>
field|@TR<<Server Name>
text|ddns_server|$FORM_ddns_server
field|@TR<<Max Interval (sec)>>
text|ddns_max_interval|$FORM_ddns_max_interval
string|<br /><a href="network-logread-ez-ipupdate.sh">@TR<<View DynDNS Syslog>></a>
end_form"
?>
<?if [ -f  $ddns_msg ] ?>
<br/>Last update: <? cat $ddns_msg ?><br/><br/>
<?fi?>
<? footer ?>
<!--
##WEBIF:name:Network:651:DynDNS
-->
