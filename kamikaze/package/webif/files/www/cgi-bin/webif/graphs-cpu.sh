#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./graphs-subcategories.sh

header "Graphs" "CPU" "@TR<<CPU Usage>>" "" "$SCRIPT_NAME"
?>
<center>
	<embed src="/cgi-bin/webif/graph_cpu_svg.sh?/cgi-bin/webif/data.sh"
		width="500" height="250" type="image/svg+xml"
	/>
</center>
<? footer ?>
<!--
##WEBIF:name:Graphs:1:CPU
-->
