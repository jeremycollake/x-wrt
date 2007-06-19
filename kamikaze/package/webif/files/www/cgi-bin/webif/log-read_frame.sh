#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
mini_header
DEFAULT_log_file="/var/log/messages"
DEFAULT_log_type="circular"
uci_load "syslogd"
prefix="$CONFIG_general_prefix"
LOG_TYPE="$CONFIG_general_type"
LOG_FILE="$CONFIG_general_file"
if equal $LOG_TYPE "file" ; then
	LOG_FILE=${LOG_FILE:-$DEFAULT_log_file}
	LOGREAD="cat "$LOG_FILE
else LOGREAD="logread"
fi
echo -n "<body><div class=\"logread\"><pre>"
$LOGREAD | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | sed -e "s| $prefix| |" | \
sed 's/\&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' ?></pre>
</div>
</body>
</html>
