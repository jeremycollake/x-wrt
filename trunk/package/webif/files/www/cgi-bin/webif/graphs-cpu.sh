#!/usr/bin/webif-page
<? 
#
#credit goes to arantius and GasFed
#
. /usr/lib/webif/webif.sh
. ./subcategories.sh

header "Graphs" "CPU" "CPU Usage" "" "$SCRIPT_NAME"
?>
<center>
	<object data="/svggraph/graph_cpu.svg?/cgi-bin/webif/data.sh" 
		width="500" height="250"
	/>
</center>
<? footer ?>
<!-- 	 
##WEBIF:name:Graphs:1:CPU 	 
-->
