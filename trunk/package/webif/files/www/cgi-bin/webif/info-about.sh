#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
###################################################################
# About page
#
# Description:
#	Shows the many contributors.
#
# Author(s) [in order of work date]: 
#       Original webif authors.
# 	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced: 
#   none
#
header "Info" "About" "@TR<<About>>" '' ''

this_revision=$(cat /www/.version)

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
	fi
	rm -f "$tmpfile"	 
 	
?>


<script type="text/javascript">
<!--
swatch()
-->
</script>

<div class="webif-name-title">X-Wrt extensions: webif<sup>2</sup></div></font>
<div class="webif-name-subtitle"></div>
<div class="webif-name-version">Alpha development - revision <? echo $this_revision ?> </div>
<form enctype="multipart/form-data" method="post"><input type="submit" value=" Check For Webif Update " name="update_check" /></form>
<? echo $revision_text ?>
<div class="webif-contributors">
<table><tbody>
<tr><td><br /></td></tr>  
<tr><th>X-Wrt Webif<sup>2</sup> Contributors (sorted by name):</th></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:jeremy.collake@gmail.com">Jeremy Collake</a>
</td></tr>			
<tr><td>
&nbsp&nbsp <a href="mailto:kemen04@gmail.com">Travis Kemen</a>
</td></tr>		
<tr><td><br /></td></tr>
<tr><th>OpenWrt Contributors:</th></tr>
<tr><td>	
&nbsp&nbsp florian, kaloz, malbon, mbm, Olli, <a href="mailto:openwrt@nbd.name">Felix Fietkau</a> (nbd), wbx
</td></tr>  
<tr><td>
&nbsp&nbsp Companies/Projects: linux, Broadcom, Linksys, Squashfs, JFFS2, MTD, etc...
<tr><td>
&nbsp&nbsp <b><i>Countless</i></b> contributors from the community.
</td></tr>  
<tr><td><br /></td></tr>  
<tr><th>Other Webif Contributors (sorted by name):</th></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:openwrt@nbd.name">Felix Fietkau</a>
</td></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:markus@freewrt.org">Markus Wigge</a>			
</td></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:openwrt@kewis.ch">Philipp Kewisch</a>
</td></tr>
<tr><td>
&nbsp&nbsp SeDeKy
</td></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:spectra@gmx.ch">Spectra</a>
</td></tr>
<tr><td><br /></td></tr> 
<tr><td>
Layout was originally based on <a href="http://www.openwebdesign.org/design/1773/prosimii/">&quot;Prosimii&quot;</a> @TR<<by>> haran
</tr></td>
<tr><td><br /></td></tr>
<tr><td>
<font size=-1>@TR<<GPL_Text|This program is free software; you can redistribute it and/or <br />modify it under the terms of the GNU General Public License <br />as published by the Free Software Foundation; either version 2 <br />of the License, or (at your option) any later version.</font> <br /> >>
</tr></td>
</tbody></table>
</div>
<? footer ?>
<!--
##WEBIF:name:Info:950:About
-->
