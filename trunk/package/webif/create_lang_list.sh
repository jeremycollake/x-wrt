#!/bin/sh
# Create default language list from translations.
# (c)2006 Lubos Stanek - X-Wrt project
# Released under GPL license.
#
WEBIF_ROOT="$1"
WEBIF_TARGET="$2"
[ "$#" -lt 2 ] && {
	echo "USAGE: $0 webif_base_file_folder webif_installation_folder"
	exit 1
}

LANG_ROOT_DIR="etc"
LANG_ROOT_FILE="languages.root"

create_lang_list() {
	mkdir -p "${WEBIF_TARGET}/${LANG_ROOT_DIR}"
	tmplanglst="${WEBIF_TARGET}/${LANG_ROOT_DIR}/.${LANG_ROOT_FILE}"
	langlst="${WEBIF_TARGET}/etc/${LANG_ROOT_FILE}"
	for lang_dir in ${WEBIF_ROOT}/files/usr/lib/webif/lang/*; do
		lang_short=${lang_dir##*/}
		if [ "$lang_short" != "template" ]; then
			lang_name=$(grep "^lang =>" "${lang_dir}/common.txt" | sed -e 's/^lang =>//; s/^ *//; s/ *$//;')
			if [ -z "$lang_name" ]; then
				lang_name=$(grep "^Description: " "${WEBIF_ROOT}/ipkg/webif-lang-${lang_short}.control" | sed -e 's/^Description: \([^[:space:]]*\)[[:space:]]*.*/\1/; s/^ *//; s/ *$//;')
			fi
			if [ -n "$lang_name" ]; then
				echo "option|${lang_short}|${lang_name}" >>"$tmplanglst"
			fi
		fi
	done
	echo "option|en|English" >"$langlst"
	sort -u "$tmplanglst" >>"$langlst"
	rm -f "$tmplanglst"
}
create_lang_list
echo "Default language list created."
