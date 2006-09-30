#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "System Information" "@TR<<System Information>>" '' ''

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

cat <<EOF
<table>
<tbody>
<tr><td><br /><br /></td></tr>
	<tr>
		<td><strong>@TR<<Firmware>></strong></td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>$_firmware_name - $_firmware_subtitle $_version</td>		
	</tr>
	<tr>
		<td><strong>@TR<<Webif>></strong></td><td>&nbsp;</td>
		<td>webif^2 r__SVN_REVISION__</td>
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
EOF

footer

?>
<!--
##WEBIF:name:Info:10:System Information
-->
