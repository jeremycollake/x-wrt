#!/bin/sh
languages_lst="/etc/languages.lst"
tmplanglst=$(mktemp "/tmp/.webif-XXXXXX")
echo "option|en|English" >  "$tmplanglst"
ipkg list | awk '/webif-lang/ { gsub("webif-lang-",""); print "option|"$1"|"$5}' | sort | uniq >> "$tmplanglst"
if [ "'cat $tmplanglst'" != "option|en|English" ]; then
	if [ "'cat $tmplanglst'" != "'cat $languages_lst'" ]; then
		rm -f "$languages_lst"
		chmod 0644 "$tmplanglst"
		mv -f "$tmplanglst" "$languages_lst"
	fi
fi
rm -f "$tmplanglst"