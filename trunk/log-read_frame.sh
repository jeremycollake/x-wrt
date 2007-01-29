#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/runsyslogd.conf
colorize_script=""

prefix=$(nvram get log_prefix)
LOG_TYPE=$(nvram get log_type)
LOG_FILE=$(nvram get log_file)
if equal $LOG_TYPE "file" ; then
	LOG_FILE=${LOG_FILE:-$DEFAULT_log_file}
	LOGREAD="cat "$LOG_FILE
else LOGREAD="logread"
fi

$LOGREAD | sort -r  | sed -e "s| $prefix| |"
?>
