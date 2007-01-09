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
#	Jeremy Collake <jeremy.collake@gmail.com>
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

?>

<div class="webif-name-title"><a href="http://www.x-wrt.org">X-Wrt @TR<<Extensions>></a> - webif<sup>2</sup></div>
<div class="webif-name-subtitle"></div>
<div class="webif-name-version">Milestone 2.5 - r<? echo "$this_revision" ?> </div><br />
<table class="webif-contributors" width="70%"><tbody>
<tr><th>Webif^2 Primary Developers: <div class="smalltext">(@TR<<sorted_by_name#sorted by name>>)</div></th></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:jeremy.collake@gmail.com">Jeremy Collake (db90h)</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:kemen04@gmail.com">Travis Kemen (thepeople)</a>
</td></tr>
<tr><td><br /></td></tr>
<tr><th>Webif<sup>2</sup> @TR<<Contributing Developers>>: <div class="smalltext">(@TR<<sorted_by_name#sorted by name>>)</div></th></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:oxo@users.berlios.de">Owen Brotherwood (oxo)</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:openwrt@nbd.name">Felix Fietkau</a> (nbd)
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:guymarc@users.berlios.de">Guy Marcenac (guymarc)</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:openwrt@kewis.ch">Philipp Kewisch</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:mtsales@users.berlios.de">Mario Sales</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:markus@freewrt.org">Markus Wigge</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; SeDeKy
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:spectra@gmx.ch">Spectra</a>
</td></tr>
<tr><td>
&nbsp;&nbsp; <a href="mailto:tyardley@users.berlios.de">Tim Yardley (lst)</a>
</td></tr>
<tr><td colspan="2">
&nbsp;&nbsp; With help from Reinhold Kainhofer, ido, Strontian, Sven-Ola, redhat, Exiles, and many others.
</td></tr>
<tr><td><br /></td></tr>
<tr><td>
@TR<<Monowall_Credit#CPU and Traffic graphs based on code from>> <a href="http://m0n0.ch/wall/">m0n0wall</a>.
</td></tr>
<tr><td>
@TR<<Cova_Credit#Some pages have been adopted from code written>> @TR<<by>> David Bird, <a href="http://www.coova.org">Coova Technologies</a>, @TR<<and>> <a href="http://sourceforge.net/projects/hotspot-zone">Hotspot-Zone</a>.
</td></tr>
<tr><td>
@TR<<CSS_Layout#Layout was originally based on>> <a href="http://www.openwebdesign.org/design/1773/prosimii/">&quot;Prosimii&quot;</a> @TR<<by>> haran.
</td></tr>
<tr><td>
@TR<<UCI>> @TR<<facilitating code>> @TR<<Copyright>> (C) 2006 by <a href="mailto:carsten.tittel@fokus.fraumhofer.de">Fokus Fraunhofer</a>.
</td></tr>
<tr><td>
@TR<<Translator_Credit#The translation you are currently using is authored by (nobody)>>.
</td></tr>
<tr><td>
@TR<<This device is running>> <a href="http://www.openwrt.org">OpenWrt</a> @TR<<or a close derivative>>.
</td></tr>
<tr><td><br /></td></tr>
<tr><td>
@TR<<GPL_Text#This program is free software; you can redistribute it and/or <br />modify it under the terms of the GNU General Public License <br />as published by the Free Software Foundation; either version 2 <br />of the License, or (at your option) any later version.<br /> >>
</td></tr>
<tr><td>
@TR<<zephyr_Text#The Zephyr theme is under the MIT licence.<br /> >>
</td></tr>
</tbody></table>
<br />
<? show_validated_logo
footer ?>
<!--
##WEBIF:name:Info:950:About
-->
