#!/usr/bin/webif-page
Content-Type: text/html 
Pragma: no-cache

<?
colorize_script=""
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>@TR<<Syslog Messages>></title>
	<link rel="stylesheet" type="text/css" href="/webif.css" />
	<!--[if lt IE 7]>
		<link rel="stylesheet" type="text/css" href="/ie_lt7.css" />
	<![endif]-->
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta http-equiv="expires" content="-1" />
	<script type="text/javascript" src="/colorize.js"></script>
		<script type="text/javascript"> colorize(); </script>
</head>
<body $4>
<div class="logread"><pre>
<?
. /usr/lib/webif/webif.sh
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

$LOGREAD | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | sed -e "s| $prefix| |"
?>
</pre></div>
</body>
</html>
