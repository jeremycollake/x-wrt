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
	echo "USAGE: diff-webif.sh filename filename2 filename3"
	exit 1
fi

BRANCH_SOURCE="trunk/package/webif/files"
BRANCH_DEST="kamikaze/package/webif/files"

diff_file () {
	# filename	
	diff ${BRANCH_SOURCE}/$1 ${BRANCH_DEST}/$1 -BurN
}

for i in $(seq 1 $#); do	
	if [ -f "${BRANCH_SOURCE}/www/cgi-bin/webif/$1" ]; then
		diff_file "/www/cgi-bin/webif/$1"
	else
		diff_file "$1"
	fi
	shift
done

