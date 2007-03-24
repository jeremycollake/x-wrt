#!/usr/bin/haserl -u
content-type: text/html

<?
###################################################################
# freeloader-uploadcallback.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2007-03-02 m4rc0
#
#	version 1.4
#
# Description:
#	When the file is uploaded this page makes sure the file placed in the right directory.
#
# Author(s) [in order of work date]:
#	m4rc0 <janssenmaj@gmail.com>
#
# Major revisions:
#	
#
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#   /etc/freeloader-include.sh
#
#

#Include settings
. /etc/freeloader-include.sh


if [ -n "$FORM_uploadfile" ]; then
	#Get only the filename from the path
	#This fix is for IE-browsers,which will send the complete path. firefox will only send the filename.
	FORM_uploadfile_name=`echo $FORM_uploadfile_name|awk '{n=split($0,fn,"\\\"); print fn[n]}'`

	if [ "$FORM_queue" = "normal" ]; then
		mv $FORM_uploadfile "$QUEUE_NORMAL/$FORM_uploadfile_name"
	else
		mv  $FORM_uploadfile "$QUEUE_PRIO/$FORM_uploadfile_name"
	fi
	
	logstatus "$FORM_uploadfile_name has been uploaded to the $FORM_queue queue"
fi

if [ -n "$FORM_uploadURL" ]; then 
	URL_FILENAME=`echo $FORM_uploadURL | awk '{n=split($0,fn,"/"); print fn[n]}'`
	if [ "$FORM_queue" = "normal" ]; then
		echo $FORM_uploadURL > "$QUEUE_NORMAL/$URL_FILENAME.link"
	else
		echo $FORM_uploadURL > "$QUEUE_PRIO/$URL_FILENAME.link"
	fi
	
	logstatus "$URL_FILENAME has been uploaded to the $FORM_queue queue"
fi

echo "<html><body>"
cat <<EOF
<script type="text/javascript">
<!--
window.location="freeloader-upload.sh"
// -->
</script>
EOF
echo "</body></html>"
?>
