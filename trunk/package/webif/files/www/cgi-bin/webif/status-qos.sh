#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Status" "QoS" "@TR<<Quality of Service Statistics>>"
###################################################################
# TCP/IP status page
#
# Description:
#	Shows connections to the router, netstat stuff, routing table..
#
# Author(s) [in order of work date]: 
#	Original webif developers 	
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	todo
#
# Configuration files referenced: 
#   	none
#
?>
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
        <tr>
          <th><b>@TR<<QoS Packets | Quality of Service Packet Info>></b></th>
        </tr>
        <tr>
                <td>
                <? 
                if [ -f "/etc/config/qos" ]; then				
					echo "<br /><pre>"
					qos-stat	
					echo "</pre>"
                elif [ -f "/etc/qos.conf" ]; then				
					echo "<br /><pre>"
					qos-stat	
					echo "</pre>"								
		else
                	echo "Compatible QOS package was not found to be installed. Try nbd's or Rudy's QOS scripts."
                fi                
                ?></td>
        </tr>
	<tr><td><br /><br /></td></tr>
	
</tbody>
</table>

<br />
<? 
show_validated_logo
footer ?>
<!--
##WEBIF:name:Status:425:QoS
-->
