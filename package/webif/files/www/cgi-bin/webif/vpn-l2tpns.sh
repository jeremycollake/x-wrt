#!/usr/bin/webif-page
<?
# Adopted from vpn-openvpn.sh
# July 2007 - Authored by Liran Tal <liran@enginx.com>

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
	eval "FORM_l2tpns_cli_port=\"\$CONFIG_${server_cfg}_port\""
	FORM_l2tpns_cli_port=${FORM_l2tpns_cli_port:-1194}
	eval "FORM_l2tpns_cli_radacct=\"\$CONFIG_${server_cfg}_radacct\""
	FORM_l2tpns_cli_pidfile=${FORM_l2tpns_cli_pidfile:-/var/run/l2tpns.pid}
	FORM_l2tpns_cli_logfile=${FORM_l2tpns_cli_logfile:-/var/log/l2tpns}
	FORM_l2tpns_cli_radport=${FORM_l2tpns_cli_radport:-1812}

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

	sh /usr/lib/webif/l2tpns_apply.sh
fi

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	v = isset('l2tpns_cli', 'server');
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
option|0|@TR<<Disabled>>
option|server|@TR<<Enabled>>
end_form

start_form|@TR<<Connection Settings>>|connection_settings|hidden
field|@TR<<Server Address>>
text|l2tpns_cli_server|$FORM_l2tpns_cli_server

field|@TR<<Primary DNS>>
text|l2tpns_cli_dns1|$FORM_l2tpns_cli_dns1
field|@TR<<Secondary DNS>>
text|l2tpns_cli_dns2|$FORM_l2tpns_cli_dns2

field|@TR<<Primary RADIUS>>
text|l2tpns_cli_rad1|$FORM_l2tpns_cli_rad1
field|@TR<<Secondary RADIUS>>
text|l2tpns_cli_rad2|$FORM_l2tpns_cli_rad2
field|@TR<<RADIUS Secret>>
text|l2tpns_cli_radsecret|$FORM_l2tpns_cli_radsecret
field|@TR<<RADIUS Port>>
text|l2tpns_cli_radport|$FORM_l2tpns_cli_radport
field|@TR<<RADIUS Accounting>>
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
