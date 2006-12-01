#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "Conntrack Table" "@TR<<Conntrack Table>>"
ShowNotUpdatedWarning

echo "<table><tbody><tr><td><div class=smalltext><pre>"
cat /proc/net/ip_conntrack | sort
echo "</pre></div></td></tr></tbody></table>"
footer ?>
