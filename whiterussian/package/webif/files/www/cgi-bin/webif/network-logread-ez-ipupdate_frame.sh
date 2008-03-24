#!/usr/bin/webif-page
<?
colorize_script=""
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>@TR<<EZ-IP-Update Messages>></title>
	<link rel="stylesheet" type="text/css" href="/webif.css" />
	<!--[if lt IE 7]>
		<link rel="stylesheet" type="text/css" href="/ie_lt7.css" />
	<![endif]-->
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta http-equiv="expires" content="-1" />
</head>
<body $4>
<div class="logread"><pre>
<?
echo "If this page is blank then dyndns is not started, or you may have just rebooted"
[ -f /etc/syslog.default ] && . /etc/syslog.default
logtype=$(nvram get log_type)
logfile=$(nvram get log_file)
logfile="${logfile:-$DEFAULT_log_file}"
if [ "$logtype" = "file" ]; then
	syslog_cmd="cat \"$logfile\""
else
	syslog_cmd="logread"
fi
	eval $syslog_cmd 2>/dev/null | grep 'ez-ipupdate\( \|\[\)' | sort -r | sed 's/[a-zA-Z]*\..*ez-ipupdate\[[0-9]*\]//' | sed ' s/\&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
?>
</pre></div>
</body>
</html>
