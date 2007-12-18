#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Info" "System" "<img src=\"/images/blkbox.jpg\" alt=\"@TR<<System Information>>\"/>@TR<<System Information>>"

uci_load "webif"
firmware_version="$CONFIG_general_firmware_version"
firmware_name="$CONFIG_general_firmware_name"
firmware_subtitle="$CONFIG_general_firmware_subtitle"
device_name="$CONFIG_general_device_name"
[ -z "$device_name" ] && device_name="unidentified"
device_string=$(echo "$device_name" && ! empty "$device_version" && echo "$device_version")
_kversion=$(uname -srv 2>/dev/null)
_mac=$(/sbin/ifconfig eth0 2>/dev/null | grep HWaddr | cut -b39-)
board_type=$(cat /proc/cpuinfo 2>/dev/null | sed 2,20d | cut -c16-)
[ -z "$board_type" ] && board_type=$(uname -m 2>/dev/null)
user_string="$REMOTE_USER"
[ -z "$user_string" ] && user_string="not logged in"
machinfo=$(uname -a 2>/dev/null)
if $(echo "$machinfo" | grep -q "mips"); then
	if $(echo "$board_type" | grep -q "Atheros"); then
		target_path="atheros-2.6"
	elif $(echo "$board_type" | grep -q "WP54"); then
		target_path="adm5120-2.6"
	elif $(echo "$machinfo" | grep -q "2\.4"); then
		target_path="brcm-2.4"
	elif $(echo "$machinfo" | grep -q "2\.6"); then
		target_path="brcm-2.6"
	fi
elif $(echo "$machinfo" | grep -q " i[0-9]86 "); then
	target_path="x86-2.6"
elif $(echo "$machinfo" | grep -q " avr32 "); then
	target_path="avr32-2.6"
elif $(cat /proc/cpuinfo 2>/dev/null | grep -q "IXP4"); then
	target_path="ixp4xx-2.6"
fi
package_filename="webif_latest_stable.ipk"
if $(echo "$firmware_version" | grep -q "r[[:digit:]]*"); then
	version_path="snapshots"
	svn_path="trunk"
else
	version_path="$firmware_version"
	svn_path="tags/kamikaze_$firmware_version"
fi
# let the user to serve it locally, it requires the X-Wrt (local) repository to be present
config_get_bool local_update general local_update 0
[ 1 -eq "$local_update" ] && version_url=$(sed '/^src[[:space:]]*X-Wrt[[:space:]]*/!d; s/^src[[:space:]]*X-Wrt[[:space:]]*//g; s/\/packages.*$/\//g' /etc/ipkg.conf 2>/dev/null)
[ -z "$version_url" ] && version_url="http://downloads.x-wrt.org/xwrt/kamikaze/$version_path/$target_path/"
this_revision=$(cat "/www/.version" 2>/dev/null)
revision_text=" r$this_revision "
version_file=".version-stable"
daily_checked=""
upgrade_button=""

equal "$FORM_check_daily" "1" && {	
	version_file=".version"
	package_filename="webif_latest.ipk"
	daily_checked="checked=\"checked\""
}

if [ -n "$FORM_update_check" ]; then
	echo "@TR<<Please wait>> ...<br />"
	tmpfile=$(mktemp "/tmp/.webif-XXXXXX")
	rm -f $tmpfile
	wget -q "$version_url$version_file" -O "$tmpfile" 2>&-	
	! exists "$tmpfile" && echo "doesn't exist" > "$tmpfile"		
	cat $tmpfile | grep -q "doesn't exist"
	if [ $? = 0 ]; then
		revision_text="<em class="warning">@TR<<info_error_checking#ERROR CHECKING FOR UPDATE>><em>"
	else
		latest_revision=$(cat $tmpfile)
		if [ "$this_revision" -lt "$latest_revision" ]; then
			revision_text="<em class="warning">@TR<<info_update_available#webif&sup2; update available>>: r$latest_revision - <a href=\"http://svn.berlios.de/wsvn/xwrt/${svn_path}/package/webif/?op=log&amp;rev=0&amp;sc=0&amp;isdir=1\" target=\"_blank\">@TR<<info_view_changes#view changes>></a></em>"
			upgrade_button="<input type=\"submit\" value=\" @TR<<info_upgrade_webif#Update/Reinstall Webif>> \"  name=\"install_webif\" />"
		else
			revision_text="<em>@TR<<info_already_latest#You have the latest webif&sup2;>>: r$this_revision</em>"
		fi
	fi
	rm -f "$tmpfile"
fi

if [ -n "$FORM_install_webif" ]; then
	echo "@TR<<info_wait_install#Please wait, installation may take a minute>> ... <br />"
	echo "<pre>"
	ipkg -V 0 update
	ipkg install "${version_url}${package_filename}" -force-overwrite -force-reinstall| uniq
	echo "</pre>"
	this_revision=$(cat "/www/.version")
	# update the active language package
	curlang="$(cat "/etc/config/webif" |grep "lang=" |cut -d'=' -f2)"
	! equal "$(ipkg status "webif-lang-${curlang}" |grep "Status:" | grep " installed" )" "" && {
		webif_version=$(ipkg status webif | awk '/Version:/ { print $2 }')
		echo "<pre>"
		ipkg install "${version_url}packages/webif-lang-${curlang}_${webif_version}_mipsel.ipk" -force-reinstall -force-overwrite | uniq
		echo "</pre>"
	}
fi

config_get_bool show_banner general show_banner 0
[ 1 -eq "$show_banner" ] && {
	echo "<pre>"
	cat /etc/banner 2>/dev/null
	echo "</pre><br />"
}

cat <<EOF
<table summary="System Information">
<tbody>
	<tr>
		<td width="100"><strong>@TR<<Firmware>></strong></td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>$firmware_name - $firmware_subtitle $firmware_version</td>
	</tr>
	<tr>
		<td><strong>@TR<<Kernel>></strong></td><td>&nbsp;</td>
		<td>$_kversion</td>
	</tr>
	<tr>
		<td><strong>@TR<<MAC>></strong></td><td>&nbsp;</td>
		<td>$_mac</td>
	</tr>
	<tr>
		<td><strong>@TR<<Device>></strong></td><td>&nbsp;</td><td>$device_string</td>
	</tr>
	<tr>
		<td><strong>@TR<<Board>></strong></td><td>&nbsp;</td><td>$board_type</td>
	</tr>
	<tr>
		<td><strong>@TR<<Username>></strong></td><td>&nbsp;</td>
		<td>$user_string</td>
	</tr>	
</tbody>
</table>
<br />
<table summary="Webif Information">
<tbody>
	<tr>
		<td><strong>@TR<<Web mgt. console>></strong></td><td>&nbsp;</td>
		<td>Webif&sup2;</td>
	</tr>
	<tr>
		<td><strong>@TR<<Version>></strong></td><td></td><td>$revision_text</td>
	</tr>
</tbody>
</table>

<form action="" enctype="multipart/form-data" method="post">
<table summary="Update webif">
<tbody>
	<tr>
		<td colspan="2">
		<input type="submit" value=" @TR<<info_check_update#Check For Webif Update>> " name="update_check" />
		$upgrade_button
		</td>
	</tr>
	<tr>
		<td colspan="2"><input type="checkbox" $daily_checked value="1" name="check_daily" id="field_check_daily" />@TR<<info_check_daily_text#Include daily builds when checking for update to webif&sup2;>></td>
	</tr>
</tbody>
</table>
</form>

EOF

footer

?>
<!--
##WEBIF:name:Info:001:System
-->
