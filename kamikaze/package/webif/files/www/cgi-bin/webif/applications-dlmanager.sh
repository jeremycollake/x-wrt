#!/usr/bin/webif-page "-U /tmp"
<?
#########################################
# Applications Download Manager
#
# Author(s) [in order of work date]:
#        Dmytro Dykhman <dmytro@iroot.ca>
#

. /usr/lib/webif/webif.sh
. /www/cgi-bin/webif/applications-shell.sh

filename=""

echo "$HEADER"

if ! empty "$FORM_package"; then

	App_package_install "Download Manager" "" "ctorrent" "curl"

	if  is_package_installed "ctorrent"  &&  is_package_installed "curl"  ; then 
	##### Make config file

	if [ ! -s "/etc/config/app.dlmanager" ] ; then 
	echo "config dlmanager http
	option destination	'/mnt/sd'
config dlmanager ftp
	option destination	'/mnt/sd'
config dlmanager torrent
	option destination	'/mnt/sd'" > /etc/config/app.dlmanager
	mkdir /etc/dlmanager
	mkdir /etc/dlmanager/http
	mkdir /etc/dlmanager/ftp
	mkdir /etc/dlmanager/torrents
	mkdir /etc/dlmanager/history
	fi
	echo_install_complete
	Load_remote_libs
	ln -s /usr/lib/libuClibc++-0.2.1.so /lib/libuClibc++.so.0
	ln -s /usr/lib/libcurl.so.3.0.0 /lib/libcurl.so.3
	ln -s /usr/lib/libz.so.1.2.3 /lib/libz.so.1
	ln -s $ipklocation/usr/bin/ctorrent /usr/sbin/ctorrent
	ln -s $ipklocation/usr/bin/curl /usr/sbin/curl
	fi
exit
fi

if ! empty "$FORM_remove"; then
	App_package_remove "Download Manager" "app.dlmanager" "ctorrent" "uclibcxx" "curl" "libcurl" "libopenssl" "zlib"
	rm /lib/libuClibc++.so.0 2> /dev/null
	rm /lib/libcurl.so.3 2> /dev/null
	rm /lib/libz.so.1 2> /dev/null
	rm /usr/sbin/ctorrent 2> /dev/null
	rm /usr/sbin/curl 2> /dev/null
exit
fi

if  is_package_installed "ctorrent"  &&  is_package_installed "curl"  ; then 

	######## Read config
	uci_load "app.dlmanager"
	HTTP_PATH="$CONFIG_http_destination"
	TORRENT_PATH="$CONFIG_torrent_destination"

	cat <<EOF
	$HTMLHEAD</head><body bgcolor="#eceeec">
	<div id="mainmenu"><ul>
	<li><a href="$SCRIPT_NAME">Status</a></li>
	<li class="separator">-</li>
	<li><a href="$SCRIPT_NAME?page=http">HTTP</a></li>
	<li><a href="$SCRIPT_NAME?page=ftp">FTP</a></li>
	<li><a href="$SCRIPT_NAME?page=torrent">Torrents</a></li>
	<li class="separator">-</li>
	<li><a href="$SCRIPT_NAME?page=history">History</a></li>
	</ul></div><br/>
EOF
GetFilenameFromPath(){

	echo $1 | sed -e s/' '/'_'/g -e s/'\\'/'\n'/g | awk '{ print $1 }' | while read output;
	do echo $output > /tmp/.filename
	done
	filename=$(grep '' < /tmp/.filename)
}
##################################################################
	if ! equal "$FORM_uploadbt" ""; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>File sucessfully uploaded ...</br>"
		GetFilenameFromPath $FORM_uploadname

		mv  $FORM_uploadbt /etc/dlmanager/torrents/$filename
		exit
	fi

	if ! equal "$FORM_urlbt" ""; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>File is downloading ...</br>"
		wget -q $FORM_urlbt -P /etc/dlmanager/torrents/
		exit
	fi

	if ! equal "$FORM_urlhttp" ""; then
		GetFilenameFromPath $(echo $FORM_uploadname | sed -e s/'\/'/'\\'/g)
		if  [ -s "$HTTP_PATH/$filename" ]  ; then
			APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/><font color=red>File already exist in \"$HTTP_PATH\" ...</font></br>"
		else	APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>Adding File to List ...</br>"
			echo "$FORM_urlhttp" > /etc/dlmanager/http/$filename
		fi
		exit
	fi

	if ! equal "$FORM_start_torrent" ""; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>Starting torrent download ...</br>"
		ctorrent -e 0 -s /mnt/ /etc/dlmanager/torrents/$FORM_file
		exit
	fi

	if ! equal "$FORM_start_http" ""; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>Starting HTTP download ...</br>"
		FILE_PATH=$(grep '' < /etc/dlmanager/http/$FORM_file )
		curl -I $FILE_PATH > /etc/dlmanager/http/.$FORM_file 2> /dev/null ###To read the HTTP header first for fileinfo (size)
		curl -o $HTTP_PATH/$FORM_file $FILE_PATH 2> /dev/null
		mv /etc/dlmanager/http/$FORM_file /etc/dlmanager/history/$FORM_file
		rm /etc/dlmanager/http/.$FORM_file
		exit
	fi

	if	! equal "$FORM_save_torrent" "" ; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>Saving Settings ...</br/>"
		uci_set "app.dlmanager" "torrent" "destination" "$FORM_dest"
		uci_commit "app.dlmanager"
		exit
	fi
	if	! equal "$FORM_save_http" "" ; then
		APP_Refresh_Page $SCRIPT_NAME?page=$FORM_page "<br/>Saving Settings ...</br/>"
		uci_set "app.dlmanager" "http" "destination" "$FORM_dest"
		uci_commit "app.dlmanager"
		exit
	fi
if [ "$FORM_page" = "http" ]; then

	echo "<strong>Status</strong><br><br><hr>"
	if [ $(ps ax | grep -c curl) = "1" ] ; then 
		echo "<div class=warning>HTTP downloading stopped</div><br/><br/>"
	else echo "<form method="post" action='$SCRIPT_NAME'><font color="#33CC00">HTTP downloading sucessfully started</font>&nbsp;&nbsp;<input type="submit" name="stop_http" class='flatbtn' value='Stop All Downloads' /></form><br/><br/>"
	fi
	cat <<EOF
<script type='text/javascript'>
function java1() {
document.addnew.uploadname.value = document.addnew.urlhttp.value;
}
</script>

<form method='post'  name='addnew' action='$SCRIPT_NAME' enctype='multipart/form-data' >
<strong>Add New File</strong><br/><br/>
<table width="100%" border="0" cellspacing="1">
EOF
	HTML_Table_Line 2
	HTML_Table_TR "b1" "URL Address:" "<input type="text" name='urlhttp' /><input type="hidden" name="uploadname" />&nbsp;&nbsp;<input type="submit" class='flatbtn' value='Add to List' onClick='java1()' />"
	HTML_Table_Line 2
	HTML_Table_TR "b2" "Destination:" "<br/><input type="text" name='dest' value='$HTTP_PATH' /><br/><br/>"
	HTML_Table_Line 2
	HTML_Table_TR "" "" "<input type="checkbox" name="http_startup" $CFG_BOOTAIR />&nbsp;Start downloading on boot<br/><br/>"
	HTML_Table_TR "" "" "<input name='page' type='hidden' value='$FORM_page' /><input type='submit' class='flatbtn' name='save_http' value='Save Settings' />"
	echo "</table></form>"

	TIP 0 "Specify URL address of web file"
	TIP 0 "Location to where files will be downloaded"

	if [ "$FORM_do" = "del_http" ]; then
		echo "<br/><font color=red>Web File \"$FORM_file\" deleted</font></br/><br/>"
		rm /etc/dlmanager/http/$FORM_file
	fi

	cat <<EOF
Web File List:<br/><br/>
<table width="100%" border="0" cellspacing="1" bgcolor="#000000" align='center'><tr bgcolor='#FFFFFF'><td><table width='100%' border='0'>
<tr bgcolor='#999999'><td width='80%'><center>File Name</center></td><td><center>Status</center></td><td><center>Action</center></td></tr>
EOF

	ls /etc/dlmanager/http | while read output;
	do
		if [ "$color" = "#FFFFFF" ] ; then color="#E6E6E6" ; else color="#FFFFFF" ; fi
		echo "<tr bgcolor='$color'><td>&nbsp;$output</td><td><center>?</center></td><td><center><a href='$SCRIPT_NAME?page=http&start_http=1&file=$output'><img src='/images/action_ok.gif' alt='Start Download' /></a>&nbsp;<a href='$SCRIPT_NAME?page=http&do=del_http&file=$output'><img src='/images/action_x.gif' alt='Delete' /></a></center></td></tr>"	
	done

elif [ "$FORM_page" = "ftp" ]; then
		echo "in developemnt..."

elif [ "$FORM_page" = "torrent" ]; then

	echo "<strong>Status</strong><br><br><hr>"
	if [ $(ps ax | grep -c ctorrent) = "1" ] ; then 
		echo "<div class=warning>Torrent downloading stopped</div><br/><br/>"
	else echo "<form method="post" action='$SCRIPT_NAME'><font color="#33CC00">Torrent Client is sucessfully started</font>&nbsp;&nbsp;<input type="submit" name="stop_torrent" class='flatbtn' value='Stop All Downloads' /></form><br/><br/>"
	fi

	cat <<EOF
<script type='text/javascript'>
function java1() {
document.addnew.uploadname.value = document.addnew.uploadbt.value;
}
</script>

<form method='post' name='addnew' action='$SCRIPT_NAME' enctype='multipart/form-data' >
<strong>Add New Torrent</strong><br/><br/>
<table width="100%" border="0" cellspacing="1">
EOF

	HTML_Table_Line 2
	HTML_Table_TR "b1" "Local torrent:" "<input type="file" class="flatbtn" name="uploadbt" /><input type="hidden" name="uploadname" />&nbsp;&nbsp;<input type='submit' class='flatbtn' value='   Upload  ' onClick='java1()' />" 200
	HTML_Table_TR "b2" "Web torrent:" "<input type="text" class="flatbtn" name='urlbt' size='34' />&nbsp;&nbsp;<input type="submit" class='flatbtn' value='Download' />"
	HTML_Table_Line 2
	HTML_Table_TR "b3" "Destination:" "<br/><input type="text" name='dest' value='$TORRENT_PATH' /><br/><br/>"
	HTML_Table_Line 2
	HTML_Table_TR "" "" "<input type="checkbox" name="torrent_startup" $CFG_BOOTAIR />&nbsp;Start downloading on boot<br/><br/>"
	HTML_Table_TR "" "" "<input name='page' type='hidden' value='$FORM_page' /><input type='submit' class='flatbtn' name='save_torrent' value='Save Settings' />"
	echo "</table></form>"

	TIP 0 "You may upload new torrents from local disk"
	TIP 0 "Specify URL address of torrent file"
	TIP 0 "Location to where the torrents will be downloaded"

	if [ "$FORM_do" = "delete" ]; then
		echo "<br/><font color=red>Torrent \"$FORM_file\" deleted</font></br/><br/>"
		rm /etc/dlmanager/torrents/$FORM_file
	fi

cat <<EOF
Torrents List:<br/><br/>
<table width="100%" border="0" cellspacing="1" bgcolor="#000000" align='center'><tr bgcolor='#FFFFFF'><td><table width='100%' border='0'>
<tr bgcolor='#999999'><td width='80%'><center>File Name</center></td><td><center>Status</center></td><td><center>Action</center></td></tr>
EOF

ls /etc/dlmanager/torrents | while read output;
do
	if [ "$color" = "#FFFFFF" ] ; then color="#E6E6E6" ; else color="#FFFFFF" ; fi
	echo "<tr bgcolor='$color'><td>&nbsp;$output</td><td><center>?</center></td><td><center><a href='$SCRIPT_NAME?page=torrent&start_torrent=1&file=$output'><img src='/images/action_ok.gif' alt='Start Download' /></a>&nbsp;<a href='$SCRIPT_NAME?page=torrent&do=delete&file=$output'><img src='/images/action_x.gif' alt='Delete' /></a></center></td></tr>"	
done
	
elif [ "$FORM_page" = "history" ]; then
	if [ "$FORM_do" = "delete" ]; then
		echo "<font color=red>History \"$FORM_file\" cleaned</font></br/><br/>"
		rm /etc/dlmanager/history/$FORM_file
	fi
		cat <<EOF
History List:<br/><br/>
<table width="100%" border="0" cellspacing="1" bgcolor="#000000" align='center'><tr bgcolor='#FFFFFF'><td><table width='100%' border='0'>
<tr bgcolor='#999999' align='center'><td>Type</td><td width='80%'>File Name</td><td>Status</td><td>Action</td></tr>
EOF

	ls /etc/dlmanager/history | while read output;
	do
		if [ "$color" = "#FFFFFF" ] ; then color="#E6E6E6" ; else color="#FFFFFF" ; fi
		echo "<tr bgcolor='$color' align='center'><td>?</td><td align='left'>&nbsp;$output</td><td>100%</td><td><a href='$SCRIPT_NAME?page=history&start_type=1&file=$output'><img src='/images/action_ok.gif' alt='Re Download' /></a>&nbsp;<a href='$SCRIPT_NAME?page=history&do=delete&file=$output'><img src='/images/action_x.gif' alt='Delete' /></a></td></tr>"	
	done
else
cat <<EOF
Files currently downloading:<br/><br/>
<table width="100%" border="0" cellspacing="1" bgcolor="#000000" align='center'><tr bgcolor='#FFFFFF'><td><table width='100%' border='0'>
<tr bgcolor='#999999' align='center'><td width='60%' align='left'>File Name</td><td>Status</td><td>Action</td></tr>
EOF
	ls -a $CFG_PATH | grep ".txt" | sed -e s/'.txt'//g | awk '{ print $1 }' | while read output;
	do
		if [ "$color" = "#FFFFFF" ] ; then color="#E6E6E6" ; else color="#FFFFFF" ; fi
		echo "<tr bgcolor='$color'><td>&nbsp;<a href=\"$SCRIPT_NAME?page=showstatus&file=$output\">$output</a></td><td><center>?</center></td><td><center><a href='$SCRIPT_NAME?page=savestatus&file=$output' target='DLIVS'><img src='/images/action_sv.gif' alt='Save' /></a>&nbsp;<a href='$SCRIPT_NAME?page=aircrackit&file=$output'><img src='/images/action_ok.gif' alt='AirCrack' /></a>&nbsp;<a href='$SCRIPT_NAME?page=deletestatus&file=$output'><img src='/images/action_x.gif' alt='Delete' /></a></center></td></tr>"
	done
	echo "</table></td></tr></table><IFRAME STYLE=\"width:0px; height:0px;\" FRAMEBORDER='0' SCROLLING='no' name='DLFILE'></IFRAME>"


	fi
echo "</body></html>"
fi
?>