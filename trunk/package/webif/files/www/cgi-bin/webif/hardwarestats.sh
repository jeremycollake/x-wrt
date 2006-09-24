#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "Hardware" "@TR<<Hardware resources>>"

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
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
 	
	<tr>
		<th><b>@TR<<Statistics|Board Info>></b></th>
	</tr>
	<tr>
		<td><pre>Board type: <? echo $board_type && ! empty $board_version && echo $board_version ?></pre></td>
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
	
</tbody>
</table>

<? footer ?>
<!--
##WEBIF:name:Info:30:Hardware
-->
