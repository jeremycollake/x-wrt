#!/usr/bin/webif-page
<? date ?><?if [ "$FORM_if" ] ?><? grep "${FORM_if}:"cat /proc/net/dev ?><?el?><? head -n 1 /proc/stat ?><?fi?>