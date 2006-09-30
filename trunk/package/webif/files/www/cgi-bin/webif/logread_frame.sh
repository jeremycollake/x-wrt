#!/usr/bin/webif-page
<? 
prefix=$(nvram get log_prefix)
logread | sort -r | sed -e "s| $prefix| |" 
?>
