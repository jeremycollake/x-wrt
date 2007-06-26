#!/bin/sh
# Add missing/new symbols from translations.
# (c)2006 Owen Brotherwood and Jeremy Collake - X-Wrt project
# Released under GPL license.
#
ROOT="$1"
[ "$#" != 1 ] && {
	echo "USAGE: $0 webif_base_file_folder"	
	echo "Assuming ./files/ as base folder ..."
	ROOT="files"
}
add_missing_symbols() {
        for dir in ${ROOT}/www/* ${ROOT}/usr/lib/webif/*; do
                tmp_symbol_names=$(grep @TR -R "$dir" | sed -e 's/.*@TR<<\(.*\)>>.*/\1/' | tr '|' '#' | cut -f1 -d'#' | sed -e s/'"'//g -e s/' '/'%20'/g | sort -u)
		# spaces translated above to %20, so we can use space as delimiter
		all_symbol_names="$all_symbol_names $tmp_symbol_names"
        done
	#
	# now see which symbols are missing from lang files and add them
	#
	for lang_dir in ${ROOT}/usr/lib/webif/lang/*; do
		lang_file="${lang_dir}/common.txt"
		echo
		echo "Processing $lang_file ........."
		echo
		for cur_symbol in $all_symbol_names; do
			cur_symbol=$(echo "$cur_symbol" | sed s/'%20'/' '/g) # put back spaces
			# make sure symbol doesn't contain '$'			
			if ! echo "$cur_symbol" | grep -q '\$' && ! echo "$cur_symbol" | grep -q 'c\[i\]'; then
				sym_lookup=$(grep "$cur_symbol" "$lang_file" 2>&-)
					[ "$?" != "0" ] && {
						echo "adding $cur_symbol to $lang_file"
						echo "$cur_symbol =>" >> $lang_file
					}
			fi
		done
	done	
}
add_missing_symbols
echo "All Done."

