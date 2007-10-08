#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

crondir="/etc/crontabs/"

load_settings "cron"

header "System" "Crontabs" "@TR<<Cron Tables>>" '' "$SCRIPT_NAME"

for crontab in $(ls $crondir/); do
	for i in $(cat $crondir$crontab | tr ' ' '@'); do
		text="$text$i<br/>"
	done
	cron_text="<tr><td><h3>$crontab</h3></td></tr><tr><td><pre>$(echo "$text" | tr '@' ' ')</pre><br/>$cron_text"
	text=""
done

display_form <<EOF
start_form|@TR<<Cron Jobs>>
string|$cron_text
string|</td></tr>
helpitem|crontabs
helptext|HelpText crontabs#The Cron Tables is a list of jobs the cron daemon (crond) should execute at specified intervals or times.
field|@TR<<Cron Tables Directory>>
string|$crondir
end_form
EOF

footer ?>
<!--
##WEBIF:name:System:175:Crontabs
-->
