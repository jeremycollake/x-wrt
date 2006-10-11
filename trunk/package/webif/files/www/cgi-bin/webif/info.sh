#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "System Information" "@TR<<System Information>>" '' ''

this_revision=$(cat "/www/.version")

if [ -n "$FORM_update_check" ]; then	  	
	tmpfile=$(mktemp "/tmp/.webif.XXXXXX")
	wget http://ftp.berlios.de/pub/xwrt/.version -O $tmpfile 2> /dev/null >> /dev/null
	cat $tmpfile | grep "doesn't exist" 2>&1 >> /dev/null
	if [ $? = 0 ]; then		
		revision_text="<div id=\"update-error\">ERROR CHECKING FOR UPDATE</div>"
	else
		latest_revision=$(cat $tmpfile)
		if [ "$this_revision" != "$latest_revision" ]; then
 			revision_text="<div id=\"update-available\">webif^2 update available: r$latest_revision (you have r$this_revision)</div>"
 		else
 			revision_text="<div id=\"update-unavailable\">You have the latest webif^2: r$latest_revision</div>"	 		
 		fi
	fi	
	rm -f "$tmpfile"	 	
fi

if [ -n "$FORM_install_webif" ]; then	  
	echo "Please wait, installation may take a couple minutes ... <br />"
	echo "<pre>"
	ipkg install http://ftp.berlios.de/pub/xwrt/webif_latest.ipk	
	echo "</pre>" 	
fi


_version=$(nvram get firmware_version)
_kversion="$( uname -srv )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
#
# board id checks go here.. todo: much work remains here
#
# loop is just used to avoid a jump
while empty $device_type; do	
	strings /dev/mtdblock/0 | grep 'W54G' 2>&1 >> /dev/null
	if [ $? = "0" ]; then
 		device_type="WRT54G"
 		device_version="v??"
 		break
	fi	
	break
done
empty $device_type && device_type="-id code not done for this board-";
board_type=$(cat /proc/cpuinfo | sed 2,20d | cut -c16-)
device_string=$(echo $device_type && ! empty $device_version && echo $device_version)
user_string=$REMOTE_USER
equal $user_string "" && user_string="not logged in"

echo "<pre>"
cat '/etc/banner'
echo "</pre><br />"
cat <<EOF
<table>
<tbody>	
	<tr>
		<td><strong>@TR<<Firmware>></strong></td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>$_firmware_name - $_firmware_subtitle $_version</td>		
	</tr>
	<tr>
		<td><strong>@TR<<Webif>></strong></td><td>&nbsp;</td>
		<td>webif<sup>2</sup> r$this_revision $revision_text</td> 				
<td colspan="2">
<form action="" enctype="multipart/form-data" method="post">
<input type="submit" value=" Check For Webif^2 Update " name="update_check" />
<input type="submit" value=" Install/Reinstall Webif^2  " name="install_webif" />
</form>	
</td>
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
	
	<tr><td><br /><br /></td></tr>
</tbody>
</table>
  <p>
    <a href="http://validator.w3.org/check?uri=referer"><img
        src="http://www.w3.org/Icons/valid-xhtml10"
        alt="Valid XHTML 1.0 Transitional" height="31" width="88" /></a>
  </p>
EOF

footer

?>
<!--
##WEBIF:name:Info:10:System Information
-->
