#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

#$meta_refresh="<meta http-equiv=\"refresh\" content=\"5; URL=logread.sh\">" 

header "System" "Syslog" "Syslog View" '' "$SCRIPT_NAME" 
#| sed -e "s|<head>|<head>$meta_refresh|"
prefix=$(nvram get log_prefix)
?>
<? echo "Message Prefix: $prefix" ?><br/>
<iframe src="logread_frame.sh" width="90%" height="80%" scrolling="auto" >
Your browser does not support frames,
please follow this link: <a href="logread_frame.sh" target="blank" >View Syslog</a>
</iframe>
<? footer ?>
