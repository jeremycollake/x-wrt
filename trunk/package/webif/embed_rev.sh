#!/bin/sh
#
# this script embeds the global revision number in document(s) given on command line
# document should have __SVN_REVISION__ where it wants the revision number
# to be placed. Wildcards okay.
#
if [ $# -lt 1 ]; then
	echo " Invalid usage. Must supply one or more files."
	exit 1
fi
revision_number=$(svn info | grep Revision | cut -c11-)
tempfile=$(mktemp)
echo " Revision number is $revision_number"
echo " Temporary file is $tempfile"
until [ -z "$1" ]  
do
	for curfile in $1; do
		echo " Processing $curfile ..."
		cp $curfile $tempfile	
		cat $tempfile | sed s/__SVN_REVISION__/$revision_number/ > $curfile
		rm $tempfile	
	done
  shift
done

