#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "Firmware" "@TR<<Firmware Info>>" '' ''

# __SVN_REVISION__ is replaced by revision by preprocessor at build
this_revision=__SVN_REVISION__

if [ -n "$FORM_update_check" ]; then	  	
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
	fi
	rm -f "$tmpfile"	 
 	
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
</tbody>
</table>
<br />
EOF

footer
?>
<!--
##WEBIF:name:Info:20:Firmware
-->
