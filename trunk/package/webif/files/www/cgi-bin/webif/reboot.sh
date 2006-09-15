#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Reboot" "Reboot" ""
timeout=45
if empty "$FORM_reboot"; then	  	
	reboot_msg="<form enctype=\"multipart/form-data\" method=\"post\"><input type=\"submit\" value=\" Yes, really reboot now \" name=\"reboot\" /></form>"
else
	router_ip=$(nvram get lan_ipaddr)
	echo "<meta http-equiv="refresh" content=$timeout;http://$router_ip />"
	reboot_msg="Rebooting now... router should be up in about $timeout seconds. The webif should automatically reload."	
fi

?>
<table style="width: 90%; text-align: center;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
<br><br><br><tr><td>
<? echo "$reboot_msg" ?>
<br><br><br></td></tr>
</tbody>
</table>

<?
if ! empty "$FORM_reboot"; then
	reboot &
fi
?>

<? footer ?>
<!--
##WEBIF:name:Reboot:100:Are you sure?
-->
