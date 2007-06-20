#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Log" "Kernel" "@TR<<log_dmesg_Kernel_Ring_Buffer#Kernel Ring Buffer>>"
?>
<iframe src="log-dmesg_frame.sh" width="90%" height="300" scrolling="auto">
@TR<<HelpText Browser_Frames#Your browser does not support frames,<br>please follow this link>>: <a href="log-dmesg_frame.sh" target="blank" >@TR<<log_dmesg_View_Kernel_Ring_Buffer#View Kernel Ring Buffer>></a>
</iframe>
<? footer ?>
<!--
##WEBIF:name:Log:3:Kernel
-->
