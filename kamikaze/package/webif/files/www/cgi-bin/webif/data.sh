#!/usr/bin/webif-page
<? date ?><?if [ "$FORM_if" ] ?><? grep "${FORM_if}:"/proc/net/dev ?><?el?><? head -n 1 cat /proc/stat ?><?fi?>