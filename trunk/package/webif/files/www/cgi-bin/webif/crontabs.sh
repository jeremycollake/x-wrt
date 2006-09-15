#!/usr/bin/webif-page
<? 
crondir_base="/var/spool/cron"
crondir="$crondir_base/crontabs"

. /usr/lib/webif/webif.sh

load_settings "cron"

header "System" "Crontabs" '' "$SCRIPT_NAME"

echo "Cron Tables Directory:<pre>$crondir</pre><br/>"

cd $crondir

for crontab in $(ls * 2>&-); do
    echo -n "<h3>$crontab</h3><br /><pre>"
    cat "$crondir/$crontab"
    echo '</pre><br />'
done

footer ?>
<!--
##WEBIF:name:System:175:Crontabs
-->

