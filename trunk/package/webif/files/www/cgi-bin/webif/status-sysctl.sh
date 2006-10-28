#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
header "Status" "TCP/IP Params" "@TR<<TCP/IP Parameters>>"
?>
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
  <tr><td>These settings can be adjusted at runtime through the sysctl tool, or over-ridden in <i>/etc/sysctl.conf</i>.
  <br><br>For example, to set "net.ipv4.netfilter.ip_conntrack_tcp_timeout_established":
  <br><br><p>"<i>sysctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_established=3600"</i>.</p>
  </td></tr>
  <tr><td><br></td></tr>
		<tr>
		<th><b>@TR<<Statistics|IP Parameters>></b></th>
	</tr>
	<tr>
		<td><pre><? sysctl -a 2> /dev/null | grep "net." | sort  ?></pre></td>
	</tr>
	
</tbody>
</table>
<? footer ?>
<!--
##WEBIF:name:Status:950:TCP/IP Params
-->
