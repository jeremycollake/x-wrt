#!/usr/bin/webif-page
<?
crondir_base="/var/spool/cron"
crondir="$crondir_base/crontabs/crontabs/"

. /usr/lib/webif/webif.sh

load_settings "cron"

header "System" "Crontabs" "@TR<<Cron Tables>>" "$SCRIPT_NAME"

cron_dir_text="<br/>Cron Tables Directory:<pre>$crondir</pre><br/>"

for crontab in $(ls $crondir/* 2>&-); do
	cron_text='<h3>$crontab</h3><br /><pre>$cron_text $(cat "$crondir/$crontab")</pre><br />'
done

display_form <<EOF
start_form|@TR<<Cron Jobs>>
string|$cron_text
helpitem|crontabs
helptext|HelpText crontabs#The Cron Tables is a list of jobs the cron daemon (crond) should execute at specified intervals or times.
string|$cron_dir_text
end_form
EOF

footer ?>
<!--
##WEBIF:name:System:175:Crontabs
-->

