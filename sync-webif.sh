#!/bin/sh
#
# This file keeps our two branches of the webif in synchronization.
# All files confirmed to work in both branches get added here. Then
# we can simply update any one file to update both branches.
#
# We should endeavor for pages to be identical between branches
# wherever possible. This is extremely important for maintanence.
# As any programmer knows, maintainence is part of life.
#

BRANCH_SOURCE="trunk/package/webif/files"
BRANCH_DEST="kamikaze/package/webif/files"

synchronize_file () {
	# filename	
	for file in $(ls ${BRANCH_SOURCE}/$1); do
		sed_pre=$(echo $BRANCH_SOURCE | sed -e s/'\/'/'\\\/'/g )
		base_file=$(echo $file | sed -e s/$sed_pre//g )
		echo $base_file
		cp ${BRANCH_SOURCE}/${base_file} ${BRANCH_DEST}/${base_file}
	done
}
echo "Synchronizing branches ..."
synchronize_file "www/themes/xwrt/*"
svn ci "$BRANCH_DEST" -m "synchronize with white russian branch"
