#!/usr/bin/webif-page
<? 
###################################################################
# Crond
#
# Description:
#	Cron daemon configuration.
#
# Author(s) [in order of work date]: 
#       Travis Kemen <kemen04@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced: 
#   none
#
crondir_base="/var/spool/cron"
cron_realdir="/etc/spool/cron/crontabs"
crondir="$crondir_base/crontabs"

. /usr/lib/webif/webif.sh

load_settings "cron"

[ -z $FORM_submit ] && {
	
    FORM_cron_enable=${cron_enable:-$(nvram get cron_enable)}
	FORM_cron_enable=${FORM_cron_enable:-"0"}

} || {
	SAVED=1
    {
    save_setting cron cron_enable $FORM_cron_enable
    }
}

header "System" "Cron" "@TR<<Cron>>" '' "$SCRIPT_NAME"

display_form "start_form|Cron Settings
field|Cron Daemon
radio|cron_enable|$FORM_cron_enable|1|Enable
radio|cron_enable|$FORM_cron_enable|0|Disable
end_form" 
?>

<a href="crontabs.sh">View Crontab files</a>

<? footer ?>
<!--
##WEBIF:name:System:150:Cron
-->
