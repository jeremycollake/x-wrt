#!/usr/bin/webif-page
<? echo -e "Content-Type: text/plain\r" ?>
<? echo -e "\r"`date` ?><?if [ "$FORM_if" ] ?><? grep "${FORM_if}:" /proc/net/dev ?><?el?><? head -n 1 /proc/stat ?><?fi?>