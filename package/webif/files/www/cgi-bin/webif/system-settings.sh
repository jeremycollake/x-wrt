#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"

###################################################################
# system configuration page
#
# Description:
#	Configures general system settings.
#
# Author(s) [in order of work date]:
#   	Original webif developers -- todo
#	Markus Wigge <markus@freewrt.org>
#   	Jeremy Collake <jeremy.collake@gmail.com>
#	Travis Kemen <kemen04@gmail.com>
#
# Major revisions:
#
# Configuration files referenced:
#   none
#

# Add NTP Server
if ! empty "$FORM_add_ntpcfg_number"; then
	uci_add "ntp_client" "ntp_client" ""
	uci_set "ntp_client" "cfg$FORM_add_ntpcfg_number" "hostname" ""
	uci_set "ntp_client" "cfg$FORM_add_ntpcfg_number" "port" "123"
	uci_set "ntp_client" "cfg$FORM_add_ntpcfg_number" "count" "1"
	FORM_add_ntpcfg=""
fi

# Remove NTP Server
if ! empty "$FORM_remove_ntpcfg"; then
	uci_remove "ntp_client" "$FORM_remove_ntpcfg"
fi

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		system)
			hostname_cfg="$CONFIG_SECTION"
		;;
		timezone)
			timezone_cfg="$CONFIG_SECTION"
		;;
		ntp_client)
			append ntpservers "$CONFIG_SECTION" "$N"
		;;
	esac
}

uci_load "webif"
uci_load "webifssl"
uci_load "system"
#We have to load the system host name setting here because ntp_client also uses the hostname setting.
eval CONFIG_systemhostname="\$CONFIG_${hostname_cfg}_hostname"
FORM_hostname="${FORM_hostname:-$CONFIG_systemhostname}"
FORM_hostname="${FORM_hostname:-OpenWrt}"
config_clear "$hostname_cfg"
uci_load "network"
uci_load "timezone"
uci_load "ntp_client"

#FIXME: uci_load bug
#uci_load will pass the same config twice when there is a section to be added by using uci_add before a uci_commit happens
#we will use uniq so we don't try to parse the same config section twice.
ntpservers=$(echo "$ntpservers" |uniq)

ntpcfg_number=$(echo "$ntpservers" |wc -l)
let "ntpcfg_number+=1"

#####################################################################
header "System" "Settings" "@TR<<System Settings>>" ' onload="modechange()" ' "$SCRIPT_NAME"

#####################################################################
# install NTP client if asked
if ! empty "$FORM_install_ntpclient"; then
	tmpfile=$(mktemp "/tmp/.webif_ntp-XXXXXX")
	echo "@TR<<system_settings_Installing_NTPCLIENT_package#Installing NTPCLIENT package>> ...<pre>"
	install_package "ntpclient"
	echo "</pre>"
fi

generate_ssl_key() {
	local inst_packages llib llink libsymlinks
	is_package_installed "zlib"
	[ "$?" != "0" ] && inst_packages="$inst_packages zlib"
	is_package_installed "libopenssl"
	[ "$?" != "0" ] && inst_packages="$inst_packages libopenssl"
	is_package_installed "openssl-util"
	[ "$?" != "0" ] && inst_packages="$inst_packages openssl-util"
	[ -n "$inst_packages" ] && ipkg -d ram install $inst_packages -force-overwrite
	is_package_installed "openssl-util"
	if [ "$?" = "0" ]; then
		for llib in $(ls /tmp/usr/lib/libssl.so.* /tmp/usr/lib/libcrypto.so.* /tmp/usr/lib/libz.so.* /tmp/usr/bin/openssl 2>/dev/null); do
			llink=$(echo "$llib" | sed 's/\/tmp//')
			ln -s $llib $llink
			[ "$?" = "0" ] && libsymlinks="$libsymlinks $llink"
		done
		if [  -z "$(ps -A | grep "[n]tpd\>")" ]; then
			is_package_installed "ntpclient"
			[ "$?" != "0" ] && {
				echo "@TR<<system_settings_Updating_time#Updating time>> ..."
				rdate -s pool.ntp.org
			}
		fi
		export RANDFILE="/tmp/.rnd"
		dd if=/dev/urandom of="$RANDFILE" count=1 bs=512 2>/dev/null
		(openssl genrsa -out /etc/ssl/matrixtunnel.key 2048; openssl req -new -batch -nodes -key /etc/ssl/matrixtunnel.key -out /etc/ssl/matrixtunnel.csr; openssl x509 -req -days 365 -in /etc/ssl/matrixtunnel.csr -signkey /etc/ssl/matrixtunnel.key -out /etc/ssl/matrixtunnel.cert)
		rm -f "$RANDFILE" 2>/dev/null
		unset RANDFILE
	fi
	[ -n "$libsymlinks" ] && rm -f $libsymlinks
	[ -n "$inst_packages" ] && ipkg remove $inst_packages
}

if ! empty "$FORM_install_stunnel"; then
	echo "@TR<<system_settings_Installing_MatrixTunnel_package#Installing MatrixTunnel package>> ...<pre>"
	install_package "matrixtunnel"
	is_package_installed "matrixtunnel"
	[ "$?" = "0" ] && [ ! -e /etc/ssl/matrixtunnel.key -o ! -e /etc/ssl/matrixtunnel.cert ] && {
		echo "@TR<<system_settings_Generating_SSL_certificate#Generating SSL certificate>> ..."
		generate_ssl_key
	}
	echo "</pre><br />"
fi
if ! empty "$FORM_generate_certificate"; then
	echo "@TR<<system_settings_Generating_SSL_certificate#Generating SSL certificate>> ...<pre>"
	generate_ssl_key
	echo "</pre><br />"
fi

#####################################################################
# initialize forms
if empty "$FORM_submit"; then
	# initialize all defaults
	eval time_zone_part="\$CONFIG_${timezone_cfg}_posixtz"
	eval time_zoneinfo_part="\$CONFIG_${timezone_cfg}_zoneinfo"
	time_zone_part="${time_zone_part:-"UTC+0"}"
	time_zoneinfo_part="${time_zoneinfo_part:-"-"}"
	FORM_system_timezone="${time_zoneinfo_part}@${time_zone_part}"

	is_bcm947xx && {
		FORM_boot_wait="${boot_wait:-$(nvram get boot_wait)}"
		FORM_boot_wait="${FORM_boot_wait:-off}"
		FORM_wait_time="${wait_time:-$(nvram get wait_time)}"
		FORM_wait_time="${FORM_wait_time:-1}"
	}
	# webif settings
	FORM_effect="${CONFIG_general_use_progressbar}"		# -- effects checkbox
	if equal $FORM_effect "1" ; then FORM_effect="checked" ; fi	# -- effects checkbox
	FORM_language="${CONFIG_general_lang:-en}"	
	FORM_theme=${CONFIG_theme_id:-xwrt}
	FORM_ssl_enable="${CONFIG_matrixtunnel_enable:-0}"
else
#####################################################################
# save forms
	SAVED=1
	validate <<EOF
hostname|FORM_hostname|@TR<<Host Name>>|nodots required|$FORM_hostname
EOF
	if equal "$?" 0 ; then
		time_zone_part="${FORM_system_timezone#*@}"
		time_zoneinfo_part="${FORM_system_timezone%@*}"
		empty "$hostname_cfg" && {
			uci_add system system
			hostname_cfg="cfg1"
		}
		uci_set "system" "$hostname_cfg" "hostname" "$FORM_hostname"
		empty "$timezone_cfg" && {
			uci_add timezone timezone timezone
			timezone_cfg="timezone"
		}
		uci_set timezone "$timezone_cfg" posixtz "$time_zone_part"
		uci_set timezone "$timezone_cfg" zoneinfo "$time_zoneinfo_part"
		for server in $ntpservers; do
			eval FORM_ntp_server="\$FORM_ntp_server_$server"
			eval FORM_ntp_port="\$FORM_ntp_port_$server"
			eval FORM_ntp_count="\$FORM_ntp_count_$server"
			uci_set ntp_client "$server" hostname "$FORM_ntp_server"
			uci_set ntp_client "$server" port "$FORM_ntp_port"
			uci_set ntp_client "$server" count "$FORM_ntp_count"
		done

		is_bcm947xx && {
			case "$FORM_boot_wait" in
				on|off) save_setting system boot_wait "$FORM_boot_wait";;
			esac
			! empty "$FORM_wait_time" &&
			{
				save_setting system wait_time "$FORM_wait_time"
			}
		}
		# webif settings
		# fix emptying the field when not present
		FORM_ssl_enable="${FORM_ssl_enable:-$CONFIG_matrixtunnel_enable}"
		FORM_ssl_enable="${FORM_ssl_enable:-0}"
		uci_set "webifssl" "matrixtunnel" "enable" "$FORM_ssl_enable"
		uci_set "webif" "theme" "id" "$FORM_theme"
		uci_set "webif" "general" "lang" "$FORM_language"
		uci_set "webif" "general" "use_progressbar" "$FORM_effect_enable"
		FORM_effect=$FORM_effect_enable ; if equal $FORM_effect "1" ; then FORM_effect="checked" ; fi
	else
		echo "<br /><div class=\"warning\">@TR<<Warning>>: @TR<<system_settings_Hostname_failed_validation#Hostname failed validation. Can not be saved.>></div><br />"
	fi
fi

WEBIF_SSL="field|@TR<<system_settings_Webif_SSL#Webif&sup2; SSL>>"
is_package_installed "matrixtunnel"
if [ "$?" != "0" ]; then
	WEBIF_SSL="$WEBIF_SSL
string|<div class=\"warning\">@TR<<system_settings_Feature_requires_matrixtunnel#MatrixTunnel package is not installed. You need to install it for ssl support>>:</div>
submit|install_stunnel| @TR<<system_settings_Install_MatrixTunnel#Install MatrixTunnel>> |"
else
	if [ -e /etc/ssl/matrixtunnel.key -a -e /etc/ssl/matrixtunnel.cert ]; then
		WEBIF_SSL="$WEBIF_SSL
select|ssl_enable|$FORM_ssl_enable
option|0|@TR<<system_settings_webifssl_Off#Off>>
option|1|@TR<<system_settings_webifssl_On#On>>"
	else
		WEBIF_SSL="$WEBIF_SSL
string|<div class=\"warning\">@TR<<system_settings_Feature_requires_certificate#The SSL certificate is missing. You need to generate it for ssl support>>:</div>
submit|generate_certificate| @TR<<system_settings_Generate_SSL_Certificate#Generate SSL Certificate>> |"
	fi
fi

	effect_field=$(cat <<EOF
field| 
string|<input type="checkbox" name="effect_enable" value="1" $FORM_effect />&nbsp;@TR<<Enable visual effects>><br/><br/>
EOF
)

#####################################################################
# over/underclocking
#
is_bcm947xx && {
	#####################################################################
	# Initialize wait_time form
	for wtime in $(seq 1 30); do
		FORM_wait_time="$FORM_wait_time
			option|$wtime"
	done
}

#####################################################################
# Initialize THEMES form
#
#
# start with list of available installable theme packages
#
! exists "/etc/themes.lst" && {
	# create list if it doesn't exist ..
	/usr/lib/webif/webif-mkthemelist.sh	
}
THEMES=$(cat "/etc/themes.lst")
for str in $temp_t; do
	THEME="$THEME
		option|$str"
done

# enumerate installed themes by finding all subdirectories of /www/theme
# this lets users install themes not built into packages.
#
for curtheme in /www/themes/*; do
	curtheme=$(echo "$curtheme" | sed s/'\/www\/themes\/'//g)
	if exists "/www/themes/$curtheme/name"; then
		theme_name=$(cat "/www/themes/$curtheme/name")
	else
		theme_name="$curtheme"
	fi
	! equal "$curtheme" "active" && {
		THEMES="$THEMES
option|$curtheme|$theme_name"
	}
done
#
# sort list and remove dupes
#
THEMES=$(echo "$THEMES" | sort -u)

#####################################################################
# Initialize LANGUAGES form
# create list if it doesn't exist ..
! exists "/etc/languages.lst" && {
	/usr/lib/webif/webif-mklanglist.sh
}
LANGUAGES=$(cat "/etc/languages.lst")

is_bcm947xx && {
	bootwait_form="field|@TR<<Boot Wait>>
	select|boot_wait|$FORM_boot_wait
	option|on|@TR<<Enabled>>
	option|off|@TR<<Disabled>>
	helpitem|Boot Wait
	helptext|HelpText boot_wait#Boot wait causes the boot loader of some devices to wait a few seconds at bootup for a TFTP transfer of a new firmware image. This is a security risk to be left on."

	waittime_form="field|@TR<<Wait Time>>
	select|wait_time|$FORM_wait_time
	helpitem|Wait Time
	helptext|HelpText wait_time#Number of seconds the boot loader should wait for a TFTP transfer if Boot Wait is on."

}

#####################################################################
# ntp form
for server in $ntpservers; do
	if empty "$FORM_submit"; then
		config_get FORM_ntp_server $server hostname
		config_get FORM_ntp_port $server port
		config_get FORM_ntp_count $server count
	else
		eval FORM_ntp_server="\$FORM_ntp_server_$server"
		eval FORM_ntp_port="\$FORM_ntp_port_$server"
		eval FORM_ntp_count="\$FORM_ntp_count_$server"
	fi
	#add check for blank config, the only time it will be seen is when config section is waitings to be removed
	if [ "$FORM_ntp_port" != "" -o "$FORM_ntp_count" != "" -o "$FORM_ntp_server" != "" ]; then
		if [ "$FORM_ntp_port" = "" ]; then
			FORM_ntp_port=123
		fi
		if [ "$FORM_ntp_count" = "" ]; then
			FORM_ntp_count=1
		fi
		ntp_form="field|@TR<<NTP Server>>
		text|ntp_server_$server|$FORM_ntp_server
		field|@TR<<NTP Server Port>>
		text|ntp_port_$server|$FORM_ntp_port
		field|@TR<<NTP Count>>
		text|ntp_count_$server|$FORM_ntp_count
		string|<tr><td><a href="$SCRIPT_NAME?remove_ntpcfg=$server">@TR<<Remove NTP Server>></a>"
		append NTP "$ntp_form" "$N"
	fi
done

add_ntpcfg="string|<tr><td><a href=$SCRIPT_NAME?add_ntpcfg_number=$ntpcfg_number>@TR<<Add NTP Server>></a>"
append NTP "$add_ntpcfg" "$N"

if [ -n "$(has_pkgs ntpclient)" -a -n "$(has_pkgs openntpd)" ]; then
	NTPCLIENT_INSTALL_FORM="string|<div class=\"warning\">@TR<<Warning>>: @TR<<system_settings_feature_requires_ntpclient#No NTP client is installed. For correct time support you need to install one>>:</div>
		submit|install_ntpclient| @TR<<system_settings_Install_NTP_Client#Install NTP Client>> |"
fi

#####################################################################
# initialize time zones

TIMEZONE_OPTS=$(
	awk -v timezoneinfo="$FORM_system_timezone" '
		BEGIN {
			FS="	"
			last_group=""
			defined = 0
		}
		/^(#.*)?$/ {next}
		$1 != last_group {
			last_group=$1
			print "optgroup|" $1
		}
		{
			list_timezone = $4 "@" $3
			if (list_timezone == timezoneinfo)
				defined = defined + 1
			print "option|" list_timezone "|@TR<<" $2 ">>"
		}
		END {
			if (defined == 0) {
				split(timezoneinfo, oldtz, "@")
				print "optgroup|@TR<<system_settings_group_unknown_TZ#Unknown>>"
				if (oldtz[1] == "-") oldtz[1] = "@TR<<system_settings_User_or_old_TZ#User defined (or out of date)>>"
				print "option|" timezoneinfo "|" oldtz[1]
			}
		}' < /usr/lib/webif/timezones.csv 2>/dev/null

)
#######################################################
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{
EOF
is_bcm947xx && cat <<EOF
	if(isset('boot_wait','on'))
	{
		document.getElementById('wait_time').disabled = false;
	}
	else
	{
		document.getElementById('wait_time').disabled = true;
	}

EOF
cat <<EOF
	var tz_info = value('system_timezone');
	if ((tz_info=='') || (tz_info==null)){
		set_value('show_TZ', tz_info);
	}
	else {
		var tz_split = tz_info.split('@');
		set_value('show_TZ', tz_split[1]);
	}
}
-->
</script>
EOF
#######################################################
# Show form
display_form <<EOF
onchange|modechange
start_form|@TR<<System Settings>>
field|@TR<<Host Name>>
text|hostname|$FORM_hostname
$bootwait_form
$waittime_form
end_form
start_form|@TR<<Time Settings>>
field|@TR<<Timezone>>
select|system_timezone|$FORM_system_timezone
$TIMEZONE_OPTS
field|@TR<<system_settings_POSIX_TZ_String#POSIX TZ String>>|view_tz_string|
string|<input id="show_TZ" type="text" style="width: 96%; height: 1.2em; color: #2f2f2f; background: #ececec; " name="show_TZ" readonly="readonly" value="@TR<<system_settings_js_required#This field requires the JavaScript support.>>" />
helpitem|Timezone
helptext|Timezone_helptext#Set up your time zone according to the nearest city of your region from the predefined list.
$NTP
end_form
$NTPCLIENT_INSTALL_FORM
##########################
# webif settings
start_form|@TR<<Webif&sup2; Settings>>
$effect_field
field|@TR<<Language>>
select|language|$FORM_language
$LANGUAGES
field|@TR<<Theme>>
select|theme|$FORM_theme
$THEMES
$WEBIF_SSL
end_form
EOF

footer ?>

<!--
##WEBIF:name:System:010:Settings
-->
