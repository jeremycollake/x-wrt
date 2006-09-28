#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
###################################################################
# Packages configuration page
#
# Description:
#	Allows installation and removal of packages.
#
# Author(s) [in order of work date]: 
#   OpenWrt developers (??)
#   todo: person who added descriptions..
#   eJunky
#   emag
#   Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced: 
#   none
#
# Utilities/applets referenced:
#   ipkg
#
#

header "System" "Installed Software" "@TR<<Installed Software>>"

?>
<p style="position: absolute; right: 1em; top: 4em"><a href="ipkg.sh?action=update">@TR<<Update package lists>></a></p>
<pre>
<?
if [ "$FORM_action" = "update" ]; then
	ipkg update
elif [ "$FORM_action" = "install" ]; then
	yes n | ipkg install `echo "$FORM_pkg" | sed -e 's, ,+,g'`
elif [ "$FORM_action" = "remove" ]; then
	ipkg remove `echo "$FORM_pkg" | sed -e 's, ,+,g'`
fi
?>
</pre>
<div class="half noBorderOnLeft">
  <h3>@TR<<Installed Optional Packages>></h3>
  <table style="width: 90%"><tr><th width="100">Action</th><th width="200">Package</th><th>Description</th></tr>
<?
ipkg list_installed | egrep -v "(base-files|bridge|busybox|uclibc|kernel|Done\.)" | awk -F ' ' '
$2 !~ /terminated/ {       
       link=$1
       gsub(/\+/,"%2B",link)
       desc=$5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15 " " $16 " " $17 " " $18 " " $19 " " $20 " " $21 " " $22 " " $23 " " $24 " " $25 " " $26 " " $27
       print "<tr><td><a href=\"ipkg.sh?action=remove&pkg=" link "\">@TR<<Uninstall>></td><td>" $1 "</td><td><font size=-1>" desc "</font></td></tr>"       
}
'
?>
  </table>
</div>
<div class="half noBorderOnLeft"><br />
  <h3>@TR<<Available packages>></h3>
  <table style="width: 90%"><tr><th width="100">Action</th><th width="200">Package</th><th>Description</th></tr>
<?
egrep 'Package:|Description:' /usr/lib/ipkg/status /usr/lib/ipkg/lists/* 2>&- | sed -e 's, ,,' -e 's,/usr/lib/ipkg/lists/,,' | awk -F: '
$1 ~ /status/ {
	installed[$3]++;
}
($1 !~ /terminated/) && ($1 !~ /\/status/) && (!installed[$3]) && ($2 !~ /Description/) {
	if (current != $1) print "<tr><th>" $1 "</th></tr>"
	link=$3
	gsub(/\+/,"%2B",link)		
	getline descline
        split(descline,desc,":")
        print "<tr><td><a href=\"ipkg.sh?action=install&pkg=" link "\">@TR<<Install>></td><td>" $3 "</td><td><font size=-1>" desc[3] "</font></td></tr>"
        current=$1
}
'
?>
  </table>
</div>

<div class="rowOfBoxes"></div>
	  
<? footer ?>
<!--
##WEBIF:name:System:300:Installed Software
-->
