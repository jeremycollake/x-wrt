#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!

. /usr/lib/webif/webif.sh
load_settings "openvpn"

header "VPN" "OpenVPN" "@TR<<OpenVPN>>" ' onload="modechange()" ' "$SCRIPT_NAME"

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
	[ -f /etc/openvpn/ca.crt ] ||
		NOROOTCACERT=1
	[ -f /etc/openvpn/client.crt ] ||
		NOCLIENTCERT=1
	[ -f /etc/openvpn/client.key ] ||
		NOCLIENTKEY=1
	FORM_openvpn_cli=${openvpn_cli:-$(nvram get openvpn_cli)}
	FORM_openvpn_cli_server=${openvpn_cli_server:-$(nvram get openvpn_cli_server)}
	FORM_openvpn_cli_proto=${openvpn_cli_proto:-$(nvram get openvpn_cli_proto)}
	FORM_openvpn_cli_port=${openvpn_cli_port:-$(nvram get openvpn_cli_port)}
	FORM_openvpn_cli_port=${FORM_openvpn_cli_port:-1194}
	FORM_openvpn_cli_auth=${openvpn_cli_auth:-$(nvram get openvpn_cli_auth)}
	FORM_openvpn_cli_auth=${FORM_openvpn_cli_auth:-cert)}
	FORM_openvpn_cli_psk=${openvpn_cli_psk:-$(nvram get openvpn_cli_psk)}
else
	#PKCS12
	[ -d /etc/openvpn ] || mkdir /etc/openvpn
	[ -f "$FORM_openvpn_pkcs12file" ] && {
		cp "$FORM_openvpn_pkcs12file" /etc/openvpn/certificate.p12 &&
			UPLOAD_CERT=1
	}
	#PreShared Key
	[ -f "$FORM_openvpn_pskfile" ] && {
		cp "$FORM_openvpn_pskfile" /etc/openvpn/shared.key &&
			UPLOAD_PSK=1
	}
	#PEM Cert
	[ -f "$FORM_openvpn_rootcafile" ] && {
		cp "$FORM_openvpn_rootcafile" /etc/openvpn/ca.crt &&
			UPLOAD_ROOTCACERT=1
	}
	[ -f "$FORM_openvpn_clientcertfile" ] && {
		cp "$FORM_openvpn_clientcertfile" /etc/openvpn/client.crt &&
			UPLOAD_CLIENTCERT=1
	}
	[ -f "$FORM_openvpn_clientkeyfile" ] && {
		cp "$FORM_openvpn_clientkeyfile" /etc/openvpn/client.key &&
			UPLOAD_CLIENTKEY=1
	}
	save_setting openvpn openvpn_cli $FORM_openvpn_cli
	save_setting openvpn openvpn_cli_server $FORM_openvpn_cli_server
	save_setting openvpn openvpn_cli_proto $FORM_openvpn_cli_proto
	save_setting openvpn openvpn_cli_port $FORM_openvpn_cli_port
	save_setting openvpn openvpn_cli_auth $FORM_openvpn_cli_auth
	save_setting openvpn openvpn_cli_psk $FORM_openvpn_cli_psk
fi

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	v = isset('openvpn_cli', '1');
	set_visible('connection_settings', v);
	set_visible('authentication', v);

	v = isset('openvpn_cli_auth', 'psk');
	set_visible('psk_status', v);
	set_visible('psk', v);

	v = isset('openvpn_cli_auth', 'cert');
	set_visible('certificate_status', v);
	set_visible('certificate', v);
	
	v = isset('openvpn_cli_auth', 'pem');
	set_visible('root_ca_status', v);
	set_visible('root_ca', v);
	set_visible('client_certificate_status', v);
	set_visible('client_certificate', v);
	set_visible('client_key_status', v);
	set_visible('client_key', v);

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
option|1|@TR<<Enabled>>
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
option|pem|@TR<<Certificate (PEM)>>
onchange|
end_form

#PreShared Key
start_form|@TR<<Authentication>>|authentication|hidden
field|@TR<<Preshared Key Status>>|psk_status|hidden
$(empty "$NOPSK" || echo 'string|<span style="color:red">@TR<<No Keyfile uploaded yet!>></span>')
$(empty "$UPLOAD_PSK" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOPSK" && echo 'string|@TR<<Found Installed Keyfile>>')
field|@TR<<Upload Preshared Key>>|psk|hidden
upload|openvpn_pskfile

#PKCS12 Cert
field|@TR<<Certificate Status>>|certificate_status|hidden
$(empty "$NOCERT" || echo 'string|<span style="color:red">@TR<<No Certificate uploaded yet!>></span>')
$(empty "$UPLOAD_CERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload PKCS12 Certificate>>|certificate|hidden
upload|openvpn_pkcs12file

# PEM Cert
field|@TR<<Certificate Status>>|root_ca_status|hidden
$(empty "$NOROOTCACERT" || echo 'string|<span style="color:red">@TR<<Root CA certificate uploaded yet!>></span>')
$(empty "$UPLOAD_ROOTCACERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOROOTCACERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload Root CA certificate>>|root_ca|hidden
upload|openvpn_rootcafile

field|@TR<<Certificate Status>>|client_certificate_status|hidden
$(empty "$NOCLIENTCERT" || echo 'string|<span style="color:red">@TR<<No client certificate uploaded yet!>></span>')
$(empty "$UPLOAD_CLIENTCERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCLIENTCERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload Client Certificate>>|client_certificate|hidden
upload|openvpn_clientcertfile

field|@TR<<Certificate Status>>|client_key_status|hidden
$(empty "$NOCLIENTKEY" || echo 'string|<span style="color:red">@TR<<No client key uploaded yet!>></span>')
$(empty "$UPLOAD_CLIENTKEY" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCLIENTKEY" && echo 'string|@TR<<Found installed client key.>>')
field|@TR<<Upload Client Key>>|client_key|hidden
upload|openvpn_clientkeyfile
end_form


EOF

footer
?>
<!--
##WEBIF:name:VPN:1:OpenVPN
-->
