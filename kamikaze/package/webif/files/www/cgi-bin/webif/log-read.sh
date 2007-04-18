#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

#$meta_refresh="<meta http-equiv=\"refresh\" content=\"5; URL=log-read.sh\">"
uci_load "syslogd"
header "Log" "Syslog" "@TR<<Syslog View>>" '' ""
#| sed -e "s|<head>|<head>$meta_refresh|"
prefix="$CONFIG_general_prefix"
?>
<? echo "@TR<<Message Prefix>>: $prefix" ?><br/>
<iframe src="log-read_frame.sh" width="90%" height="300" scrolling="auto">
@TR<<HelpText Browser_Frames#Your browser does not support frames,<br>please follow this link>>: <a href="log-read_frame.sh" target="blank" >@TR<<View Syslog>></a>
</iframe>
<? footer ?>
<!--
##WEBIF:name:Log:2:Syslog
-->
