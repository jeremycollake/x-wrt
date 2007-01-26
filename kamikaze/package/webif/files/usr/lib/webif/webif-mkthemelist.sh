#!/bin/sh
themes_lst="/etc/themes.lst"
tmpthemeslst=$(mktemp "/tmp/.webif-XXXXXX")
ipkg list | awk '/webif-theme/ { gsub("webif-theme-",""); print "option|"$1"|"$5}' | sort | uniq >> "$tmpthemeslst"
rm -f "$themes_lst"
mv -f "$tmpthemeslst" "$themes_lst"
.
