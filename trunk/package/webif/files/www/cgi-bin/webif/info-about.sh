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
?>


<script type="text/javascript">
<!--
swatch()
-->
</script>

<div class="webif-name-title"><a href="http://www.bitsum.com/xwrt.asp">X-Wrt Extensions</a> - webif<sup>2</sup></div>
<div class="webif-name-subtitle"></div>
<div class="webif-name-version">Milestone 1 rc2 - r<? echo "$this_revision" ?> </div><br />
<form action="" enctype="multipart/form-data" method="post">
<input type="submit" value=" Check For Webif^2 Update " name="update_check" />
<input type="submit" value=" Install/Reinstall Webif^2  " name="install_webif" />
</form>
<? echo $revision_text ?>
<table class="webif-contributors"><tbody>
<tr><td><br /></td></tr>  
<tr><th>X-Wrt Webif<sup>2</sup> Contributors:</th></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:jeremy.collake@gmail.com">Jeremy Collake</a>
</td></tr>			
<tr><td>
&nbsp;&nbsp; <a href="mailto:kemen04@gmail.com">Travis Kemen</a>
</td></tr>		
<tr><td>
&nbsp;&nbsp; Special thanks to Spectra, Strontian, Felix Fietkau, beta testers, and others.
</td></tr>		

<tr><td><br /></td></tr>  
<tr><th>Webif Contributors:</th></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:openwrt@nbd.name">Felix Fietkau</a> (nbd)
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:markus@freewrt.org">Markus Wigge</a>			
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:openwrt@kewis.ch">Philipp Kewisch</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; SeDeKy
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:spectra@gmx.ch">Spectra</a>
</td></tr>
<tr><td><br /></td></tr>
<tr><th>OpenWrt Contributors:</th></tr>
<tr><td>	
&nbsp;&nbsp; <a href="mailto:openwrt@nbd.name">Felix Fietkau</a> (nbd), florian, groz, kaloz, malbon, mbm, Olli, wbx
</td></tr>  
<tr><td>
&nbsp;&nbsp; Companies/Projects: linux, Broadcom, Linksys, Squashfs, JFFS2, MTD, etc...
</td></tr>  
<tr><td>
&nbsp;&nbsp; <b><i>Countless</i></b> contributors from the community.
</td></tr>  
<tr><td><br /></td></tr> 
<tr><td>
CPU and Traffic graphs based on code from <a href="http://m0n0.ch/wall/">m0n0wall</a>.
</td></tr>  
<tr><td>
Layout was originally based on <a href="http://www.openwebdesign.org/design/1773/prosimii/">&quot;Prosimii&quot;</a> @TR<<by>> haran.
</td></tr>
<tr><td>
This device is running <a href="http://www.openwrt.org">OpenWrt</a> or a close derivative.
</td></tr>
<tr><td><br /></td></tr>
<tr><td>
<font size="-1">@TR<<GPL_Text|This program is free software; you can redistribute it and/or <br />modify it under the terms of the GNU General Public License <br />as published by the Free Software Foundation; either version 2 <br />of the License, or (at your option) any later version.</font> <br /> >>
</td></tr>
</tbody></table>
<br />
<p>
    <a href="http://validator.w3.org/check?uri=referer"><img
        src="http://www.w3.org/Icons/valid-xhtml10"
        alt="Valid XHTML 1.0 Transitional" height="31" width="88" /></a>
  </p>
<? footer ?>
<!--
##WEBIF:name:Info:950:About
-->
