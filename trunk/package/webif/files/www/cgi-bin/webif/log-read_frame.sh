#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
. /etc/runsyslogd.conf
colorize_script=""

mini_header
echo -n "<body><div class=\"logread\"><pre>"

prefix=$(nvram get log_prefix)
LOG_TYPE=$(nvram get log_type)
LOG_FILE=$(nvram get log_file)
if equal $LOG_TYPE "file" ; then
	LOG_FILE=${LOG_FILE:-$DEFAULT_log_file}
	LOGREAD="cat "$LOG_FILE
else LOGREAD="logread"
fi

$LOGREAD | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | sed -e "s| $prefix| |" | \
sed 's/\&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' ?></pre>
</div>
</body>
</html>
