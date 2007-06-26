#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
. /usr/lib/webif/webif.sh
###################################################################
# System Backup & Restore page
#
# Description:
#	An interface to backup and restore functions.
#
# Author(s) [in order of work date]:
#	unknown
#	Dmytro Dykhman <dmytro@iroot.ca>
#	Lubos Stanek <lubek@users.berlios.de> - total redesign, the uci configuration
#
# Configuration files referenced:
#	/etc/config/backup
#

lf_IFS="
"

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
label {
	margin-left: 5px;
}
-->
</style>

EOF
)

config_cb() {
	config_get TYPE "$CONFIG_SECTION" TYPE
	case "$TYPE" in
		backup)
			backup_cfg="$CONFIG_SECTION"
		;;
	esac
}

make_backup() {
	[ ! -f /etc/config/backup ] && cp -pf /usr/lib/webif/backup.default /etc/config/backup >/dev/null 2>&1
	uci_load "backup"
	local tmpdir bkstamp nvram_selector seccfg seccfg_type seccfg_mask tmpgz prepwd oldIFS dir file file_path realname tmpgz_name tmpgz_path
	echo "<form method=\"post\" name=\"backupreturn\" action=\"$SCRIPT_NAME\">"
	echo "<h3><strong>@TR<<system_confman_Backup_Configuration#Backup Configuration>></strong></h3>"
	echo -n "<pre>"
	echo "@TR<<system_confman_Preparing_backup#Preparing the backup...>>"
	tmpdir=$(mktemp -d "/tmp/.config-XXXXXX")
	[ -n "$tmpdir" ] && {
		bkstamp=$(date "+%m%d%H%M%Y.%S")
		date -d "$bkstamp" "+%Y-%m-%d %H:%M:%S %Z" > $tmpdir/config.date
		echo "$FORM_name" > $tmpdir/config.name
		echo "$(nvram get boardtype)" > $tmpdir/config.boardtype
		echo "@TR<<system_confman_Backing_fidi#Backing up files and directories...>>"
		for seccfg in $CONFIG_SECTIONS; do
			# prepare the nvram selector
			eval "seccfg_type=\"\$CONFIG_${seccfg}_TYPE\""
			[ "$seccfg_type" = "nvramgroupmask" ] && {
				eval "seccfg_mask=\"\$CONFIG_${seccfg}_nvramgroupmask\""
				nvram_selector="$nvram_selector $seccfg_mask"
			}
			[ "$seccfg_type" = "nvramvariable" ] && {
				eval "seccfg_mask=\"\$CONFIG_${seccfg}_nvramvariable\""
				nvram_selector="$nvram_selector ${seccfg_mask}="
			}
			# copy directories
			[ "$seccfg_type" = "directorymask" ] && {
				eval "seccfg_mask=\"\$CONFIG_${seccfg}_directorymask\""
				[ -n "$seccfg_mask" ] && {
					oldIFS="$IFS"
					IFS="$lf_IFS"
					seccfg_mask=$(echo "$seccfg_mask" | sed 's/ /\ /g')
					for dir in $(find $seccfg_mask 2>/dev/null); do
						[ -d "$dir" ] && {
							mkdir -p $tmpdir$dir
							cp -fpr $dir/* $tmpdir$dir/
						}
					done
					IFS="$oldIFS"
				}
			}
			# copy files
			[ "$seccfg_type" = "filemask" ] && {
				eval "seccfg_mask=\"\$CONFIG_${seccfg}_filemask\""
				[ -n "$seccfg_mask" ] && {
					oldIFS="$IFS"
					IFS="$lf_IFS"
					seccfg_mask=$(echo "$seccfg_mask" | sed 's/ /\ /g')
					for file in $(find $seccfg_mask 2>/dev/null); do
						[ -f "$file" ] && [ ! -d "$file" ] && [ ! -h "$file" ] && {
							file_path="${file%/*}"
							[ ! -d "$tmpdir$file_path" ] && mkdir -p "$tmpdir$file_path"
							cp -fp "$file" "$tmpdir$file"
						}
					done
					IFS="$oldIFS"
				}
			}
		done
		[ -n "$nvram_selector" ] && {
			nvram_selector=$(echo "$nvram_selector" | sed 's/^ *//; s/ /|/g;')
			echo "@TR<<system_confman_Backing_NVRAM#Backing up NVRAM variables...>>"
			nvram show 2>/dev/null | egrep "^(${nvram_selector})" | sort > $tmpdir/nvram
		}
		echo "@TR<<system_confman_Backup_Prepared#The backup was prepared successfully.>>"
		echo "</pre>"
		tmpgz=$(mktemp "/tmp/config.tgz-XXXXXX")
		[ -n "$tmpgz" ] && {
			prepwd=$(pwd)
			cd "$tmpdir"
			tar czf "$tmpgz" *
			chmod 0600 "$tmpgz" 2>/dev/null
			cd "$prepwd"
			rm -rf "$tmpdir" 2>/dev/null

			tmpgz_path="${tmpgz%/*}"
			tmpgz_name="${tmpgz##*/}"
			realname="config-$(date -d "$bkstamp" "+%Y%m%d%H%M%S").tgz"
			cat <<EOF
<p>@TR<<confman_noauto_click#If downloading does not start automatically, click here>> ... <a href="/cgi-bin/webif/download.sh?script=$SCRIPT_NAME&amp;path=$tmpgz_path&amp;savefile=$tmpgz_name&amp;realname=$realname">$realname</a></p>
<script language="JavaScript" type="text/javascript">
<!--
setTimeout('top.location.href=\"/cgi-bin/webif/download.sh?script=$SCRIPT_NAME&amp;path=$tmpgz_path&amp;savefile=$tmpgz_name&amp;realname=$realname\"',"1500")
//-->
</script>
EOF
		}
	}
	echo "<br />"
	echo "<input type=\"hidden\" name=\"tmpgzname\" value=\"$tmpgz\" />"
	echo "<input type=\"hidden\" name=\"action\" value=\"backupreturn\" />"
	echo "<input type=\"submit\" name=\"submit\" value=\" @TR<<system_confman_Clean_Return#Clean &amp; Return>> \" />"
	echo "</form>"
	echo "<p>@TR<<system_confman_Press_to_clean#Press the button to free the memory used by the backup archive after the successful download.>></p>"
}

check_archive() {
	echo "<form method=\"post\" name=\"restore\" action=\"$SCRIPT_NAME\">"
	echo "<input type=\"hidden\" name=\"action\" value=\"restore\" />"
	echo "<input type=\"hidden\" name=\"submit\" value=\"restore\" />"
	local tmpdir prepwd config_name config_boardtype config_date local_boardtype tmplist erlev
	[ -n "$FORM_config_file" ] && [ -e "$FORM_config_file" ] && {
		echo "<input type=\"hidden\" name=\"tmpgzname\" value=\"${FORM_config_file}\" />"
		tmpdir=$(mktemp -d "/tmp/.checkconfig-XXXXXX")
		[ -n "$tmpdir" ] && {
			prepwd=$(pwd)
			cd "$tmpdir"
			tar zx -f "$FORM_config_file" 2>/dev/null
			erlev="$?"
			cd "$prepwd"
			[ "$erlev" != "0" ] && [ ! -e "$tmpdir/config.name" ] && [ ! -e "$tmpdir/config.boardtype" ] && [ ! -e "$tmpdir/config.date" ] && [ ! -e "$tmpdir/nvram" ] && {
				echo "<h3 class=\"warning\">@TR<<system_confman_Invalid_config_archive#Invalid configuration archive!>></h3>"
			} || {
				config_name=$(cat "$tmpdir/config.name")
				config_boardtype=$(cat "$tmpdir/config.boardtype")
				config_date=$(cat "$tmpdir/config.date")
				local_boardtype=$(nvram get boardtype)
				[ "$config_boardtype" != "$local_boardtype" ] && {
					echo "<h3 class=\"warning\">@TR<<system_confman_Wrong_board_type#Wrong board type>>!</h3>"
					echo "<div class=\"settings\">"
					echo "<h3><strong>@TR<<system_confman_Wrong_board_type#Wrong board type>></strong></h3>"
					echo "<table>"
					echo "<tr><td>@TR<<system_confman_Device_Board_Type#Device's Board Type>>:&nbsp;</td><td><strong>$config_boardtype</strong></td></tr>"
					echo "<tr><td>@TR<<system_confman_Archived_Board_Type#Archived Board Type>>:&nbsp;</td><td><strong>$local_boardtype</strong></td></tr>"
					echo "</table>"
					echo "</div>"
				} || {
					echo "<p><input type=\"submit\" name=\"checkarchive_cancel\" value=\" @TR<<system_confman_Cancel_Clean#Cancel &amp; Clean>> \" /></p>"
					echo "<p>@TR<<system_confman_Cancel_to_clean#Press the button to free the memory used by the backup archive and temporary files to cancel the restore.>></p>"
					echo "<br />"
					echo "<div class=\"settings\">"
					echo "<h3><strong>@TR<<system_confman_Restore_Configuration#Restore Configuration>></strong></h3>"
					echo "<table>"
					echo "<tr><td>@TR<<system_confman_Config_Name#Config Name>>:&nbsp;</td><td><strong>$config_name</strong></td></tr>"
					echo "<tr><td>@TR<<system_confman_Board_Type#Board Type>>:&nbsp;</td><td><strong>$config_boardtype</strong></td></tr>"
					echo "<tr><td>@TR<<system_confman_Generated#Generated>>:&nbsp;</td><td><strong>$config_date</strong></tr>"
					echo "</table><br />"
					echo "<h4>@TR<<system_confman_Files#Files>></h4>"
					tar zt -f "$FORM_config_file" | sed '/^config\.\(boardtype\|date\|name\)$/d; /^nvram$/d; /\/$/d; s/^/\//;' | sort | awk '
{
	idname = "restfile_" NR
	val = $0
	if ((length($0) == 0) || ($0 == " ")) $0 = "&nbsp;"
	else {
		gsub(/&/, "\\&amp;", $0)
		gsub(/</, "\\&lt;", $0)
		gsub(/>/, "\\&gt;", $0)
	}
	print "<input type=\"checkbox\" id=\"" idname "\" name=\"" idname "\" value=\"" val "\" /><label for=\"" idname "\">" $0 "</label><br />"
}'
					echo "<br />"
					echo "<h4>@TR<<system_confman_NVRAM#NVRAM>></h4>"
					cat "$tmpdir/nvram" | sort | awk -F "=" '
{
	val = $2
	for (i = 3; i <= NF; i++) val = val "=" $(i)
	idname = "restnvram_" $1
	if ((length($0) == 0) || ($0 == " ")) $0 = "&nbsp;"
	else {
		gsub(/&/, "\\&amp;", $0)
		gsub(/</, "\\&lt;", $0)
		gsub(/>/, "\\&gt;", $0)
	}
	print "<input type=\"checkbox\" id=\"" idname "\" name=\"" idname "\" value=\"" val "\" /><label for=\"" idname "\">" $0 "</label><br />"
}'
					echo "</div>"
					echo "<br />"
					echo "<p><input type=\"submit\" id=\"restore_button\" name=\"restore_restore\" value=\" @TR<<system_confman_Restore_Selected#Restore Selected>> \" /></p>"
				}
			}
			rm -rf "$tmpdir" 2>/dev/null
		}
	} || {
		echo "<h3 class=\"warning\">@TR<<system_confman_no_archive_supplied#No backup archive was supplied.>></h3>"
	}
	echo "<br />"
	echo "<p><input type=\"submit\" name=\"restore_cancel\" value=\" @TR<<system_confman_Cancel_Clean#Cancel &amp; Clean>> \" /></p>"
	echo "<p>@TR<<system_confman_Cancel_to_clean#Press the button to free the memory used by the backup archive and temporary files to cancel the restore.>></p>"
	echo "</form>"
}

restore_selection() {
	local tmpdir prepwd erlev filelist editpath cpfile tmpfpath nvramlist ucipath ucifile
	CHANGES=0
	echo "<p>@TR<<system_confman_Preparing_restore#Preparing the restore...>></p>"
	tmpdir=$(mktemp -d "/tmp/.restore-XXXXXX")
	[ -n "$tmpdir" ] && {
		prepwd=$(pwd)
		cd "$tmpdir"
		tar zx -f "$FORM_tmpgzname" 2>/dev/null
		erlev="$?"
		cd "$prepwd"
		[ "$erlev" = "0" ] && {
			echo "<pre>"
			echo "@TR<<system_confman_Restoring_Files#Restoring files...>>"
			# scan FORM_restfile_?
			filelist=$(set | egrep "^FORM_restfile_[[:digit:]]*=" | sed 's/^FORM_restfile_[[:digit:]]\{1,2\}='\''//; s/'\''$//')
			! empty "$filelist" && {
				editpath="/tmp/.webif/edited-files"
				ucipath="/tmp/.uci"
				oldIFS="$IFS"
				IFS="$lf_IFS"
				for cpfile in $filelist; do
					tmpfpath="${cpfile%/*}"
					[ ! -d "$editpath$tmpfpath" ] && mkdir -p "$editpath$tmpfpath"
					cp -fp "$tmpdir$cpfile" "$editpath$cpfile"
					[ "$tmpfpath" = "/etc/config" ] && {
						ucifile="${cpfile##*/}"
						[ "$ucifile" != "firewall" ] && {
							[ ! -d "$ucipath" ] && mkdir -p "$ucipath"
							touch "$ucipath/$ucifile"
						}
					}
				done
				IFS="$oldIFS"
			}
			echo "@TR<<system_confman_Restoring_NVRAM#Restoring NVRAM values...>>"
			# scan FORM_restnvram_[var]
			nvramlist=$(set | egrep "^FORM_restnvram_" | sed 's/^FORM_restnvram_//')
			! empty "$nvramlist" && {
				oldIFS="$IFS"
				IFS="$lf_IFS"
				for nvramvar in $nvramlist; do
					tmpnvram=$(echo "$nvramvar" | sed 's/='\''.*//')
					tmpvalue=$(echo "$nvramvar" | sed 's/^[^'\'']*='\''//; s/'\''$//')
					nvramgroup=""
					if ! empty "$(echo "$tmpnvram" | egrep "^(lan|wan|wifi|wwan|ppp)_")"; then nvramgroup="network"
					elif ! empty "$(echo "$tmpnvram" | egrep "(^dhcp_|_dhcp_)")"; then nvramgroup="network"
					elif ! empty "$(echo "$tmpnvram" | egrep "^wl0_")"; then nvramgroup="wireless"
					elif ! empty "$(echo "$tmpnvram" | egrep "^log_")"; then nvramgroup="log"
					elif ! empty "$(echo "$tmpnvram" | egrep "^ddns_")"; then nvramgroup="ezipupdate"
					elif ! empty "$(echo "$tmpnvram" | egrep "^time_(zone|zoneinfo)")"; then nvramgroup="timezone"
					elif ! empty "$(echo "$tmpnvram" | egrep "^snmp_")"; then nvramgroup="snmp"
					elif ! empty "$(echo "$tmpnvram" | egrep "^openvpn_")"; then nvramgroup="openvpn"
					elif ! empty "$(echo "$tmpnvram" | egrep "^vlan[[:digit:]]{1,2}(hwname|ports)")"; then nvramgroup="network"
					elif ! empty "$(echo "$tmpnvram" | egrep "^pptp_(cli|srv)")"; then nvramgroup="pptp"
					elif equal "$tmpnvram" "pptp_server_ip"; then nvramgroup="network"
					elif equal "$tmpnvram" "cron_enable"; then nvramgroup="cron"
					elif equal "$tmpnvram" "clkfreq"; then nvramgroup="nvram"
					else nvramgroup="system"
					fi
					save_setting "$nvramgroup" "$tmpnvram" "$tmpvalue"
				done
				IFS="$oldIFS"
			}
			echo "</pre>"
			update_changes
			echo "@TR<<system_confman_total_changes#Total of configuration changes>>: $CHANGES"
		} || {
			echo "<h3 class=\"warning\">@TR<<confman_Invalid_configuration_archive#Invalid configuration archive!>></h3>"
		}
	}
	rm -rf "$tmpdir" 2>/dev/null
	[ "$CHANGES" -gt 0 ] && {
		echo "<h2>@TR<<Backup and Restore>>: @TR<<Settings saved>><br />"
		echo "@TR<<system_confman_click_apply#You must click on the Apply Changes link to finally restore the changes and make them permanent.>><br />"
		echo "@TR<<system_confman_remind_restart#It is recommended to restart the whole system. The number of changes could be really big and not all services might be able to absorb restored settings.>></h2>"
	}
}

basic_form() {
	echo "<form method=\"post\" name=\"backup\" action=\"$SCRIPT_NAME\">"
	display_form <<EOF
start_form|@TR<<system_confman_Backup_Configuration#Backup Configuration>>
field|@TR<<system_confman_Backup_Name#Backup Name>>
text|name|$FORM_name
field|&nbsp;
string|<input type="hidden" name="action" value="backup" />
field|&nbsp;
submit|submit|@TR<<system_confman_Create_Backup#Create Backup>>
helpitem|system_confman_Backup_Name#Backup Name
helptext|system_confman_Backup_Name_helptext#You can add a descriptive name to your configuration to better distinguish between several backups. The time of the backup is automatically included.
end_form
EOF
	echo "</form>"
	echo "<form method=\"post\" name=\"restore\" action=\"$SCRIPT_NAME\" enctype=\"multipart/form-data\">"
	display_form <<EOF
start_form|@TR<<system_confman_Restore_Configuration#Restore Configuration>>
field|@TR<<system_confman_Backup_File#Backup File>>
upload|config_file|$FORM_config_file
field|&nbsp;
string|<input type="hidden" name="action" value="checkarchive" />
field|&nbsp;
submit|submit|@TR<<system_confman_Restore_Configuration#Restore Configuration>>
helpitem|system_confman_Backup_File#Backup File
helptext|system_confman_Backup_File_helptext#Browse for the requested backup archive (config[-datetime].tgz) to restore the configuration from.
end_form
EOF
	echo "</form>"
}

header "System" "Backup &amp; Restore" "@TR<<Backup and Restore>>" ''

FORM_name="${FORM_name:-$(nvram get wan_hostname)}"

! empty "$FORM_submit" && {
	case "$FORM_action" in
		backup)
			make_backup
		;;
		backupreturn)
			! empty "$FORM_tmpgzname" && rm -f "$FORM_tmpgzname" >/dev/null 2>&1
			basic_form
		;;
		checkarchive)
			check_archive
		;;
		restore)
			! empty "$FORM_restore_restore" && ! empty "$FORM_tmpgzname" && exists "$FORM_tmpgzname" && restore_selection
			! empty "$FORM_tmpgzname" && rm -f "$FORM_tmpgzname" >/dev/null 2>&1
			basic_form
		;;
	esac
} || {
	basic_form
}

footer
?>
<!--
##WEBIF:name:System:450:Backup &amp; Restore
-->
