#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# system-editor
#
# Description:
#	Filesystem browser/File editor.
#       This file is compatible with both branches and
#       should be synchronized between branches
#
# Author(s) [in order of work date]:
#       unknown
#       Lubos Stanek <lubek@users.berlios.de>
#
# Major revisions (ISO 8601):
#       2007-04-14 - major update with enhancements
#                    and port to Kamikaze
#
# NVRAM variables referenced:
#       none
#
# Configuration files referenced:
#       none
#
# Required components:
#       /usr/lib/webif/common.awk
#       /usr/lib/webif/browser.awk
#       /usr/lib/webif/editor.awk
#

header "System" "Service" "@TR<<Services>>" '' "$SCRIPT_NAME"
echo "<table>"
ls -l /etc/init.d/ | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent=" $9 "\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent="filename"\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent="filename"\">remove</a>","</td></tr>"}'
echo "</table>"

echo "<table border=1>"
ls -l /etc/init.d/fstab | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent=" $9 "\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent="filename"\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent="filename"\">remove</a>","</td></tr>"}'
echo "</table>"


footer ?>
<!--
##WEBIF:name:System:126:Services
-->