#!/usr/bin/webif-page
<? 
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./subcategories.sh

header "Graphs" "Traffic $FORM_if" "Interface $FORM_if Traffic" "" "$SCRIPT_NAME"

echo "<center>"
#cat /proc/net/dev|sed -n '/:/{s/:.*//;s/^ *//;s/\(.*\)/<a href="\/cgi-bin\/webif\/graphs-if.sh?if=\1">\1<\/a>/p}'
?>
<br /><br />
<?if [ "$FORM_if" ] ?>
	<embed src="/svggraph/graph_if.svg?if=<? echo -n ${FORM_if} ?>" 
		width="500" height="250" type="image/svg+xml"
	/>
<?fi?>
</center>
<? footer ?>
