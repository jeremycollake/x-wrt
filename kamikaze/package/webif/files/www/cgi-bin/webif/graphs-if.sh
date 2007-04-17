#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./graphs-subcategories.sh

header "Graphs" "Traffic $FORM_if" "@TR<<Traffic of Interface>> $FORM_if" "" "$SCRIPT_NAME"

echo "<center>"
#cat /proc/net/dev|sed -n '/:/{s/:.*//;s/^ *//;s/\(.*\)/<a href="\/cgi-bin\/webif\/graphs-if.sh?if=\1">\1<\/a>/p}'
?>
<br /><br />
<?if [ "$FORM_if" ] ?>
	<embed src="/cgi-bin/webif/graph_if_svg.sh?if=<? echo -n ${FORM_if} ?>"
		width="500" height="250" type="image/svg+xml"
	/>
<?fi?>
</center>
<? footer ?>
