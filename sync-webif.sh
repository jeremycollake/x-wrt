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

if [ $# != 1 ]; then
	echo "USAGE: sync-webif.sh [-fromkami|-fromwr]"
	echo "  use -fromkami to copy files from Kamikaze to White Russian."
	echo "  use -fromwr to copy files from White Russian to Kamikaze."
	exit 1
fi

case "$1" in
	"-fromkami") 
		BRANCH_DEST="trunk/package/webif/files"
		BRANCH_SOURCE="kamikaze/package/webif/files";;
	"-fromwr") 
		BRANCH_SOURCE="trunk/package/webif/files"
		BRANCH_DEST="kamikaze/package/webif/files";;
	*) echo "Invalid parameter!"
	   exit 1;;
esac

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
synchronize_file "etc/config/webif"
synchronize_file "usr/lib/webif/functions.sh"
synchronize_file "www/cgi-bin/webif/info.sh"
svn ci "$BRANCH_DEST" -m "synchronize with white russian branch"
