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
# NVRAM variables referenced:
#	time_zone
#  	ntp_server
#
# Configuration files referenced:
#   none
#

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		system)
			hostname_cfg="$CONFIG_SECTION"
		;;
		timezone)
			timezone_cfg="$CONFIG_SECTION"
		;;
	esac
}

is_bcm947xx && {
	load_settings "system"
	load_settings "webif"
}

uci_load "webif"

is_kamikaze && {
	uci_load "system"
	uci_load "network"
	uci_load "timezone"
}


#####################################################################
# defaults
#
# Overclocking note:
#  we only handle 3302 0.8 since these are usually safer if they have
#  the same default CFE as found on Linksys WRT54G(S) v4+, as it
#  will handle invalid clock frequencies more gracefully and default
#  to a limit of 250mhz. It also has a fixed divider, so sbclock
#  frequencies are implied, and ignored if specified.
#
OVERCLOCKING_DISABLED="1" # set to 1 to disble OC support, we disable overclocking by default for kamikaze and only enable it for bcm947xx
is_bcm947xx && {
	OVERCLOCKING_DISABLED="0"
}

#####################################################################
header "System" "Settings" "@TR<<System Settings>>" ' onload="modechange()" ' "$SCRIPT_NAME"

#####################################################################
# todo: CPU_MODEL not actually used atm (except in building version)
equal "$OVERCLOCKING_DISABLED" "0" && {
	CPU_MODEL=$(sed -n "/cpu model/p" "/proc/cpuinfo")
	CPU_VERSION=$(echo "$CPU_MODEL" | sed -e "s/BCM3302//" -e "s/cpu model//" -e "s/://")
	#echo "debug.model: $CPU_MODEL <br />"
	#echo "debug.version: $CPU_VERSION <br />"
}

#####################################################################
# install NTP client if asked
if ! empty "$FORM_install_ntpclient"; then
	tmpfile=$(mktemp "/tmp/.webif_ntp-XXXXXX")
	echo "@TR<<system_settings_Installing_NTPCLIENT_package#Installing NTPCLIENT package>> ...<pre>"
	install_package "ntpclient"
	echo "</pre>"
fi

if ! empty "$FORM_install_stunnel"; then
	echo "@TR<<system_settings_Installing_MatrixTunnel_package#Installing MatrixTunnel package>> ...<pre>"
	install_package "matrixtunnel"
	if [ ! -e "/etc/ssl/matrixtunnel.key" ]; then
		is_package_installed "openssl-util"
		if [ "$?" = "1" ]; then
			inst_packages="$inst_packages openssl-util"
			openssl_install="1"
		fi
		is_package_installed "libopenssl"
		if [ "$?" = "1" ]; then
			inst_packages="$inst_packages libopenssl"
			libsslsymlink=1
		fi
		is_package_installed "zlib"
		if [ "$?" = "1" ]; then
			inst_packages="$inst_packages zlib"
		fi
		if [ "$openssl_install" = "1" ]; then
			ipkg -d ram install "openssl-util"
		fi
		if [ "$libsslsymlink" = "1" ]; then
			ln -s /tmp/usr/lib/libssl.so.0.9.8 /lib/libssl.so.0.9.8
			ln -s /tmp/usr/lib/libcrypto.so.0.9.8 /lib/libcrypto.so.0.9.8
		fi
		if [ -z "$(ps -A | grep "[n]tpclient\>")" ] && [ -z "$(ps -A | grep "[n]tpd\>")" ]; then
			ntpcli=$(which ntpclient)
			if [ -n "$ntpcli" ]; then
				$ntpcli -c 1 -s -h pool.ntp.org
			else
				rdate -s pool.ntp.org
			fi
		fi
		export RANDFILE="/tmp/.rnd"
		dd if=/dev/urandom of="$RANDFILE" count=1 bs=512 2>/dev/null
		/tmp/usr/bin/openssl genrsa -out /etc/ssl/matrixtunnel.key 2048; /tmp/usr/bin/openssl req -new -batch -nodes -key /etc/ssl/matrixtunnel.key -out /etc/ssl/matrixtunnel.csr; /tmp/usr/bin/openssl x509 -req -days 365 -in /etc/ssl/matrixtunnel.csr -signkey /etc/ssl/matrixtunnel.key -out /etc/ssl/matrixtunnel.cert
		rm -f "$RANDFILE" 2>/dev/null
		unset RANDFILE
		ipkg install matrixtunnel
		if [ "$libsslsymlink" = "1" ]; then
			rm /lib/libcrypto.so.0.9.8
			rm /lib/libssl.so.0.9.8
		fi
		if [ -n "$inst_packages" ]; then
			ipkg remove "$inst_packages"
		fi
	fi
	echo "</pre><br />"
fi

#####################################################################
# initialize forms
if empty "$FORM_submit"; then
	# initialize all defaults
	is_kamikaze && {
		eval CONFIG_system_hostname="\$CONFIG_${hostname_cfg}_hostname"
		FORM_hostname="${CONFIG_system_hostname:-OpenWrt}"
		eval CONFIG_timezone_posixtz="\$CONFIG_${timezone_cfg}_posixtz"
		time_zone_part="${CONFIG_timezone_posixtz}"
		eval CONFIG_timezone_zoneinfo="\$CONFIG_${timezone_cfg}_zoneinfo"
		time_zoneinfo_part="${CONFIG_timezone_zoneinfo}"
		#wait for ntpclient to be updated
		#FORM_ntp_server="${ntp_server:-$(nvram get ntp_server)}"
	} || {
		FORM_hostname="${wan_hostname:-$(nvram get wan_hostname)}"
		FORM_hostname="${FORM_hostname:-OpenWrt}"
		time_zone_part="${time_zone_part:-$(nvram get time_zone)}"
		time_zoneinfo_part="${time_zoneinfo_part:-$(nvram get time_zoneinfo)}"
		FORM_ntp_server="${ntp_server:-$(nvram get ntp_server)}"
	}
	time_zone_part="${time_zone_part:-"UTC+0"}"
	time_zoneinfo_part="${time_zoneinfo_part:-"-"}"
	FORM_system_timezone="${time_zoneinfo_part}@${time_zone_part}"

	is_bcm947xx && {
		FORM_boot_wait="${boot_wait:-$(nvram get boot_wait)}"
		FORM_boot_wait="${FORM_boot_wait:-off}"
		FORM_wait_time="${wait_time:-$(nvram get wait_time)}"
		FORM_wait_time="${FORM_wait_time:-1}"
		FORM_clkfreq="${clkfreq:-$(nvram get clkfreq)}";
		FORM_clkfreq="${FORM_clkfreq:-200}"
	}
	# webif settings
	is_kamikaze && {	
		FORM_effect="${CONFIG_general_use_progressbar}"		# -- effects checkbox
		if equal $FORM_effect "1" ; then FORM_effect="checked" ; fi	# -- effects checkbox
	}
	FORM_language="${CONFIG_general_lang:-en}"	
	FORM_theme=${CONFIG_theme_id:-xwrt}
	FORM_ssl_enable="${CONFIG_ssl_enable:-0}"
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
		is_kamikaze && {
			#to check if we actually changed hostname, else donot reload network for no reason!
			eval CONFIG_system_hostname="\$CONFIG_${hostname_cfg}_hostname"
			! equal "$FORM_hostname" "$CONFIG_system_hostname" && ! empty "$FORM_hostname" && {
				uci_set "system" "$hostname_cfg" "hostname" "$FORM_hostname"
			}
			empty "$timezone_cfg" && {
				uci_add timezone timezone timezone
				timezone_cfg = "timezone"
			}
			eval CONFIG_timezone_posixtz="\$CONFIG_${timezone_cfg}_posixtz"
			! equal "$time_zone_part" "$CONFIG_timezone_posixtz" && ! empty "$time_zone_part" && {
				uci_set timezone "$timezone_cfg" posixtz "$time_zone_part"
			}
			eval CONFIG_timezone_zoneinfo="\$CONFIG_${timezone_cfg}_zoneinfo"
			! equal "$time_zoneinfo_part" "$CONFIG_timezone_zoneinfo" && ! empty "$time_zoneinfo_part" && {
				uci_set timezone "$timezone_cfg" zoneinfo "$time_zoneinfo_part"
			}
			#waiting for ntpclient update
			#save_setting system ntp_server "$FORM_ntp_server"
		} || {
			save_setting system wan_hostname "$FORM_hostname"
			save_setting timezone time_zone "$time_zone_part"
			save_setting timezone time_zoneinfo "$time_zoneinfo_part"
			save_setting system ntp_server "$FORM_ntp_server"
		}

		is_bcm947xx && {
			case "$FORM_boot_wait" in
				on|off) save_setting system boot_wait "$FORM_boot_wait";;
			esac
			! empty "$FORM_wait_time" &&
			{
				save_setting system wait_time "$FORM_wait_time"
			}
			equal "$OVERCLOCKING_DISABLED" "0" && ! empty "$FORM_clkfreq" &&
			{
				save_setting nvram clkfreq "$FORM_clkfreq"
			}
		}
		# webif settings
		! equal "$FORM_ssl_enable" "$CONFIG_ssl_enable" && ! empty "$FORM_ssl_enable" && {
			uci_set "webif" "ssl" "enable" "$FORM_ssl_enable"
		}
		! equal "$FORM_theme" "$CONFIG_theme_id" && ! empty "$FORM_theme" && {
			uci_set "webif" "theme" "id" "$FORM_theme"
		}
		! equal "$FORM_language" "$CONFIG_general_lang" && ! empty "$FORM_language" && {
			uci_set "webif" "general" "lang" "$FORM_language"
		}
		is_kamikaze && {	
			uci_set "webif" "general" "use_progressbar" "$FORM_effect_enable"
			FORM_effect=$FORM_effect_enable ; if equal $FORM_effect "1" ; then FORM_effect="checked" ; fi
		}
	else
		echo "<br /><div class=\"warning\">@TR<<Warning>>: @TR<<system_settings_Hostname_failed_validation#Hostname failed validation. Can not be saved.>></div><br />"
	fi
fi

WEBIF_SSL="field|@TR<<system_settings_Webif_SSL#Webif&sup2; SSL>>"
is_package_installed "matrixtunnel"
if [ "$?" = "1" ]; then
	WEBIF_SSL="$WEBIF_SSL
string|<div class=\"warning\">@TR<<system_settings_Feature_requires_matrixtunnel#MatrixTunnel package is not installed. You need to install it for ssl support>>:</div>
submit|install_stunnel| @TR<<system_settings_Install_MatrixTunnel#Install MatrixTunnel>> |"
else
	WEBIF_SSL="$WEBIF_SSL
select|ssl_enable|$FORM_ssl_enable
option|0|@TR<<system_settings_webifssl_Off#Off>>
option|1|@TR<<system_settings_webifssl_On#On>>"
fi

is_kamikaze && {	
	effect_field=$(cat <<EOF
field| 
string|<input type="checkbox" name="effect_enable" value="1" $FORM_effect />&nbsp;@TR<<Enable visual effects>><br/><br/>
EOF
)
}

#####################################################################
# over/underclocking
#
is_bcm947xx && {
	equal "$OVERCLOCKING_DISABLED" "0" &&
	{
	if [ "$CPU_VERSION" = "V0.8" ]; then
		FORM_clkfreqs="$FORM_clkfreq
			option|184
			option|188
			option|197
			option|200
			option|207
			option|216
			option|217
			option|225
			option|234
			option|238
			option|240
			option|250"
		# special case for custom CFEs (like mine)
		if [ $(nvram get clkfreq) -gt 250 ]; then
			FORM_clkfreqs="$FORM_clkfreqs
				option|$(nvram get clkfreq)"
		fi
	else
		# BCM3302 v0.7 or other..
		# in this case, we'll show it, but not have any options
		FORM_clkfreqs="$FORM_clkfreq
			option|$FORM_clkfreq"
	fi
	}

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

dangerous_form_start=""
dangerous_form_end=""
dangerous_form_help=""

#####################################################################
# Initialize LANGUAGES form
# create list if it doesn't exist ..
is_kamikaze && {
	! exists "/etc/languages.lst" && {
		/usr/lib/webif/webif-mklanglist.sh
	}
} || {
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

	equal "$OVERCLOCKING_DISABLED" "0" &&
	{
		clkfreq_form="field|@TR<<CPU Clock Frequency>>
		select|clkfreq|$FORM_clkfreqs"
		dangerous_form_start="start_form|@TR<<Dangerous Settings>>"
		dangerous_form_end="end_form"
		dangerous_form_help="helpitem|CPU Clock Frequency
					helptext|HelpText CPU Clock Frequency#Do not change this. You may brick your router if you do not know what you are doing. We've tried to disable it for all routers that can be bricked through an invalid clock frequency setting. Only Linksys WRT54G v4 units are known to be unbrickable by a bad clkfreq setting."
	}
}

#####################################################################
# check if ntpclient or opennptd is installed and give user option to install ntpclient if neither are installed.
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
## selected=\"selected\"
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

function setup()
{
	modechange();
	show('view_tz_string');
}

window.onload=setup
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
field|@TR<<system_settings_POSIX_TZ_String#POSIX TZ String>>|view_tz_string|hidden
string|<input id="show_TZ" type="text" style="width: 96%; height: 1.2em; color: #2f2f2f; background: #ececec; " name="show_TZ" readonly="readonly" value="@TR<<system_settings_js_required#This field requires the JavaScript support.>>" />
helpitem|Timezone
helptext|Timezone_helptext#Set up your time zone according to the nearest city of your region from the predefined list.
field|@TR<<NTP Server>>
text|ntp_server|$FORM_ntp_server
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
# end webif settings
###########################
$dangerous_form_start
$clkfreq_form
$dangerous_form_help
$dangerous_form_end
EOF

footer ?>

<!--
##WEBIF:name:System:10:Settings
-->
