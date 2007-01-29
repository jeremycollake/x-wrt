#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# About page
#
# Description:
#        Shows the many contributors.
#
# Author(s) [in order of work date]:
#       Original webif authors.
#        Jeremy Collake <jeremy.collake@gmail.com>
#        Dmytro Dykhman <dmytro@iroot.ca.
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced:
#   none
#
header "Info" "About" "<img src=/images/abt.jpg align=absmiddle>&nbsp;@TR<<About>>" '' ''

this_revision=$(cat "/www/.version")

?>
<div class="webif-name-title"><a href="http://www.x-wrt.org">X-Wrt @TR<<Extensions>></a> - webif<sup>2</sup></div>
<div class="webif-name-subtitle"></div>
<div class="webif-name-version">Milestone 2.6 - r<? echo "$this_revision" ?> </div><br />
<DIV>
<IFRAME SRC="info-credits.sh" STYLE="width:90%; height:400px; border:1px dotted #888888;" FRAMEBORDER="0" SCROLLING="NO"></IFRAME>
</DIV>
<? show_validated_logo
footer ?>
<!--
##WEBIF:name:Info:950:About
-->
