#!/usr/bin/webif-page
<?
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./graphs-subcategories.sh

header "Graphs" "CPU" "CPU Usage" "" "$SCRIPT_NAME"

?>
<center>
	<embed src="/svggraph/graph_cpu.svg?/cgi-bin/webif/data.sh"
		width="500" height="250" type="image/svg+xml"
	/>
</center>
<? footer ?>
<!--
##WEBIF:name:Graphs:1:CPU
-->
