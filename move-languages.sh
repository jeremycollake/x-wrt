#!/bin/sh

# This file moves languages into proper directories.
# Schedule the change before the big firmware version change.
# The script can be deleted after the change

replace_all_strings() {
	local OLD_LNG_LOW=$1
	local OLD_LNG_HIGH=$(echo $1 | tr '[:lower:]' '[:upper:]')

	local NEW_LNG_LOW=$2
	local NEW_LNG_HIGH=$(echo $2 | tr '[:lower:]' '[:upper:]')

	local OLD_NAME_IPKG="webif-lang-$OLD_LNG_LOW"
	local OLD_NAME_MKWR1="WEBIF-LANG-$OLD_LNG_HIGH,$OLD_LNG_LOW"
	local OLD_NAME_MKWR2="WEBIF-LANG-$OLD_LNG_HIGH"
	local OLD_NAME_CONFIG="WEBIF_LANG_$OLD_LNG_HIGH"
	local OLD_NAME_MKKA="webif\/lang\/$OLD_LNG_LOW"

	local NEW_NAME_IPKG="webif-lang-$NEW_LNG_LOW"
	local NEW_NAME_MKWR1="WEBIF-LANG-$NEW_LNG_HIGH,$NEW_LNG_LOW"
	local NEW_NAME_MKWR2="WEBIF-LANG-$NEW_LNG_HIGH"
	local NEW_NAME_CONFIG="WEBIF_LANG_$NEW_LNG_HIGH"
	local NEW_NAME_MKKA="webif\/lang\/$NEW_LNG_LOW"

	FILELIST="trunk/package/webif/ipkg/webif-lang-$NEW_LNG_LOW.control trunk/package/webif/Config.in trunk/package/webif/Makefile kamikaze/package/webif/Makefile"
	for file in $FILELIST
	do
		sed -e "s/$OLD_NAME_IPKG/$NEW_NAME_IPKG/g;
			s/$OLD_NAME_MKWR1/$NEW_NAME_MKWR1/g;
			s/$OLD_NAME_MKWR2/$NEW_NAME_MKWR2/g;
			s/$OLD_NAME_CONFIG/$NEW_NAME_CONFIG/g;
			s/$OLD_NAME_MKKA/$NEW_NAME_MKKA/g;" \
		-i "$file"
	done
}

# cn to zh
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/cn \
	trunk/package/webif/files/usr/lib/webif/lang/zh
svn mv \
	trunk/package/webif/ipkg/webif-lang-cn.control \
	trunk/package/webif/ipkg/webif-lang-zh.control
replace_all_strings cn zh
# cz to cs
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/cz \
	trunk/package/webif/files/usr/lib/webif/lang/cs
svn mv \
	trunk/package/webif/ipkg/webif-lang-cz.control \
	trunk/package/webif/ipkg/webif-lang-cs.control
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/cz \
	kamikaze/package/webif/files/usr/lib/webif/lang/cs
replace_all_strings cz cs
# dk to da
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/dk \
	trunk/package/webif/files/usr/lib/webif/lang/da
svn mv \
	trunk/package/webif/ipkg/webif-lang-dk.control \
	trunk/package/webif/ipkg/webif-lang-da.control
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/dk \
	kamikaze/package/webif/files/usr/lib/webif/lang/da
replace_all_strings dk da
# se to sv
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/se \
	trunk/package/webif/files/usr/lib/webif/lang/sv
svn mv \
	trunk/package/webif/ipkg/webif-lang-se.control \
	trunk/package/webif/ipkg/webif-lang-sv.control
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/se \
	kamikaze/package/webif/files/usr/lib/webif/lang/sv
replace_all_strings se sv

echo
echo "You should sort properly Config.in WR and Makefiles in WR/KA as the last step."
echo

# final commit
#svn ci -m "language directories move according to ISO-639-1/2"
