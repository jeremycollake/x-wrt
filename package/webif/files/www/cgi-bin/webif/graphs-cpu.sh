#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. /www/cgi-bin/webif/graphs-subcategories.sh

header "Graphs" "graphs_cpu_subcategory#CPU" "@TR<<graphs_cpu_CPU_Usage#CPU Usage>>" "" ""
# IE (all versions) does not support the object tag with svg!
#	<object data="" width="500" height="250" type="image/svg+xml">@TR<<graphs_svg_required#This object requires the SVG support.>></object>
?>
<center>
	<embed src="/cgi-bin/webif/graph_cpu_svg.sh"
		width="500" height="250" type="image/svg+xml" />
	<object>
		<br><a href=http://www.adobe.com/svg/viewer/install/main.html>If the graph is not fuctioning download the viewer here.</a>
	</object>
</center>
<? footer ?>
<!--
##WEBIF:name:Graphs:1:graphs_cpu_subcategory#CPU
-->
