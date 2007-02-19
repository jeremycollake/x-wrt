#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
#
# TODO: This page looks ugly anymore (rendered).
#
header "Info" "System" "<img src=\"/images/blkbox.jpg\" alt=\"@TR<<System Information>>\"/>@TR<<System Information>>" '' ''

SHOW_BANNER=0	# set to show /etc/banner

if is_kamikaze; then
	XWRT_BRANCH="kamikaze"
	package_filename="kamikaze/webif_latest_stable.ipk"	
	uname -a |grep 2.4 |grep -q mips
	[ $? = 0 ] && {
		version_url="http://ftp.berlios.de/pub/xwrt/kamikaze/broadcom-2.4/"
	}
	uname -a |grep 2.6 |grep -q i586
	[ $? = 0 ] && {
		version_url="http://ftp.berlios.de/pub/xwrt/kamikaze/x86-2.6/"
	}
else
	XWRT_BRANCH="trunk"
	package_filename="webif_latest_stable.ipk"
	version_url="http://ftp.berlios.de/pub/xwrt/"
fi

this_revision=$(cat "/www/.version")
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
			revision_text="<em class="warning">@TR<<info_update_available#webif^2 update available>>: r$latest_revision - <a href=\"http://svn.berlios.de/wsvn/xwrt/${XWRT_BRANCH}/package/webif/?op=log&amp;rev=0&amp;sc=0&amp;isdir=1\" target=\"_blank\">@TR<<info_view_changes#view changes>></a></em>"
			upgrade_button="<input type=\"submit\" value=\" @TR<<info_upgrade_webif#Update/Reinstall Webif>> \"  name=\"install_webif\" />"
		else
			revision_text="<em>@TR<<info_already_latest#You have the latest webif^2>>: r$this_revision</em>"
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

uci_load "webif"
firmware_version="$CONFIG_general_firmware_version"
firmware_name="$CONFIG_general_firmware_name"
firmware_subtitle="$CONFIG_general_firmware_subtitle"
firmware_version="$CONFIG_general_firmware_version"
_kversion="$( uname -srv )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
board_type=$(cat /proc/cpuinfo | sed 2,20d | cut -c16-)
if [ "$board_type" = "" ]; then
	board_type="$(uname -m)"
fi
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
<table summary="Webif Information">
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
<table summary="Update webif">
<tbody>
	<tr>
		<td colspan="2">
		<input type="submit" value=" @TR<<info_check_update#Check For Webif Update>> " name="update_check" />
		$upgrade_button		
		</td>
	</tr>
<tr><td colspan="2"><input type="checkbox" $daily_checked value="1" name="check_daily" id="field_check_daily" />@TR<<info_check_daily_text#Include daily builds when checking for update to webif&sup2;>></td>
</tr>
</tbody>
</table>
</form>

EOF

footer

?>
<!--
##WEBIF:name:Info:1:System
-->
