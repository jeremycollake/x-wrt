#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./graphs-subcategories.sh

header "Graphs" "graphs_cpu_subcategory#CPU" "@TR<<graphs_cpu_CPU_Usage#CPU Usage>>" "" ""
?>
<center>
	<object data="/cgi-bin/webif/graph_cpu_svg.sh?data.sh"
		width="500" height="250" type="image/svg+xml">@TR<<graphs_svg_required#This object requires the SVG support.>></object>
</center>
<? footer ?>
<!--
##WEBIF:name:Graphs:1:graphs_cpu_subcategory#CPU
-->
