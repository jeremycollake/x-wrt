#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "System" "Reboot" ""
timeout=40
if empty "$FORM_reboot"; then
reboot_msg="<form enctype=\"multipart/form-data\" method=\"post\"><input type=\"submit\" value=\" @TR<<Yes, really reboot now>> \" name=\"reboot\" /></form>"
else
router_ip=$(nvram get lan_ipaddr)
echo "<meta http-equiv="refresh" content='$timeout;http://$router_ip'>"
reboot_msg="@TR<<Rebooting now>>...<br><br>@TR<<reboot_wait#Please wait about>> $timeout @TR<<reboot_seconds#seconds.>> @TR<<reboot_reload#The webif should automatically reload.>>
<br><br><center><script type='text/javascript'>
var bar1= createBar(350,15,'white',1,'black','blue',85,7,3,'');
</script></center>"
fi
?>
<table style="width: 90%; border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
<br><br><br><tr><td>
<script language="javascript" src="/js/progress.js">
</script>
<? echo "$reboot_msg" ?>
<br><br><br></td></tr>
</tbody>
</table>
<? footer ?>
<?
if ! empty "$FORM_reboot"; then
sleep 3
reboot
fi
?>
<!--
##WEBIF:name:System:910:Reboot
-->
