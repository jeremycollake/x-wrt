#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Status" "Interfaces" "@TR<<Interfaces Status>>"
?>

<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
        <tr>
        <th><b>@TR<<Interfaces Status|WAN Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? ifconfig 2>&1 | grep -A 6 "`nvram get wan_ifname`" ?></pre></td>
        </tr>
        <tr><td><br /><br /></td></tr>
        <tr>
        <th><b>@TR<<Interfaces Status|LAN Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? ifconfig 2>&1 | grep -A 6 "`nvram get lan_ifname`" ?></pre></td>
        </tr>
        <tr><td><br /><br /></td></tr>
        <th><b>@TR<<Interfaces Status|Wireless Interface>></b></th>
        </tr>
        <tr>
                <td><pre><? iwconfig 2>&1 | grep -v 'no wireless' | grep '\w' ?></pre></td>
        </tr>
                             
</tbody>
</table>

<? footer ?>
<!--
##WEBIF:name:Status:500:Interfaces
-->