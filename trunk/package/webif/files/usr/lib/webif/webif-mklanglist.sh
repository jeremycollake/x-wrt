#!/bin/sh
languages_lst="/usr/lib/webif/languages.lst"
tmplanglst=$(mktemp "/tmp/.webif-XXXXXX")
echo "option|en|English" && ipkg list | awk '/webif-lang/ { gsub("webif-lang-",""); print "option|"$1"|"$5}' | sort | uniq > "$tmplanglst"
rm -f "$languages_lst"
mv -f "$tmplanglst" "$languages_lst"

