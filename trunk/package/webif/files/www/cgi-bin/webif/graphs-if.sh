#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./graphs-subcategories.sh

header "Graphs" "graphs_if_Traffic#Traffic>> $FORM_if@TR<<" "@TR<<graphs_if_Traffic_of_Interface#Traffic of Interface>> $FORM_if" "" ""
?>
<br /><br />
<center>
<?if [ "$FORM_if" ] ?>
	<object data="/cgi-bin/webif/graph_if_svg.sh?if=<? echo -n ${FORM_if} ?>"
		width="500" height="250" type="image/svg+xml">@TR<<graphs_svg_required#This object requires the SVG support.>></object>
<?fi?>
</center>
<? footer ?>
