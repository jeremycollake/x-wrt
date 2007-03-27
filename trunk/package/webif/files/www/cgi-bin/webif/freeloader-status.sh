#!/usr/bin/webif-page
<? 
###################################################################
# freeloader-status.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2007-02-22 m4rc0
#
#	version 1.18
#
# Description:
#	Show the status of the queues and the current download.
#
# Author(s) [in order of work date]:
#	m4rc0 <janssenmaj@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#   /etc/freeloader-include.sh
#		/usr/lib/webif/webif.sh
#



. /usr/lib/webif/webif.sh
header "Freeloader" "Freeloader status" "@TR<<Freeloader status>>" ' onresize="setDiv()" onload="setDiv()" '

#Include settings
. /etc/freeloader-include.sh

#Check the required packages
is_package_installed "curl"
pkg_curl=$?
is_package_installed "ctorrent"
pkg_ctorrent=$?
is_package_installed "nzbget"
pkg_nzbget=$?

#if one of the packages is installed the page can be displayed
if [ $pkg_nzbget -eq "0" ] || [ $pkg_ctorrent -eq "0" ] || [ $pkg_curl -eq "0" ]; then

cat <<EOF
<script type="text/javascript">
<!--
//Set refresh timer for page (need to do this way, IE had problem with HTML refresh)
setTimeout("window.location='freeloader-status.sh';", 60000);

function setDiv()
{
var viewarea = document.getElementById("viewarea"); 
var windowheight = document.body.clientHeight;
viewarea.style.height = (windowheight - 344) + "px"; 
}

// -->
</script>
EOF

#check if there is a PRIO download
if [ -f /tmp/prio.lock ]; then
	#Set the current working queue as the PRIO queue
	QUEUE_DIR=$QUEUE_PRIO
else
	#Set the current working queue as the normal queue
	QUEUE_DIR=$QUEUE_NORMAL
fi

if [ "$FORM_action" = "abort" ]; then
	EXTENSION=`sed -n 1p /tmp/currentdownloadextension`
	if [ $EXTENSION = 'torrent' ]; then
		killall -9 ctorrent  > /dev/null 2>&1
	elif [ $EXTENSION = 'link' ]; then
		killall -9 curl  > /dev/null 2>&1
	elif [ $EXTENSION = 'nzb' ]; then
		killall -9 nzbget  > /dev/null 2>&1		
	fi

cat << EOF
<script type="text/javascript">
<!--
window.location="freeloader-status.sh"
// -->
</script>
EOF
elif [ "$FORM_action" = "remove" ]; then
	if [ "$FORM_queue" = "normal" ]; then
		mv "$QUEUE_NORMAL/$FORM_torrent" "$QUEUE_ABORT/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_NORMAL/$FORM_torrent.fci" ]; then
			mv "$QUEUE_NORMAL/$FORM_torrent.fci" "$QUEUE_ABORT/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	elif [ "$FORM_queue" = "prio" ]; then
		mv "$QUEUE_PRIO/$FORM_torrent" "$QUEUE_ABORT/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_PRIO/$FORM_torrent.fci" ]; then
			mv "$QUEUE_PRIO/$FORM_torrent.fci" "$QUEUE_ABORT/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	fi
elif [ "$FORM_action" = "purge" ]; then
	if [ "$FORM_queue" = "done" ]; then
		rm "$QUEUE_DONE/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_DONE/$FORM_torrent.fci" ]; then
			rm "$QUEUE_DONE/$FORM_torrent.fci"  > /dev/null 2>&1
		fi		
	elif [ "$FORM_queue" = "abort" ]; then
		rm "$QUEUE_ABORT/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_ABORT/$FORM_torrent.fci" ]; then
			rm "$QUEUE_ABORT/$FORM_torrent.fci"  > /dev/null 2>&1
		fi		
	fi
elif [ "$FORM_action" = "prio" ]; then
	if [ "$FORM_queue" = "normal" ]; then
		mv "$QUEUE_NORMAL/$FORM_torrent" "$QUEUE_PRIO/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_NORMAL/$FORM_torrent.fci" ]; then
			mv "$QUEUE_NORMAL/$FORM_torrent.fci" "$QUEUE_PRIO/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	elif [ "$FORM_queue" = "abort" ]; then
		mv "$QUEUE_ABORT/$FORM_torrent" "$QUEUE_PRIO/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_ABORT/$FORM_torrent.fci" ]; then
			mv "$QUEUE_ABORT/$FORM_torrent.fci" "$QUEUE_PRIO/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	fi
elif [ "$FORM_action" = "normal" ]; then
	if [ "$FORM_queue" = "prio" ]; then
		mv "$QUEUE_PRIO/$FORM_torrent" "$QUEUE_NORMAL/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_PRIO/$FORM_torrent.fci" ]; then
			mv "$QUEUE_PRIO/$FORM_torrent.fci" "$QUEUE_NORMAL/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	elif [ "$FORM_queue" = "abort" ]; then
		mv "$QUEUE_ABORT/$FORM_torrent" "$QUEUE_NORMAL/$FORM_torrent"  > /dev/null 2>&1
		if [ -f "$QUEUE_ABORT/$FORM_torrent.fci" ]; then
			mv "$QUEUE_ABORT/$FORM_torrent.fci" "$QUEUE_NORMAL/$FORM_torrent.fci"  > /dev/null 2>&1
		fi
	fi
elif [ "$FORM_action" = "suspend" ]; then
	touch $DOWNLOAD_DESTINATION/suspend.lock > /dev/null 2>&1
elif [ "$FORM_action" = "resume" ]; then
	rm $DOWNLOAD_DESTINATION/suspend.lock > /dev/null 2>&1
fi

cat <<EOF
<div ID="viewarea" style="overflow: auto; width: 100%;">
<h3>Normal queue</h3>
<table border="0" class="packages">

<tr>
<th width="600">Torrent</th>
<th width="150">Date</th>
<th width="50"></th>
<th width="50"></th>
<th width="50"></th>
</tr>
EOF

if [ -f /tmp/currentdownloadfile ]; then
	CURRENT_DOWNLOADFILE=`sed -n 1p /tmp/currentdownloadfile`
	if [ "`ls -l $QUEUE_NORMAL | grep -v "$CURRENT_DOWNLOADFILE"`" != '' ]; then
		ls -l $QUEUE_NORMAL | grep -v "$CURRENT_DOWNLOADFILE" | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent=" $9 "\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent="filename"\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent="filename"\">remove</a>","</td></tr>"}'
	else

	   echo "<tr><td colspan="5">There are currently no files in the queue</td><tr>"
	fi
else
	if [ "`ls -l $QUEUE_NORMAL`" != '' ]; then
		ls -l $QUEUE_NORMAL | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent=" $9 "\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=normal&torrent="filename"\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=normal&torrent="filename"\">remove</a>","</td></tr>"}'
	else
	   echo "<tr><td colspan="5">There are currently no files in the queue</td><tr>"
	fi

fi
cat << EOF
</table>

<br/><h3>Prio queue</h3>
<table border="0" class="packages">
<tr>
<th width="600">Torrent</th>
<th width="150">Date</th>
<th width="50"></th>
<th width="50"></th>
<th width="50"></th>
</tr>
EOF

if [ -f /tmp/currentdownloadfile ]; then
	CURRENT_DOWNLOADFILE=`sed -n 1p /tmp/currentdownloadfile`
	if [ "`ls -l $QUEUE_PRIO | grep -v "$CURRENT_DOWNLOADFILE"`" != '' ]; then
		ls -l $QUEUE_PRIO | grep -v "$CURRENT_DOWNLOADFILE" | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=prio&torrent=" $9 "\">normal</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=prio&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=prio&torrent="filename"\">normal</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=prio&torrent="filename"\">remove</a>","</td></tr>"}'
	else
	   echo "<tr><td colspan="5">There are currently no files in the queue</td><tr>"
	fi
else
	if [ "`ls -l $QUEUE_PRIO`" != '' ]; then
		ls -l $QUEUE_PRIO | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=prio&torrent=" $9 "\">normal</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=prio&torrent=" $9 "\">remove</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=prio&torrent="filename"\">normal</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=remove&queue=prio&torrent="filename"\">remove</a>","</td></tr>"}'
	else
	   echo "<tr><td colspan="5">There are currently no files in the queue</td><tr>"
	fi
fi
cat <<EOF
</table>

<br/><h3>Finished torrents</h3>
<table border="0" class="packages">
<tr>
<th width="600">Torrent</th>
<th width="150">Date</th>
<th width="50"></th>
<th width="50"></th>
<th width="50"></th>
</tr>
EOF

if [ "`ls -l $QUEUE_DONE`" != '' ]; then
	ls -l $QUEUE_DONE  | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=purge&queue=done&torrent=" $9 "\">purge</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=purge&queue=done&torrent="filename"\">purge</a>","</td></tr>"}'
else
	echo "<tr><td colspan="5">There are no finished downloads at the moment</td></tr>"
fi

cat <<EOF
</table>

<br/><h3>Aborted torrents</h3>
<table border="0" class="packages">
<tr>
<th width="600">Torrent</th>
<th width="150">Date</th>
<th width="50"></th>
<th width="50"></th>
<th width="50"></th>
</tr>
EOF

if [ "`ls -l $QUEUE_ABORT`" != '' ]; then
	ls -l $QUEUE_ABORT | grep -v ".link.fci" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=abort&torrent=" $9 "\">normal</a>","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=abort&torrent=" $9 "\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=purge&queue=abort&torrent=" $9 "\">purge</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=normal&queue=abort&torrent="filename"\">normal</a>","</td><td>","<a href=\"freeloader-status.sh?action=prio&queue=abort&torrent="filename"\">prio</a>","</td><td>","<a href=\"freeloader-status.sh?action=purge&queue=abort&torrent="filename"\">purge</a>","</td></tr>"}'
else
	echo "<tr><td colspan="5">There are no aborted downloads at the moment</td></tr>"
fi

cat <<EOF
</table>

<br/><h3>Currently downloading</h3>
<table border="0" class="packages">
<tr>
<th width="600">Torrent</th>
<th width="150">Date</th>
<th width="50"></th>
<th width="50"></th>
<th width="50"></th>
</tr>
EOF

if [ -f /tmp/currentdownloadfile ]; then
	CURRENT_DOWNLOADFILE=`sed -n 1p /tmp/currentdownloadfile`
	if [ -f $DOWNLOAD_DESTINATION/suspend.lock ]; then
		echo "<tr><td colspan="5"><font color="red">The proces is being suspend at the moment, please wait...<font></td></tr>"
		echo "<tr><td colspan="5">&nbsp;<td></tr>"
		ls -l $QUEUE_DIR | grep "$CURRENT_DOWNLOADFILE\$" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","&nbsp;","</td><td>","&nbsp;","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","&nbsp;","</td><td>","&nbsp;","</td><td>","&nbsp;","</td></tr>"}'
	else
		ls -l $QUEUE_DIR | grep "$CURRENT_DOWNLOADFILE\$" | awk 'NF == 9 {print "<tr><td>",$9,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=abort&queue=current&torrent=" $9 "\">abort</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=suspend\">suspend</a>","</td></tr>"};NF > 9 {filename=$9;for (i=10;i<= NF; i++){filename = filename " " $i};print "<tr><td>",filename,"</td><td>",$7,$6,$8,"</td><td>","<a href=\"freeloader-status.sh?action=abort&queue=current&torrent="filename"\">abort</a>","</td><td>","&nbsp;","</td><td>","<a href=\"freeloader-status.sh?action=suspend\">suspend</a>","</td></tr>"}'
	fi
else
	if [ -f $DOWNLOAD_DESTINATION/suspend.lock ]; then
		echo "<tr><td colspan="4">Download queue is suspended</td><td><a href="freeloader-status.sh?action=resume">resume</a></td></tr>"
	else
		echo "<tr><td colspan="5">There are no files being downloaded at the moment</td></tr>"
	fi
fi

cat <<EOF
</table>
<br/>
<pre>
EOF

if [ -f /tmp/currentlogfile ]; then
	CURRENT_LOGFILE=`sed -n 1p /tmp/currentlogfile`
	EXTENSION=`sed -n 1p /tmp/currentdownloadextension`

	if [ $EXTENSION = 'torrent' ]; then
		head -n 20 "$LOG_DIRECTORY/$CURRENT_LOGFILE" | grep -v 'Check exist:'
		echo
		tail -c 1000 "$LOG_DIRECTORY/$CURRENT_LOGFILE" | grep -v 'Check exist:'
	elif [ $EXTENSION = 'link' ]; then
		head -n 2 "$LOG_DIRECTORY/$CURRENT_LOGFILE"
		tail -c 1558 "$LOG_DIRECTORY/$CURRENT_LOGFILE"
	elif [ $EXTENSION = 'nzb' ]; then
		tail -c 1558 "$LOG_DIRECTORY/$CURRENT_LOGFILE"
	fi
fi
cat <<EOF
</pre>
</div>
EOF
else
	echo "None of the required packages is installed, check the upload-page to install the packages."
fi

footer 

?>
<!--
##WEBIF:name:Freeloader:5:Status
-->
