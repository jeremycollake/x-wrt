#!/usr/bin/webif-page
<? 
###################################################################
# freeloader-upload.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2007-03-11 m4rc0
#
#	version 1.3
#
# Description:
#	Gives functionality to upload torrent/nzb and url info to freeloader.
#
# Author(s) [in order of work date]:
#	m4rc0 <janssenmaj@gmail.com>
#
# Major revisions:
#		1.3 Added username/password - m4rc0 25-3-2007
#
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#   /etc/freeloader-include.sh
#
#
. /usr/lib/webif/webif.sh
header "Freeloader" "Freeloader upload" "@TR<<Freeloader upload>>"

cat <<EOF
<script type="text/javascript">
<!--
function checkformURL(form) {
  if (form.uploadURL.value == "") {
    alert( "Please enter a URL for uploading to the router." );
    form.uploadURL.focus();
    return false ;
  }
  
	if (form.username.value != "" && form.password.value == "") {
  	alert ( "You forgot to enter a password, please enter one." );
  	form.password.focus();
  	return false;
  }

	if (form.username.value == "" && form.password.value != "") {
  	alert ( "You forgot to enter a username, please enter one." );
  	form.username.focus();
  	return false;
  }
  
  return true ;
}

function checkformTorrentNZB(form) {
  if (form.uploadfile.value == "") {
    alert( "Please select a .torrent or .nzb file for uploading to the router." );
    form.uploadfile.focus();
    return false ;
  }   
  return true ;
}

// -->
</script>
EOF

#check for installed packages and store the status
is_package_installed "curl"
pkg_curl=$?
is_package_installed "ctorrent"
pkg_ctorrent=$?
is_package_installed "nzbget"
pkg_nzbget=$?
is_package_installed "mini-sendmail"
pkg_minisendmail=$?

if [ $pkg_nzbget -eq "0" ] || [ $pkg_ctorrent -eq "0" ]; then
cat <<EOF
<div class="settings">
<h3>Upload ctorrent and nzbget</h3>
<div class="settings-content">
<form action="freeloader-uploadcallback.sh" method="POST" enctype="multipart/form-data" onsubmit="return checkformTorrentNZB(this);">
<table border="0" class="packages" width="100%">
<tr>
	<td width="40%"><b>File</b></td>
	<td>
		<input type="file" name="uploadfile" />
		<input type="submit" value="GO" />
	</td>
</tr>
<tr>
	<td width="40%"><b>Priority</b></td>
	<td>
		<input type="radio" name="queue" value="normal" checked />normal
		<input type="radio" name="queue" value="prio" />prio
	</td>
</tr>
</table>
</form>
</div>
<blockquote class="settings-help">
<h3><strong>Short help:</strong></h3>
<h4>File:</h4><p>Here you can upload .torrent and .nzb files for downloading by pressing the browse button. When the GO button is pressed the file is uploaded to the router.</p>
<h4>Priority:</h4><p>With the priority switch you can select to which queue the file is uploaded.</p>
</blockquote>
<div class="clearfix">&nbsp;</div></div>
EOF
fi

if [ $pkg_curl -eq "0" ]; then
cat <<EOF
<div class="settings">
<h3>Upload curl</h3>
<div class="settings-content">
<form action="freeloader-uploadcallback.sh" method="POST" onsubmit="return checkformURL(this);">
<table border="0" class="packages" width="100%">
<tr>
	<td width="40%"><b>URL</b></td>
	<td>
		<input type="text" name="uploadURL" />
		<input type=submit value="GO" />
	</td>
</tr>
<tr>
	<td width="40%"><b>Priority</b></td>
	<td>
		<input type="radio" name="queue" value="normal" checked />normal
		<input type="radio" name="queue" value="prio" />prio
	</td>
</tr>
<tr>
	<td width="40%"><b>Username</b></td>
	<td><input type="text" name="username" /></td>
</tr>
<tr>
	<td width="40%"><b>Password</b></td>
	<td><input type="text" name="password" /></td>
</tr>
</table>
</form>
</div>
<blockquote class="settings-help">
<h3><strong>Short help:</strong></h3>
<h4>URL:</h4><p>Give the URL of the file you want to download.</p>
<h4>Priority:</h4><p>With the priority switch you can select to which queue the file is uploaded.</p>
<h4>Username/password:</h4><p>The credentials needed to download the file from the server.</p>
</blockquote>
<div class="clearfix">&nbsp;</div></div>
EOF
fi

#If the packages are not installed, give the user the possibilty to install the required packages.
if [ $pkg_ctorrent -eq "1" ]; then
	has_pkgs "ctorrent"
fi

if [ $pkg_nzbget -eq "1" ]; then
	has_pkgs "nzbget"
fi

if [ $pkg_curl -eq "1" ]; then
	has_pkgs "curl"
fi

if [ $pkg_minisendmail -eq "1" ]; then
	has_pkgs "mini-sendmail"
fi

crontab -l | grep -q "getfreeloader.sh\$"
cron_getfreeloader=$?
crontab -l | grep -q "killfreeloader.sh\$"
cron_killfreeloader=$?

if [ $cron_getfreeloader -eq "1" ] || [ $cron_killfreeloader -eq "1" ]; then
	echo "<pre>"
	echo "Add the following lines to crontab"
	echo ""
	echo "*/1 * * * * getfreeloader.sh"
	echo "*/1 * * * * killfreeloader.sh"
	echo "</pre>"
fi

?>


<? footer ?>
<!--
##WEBIF:name:Freeloader:10:Upload
-->
