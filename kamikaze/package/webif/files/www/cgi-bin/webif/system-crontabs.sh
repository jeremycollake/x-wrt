#!/usr/bin/webif-page
<?
crondir="/var/spool/cron/crontabs/"

. /usr/lib/webif/webif.sh

load_settings "cron"

header "System" "Crontabs" "@TR<<Cron Tables>>" "$SCRIPT_NAME"
ShowNotUpdatedWarning

cron_dir_text="<br/>Cron Tables Directory:<pre>$crondir</pre><br/>"

for crontab in $(ls $crondir/); do
	for i in $(cat $crondir$crontab | tr ' ' '@'); do
		text="$text$i<br/>"
	done
	cron_text="<h3>$crontab</h3><pre>$(echo "$text" | tr '@' ' ')</pre><br/>$cron_text"
	text=""
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