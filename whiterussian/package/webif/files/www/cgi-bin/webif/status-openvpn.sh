#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "OpenVPN" "@TR<<OpenVPN Status>>"

equal "$(nvram get openvpn_cli)" "1" && {

	case "$FORM_action" in
		start)
			ps | grep -q '[o]penvpn --client' || {
				echo -n "@TR<<status_openvpn_Starting_OpenVPN#Starting OpenVPN ...>>"
				/etc/init.d/S50openvpn start
				echo " @TR<<status_openvpn_done#done.>>"
			}
		;;
		stop)
			ps | grep -q '[o]penvpn --client' && {
				echo -n "@TR<<status_openvpn_Stopping_OpenVPN#Stopping OpenVPN ...>>"
				/etc/init.d/S50openvpn stop
				echo " @TR<<status_openvpn_done#done.>>"
			}
		;;
	esac

	case "$(nvram get openvpn_cli_auth)" in
		cert)
			[ -f "/etc/openvpn/certificate.p12" ] ||
				ERROR="@TR<<status_openvpn_Err_cert_missing#Error, certificate is missing!>>"
		;;
		psk)
			[ -f "/etc/openvpn/shared.key" ] ||
				ERROR="@TR<<status_openvpn_Err_keyfile_missing#Error, keyfile is missing!>>"
		;;
		pem)
			if [ ! -f "/etc/openvpn/client.key" ]; then
				ERROR="@TR<<status_openvpn_Err_client_keyfile_missing#Error, client keyfile is missing!>>"
			fi
			if [ ! -f "/etc/openvpn/client.crt" ]; then
				ERROR="@TR<<status_openvpn_Err_client_cert_missing#Error, client certificate is missing!>>"
			fi
			if [ ! -f "/etc/openvpn/ca.crt" ]; then
				ERROR="@TR<<status_openvpn_Err_root_cert#Error, root certificate is missing!>>"
			fi
		;;
		*)
			ERROR="@TR<<status_openvpn_Err_unknown_authtype#error in OpenVPN configuration, unknown authtype>>"
		;;
	esac

	empty "$ERROR" && {
		DEVICES=$(egrep "(tun|tap)" /proc/net/dev | cut -d: -f1 | tr -d ' ')
		empty "$DEVICES" && {
			echo "@TR<<status_openvpn_no_active_tunnel#no active tunnel found>>"
		} || {
			echo "@TR<<status_openvpn_active_tunnel#found the following active tunnel:>>"
			echo "<pre>"
			for DEV in $DEVICES;do
				ifconfig $DEV
			done
			echo "</pre>"
		}
		echo "<br/>"

		ps | grep -q '[o]penvpn --proto' && {
			echo '@TR<<status_openvpn_OpenVPN_running#OpenVPN process is running>> <a href="?action=stop">@TR<<status_openvpn_stop_now#[stop now]>></a>'
		} || {
			echo '@TR<<status_openvpn_OpenVPN_not_running#OpenVPN is not running>> <a href="?action=start">@TR<<status_openvpn_start_now#[start now]>></a>'
		}
	} || {
		echo "$ERROR"
	}
} || {
	echo "<br />@TR<<status_openvpn_OpenVPN_disabled#OpenVPN is disabled>>"
}

footer ?>
<!--
##WEBIF:name:Status:910:OpenVPN
-->
