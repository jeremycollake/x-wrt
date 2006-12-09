#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
#
# TODO: This page looks ugly anymore (rendered).
#
header "Info" "System" "@TR<<System Information>>" '' ''

SHOW_BANNER=0	# set to show /etc/banner

if is_kamikaze; then
	XWRT_BRANCH="kamikaze"
	package_filename="kamikaze/webif_latest_stable.ipk"
	version_url="http://ftp.berlios.de/pub/xwrt/kamikaze/"
else
	XWRT_BRANCH="trunk"
	package_filename="webif_latest_stable.ipk"
	version_url="http://ftp.berlios.de/pub/xwrt/"
fi

this_revision=$(cat "/www/.version")
revision_text=" r$this_revision "
version_file=".version-stable"
daily_checked=""

equal "$FORM_check_daily" "1" && {	
	version_file=".version"
	package_filename="webif_latest.ipk"
	daily_checked="checked=\"checked\""
}

if [ -n "$FORM_update_check" ]; then
	echo "@TR<<Please wait>> ...<br />"
	tmpfile=$(mktemp "/tmp/.webif.XXXXXX")	
	wget -q "$version_url$version_file" -O "$tmpfile" 2>&-
	! exists "$tmpfile" && echo "doesn't exist" > "$tmpfile"
	cat $tmpfile | grep -q "doesn't exist"
	if [ $? = 0 ]; then
		revision_text="<div id=\"update-error\">ERROR CHECKING FOR UPDATE</div>"
	else
		latest_revision=$(cat $tmpfile)
		if [ "$this_revision" -lt "$latest_revision" ]; then
			revision_text="<div id=\"update-available\">webif^2 update available: r$latest_revision - <a href=\"http://svn.berlios.de/wsvn/xwrt/${XWRT_BRANCH}/package/webif/?op=log&amp;rev=0&amp;sc=0&amp;isdir=1\" target=\"_blank\">view changes</a></div>"
		else
			revision_text="<div id=\"update-unavailable\">You have the latest webif^2: r$this_revision</div>"
		fi
	fi
	rm -f "$tmpfile"
fi

if [ -n "$FORM_install_webif" ]; then
	echo "Please wait, installation may take a minute ... <br />"
	echo "<pre>"
	ipkg install "http://ftp.berlios.de/pub/xwrt/$package_filename" | uniq
	echo "</pre>"
	this_revision=$(cat "/www/.version")
fi

uci_load "webif"
firmware_version="$CONFIG_general_firmware_version"
firmware_name="$CONFIG_general_firmware_name"
firmware_subtitle="$CONFIG_general_firmware_subtitle"
firmware_version="$CONFIG_general_firmware_version"
_kversion="$( uname -srv )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
board_type=$(cat /proc/cpuinfo | sed 2,20d | cut -c16-)
device_name="$CONFIG_general_device_name"
empty "$device_name" && device_name="unidentified"
device_string=$(echo $device_name && ! empty $device_version && echo $device_version)
user_string=$REMOTE_USER
equal $user_string "" && user_string="not logged in"

equal "$SHOW_BANNER" "1" && {
	echo "<pre>"
	cat '/etc/banner'
	echo "</pre><br />"
}

cat <<EOF

@TR<<Welcome to your <a href="http://www.openwrt.org">OpenWrt</a> and <a href="http://www.x-wrt.org">X-Wrt</a> based router>>.
<br /><br />
<table>
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
		<td><strong>@TR<<Device>></strong></td><td>&nbsp;</td><td> $device_string</td>
	</tr>
	<tr>
		<td><strong>@TR<<Board>></strong></td><td>&nbsp;</td><td> $board_type</td>
	</tr>
	<tr>
		<td><strong>@TR<<Username>></strong></td><td>&nbsp;</td>
		<td>$user_string</td>
	</tr>	
</tbody>
</table>
<br />
<table>
<tbody>
	<tr>
		<td><strong>@TR<<Web mgt. console>></strong></td><td>&nbsp;</td>
		<td>Webif<sup>2</sup></td>
	</tr>
	<tr>
		<td><strong>@TR<<Version>></strong></td><td></td><td>$revision_text</td>
	</tr>
</tbody>
</table>

<form action="" enctype="multipart/form-data" method="post">	
<table>
<tbody>
	<tr>
		<td colspan=2">
		<input type="submit" value=" @TR<<Check_Upgrade|Check For Webif Update>> " name="update_check" />
		<input type="submit" value=" @TR<<Upgrade_Webif#Update/Reinstall Webif>> "  name="install_webif" />
		</td>
	</tr>
<tr><td colspan="2"><input type="checkbox" $daily_checked value="1" name="check_daily" id="field_check_daily" />@TR<<Include daily builds when checking for update or installing latest webif<sup>2</sup>>></td>
</tr>
</tbody>
</table>
</form>

EOF

show_validated_logo
footer

?>
<!--
##WEBIF:name:Info:1:System
-->
