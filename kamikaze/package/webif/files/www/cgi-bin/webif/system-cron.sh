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
. /usr/lib/webif/webif.sh

load_settings "cron"

[ -z $FORM_submit ] && {

	FORM_cron_enable=${cron_enable:-$(uci get webif.cron.enable)}
	FORM_cron_enable=${FORM_cron_enable:-"1"}

} || {
	SAVED=1
	{
	uci_set "webif" "cron" "enable" "$FORM_cron_enable"
	}
}

header "System" "Cron" "@TR<<Cron>>" '' "$SCRIPT_NAME"

display_form "start_form|Cron Settings
field|Cron Daemon
radio|cron_enable|$FORM_cron_enable|1|Enable
radio|cron_enable|$FORM_cron_enable|0|Disable
helpitem|Cron
helptext|HelpText Cron#Cron is a linux daemon that executes commands are desired times or intervals.
end_form"
?>

<a href="system-crontabs.sh">View Crontab files</a>

<?
show_validated_logo
footer ?>
<!--
##WEBIF:name:System:150:Cron
-->
