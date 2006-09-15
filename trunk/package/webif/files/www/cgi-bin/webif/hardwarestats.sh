#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "Hardware" "@TR<<Hardware resources>>"
?>
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
 
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
	
</tbody>
</table>

<? footer ?>
<!--
##WEBIF:name:Info:300:Hardware
-->
