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

# decide what upnpd to be used
instlist=$(ipkg list_installed 2>/dev/null | grep "^\(miniupnpd \|linuxigd \)")
echo "$instlist" | grep -q "^miniupnpd "; miniupnpd_installed=$(($?==0))
echo "$instlist" | grep -q "^linuxigd "; linuxigd_installed=$(($?==0))

# we prefer miniupnpd (an user can install more packages outside of this page)
[ "$miniupnpd_installed" -gt 0 ] && {
	grep -q "^append_parm" "/etc/init.d/miniupnpd" 2>/dev/null && {
		config_file="miniupnpd.conf"
		miniupnpd_installed=2
	}
	linuxigd_installed=0
}
[ "$linuxigd_installed" -gt 0 ] && {
	config_file="upnpd.conf"
}

# return from edit
! empty "$FORM_cancel" || ! empty "$FORM_save" && unset FORM_submit
[ -n "$FORM_install_miniupnpd$FORM_install_linuxigd$FORM_remove_miniupnpd$FORM_remove_linuxigd$FORM_upgrade_upnpd" ] && unset FORM_submit

! empty "$FORM_submit" && {
	SAVED=1
	validate_text="int|FORM_upnp_enable|@TR<<network_upnp_UPnP_Daemon#UPnP Daemon>>||$FORM_upnp_enable"
	[ "$miniupnpd_installed" -gt 0 ] && {
		validate_text="$validate_text
int|FORM_upnpd_log_output|@TR<<network_upnp_Log_Debug_Output#Log Debug Output>>||$FORM_upnpd_log_output
int|FORM_upnpd_up_bitspeed|@TR<<network_upnp_WAN_Upload#WAN Upload>>||$FORM_upnpd_up_bitspeed
int|FORM_upnpd_down_bitspeed|@TR<<network_upnp_WAN Download#WAN Download>>||$FORM_upnpd_down_bitspeed"
	}
	[ "$miniupnpd_installed" -gt 1 ] && {
		validate_text="$validate_text
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
$validate_text
EOF
	validation_result="$?"
	[ "$miniupnpd_installed" -gt 1 ] && [ -n "$FORM_upnpd_uuid" ] && {
		[ -z "$(echo "$FORM_upnpd_uuid" | sed '/^[[:xdigit:]]\{8\}-\([[:xdigit:]]\{4\}-\)\{3\}[[:xdigit:]]\{12\}$/!d')" ] && {
			ERROR="$ERROR@TR<<Error in>> @TR<<network_upnp_UPnP_UUID#UPnP UUID>>: @TR<<network_upnp_invalid_uuid_error#Invalid UUID>><br />"
			validation_result="1"
		}
	}
	[ "$validation_result" == "0" ]
	if equal "$?" "0"; then
		FORM_upnp_enable="${FORM_upnp_enable:-0}"
		uci_set "upnpd" "general" "enable" "$FORM_upnp_enable"
		[ "$FORM_upnp_enable" -eq "1" ] && {
			uci_set "upnpd" "general" "log_output" "$FORM_upnpd_log_output"
			uci_set "upnpd" "general" "down_bitspeed" "$FORM_upnpd_down_bitspeed"
			uci_set "upnpd" "general" "up_bitspeed" "$FORM_upnpd_up_bitspeed"
			[ "$miniupnpd_installed" -gt 1 ] && {
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
	else
		! empty "$FORM_config_edit" && {
			ERROR="$ERROR@TR<<network_upnp_miniupnpd_Validate_before_edit#All settings must be valid before editing the configuration file.>><br />"
			unset FORM_config_edit
		}
	fi
}

uci_load "upnpd"

init_form() {
	empty "$FORM_submit" || ! equal "$FORM_upnp_enable" "1" && {
		# initialize all defaults
		FORM_upnp_enable="${FORM_upnp_enable:-$CONFIG_general_enable}"
		FORM_upnp_enable="${FORM_upnp_enable:-0}"
		FORM_upnpd_log_output="${FORM_upnpd_log_output:-$CONFIG_general_log_output}"
		FORM_upnpd_log_output="${FORM_upnpd_log_output:-0}"
		FORM_upnpd_up_bitspeed="${FORM_upnpd_up_bitspeed:-$CONFIG_general_up_bitspeed}"
		FORM_upnpd_up_bitspeed="${FORM_upnpd_up_bitspeed:-512}"
		FORM_upnpd_down_bitspeed="${FORM_upnpd_down_bitspeed:-$CONFIG_general_down_bitspeed}"
		FORM_upnpd_down_bitspeed="${FORM_upnpd_down_bitspeed:-1024}"
		[ "$miniupnpd_installed" -gt 1 ] && {
			FORM_upnpd_port="${FORM_upnpd_port:-$CONFIG_general_port}"
			FORM_upnpd_port="${FORM_upnpd_port:-5555}"
			FORM_upnpd_system_uptime="${FORM_upnpd_system_uptime:-$CONFIG_general_system_uptime}"
			FORM_upnpd_system_uptime="${FORM_upnpd_system_uptime:-1}"
			FORM_upnpd_secure_mode="${FORM_upnpd_secure_mode:-$CONFIG_general_secure_mode}"
			FORM_upnpd_secure_mode="${FORM_upnpd_secure_mode:-1}"
			FORM_upnpd_nat_pmp="${FORM_upnpd_nat_pmp:-$CONFIG_general_nat_pmp}"
			FORM_upnpd_nat_pmp="${FORM_upnpd_nat_pmp:-0}"
			FORM_upnpd_uuid="${FORM_upnpd_uuid:-$CONFIG_general_uuid}"
			FORM_upnpd_uuid="${FORM_upnpd_uuid:-fc4ec57e-b051-11db-88f8-0060085db3f6}"
			FORM_upnpd_serial="${FORM_upnpd_serial:-$CONFIG_general_serial}"
			FORM_upnpd_serial="${FORM_upnpd_serial:-12345678}"
			FORM_upnpd_model_number="${FORM_upnpd_model_number:-$CONFIG_general_model_number}"
			FORM_upnpd_model_number="${FORM_upnpd_model_number:-1}"
			FORM_upnpd_notify_interval="${FORM_upnpd_notify_interval:-$CONFIG_general_notify_interval}"
			FORM_upnpd_notify_interval="${FORM_upnpd_notify_interval:-30}"
			FORM_upnpd_url="${FORM_upnpd_url:-$CONFIG_general_url}"
		}
	}
}
init_form

config_path="/etc"
edited_files_path="/tmp/.webif/edited-files"
edited_file="$edited_files_path/$config_path/$config_file"
! empty "$FORM_save" && {
	mkdir -p "$edited_files_path/$config_path"
	echo "$FORM_filecontent" > "$edited_file"
	chmod 644 "$edited_file"
	unset FORM_save FORM_submit
}

if ! empty "$FORM_config_edit"; then
	header "Network" "UPnP" "@TR<<UPnP Configuration>>"
else
	header "Network" "UPnP" "@TR<<UPnP Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"
fi

! empty "$FORM_config_edit" && {
	exists "$edited_file" && {
		edit_filename="$edited_file"
	} || {
		edit_filename="$config_path/$config_file"
	}
	cat "$edit_filename" 2>/dev/null | awk \
		-v url="$SCRIPT_NAME" \
		-v path="$config_path" \
		-v file="$config_file" \
		-f /usr/lib/webif/common.awk \
		-f /usr/lib/webif/editor.awk

	footer
	exit 0
}

remove_upnpd() {
	local removed="$1"; [ -z "$removed" ] && return
	echo "@TR<<network_upnp_Removing#Removing>> $removed ...<br />"
	echo "<pre>"
	remove_package "$removed"
	rm -f /tmp/.uci/upnpd >/dev/null 2>&1
	eval "${removed}_installed=0"
	echo "</pre>"
}

if ! empty "$FORM_upgrade_upnpd"; then
	echo "@TR<<network_upnp_Upgrading#Upgrading UPnPd>>...<br />"
	remove_upnpd miniupnpd
	FORM_install_miniupnpd=1
fi

if ! empty "$FORM_install_miniupnpd"; then
	echo "@TR<<network_upnp_Installing#Installing>> miniupnp ...<br />"
	echo "<pre>"
	install_package miniupnpd
	miniupnpd_installed=$(($?==0))
	echo "</pre>"
	exists "/etc/init.d/miniupnpd" && grep -q "append_parm" "/etc/init.d/miniupnpd" 2>/dev/null && miniupnpd_installed=2
	init_form
	FORM_upnp_enable="0"
fi

if ! empty "$FORM_install_linuxigd"; then
	echo "@TR<<network_upnp_Installing#Installing>> linuxigd ...<br />"
	echo "<pre>"
	install_package linuxigd
	linuxigd_installed=$(($?==0))
	echo "</pre>"
	# if config file doesn't exist, create it since it doesn't come with above pkg at present
	rm -f /tmp/.uci/upnpd >/dev/null 2>&1
	uci_load "upnpd"
	uci_add "upnpd" "miniupnpd" "general"
	uci_set "upnpd" "general" "enable" "0"
	uci commit upnpd
fi

! empty "$FORM_remove_miniupnpd" && remove_upnpd miniupnpd

! empty "$FORM_remove_linuxigd" && {
	remove_upnpd linuxigd
	# clean dependencies if unused
	remove_package "-V 0 libupnp libpthread" >/dev/null 2>&1
}

[ "$miniupnpd_installed" -gt 0 ] && {
	remove_upnpd_button="field|@TR<<network_upnp_Remove_miniupnpd#Remove miniupnpd>>
	submit|remove_miniupnpd| @TR<<network_upnp_Remove#Remove>> |"
	# old nvram and old uci based miniupnp package should upgrade
	[ "$miniupnpd_installed" -lt 2 ] && {
	 	echo "<div class=\"warning\">@TR<<network_upnp_incompatible_miniupnpd#You have an old version of miniupnpd incompatible with this webif&sup2; version. You must upgrade to a newer miniupnpd package, else this page will not work properly.>></div>"
		display_form <<EOF
start_form
submit|upgrade_upnpd| @TR<<network_upnp_Upgrade_UPnPd#Upgrade UPnPd>> 
end_form
EOF
	}
}

[ "$linuxigd_installed" -gt 0 ] && {
	remove_upnpd_button="field|@TR<<network_upnp_Remove_linuxigd#Remove linuxigd>>
	submit|remove_linuxigd| @TR<<network_upnp_Remove#Remove>> |"
}

#####################################################################s
[ "$(( $miniupnpd_installed + $linuxigd_installed ))" -gt 0 ] && {
	cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

var fieldlist = new Array();
var fieldcntr = 0;
EOF
[ "$linuxigd_installed" -lt 1 ] && {
	cat <<EOF
fieldlist[fieldcntr] = 'upnpd_up_bitspeed'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_down_bitspeed'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_log_output'; fieldcntr++;
EOF
}
[ "$miniupnpd_installed" -gt 1 ] && {
	cat <<EOF
fieldlist[fieldcntr] = 'upnpd_port'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_system_uptime'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_secure_mode'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_nat_pmp'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_uuid'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_serial'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_model_number'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_notify_interval'; fieldcntr++;
fieldlist[fieldcntr] = 'upnpd_url'; fieldcntr++;
fieldlist[fieldcntr] = 'config_edit'; fieldcntr++;
EOF
}
[ "$linuxigd_installed" -gt 0 ] && {
	cat <<EOF
fieldlist[fieldcntr] = 'config_edit'; fieldcntr++;
EOF
}
	cat <<EOF

function field_disabled(name, state)
{
	var item = document.getElementById(name);
	if (item) item.disabled = state;
}

function modechange()
{
	var iter;
	var status = !isset('upnp_enable','1');
	for (iter in fieldlist)
	{
		field_disabled(fieldlist[iter], status)
	}
}
</script>
EOF
}

#####################################################################
if [ "$(( $miniupnpd_installed + $linuxigd_installed ))" -gt 0 ]; then
	[ "$miniupnpd_installed" -gt 0 ] && form_title="network_upnp_title_miniupnpd#miniupnpd" || form_title="network_upnp_title_linuxigd#linuxigd"
	primary_upnpd_form="field|@TR<<network_upnp_UPnP_Daemon#UPnP Daemon>>
select|upnp_enable|$FORM_upnp_enable
option|0|@TR<<network_upnp_upnpd_Disabled#Disabled>>
option|1|@TR<<network_upnp_upnpd_Enabled#Enabled>>"
	[ "$miniupnpd_installed" -gt 0 ] && {
		primary_upnpd_form="$primary_upnpd_form
field|@TR<<network_upnp_WAN_Upload#WAN Upload>>
text|upnpd_up_bitspeed|$FORM_upnpd_up_bitspeed| @TR<<Kibps>>
field|@TR<<network_upnp_WAN Download#WAN Download>>
text|upnpd_down_bitspeed|$FORM_upnpd_down_bitspeed| @TR<<Kibps>>
helpitem|network_upnp_WAN_Speeds#WAN Upload/Download Speeds
helptext|network_upnp_WAN_Speeds_helptext#Set your WAN speeds here, in kibibits per second. This is for reporting to upnp clients that request it only.
field|@TR<<network_upnp_Log_Debug_Output#Log Debug Output>>
select|upnpd_log_output|$FORM_upnpd_log_output
option|0|@TR<<network_upnp_log_Disabled#Disabled>>
option|1|@TR<<network_upnp_log_Enabled#Enabled>>"
	}
	primary_upnpd_form="$primary_upnpd_form
$remove_upnpd_button
helpitem|network_upnp_Remove#Remove
helptext|network_upnp_Remove_helptext#If you have problems you can remove your current UPnPd and try the other one to see if it works better for you."
	[ "$miniupnpd_installed" -gt 1 ] && {
		primary_upnpd_form="$primary_upnpd_form
end_form
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
	form_title="UPnP"
	install_miniupnpd_button="field|@TR<<network_upnp_miniupnpd#miniupnpd>>
submit|install_miniupnpd| @TR<<network_upnp_Install#Install>> |"
	install_linuxigd_button="field|@TR<<network_upnp_linuxigd#linuxigd>>
submit|install_linuxigd| @TR<<network_upnp_Install#Install>> |"
	install_help="helpitem|network_upnp_Which_UPnPd#Which UPnPd to choose
helptext|network_upnp_Which_UPnPd_helptext#There are two UPnP daemons to choose from: miniupnpd and linuxigd. Try miniupnpd first, but it if does not work for you, then remove that package and try linuxigd."
fi

display_form <<EOF
onchange|modechange
start_form|@TR<<$form_title>>
$primary_upnpd_form
$install_miniupnpd_button
$install_linuxigd_button
$install_help
end_form
EOF

[ "$miniupnpd_installed" -gt 1 -o "$linuxigd_installed" -gt 0 ] && {
	if [ "$miniupnpd_installed" -gt 1 ]; then
		conf_field="field|@TR<<network_upnp_conf_miniupnpd#miniupnpd.conf>>"
		help_field="helptext|network_upnp_Configuration_File_miniupnpd_helptext#You can configure the external IP address in case of more addresses for the WAN interface, unused rules cleaning, and permission rules in the miniupnpd's configuration file.<br />All fields above must be valid before editing the configuration file."
	else
		conf_field="field|@TR<<network_upnp_conf_linuxigd#upnpd.conf>>"
		help_field="helptext|network_upnp_Configuration_File_linuxigd_helptext#You can configure all settings of linuxigd in its configuration file."
	fi
	display_form <<EOF
onchange|modechange
start_form|@TR<<network_upnp_Configuration_File#Configuration File>>
$conf_field
string|<input id="config_edit" type="submit" name="config_edit" value="@TR<<network_upnp_Edit_Configuration#Edit Configuration>>" />
helpitem|network_upnp_Configuration_File#Configuration File
$help_field
end_form
EOF
}

footer ?>
<!--
##WEBIF:name:Network:550:UPnP
-->
