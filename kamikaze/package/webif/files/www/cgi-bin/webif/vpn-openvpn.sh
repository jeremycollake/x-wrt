#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!

. /usr/lib/webif/webif.sh
load_settings "openvpn"

header "VPN" "OpenVPN" "@TR<<OpenVPN>>" ' onload="modechange()" ' "$SCRIPT_NAME"
ShowUntestedWarning

if ! empty "$FORM_install_package"; then
	echo "Installing openvpn package ...<pre>"
	install_package "openvpn"
	echo "</pre>"
fi

install_package_button=""
! is_package_installed "openvpn" &&
	install_package_button="string|<div class=warning>VPN will not work until you install OpenVPN: </div>
		submit|install_package| Install OpenVPN Package |"

if empty "$FORM_submit"; then
	[ -f /etc/openvpn/certificate.p12 ] ||
		NOCERT=1
	[ -f /etc/openvpn/shared.key ] ||
		NOPSK=1
	FORM_openvpn_cli=${openvpn_cli:-$(uci get openvpn.general.mode)}
	FORM_openvpn_cli_server=${openvpn_cli_server:-$(uci get openvpn.client.ipaddr)}
	FORM_openvpn_cli_proto=${openvpn_cli_proto:-$(uci get openvpn.general.proto)}
	FORM_openvpn_cli_port=${openvpn_cli_port:-$(uci get openvpn.general.port)}
	FORM_openvpn_cli_port=${FORM_openvpn_cli_port:-1194}
	FORM_openvpn_cli_auth=${openvpn_cli_auth:-$(uci get openvpn.client.auth)}
	FORM_openvpn_cli_auth=${FORM_openvpn_cli_auth:-cert)}
	FORM_openvpn_cli_psk=${openvpn_cli_psk:-$(uci get openvpn.client.psk)}
else
	[ -d /etc/openvpn ] || mkdir /etc/openvpn
	[ -f "$FORM_openvpn_pkcs12file" ] && {
		cp "$FORM_openvpn_pkcs12file" /etc/openvpn/certificate.p12 &&
			UPLOAD_CERT=1
	}
	[ -f "$FORM_openvpn_pskfile" ] && {
		cp "$FORM_openvpn_pskfile" /etc/openvpn/shared.key &&
			UPLOAD_PSK=1
	}
	uci_set "openvpn" "general" "mode" "$FORM_openvpn_cli"
	uci_set "openvpn" "client" "ipaddr" "$FORM_openvpn_cli_server"
	uci_set "openvpn" "general" "proto" "$FORM_openvpn_cli_proto"
	uci_set "openvpn" "general" "port" "$FORM_openvpn_cli_port"
	uci_set "openvpn" "general" "auth" "$FORM_openvpn_cli_auth"
	uci_set "openvpn" "client" "psk" "$FORM_openvpn_cli_psk"
fi

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	v = isset('openvpn_cli', 'client');
	set_visible('connection_settings', v);
	set_visible('authentication', v);

	v = isset('openvpn_cli_auth', 'psk');
	set_visible('psk_status', v);
	set_visible('psk', v);

	v = isset('openvpn_cli_auth', 'cert');
	set_visible('certificate_status', v);
	set_visible('certificate', v);

	hide('save');
	show('save');
}
-->
</script>
EOF

display_form <<EOF
onchange|modechange
$install_package_button
start_form|@TR<<OpenVPN>>
field|@TR<<Start VPN Connection>>
select|openvpn_cli|$FORM_openvpn_cli
option|0|@TR<<Disabled>>
option|client|@TR<<Enabled>>
onchange|
end_form

start_form|@TR<<Connection Settings>>|connection_settings|hidden
field|@TR<<Server Address>>
text|openvpn_cli_server|$FORM_openvpn_cli_server
field|@TR<<Protocol>>
select|openvpn_cli_proto|$FORM_openvpn_cli_proto
option|udp|UDP
option|tcp|TCP
field|@TR<<Server Port (default: 1194)>>
text|openvpn_cli_port|$FORM_openvpn_cli_port
field|@TR<<Authentication Method>>
onchange|modechange
select|openvpn_cli_auth|$FORM_openvpn_cli_auth
option|psk|@TR<<Preshared Key>>
option|cert|@TR<<Certificate (PKCS12)>>
onchange|
end_form

start_form|@TR<<Authentication>>|authentication|hidden
field|@TR<<Preshared Key Status>>|psk_status|hidden
$(empty "$NOPSK" || echo 'string|<span style="color:red">@TR<<No Keyfile uploaded yet!>></span>')
$(empty "$UPLOAD_PSK" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOPSK" && echo 'string|@TR<<Found Installed Keyfile>>')
field|@TR<<Upload Preshared Key>>|psk|hidden
upload|openvpn_pskfile

field|@TR<<Certificate Status>>|certificate_status|hidden
$(empty "$NOCERT" || echo 'string|<span style="color:red">@TR<<No Certificate uploaded yet!>></span>')
$(empty "$UPLOAD_CERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload PKCS12 Certificate>>|certificate|hidden
upload|openvpn_pkcs12file
end_form

EOF

footer
?>
<!--
##WEBIF:name:VPN:1:OpenVPN
-->
