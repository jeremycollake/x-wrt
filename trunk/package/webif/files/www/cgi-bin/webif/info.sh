#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "Firmware" "@TR<<Firmware Info>>" '' ''

?>
<pre><?
_version=$(nvram get firmware_version)
_kversion="$( cat /proc/version )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
cat <<EOF
</pre>
<br />
<br />
<table style="width: 90%; text-align: left;" border="0" cellspacing="10" align="left">
<tbody>
	<tr>
		<td><strong>@TR<<Firmware>></strong></td>
		<td>$_firmware_name - $_firmware_subtitle $_version</td>
	</tr>
	<tr>
		<td><strong>@TR<<Mgmt Console>></strong></td>
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
</tbody>
</table>
EOF

footer
?>
<!--
##WEBIF:name:Info:20:Firmware
-->
