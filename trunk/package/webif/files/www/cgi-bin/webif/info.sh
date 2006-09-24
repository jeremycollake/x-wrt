#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "System Information" "@TR<<System Information>>" '' ''
 	
?>
<pre><?
_version=$(nvram get firmware_version)
_kversion="$( uname -srv )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
cat <<EOF
</pre>
<table style="width: 90%; text-align: left;" border="0" cellspacing="0" align="left">
<tbody>
	<tr>
		<td><strong>@TR<<Firmware>></strong></td>
		<td>$_firmware_name - $_firmware_subtitle $_version</td>		
	</tr>
	<tr>
		<td><strong>@TR<<Mangement Console>></strong></td>
		<td>webif^2 r__SVN_REVISION__</td>
	</tr>
	<tr>
		<td><strong>@TR<<Kernel>></strong></td>
		<td>$_kversion</td>
	</tr>
	<tr>
		<td><strong>@TR<<MAC>></strong></td>
		<td>$_mac</td>
	</tr>
EOF

#
# board id checks go here.. todo: much work remains here
#
while empty $board_type; do
	strings /dev/mtdblock/0 | grep 'W54G' 2>&1 >> /dev/null
	if [ $? = "0" ]; then
 		board_type="WRT54G"
 		#board_version="v??"
 		break
	fi	
done
empty $board_type && board_type="-id code not done for this board-";

?>
	<tr>
		<td><strong>@TR<<Board>></strong></td><td> <? echo $board_type && ! empty $board_version && echo $board_version ?></td>
	</tr>
	
	<tr><td><br /><br /></td></tr>
	<tr>
		<th><b>@TR<<Statistics|CPU Info>></b></th>
	</tr>
	
	<tr>
		<td><pre><? cat /proc/cpuinfo ?></pre></td>
	</tr>	
	<tr><td><br /><br /></td></tr>
	
		<tr>
		<th><b>@TR<<Statistics|Memory Usage>></b></th>
	</tr>
	<tr>
		<td><pre><? cat /proc/meminfo ?></pre></td>
	</tr>
	<tr><td><br /></td></tr>
</tbody>
</table>

<?
footer
?>
<!--
##WEBIF:name:Info:10:System Information
-->
