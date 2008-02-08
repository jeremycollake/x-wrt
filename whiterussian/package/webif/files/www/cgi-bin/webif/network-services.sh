#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"
###################################################################
# Services configuration page
#
# Description:
#	Configures services not configured elsewhere.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Lubos Stanek <lubek@users.berlios.de>
#
# NVRAM variables referenced:
#	none
#
# Configuration files referenced:
#	/etc/config/upnpd
#

exists "/etc/init.d/miniupnpd" && upnpd_modern=1

! empty "$FORM_submit" && {
	if ! empty "$FORM_upgrade_upnpd"; then
		# upgrade miniupnpd
		echo "@TR<<Please wait>> ...<br />"
		ipkg remove miniupnpd 2>&1 >> /dev/null
		# X-Wrt repository is the last repository in ipkg.conf;
		# we always install latest package only by name
		if ipkg install "miniupnpd"  2>&1 >> /dev/null; then
			echo " @TR<<network_upnp_Completed_successfully#Completed successfully>>!<br />"
		else
			echo " @TR<<network_upnp_Failed_to_install#Failed to install>>!<br />"
		fi
	else
		# save form
		SAVED=1
		[ "$upnpd_modern" -gt 0 ] && {
			validate_modern="
port|FORM_upnpd_port|@TR<<network_upnp_UPnPd_Port#UPnPd Port>>||$FORM_upnpd_port
int|FORM_upnpd_system_uptime|@TR<<network_upnp_Report_Uptime#Report Uptime of>>||$FORM_upnpd_system_uptime
int|FORM_upnpd_secure_mode|@TR<<network_upnp_Secure_Mode#Secure Mode>>||$FORM_upnpd_secure_mode
int|FORM_upnpd_nat_pmp|@TR<<network_upnp_NAT_PMP_Support#NAT-PMP Support>>||$FORM_upnpd_nat_pmp
int|FORM_upnpd_serial|@TR<<network_upnp_Serial_Number#Serial Number>>||$FORM_upnpd_serial
int|FORM_upnpd_model_number|@TR<<network_upnp_Model_Number#Model Number>>||$FORM_upnpd_model_number
int|FORM_upnpd_notify_interval|@TR<<network_upnp_SSDP_notify_interval#SSDP notify interval>>||$FORM_upnpd_notify_interval
string|FORM_upnpd_url|@TR<<network_upnp_Presentation_URL#Presentation URL>>|nospaces|$FORM_upnpd_url"
		}
		validate <<EOF
int|FORM_upnp_enable|@TR<<network_upnp_UPnP_Daemon#UPnP Daemon>>||$FORM_upnp_enable
int|FORM_upnpd_log_output|@TR<<network_upnp_Log_Debug_Output#Log Debug Output>>||$FORM_upnpd_log_output
int|FORM_upnpd_up_bitspeed|@TR<<network_upnp_WAN_Upload#WAN Upload>>||$FORM_upnpd_up_bitspeed
int|FORM_upnpd_down_bitspeed|@TR<<network_upnp_WAN Download#WAN Download>>||$FORM_upnpd_down_bitspeed
$validate_modern
EOF
		validation_result="$?"
		[ "$upnpd_modern" -gt 0 ] && [ -n "$FORM_upnpd_uuid" ] && {
			[ -z "$(echo "$FORM_upnpd_uuid" | sed '/^[[:xdigit:]]\{8\}-\([[:xdigit:]]\{4\}-\)\{3\}[[:xdigit:]]\{12\}$/!d')" ] && {
				ERROR="$ERROR@TR<<Error in>> @TR<<network_upnp_UPnP_UUID#UPnP UUID>>: @TR<<network_upnp_invalid_uuid_error#Invalid UUID>><br />"
				validation_result="1"
			}
		}
		[ "$validation_result" == "0" ]
		equal "$?" "0" && {
			uci_set "upnpd" "general" "enable" "$FORM_upnp_enable"
			[ "$FORM_upnp_enable" -eq "1" ] && {
				uci_set "upnpd" "general" "log_output" "$FORM_upnpd_log_output"
				uci_set "upnpd" "general" "down_bitspeed" "$FORM_upnpd_down_bitspeed"
				uci_set "upnpd" "general" "up_bitspeed" "$FORM_upnpd_up_bitspeed"
				[ "$upnpd_modern" -gt 0 ] && {
					uci_set "upnpd" "general" "port" "$FORM_upnpd_port"
					uci_set "upnpd" "general" "system_uptime" "$FORM_upnpd_system_uptime"
					uci_set "upnpd" "general" "secure_mode" "$FORM_upnpd_secure_mode"
					uci_set "upnpd" "general" "nat_pmp" "$FORM_upnpd_nat_pmp"
					uci_set "upnpd" "general" "uuid" "$FORM_upnpd_uuid"
					uci_set "upnpd" "general" "serial" "$FORM_upnpd_serial"
					uci_set "upnpd" "general" "model_number" "$FORM_upnpd_model_number"
					uci_set "upnpd" "general" "notify_interval" "$FORM_upnpd_notify_interval"
					uci_set "upnpd" "general" "url" "$FORM_upnpd_url"
				}
			}
		}
	fi
}

uci_load "upnpd"

empty "$FORM_submit" || ! equal "$FORM_upnp_enable" "1" && {
	# initialize all defaults
	empty "$FORM_submit" && FORM_upnp_enable="${CONFIG_general_enable:-0}"
	FORM_upnpd_log_output="${CONFIG_general_log_output:-0}"
	FORM_upnpd_up_bitspeed="${CONFIG_general_up_bitspeed:-512}"
	FORM_upnpd_down_bitspeed="${CONFIG_general_down_bitspeed:-1024}"
	[ "$upnpd_modern" -gt 0 ] && {
		FORM_upnpd_port="${CONFIG_general_port:-5555}"
		FORM_upnpd_system_uptime="${CONFIG_general_system_uptime:-1}"
		FORM_upnpd_secure_mode="${CONFIG_general_secure_mode:-1}"
		FORM_upnpd_nat_pmp="${CONFIG_general_nat_pmp:-0}"
		FORM_upnpd_uuid="${CONFIG_general_uuid:-fc4ec57e-b051-11db-88f8-0060085db3f6}"
		FORM_upnpd_serial="${CONFIG_general_serial:-12345678}"
		FORM_upnpd_model_number="${CONFIG_general_model_number:-1}"
		FORM_upnpd_notify_interval="${CONFIG_general_notify_interval:-30}"
		FORM_upnpd_url="$CONFIG_general_url"
	}
}

header "Network" "UPnP" "@TR<<UPnP Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_miniupnp"; then
	echo "@TR<<network_upnp_Installing#Installing>> miniupnp ...<pre>"
	install_package miniupnpd
	uci_set "upnpd" "general" "enable" "1"
	echo "</pre>"
fi

if ! empty "$FORM_install_linuxigd"; then
	echo "@TR<<network_upnp_Installing#Installing>> linuxigd ...<pre>"
	install_package "libpthread"
	install_package "libupnp"
	install_package "linuxigd"
	# if config file doesn't exist, create it since it doesn't come with above pkg at present
	! exists "/etc/config/upnpd" && {
		touch "/etc/config/upnpd"
		uci_load "upnpd"
		uci_add "upnpd" "miniupnpd" "general"
		uci_set "upnpd" "general" "enable" "1"
	}
	echo "</pre>"
fi

if ! empty "$FORM_remove_miniupnpd"; then
	echo "@TR<<network_upnp_Removing#Removing>> miniupnpd ...<pre>"
	remove_package miniupnpd
	echo "</pre>"
fi

if ! empty "$FORM_remove_linuxigd"; then
	echo "@TR<<network_upnp_Removing#Removing>> linuxigd ...<pre>"
	remove_package linuxigd
	remove_package libupnp
	remove_package libpthread
	echo "</pre>"
fi

ipkg_listinst=$(ipkg list_installed 2>/dev/null | grep "^\(miniupnpd \|linuxigd \)")
upnp_installed="0"

echo "$ipkg_listinst" | grep -q "^miniupnpd "
equal "$?" "0" && {
	upnp_installed="1"
	remove_upnpd_button="field|@TR<<network_upnp_Remove_miniupnpd#Remove miniupnpd>>
	submit|remove_miniupnpd| @TR<<network_upnp_Remove#Remove>> |"
}

echo "$ipkg_listinst" | grep -q "^linuxigd "
equal "$?" "0" && {
	upnp_installed="1"
	remove_upnpd_button="field|@TR<<network_upnp_Remove_linuxigd#Remove linuxigd>>
	submit|remove_linuxigd| @TR<<network_upnp_Remove#Remove>> |"
}

# check to see if user has old nvram based miniupnp package
# todo: remove this check after a while, assuming everyone got new one
! equal "$upnpd_modern" "1" && exists "/etc/init.d/S95miniupnpd" && ! grep -iq "uci.sh" "/etc/init.d/S95miniupnpd" && {
 	echo "<div class=\"warning\">@TR<<network_upnp_incompatible_miniupnpd#You have an old version of miniupnpd incompatible with this webif&sup2; version. You must upgrade to a newer miniupnpd package, else this page will not work properly.>></div>"
	display_form <<EOF
	start_form
	submit|upgrade_upnpd| @TR<<network_upnp_Upgrade_UPnPd#Upgrade UPnPd>>
	end_form
EOF
}

#####################################################################s
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

function modechange()
{
	if(isset('upnp_enable','1'))
	{
		document.getElementById('upnpd_up_bitspeed').disabled = false;
		document.getElementById('upnpd_down_bitspeed').disabled = false;
		document.getElementById('upnpd_log_output').disabled = false;
EOF
	[ "$upnpd_modern" -gt 0 ] && {
	cat <<EOF
		document.getElementById('upnpd_port').disabled = false;
		document.getElementById('upnpd_system_uptime').disabled = false;
		document.getElementById('upnpd_secure_mode').disabled = false;
		document.getElementById('upnpd_nat_pmp').disabled = false;
		document.getElementById('upnpd_uuid').disabled = false;
		document.getElementById('upnpd_serial').disabled = false;
		document.getElementById('upnpd_model_number').disabled = false;
		document.getElementById('upnpd_notify_interval').disabled = false;
		document.getElementById('upnpd_url').disabled = false;
EOF
	}
cat <<EOF
	}
	else
	{
		document.getElementById('upnpd_up_bitspeed').disabled = true;
		document.getElementById('upnpd_down_bitspeed').disabled = true;
		document.getElementById('upnpd_log_output').disabled = true;
EOF
	[ "$upnpd_modern" -gt 0 ] && {
	cat <<EOF
		document.getElementById('upnpd_port').disabled = true;
		document.getElementById('upnpd_system_uptime').disabled = true;
		document.getElementById('upnpd_secure_mode').disabled = true;
		document.getElementById('upnpd_nat_pmp').disabled = true;
		document.getElementById('upnpd_uuid').disabled = true;
		document.getElementById('upnpd_serial').disabled = true;
		document.getElementById('upnpd_model_number').disabled = true;
		document.getElementById('upnpd_notify_interval').disabled = true;
		document.getElementById('upnpd_url').disabled = true;
EOF
	}
cat <<EOF
	}
}
</script>
EOF

#####################################################################

if equal "$upnp_installed" "1" ; then
	primary_upnpd_form="field|@TR<<network_upnp_UPnP_Daemon#UPnP Daemon>>
	select|upnp_enable|$FORM_upnp_enable
	option|0|@TR<<network_upnp_upnpd_Disabled#Disabled>>
	option|1|@TR<<network_upnp_upnpd_Enabled#Enabled>>
	field|@TR<<network_upnp_WAN_Upload#WAN Upload>>
	text|upnpd_up_bitspeed|$FORM_upnpd_up_bitspeed| @TR<<Kibps>>
	field|@TR<<network_upnp_WAN Download#WAN Download>>
	text|upnpd_down_bitspeed|$FORM_upnpd_down_bitspeed| @TR<<Kibps>>
	helpitem|network_upnp_WAN_Speeds#WAN Upload/Download Speeds
	helptext|network_upnp_WAN_Speeds_helptext#Set your WAN speeds here, in kibibits per second. This is for reporting to upnp clients that request it only.
	field|@TR<<network_upnp_Log_Debug_Output#Log Debug Output>>
	select|upnpd_log_output|$FORM_upnpd_log_output
	option|0|@TR<<network_upnp_log_Disabled#Disabled>>
	option|1|@TR<<network_upnp_log_Enabled#Enabled>>
	$remove_upnpd_button
	helpitem|network_upnp_Remove#Remove
	helptext|network_upnp_Remove_helptext#If you have problems you can remove your current UPnPd and try the other one to see if it works better for you."
	[ "$upnpd_modern" -gt 0 ] && {
		modern_upnpd_form="end_form
		onchange|modechange
		start_form|@TR<<network_upnp_Additional_Settings#Additional Settings>>
		field|@TR<<network_upnp_UPnPd_Port#UPnPd Port>>
		text|upnpd_port|$FORM_upnpd_port
		helpitem|network_upnp_UPnPd_Port#UPnPd Port
		helptext|network_upnp_UPnPd_Port_helptext#Default port for HTTP (descriptions and SOAP) traffic is 5555.
		field|@TR<<network_upnp_Report_Uptime#Report Uptime of>>
		select|upnpd_system_uptime|$FORM_upnpd_system_uptime
		option|0|@TR<<network_upnp_Report_Daemon#Daemon>>
		option|1|@TR<<network_upnp_Report_System#System>>
		helpitem|network_upnp_Report_Uptime#Report Uptime of
		helptext|network_upnp_Report_Uptime_helptext#Report the daemon uptime or the system uptime.
		field|@TR<<network_upnp_Secure_Mode#Secure Mode>>
		select|upnpd_secure_mode|$FORM_upnpd_secure_mode
		option|0|@TR<<network_upnp_Secure_Off#Off>>
		option|1|@TR<<network_upnp_Secure_On#On>>
		helpitem|network_upnp_Secure_Mode#Secure Mode
		helptext|network_upnp_Secure_Mode_helptext#UPnP client are allowed to add mappings only to their IP in the secure mode.
		field|@TR<<network_upnp_NAT_PMP_Support#NAT-PMP Support>>
		select|upnpd_nat_pmp|$FORM_upnpd_nat_pmp
		option|0|@TR<<network_upnp_NAT_PMP_Off#Off>>
		option|1|@TR<<network_upnp_NAT_PMP_On#On>>
		helpitem|network_upnp_NAT_PMP_Support#NAT-PMP Support
		helptext|network_upnp_NAT_PMP_helptext#Enable experimental support for the NAT Port Mapping Protocol.
		field|@TR<<network_upnp_UPnP_UUID#UPnP UUID>>
		text|upnpd_uuid|$FORM_upnpd_uuid
		helpitem|network_upnp_UPnP_UUID#UPnP UUID
		helptext|network_upnp_UPnP_UUID_helptext#Set your own universally unique identifier of the Internet Gateway Device (32 hexadecimal digits in 5 groups separated by hyphens, ex.: edfabdbd-fd44-45d9-865a-443d840b9ece).
		helplink|http://en.wikipedia.org/wiki/UUID
		field|@TR<<network_upnp_Serial_Number#Serial Number>>
		text|upnpd_serial|$FORM_upnpd_serial
		field|@TR<<network_upnp_Model_Number#Model Number>>
		text|upnpd_model_number|$FORM_upnpd_model_number
		field|@TR<<network_upnp_SSDP_notify_interval#SSDP notify interval>>
		text|upnpd_notify_interval|$FORM_upnpd_notify_interval| @TR<<network_upnp_seconds#seconds>>
		helpitem|network_upnp_SSDP_notify_interval#SSDP notify interval
		helptext|network_upnp_SSDP_notify_interval_helptext#Simple Service Discovery Protocol announce messages will be broadcasted at this interval.
		field|@TR<<network_upnp_Presentation_URL#Presentation URL>>
		text|upnpd_url|$FORM_upnpd_url
		helpitem|network_upnp_Presentation_URL#Presentation URL
		helptext|network_upnp_Presentation_URL_helptext#Default is the first address on LAN, port 80.
		helplink|http://miniupnp.free.fr/"
	}
else
	install_miniupnp_button="field|@TR<<network_upnp_miniupnpd#miniupnpd>>
submit|install_miniupnp| @TR<<network_upnp_Install#Install>> |"
	install_linuxigd_button="field|@TR<<network_upnp_linuxigd#linuxigd>>
submit|install_linuxigd| @TR<<network_upnp_Install#Install>> |"
	install_help="helpitem|network_upnp_Which_UPnPd#Which UPnPd to choose
helptext|network_upnp_Which_UPnPd_helptext#There are two UPnP daemons to choose from: miniupnpd and linuxigd. Try miniupnpd first, but it if does not work for you, then remove that package and try linuxigd."
fi

display_form <<EOF
onchange|modechange
start_form|@TR<<UPnP>>
$primary_upnpd_form
$modern_upnpd_form
$install_miniupnp_button
$install_linuxigd_button
$install_help
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:550:UPnP
-->
