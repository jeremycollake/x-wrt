#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. /www/cgi-bin/webif/graphs-subcategories.sh

header "Graphs" "graphs_if_Traffic#Traffic>> $FORM_if@TR<<" "@TR<<graphs_if_Traffic_of_Interface#Traffic of Interface>> $FORM_if" "" ""
# IE (all versions) does not support the object tag with svg!
#	<object data="" width="500" height="250" type="image/svg+xml">@TR<<graphs_svg_required#This object requires the SVG support.>></object>
?>
<center>
<?if [ "$FORM_if" ] ?>
	<embed src="/cgi-bin/webif/graph_if_svg.sh?if=<? echo -n ${FORM_if} ?>"
		width="500" height="250" type="image/svg+xml" />
<?fi?>
</center>
<? footer ?>
