#!/bin/sh

# This file moves languages into proper directories.
# Schedule the change before the big firmware version change.
# The script can be deleted after the change

# cn to zh
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/cn \
	trunk/package/webif/files/usr/lib/webif/lang/zh
# cz to cs
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/cz \
	trunk/package/webif/files/usr/lib/webif/lang/cs
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/cz \
	kamikaze/package/webif/files/usr/lib/webif/lang/cs
# dk to da
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/dk \
	trunk/package/webif/files/usr/lib/webif/lang/da
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/dk \
	kamikaze/package/webif/files/usr/lib/webif/lang/da
# se to sv
svn mv \
	trunk/package/webif/files/usr/lib/webif/lang/se \
	trunk/package/webif/files/usr/lib/webif/lang/sv
svn mv \
	kamikaze/package/webif/files/usr/lib/webif/lang/se \
	kamikaze/package/webif/files/usr/lib/webif/lang/sv
# final commit
svn ci -m "language directories move according to ISO-639-1/2"
