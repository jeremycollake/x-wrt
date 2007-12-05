#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!

. /usr/lib/webif/webif.sh
load_settings "openvpn"

openvpn_dir="/etc/openvpn"

if empty "$FORM_submit"; then
	FORM_openvpn_cli=${openvpn_cli:-$(nvram get openvpn_cli)}
	FORM_openvpn_cli_server=${openvpn_cli_server:-$(nvram get openvpn_cli_server)}
	FORM_openvpn_cli_proto=${openvpn_cli_proto:-$(nvram get openvpn_cli_proto)}
	FORM_openvpn_cli_port=${openvpn_cli_port:-$(nvram get openvpn_cli_port)}
	FORM_openvpn_cli_port=${FORM_openvpn_cli_port:-1194}
	FORM_openvpn_cli_auth=${openvpn_cli_auth:-$(nvram get openvpn_cli_auth)}
	FORM_openvpn_cli_auth=${FORM_openvpn_cli_auth:-cert)}
	FORM_openvpn_cli_psk=${openvpn_cli_psk:-$(nvram get openvpn_cli_psk)}
else
	process_certupload() {
		local certtemp="$1"
		local targetfile="$2"
		[ -f "$certtemp" ] && {
			mv -f "$certtemp" "$openvpn_dir/$targetfile" >/dev/null 2>&1 && {
				return 0
			} || {
				ERROR="${ERROR}@TR<<vpn_openvpn_Error#Error>> @TR<<vpn_openvpn_upload_failed#Cannot process uploaded file>>: $targetfile<br />"
				rm -f "$certtemp" >/dev/null 2>&1
				return 1
			}
		} || return 1
	}
	[ -d "$openvpn_dir" ] || {
		mkdir "$openvpn_dir" 2>/dev/null 2>&1
		[ "$0" != "0" ] && ERROR="${ERROR}@TR<<vpn_openvpn_Error#Error>> @TR<<vpn_openvpn_directory_failed#Cannot create the openvpn directory>><br />"
	}
	#PKCS12
	process_certupload "$FORM_openvpn_pkcs12file" "certificate.p12" && UPLOAD_CERT=1
	#PreShared Key
	process_certupload "$FORM_openvpn_pskfile" "shared.key" && UPLOAD_PSK=1
	#PEM Cert
	process_certupload "$FORM_openvpn_rootcafile" "ca.crt" && UPLOAD_ROOTCACERT=1
	process_certupload "$FORM_openvpn_clientcertfile" "client.crt" && UPLOAD_CLIENTCERT=1
	process_certupload "$FORM_openvpn_clientkeyfile" "client.key" && UPLOAD_CLIENTKEY=1

	SAVED=1
	validate <<EOF
int|FORM_openvpn_cli|@TR<<Start VPN Connection>>||$FORM_openvpn_cli
ip|FORM_openvpn_cli_server|@TR<<Server Address>>|required|$FORM_openvpn_cli_server
string|FORM_openvpn_cli_proto|@TR<<Protocol>>||$FORM_openvpn_cli_proto
port|FORM_openvpn_cli_port|@TR<<Server Port (default: 1194)>>||$FORM_openvpn_cli_port
string|FORM_openvpn_cli_auth|@TR<<Authentication Method>>||$FORM_openvpn_cli_auth
EOF
	equal "$?" 0 && {
		save_setting openvpn openvpn_cli $FORM_openvpn_cli
		save_setting openvpn openvpn_cli_server $FORM_openvpn_cli_server
		save_setting openvpn openvpn_cli_proto $FORM_openvpn_cli_proto
		save_setting openvpn openvpn_cli_port $FORM_openvpn_cli_port
		save_setting openvpn openvpn_cli_auth $FORM_openvpn_cli_auth
		save_setting openvpn openvpn_cli_psk $FORM_openvpn_cli_psk
	}
fi

[ -f "$openvpn_dir/certificate.p12" ] || NOCERT=1
[ -f "$openvpn_dir/shared.key" ] || NOPSK=1
[ -f "$openvpn_dir/ca.crt" ] || NOROOTCACERT=1
[ -f "$openvpn_dir/client.crt" ] || NOCLIENTCERT=1
[ -f "$openvpn_dir/client.key" ] || NOCLIENTKEY=1

header "VPN" "OpenVPN" "@TR<<OpenVPN>>" ' onload="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_package"; then
	echo "@TR<<vpn_openvpn_Installing_package#Installing openvpn package ...>><pre>"
	install_package "openvpn"
	echo "</pre>"
fi

install_package_button=""
! is_package_installed "openvpn" &&
	install_package_button="string|<div class=\"warning\">@TR<<vpn_openvpn_warn#VPN will not work until you install OpenVPN>>: </div>
		submit|install_package| @TR<<vpn_openvpn_install_package#Install OpenVPN Package>> |"

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
	if (!v) set_value('openvpn_pskfile','');

	v = isset('openvpn_cli_auth', 'cert');
	set_visible('certificate_status', v);
	set_visible('certificate', v);
	if (!v) set_value('openvpn_pkcs12file','');

	v = isset('openvpn_cli_auth', 'pem');
	set_visible('root_ca_status', v);
	set_visible('root_ca', v);
	set_visible('client_certificate_status', v);
	set_visible('client_certificate', v);
	set_visible('client_key_status', v);
	set_visible('client_key', v);
	if (!v) {
		set_value('openvpn_rootcafile','');
		set_value('openvpn_clientcertfile','');
		set_value('openvpn_clientkeyfile','');
	}
	onefile();

	hide('save');
	show('save');
}
function field_disabled(name,state)
{
	var item = document.getElementById(name);
	if (item) item.disabled = state;
}
function set_enabled(name)
{
	field_disabled(name, false);
}
function set_disabled(name)
{
	field_disabled(name, true);
}
function onefile()
{
	// haserl cannot process more than one upload at a time!
	// disable other file uploads when one is set
	set_enabled('openvpn_rootcafile');
	set_enabled('openvpn_clientcertfile');
	set_enabled('openvpn_clientkeyfile','');
	if (!isset('openvpn_rootcafile', '')) {
		set_value('openvpn_clientcertfile','');
		set_disabled('openvpn_clientcertfile');
		set_value('openvpn_clientkeyfile','');
		set_disabled('openvpn_clientkeyfile');
	}
	if (!isset('openvpn_clientcertfile', '')) {
		set_value('openvpn_rootcafile','');
		set_disabled('openvpn_rootcafile');
		set_value('openvpn_clientkeyfile','');
		set_disabled('openvpn_clientkeyfile');
	}
	if (!isset('openvpn_clientkeyfile', '')) {
		set_value('openvpn_rootcafile','');
		set_disabled('openvpn_rootcafile');
		set_value('openvpn_clientcertfile','');
		set_disabled('openvpn_clientcertfile');
	}
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
$(empty "$NOROOTCACERT" || echo 'string|<span style="color:red">@TR<<No Root CA certificate uploaded yet!>></span>')
$(empty "$UPLOAD_ROOTCACERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOROOTCACERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload Root CA certificate>>|root_ca|hidden
string|<input id="openvpn_rootcafile" type="file" name="openvpn_rootcafile" onchange="onefile(this)"/>

field|@TR<<Certificate Status>>|client_certificate_status|hidden
$(empty "$NOCLIENTCERT" || echo 'string|<span style="color:red">@TR<<No client certificate uploaded yet!>></span>')
$(empty "$UPLOAD_CLIENTCERT" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCLIENTCERT" && echo 'string|@TR<<Found Installed Certificate.>>')
field|@TR<<Upload Client Certificate>>|client_certificate|hidden
string|<input id="openvpn_clientcertfile" type="file" name="openvpn_clientcertfile" onchange="onefile(this)"/>

field|@TR<<Certificate Status>>|client_key_status|hidden
$(empty "$NOCLIENTKEY" || echo 'string|<span style="color:red">@TR<<No client key uploaded yet!>></span>')
$(empty "$UPLOAD_CLIENTKEY" || echo 'string|<span style="color:green">@TR<<Upload Successful>><br/></span>')
$(empty "$NOCLIENTKEY" && echo 'string|@TR<<Found installed client key.>>')
field|@TR<<Upload Client Key>>|client_key|hidden
string|<input id="openvpn_clientkeyfile" type="file" name="openvpn_clientkeyfile" onchange="onefile(this)"/>

helpitem|vpn_openvpn_upload#Key/Certificate Upload
helptext|vpn_openvpn_upload_helptext#Upload only one key/certificate at a time. Clear the populated field, if you want to upload other key/certificate.
end_form

EOF

footer
?>
<!--
##WEBIF:name:VPN:1:OpenVPN
-->
