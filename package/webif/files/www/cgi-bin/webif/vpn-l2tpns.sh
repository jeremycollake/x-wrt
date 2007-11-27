#!/usr/bin/webif-page
<?
#
# Adopted from vpn-openvpn.sh
# Author: Liran Tal <liran@enginx.com>
#                   <liran.tal@gmail.com>
#
# July 2007   - initial release

. /usr/lib/webif/webif.sh

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		server)
			server_cfg="$CONFIG_SECTION"
		;;
	esac
}

uci_load "l2tpns"

header "VPN" "L2TPns" "@TR<<L2TPns>>" ' onload="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_package"; then
	echo "@TR<<vpn_l2tpns_Installing_package#Installing l2tpns package ...>><pre>"
	install_package "l2tpns"
	echo "</pre>"
fi

install_package_button=""
! is_package_installed "l2tpns" &&
	install_package_button="string|<div class=warning>@TR<<vpn_l2tpns_warn#VPN will not work until you install L2TPns:>> </div>
		submit|install_package| @TR<<vpn_l2tpns_install_package#Install L2TPns Package>> |"

if empty "$FORM_submit"; then
	eval "FORM_l2tpns_cli=\"\$CONFIG_${server_cfg}_mode\""
	eval "FORM_l2tpns_cli_server=\"\$CONFIG_${server_cfg}_ipaddr\""
	eval "FORM_l2tpns_cli_debug=\"\$CONFIG_${server_cfg}_debug\""
	eval "FORM_l2tpns_cli_radacct=\"\$CONFIG_${server_cfg}_radacct\""
	eval "FORM_l2tpns_cli_pidfile=\"\$CONFIG_${server_cfg}_pidfile\"" 
	eval "FORM_l2tpns_cli_logfile=\"\$CONFIG_${server_cfg}_logfile\""
	eval "FORM_l2tpns_cli_radport=\"\$CONFIG_${server_cfg}_radport\"" 

else
	[ "$server_cfg" = "" ] && {
		uci_add "l2tpns" "server"
		server_cfg="cfg1"
	}
	uci_set "l2tpns" "$server_cfg" "mode" "$FORM_l2tpns_cli"
	uci_set "l2tpns" "$server_cfg" "ipaddr" "$FORM_l2tpns_cli_server"
	uci_set "l2tpns" "$server_cfg" "dns1" "$FORM_l2tpns_cli_dns1"
	uci_set "l2tpns" "$server_cfg" "dns2" "$FORM_l2tpns_cli_dns2"
	uci_set "l2tpns" "$server_cfg" "rad1" "$FORM_l2tpns_cli_rad1"
	uci_set "l2tpns" "$server_cfg" "rad2" "$FORM_l2tpns_cli_rad2"
	uci_set "l2tpns" "$server_cfg" "radsecret" "$FORM_l2tpns_cli_radsecret"
	uci_set "l2tpns" "$server_cfg" "radport" "$FORM_l2tpns_cli_radport"
	uci_set "l2tpns" "$server_cfg" "radacct" "$FORM_l2tpns_cli_radacct"
	uci_set "l2tpns" "$server_cfg" "debug" "$FORM_l2tpns_cli_debug"
	uci_set "l2tpns" "$server_cfg" "pidfile" "$FORM_l2tpns_cli_pidfile"
	uci_set "l2tpns" "$server_cfg" "logfile" "$FORM_l2tpns_cli_logfile"

fi

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	v = isset('l2tpns_cli', 'enabled');
	set_visible('connection_settings', v);

	hide('save');
	show('save');
}
-->
</script>
EOF

display_form <<EOF
onchange|modechange
$install_package_button
start_form|@TR<<L2TPns>>
field|@TR<<Start L2TPns Connection>>
select|l2tpns_cli|$FORM_l2tpns_cli
option|disabled|@TR<<Disabled>>
option|enabled|@TR<<Enabled>>
end_form

start_form|@TR<<Connection Settings>>|connection_settings|hidden
field|@TR<<Server Address>>
text|l2tpns_cli_server|$FORM_l2tpns_cli_server
helpitem|l2tpns_server#Server Address
helptext|l2tpns_server_text#The IP Address on which the L2TPns server will be listening on (example: 127.0.0.1)

field|@TR<<Primary DNS>>
text|l2tpns_cli_dns1|$FORM_l2tpns_cli_dns1
field|@TR<<Secondary DNS>>
text|l2tpns_cli_dns2|$FORM_l2tpns_cli_dns2
helpitem|l2tpns_dns#DNS Addresses
helptext|l2tpns_dns_text#DNS Servers upon which clients will be provided with


field|@TR<<Primary RADIUS>>
text|l2tpns_cli_rad1|$FORM_l2tpns_cli_rad1
field|@TR<<Secondary RADIUS>>
text|l2tpns_cli_rad2|$FORM_l2tpns_cli_rad2
field|@TR<<RADIUS Secret>>
helpitem|l2tpns_radius#RADIUS Servers
helptext|l2tpns_radius_text#RADIUS Servers IP Addresses

text|l2tpns_cli_radsecret|$FORM_l2tpns_cli_radsecret
field|@TR<<RADIUS Port>>
helpitem|l2tpns_radius_secret#RADIUS Secret 
helptext|l2tpns_radius_secret_text#RADIUS Servers shared secret key


text|l2tpns_cli_radport|$FORM_l2tpns_cli_radport
field|@TR<<RADIUS Accounting>>
helpitem|l2tpns_radius_port#RADIUS Port (example: 1812 is the default port for authentication)
helptext|l2tpns_radius_port_text#RADIUS Servers Port for authentication (the same is used for both primary and secondary radius servers)

select|l2tpns_cli_radacct|$FORM_l2tpns_cli_radacct
option|yes|@TR<<Yes>>
option|no|@TR<<No>>

field|@TR<<Debug>>
select|l2tpns_cli_debug|$FORM_l2tpns_cli_debug
option|1|1
option|2|2
option|3|3

field|@TR<<Log file>>
text|l2tpns_cli_logfile|$FORM_l2tpns_cli_logfile

field|@TR<<Pid file>>
text|l2tpns_cli_pidfile|$FORM_l2tpns_cli_pidfile

end_form

EOF

footer
?>
<!--
##WEBIF:name:VPN:3:L2TPns
-->
