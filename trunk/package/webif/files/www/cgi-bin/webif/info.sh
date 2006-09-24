#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "System Information" "@TR<<System Information>>" '' ''

# __SVN_REVISION__ is replaced by revision by preprocessor at build
this_revision=__SVN_REVISION__

! empty $FORM_update_check &&
{	  	
	tmpfile=$(mktemp "/tmp/.webif.XXXXXX")
	wget http://ftp.berlios.de/pub/xwrt/.version -O $tmpfile 2> /dev/null >> /dev/null
	cat $tmpfile | grep "doesn't exist" 2>&1 >> /dev/null
	if [ $? = 0 ]; then		
		revision_text="<div id=\"update-error\">ERROR CHECKING FOR UPDATE</div>"
	else
		latest_revision=$(cat $tmpfile)
		if [ "$this_revision" != "$latest_revision" ]; then
 			revision_text="<div id=\"update-available\">webif^2 update available: r$latest_revision</div>"
 		else
 			revision_text="<div id=\"update-unavailable\">You have the latest webif^2: r$latest_revision</div>"	 		
 		fi
	fi
	rm -f "$tmpfile"	 
}
 	
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
<td><form enctype="multipart/form-data" method="post"><input type="submit" value=" Check for webif update " name="update_check" /></form></td>
</tr>
<tr><td></td><td>$revision_text</td></tr>		
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
