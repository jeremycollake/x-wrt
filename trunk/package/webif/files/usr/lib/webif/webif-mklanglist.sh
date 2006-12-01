#!/bin/sh
languages_lst="/usr/lib/webif/languages.lst"
langs=$(echo "option|en|English" && ipkg list | awk '/webif-lang/ { gsub("webif-lang-",""); print "option|"$1"|"$5}')
langs=$(echo "$langs" | sort | uniq)
rm -f "$languages_lst"
echo "$langs" > "$languages_lst"
