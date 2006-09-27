#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Info" "About" "@TR<<About>>" '' ''
# 322 is replaced by revision by preprocessor at build
this_revision=322
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

<div class="webif-name-title">webif^2</div></font>
<div class="webif-name-subtitle">Part of the end user extensions to OpenWrt by the X-Wrt project.</div>
<div class="webif-name-version">Alpha development - revision __SVN_REVISION__</div>
<form enctype="multipart/form-data" method="post"><input type="submit" value=" Check for webif update " name="update_check" /></form>
<? echo $revision_text ?>
<div class="webif-contributors">
<table><tbody>
<tr><th>OpenWrt Contributors (sorted by name):</th></tr>
<tr><td>	
&nbsp&nbsp florian, kaloz, malbon, mbm, Olli, <a href="mailto:openwrt@nbd.name">Felix Fietkau</a> (nbd), wbx
</td></tr>  
<tr><td>
&nbsp&nbsp Companies/Projects: linux, Broadcom, Linksys, Squashfs, JFFS2, MTD, etc...
<tr><td>
<i>&nbsp&nbsp Openwrt is the product of countless contributors from the community.</i>
</td></tr>  
<br />

<tr><th>Webif Contributors (sorted by name):</th></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:openwrt@nbd.name">Felix Fietkau</a>
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
<tr><th>Webif<sup>2</sup> Contributors (sorted by name):</th></tr>
<tr><td>
&nbsp&nbsp <a href="mailto:jeremy.collake@gmail.com">Jeremy Collake</a>
</td></tr>			
<tr><td>
&nbsp&nbsp <a href="mailto:kemen04@gmail.com">Travis Kemen</a>
</td></tr>		
<tr><td>
&nbsp&nbsp <a href="mailto:markus@freewrt.org">Markus Wigge</a>			
</td></tr>
<tr><td><br /></td></tr>
<tr><td>
Original webif system &copy; 2005 Felix Fietkau &lt;<a href="mailto:openwrt@nbd.name">openwrt@nbd.name</a>&gt;.<br />
Layout based on <a href="http://www.openwebdesign.org/design/1773/prosimii/">&quot;Prosimii&quot;</a> @TR<<by>> haran
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
