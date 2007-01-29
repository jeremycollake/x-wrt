#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
###################################################################
# Applications page
#
# Description:
#        List and install additional applications.
#
# Author(s) [in order of work date]:        
#        Dmytro Dykhman <dmytro@iroot.ca>
#
# Major revisions:
#
#
# Configuration files referenced:
#   none
#
# TODO:

. "/usr/lib/webif/functions.sh"

HEADER="<link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css">
<script type="text/javascript" src="/js/balloontip.js">
</script><script type="text/javascript" src="/js/imgdepth.js">
</script>"

HighLight="class='gradualshine' onMouseover='slowhigh(this)' onMouseout='slowlow(this)'"


if [ "$FORM_page" = "index" ]; then
echo "Content-type: text/plain"
echo "HTTP/1.0 200 OK"
echo ""
#echo "<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">"
#echo "<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">"

cat <<EOF
<html>
<body>
</body>
</html>
EOF
exit
elif [ "$FORM_page" = "web" ]; then

cat <<EOF
<html>
<head>
$HEADER
</head>

<body>
<center>
<table width="98%" border="0" cellspacing="1" >

  <tr class='appindex'>
      <td width="20%"><center><a href="" rel="b1"><img src="/images/app.4.jpg" border="0" $HighLight ></a><br><font color=silver>Apache Webserver</font></center></td>
      <td width="20%"><div align="center"><a href="" rel="b2"><img src="/images/app.6.jpg" border="0" $HighLight ></a><br><font color=silver>FTP Server</font></div></td>
      <td width="20%"><div align="center"><a href="" rel="b3"><img src="/images/app.7.jpg" border="0" $HighLight ></a><br><font color=silver>MySQL Server</font></div></td>
      <td width="20%">&nbsp;</td>
      <td width="20%">&nbsp;</td>
  </tr>
  <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
  </tr>
</table>
<div id="b1" class="balloonstyle">
Apache Web server 1.3.3 - Powerfull webserver to serve webpages on World Wide Web.
</div>

<div id="b2" class="balloonstyle">
ProFTPD ?.? - Powerfull FTP server for sharing files globally.
</div>

<div id="b3" class="balloonstyle">
MySQL 4.3 - Massive database server
</div>
</center>
</body>
</html>

EOF

elif [ "$FORM_page" = "security" ]; then

cat <<EOF
<html>
<head>
$HEADER
</head>

<body>
<center>
<table width="98%" border="0" cellspacing="1" >
<tr class="appindex">
<td width="20%"><center><a href="" rel="b1"><img src="/images/app.2.jpg" border="0" $HighLight ></a><br><font color=silver>Hydra</font></center></td>
<td width="20%">&nbsp;</td>
<td width="20%">&nbsp;</td>
<td width="20%">&nbsp;</td>
<td width="20%">&nbsp;</td>
</tr>
<tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
</center>
<div id="b1" class="balloonstyle"  style="width: 300px;">
Hydra 4.5 - "Password Brute Force" - attacker for checking weak passwords. Great utility to check your (http,ftp,ssh) services.
</div>
</body>
</html>

EOF

elif [ "$FORM_page" = "network" ]; then

cat <<EOF
<html>
<head>

$HEADER

<script type="text/javascript">
<!--

function confirmModifications() 
 {  
 if (window.confirm("Do you want to DELETE this account from shell? \n\n(Note: account will be terminated completely in 24-48 hours)"))
  {  
  window.location="app.samba.sh?package=install"
  } else {  
  } 
  }  
// --> 
</script>
</head>

<body>
<center>
<table width="98%" border="0" cellspacing="1" >
  <tr class='appindex'>

EOF

#--------------------------------------
if  is_package_installed "kmod-cifs"  &&  is_package_installed "cifsmount"  ; then

#<<---If package is already installed--->>
echo "<td width='20%'><center><a href='app.samba.sh' rel='b1'><img src='/images/app.10.jpg' border='0'></a><br>Samba Client</center></td>"
     
else

#<<---If package is NOT installed--->>
echo "<td width='20%'><center><a href='javascript:confirmModifications()' rel='b1'><img src='/images/app.10.jpg' border='0'  $HighLight ><a><br><font color=silver>Samba Client</font></center></td>"

fi
#-------------------------------------------
cat <<EOF
      <td width="20%">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="20%">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
</center>
<div id="b1" class="balloonstyle"  style="width: 200px;">
Samba Client- Allows to map network drive from Windows based file system.
</div>
</body>
</html>

EOF

elif [ "$FORM_page" = "list" ]; then



echo "<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">"
echo "<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">"

cat <<EOF
<head>
</head>

<body >
<table width="90%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td><a href="applications.sh?page=web" target="AppIndex"><img src="/images/app.8.jpg" border="0" ></a></td>
    <td><strong>Web Applications</strong></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td><a href="applications.sh?page=security" target="AppIndex"><img src="/images/app.5.jpg" border="0" ></a></td>
    <td><strong>Security Applications</strong></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td><a href="applications.sh?page=network" target="AppIndex"><img src="/images/app.9.jpg" border="0" ></a></td>
    <td><strong>Network Applications</strong></td>
  </tr>
</table>
</body>
</html>

EOF

else

. /usr/lib/webif/webif.sh

header "Applications" "List" "<img src=/images/app.jpg align="absmiddle">&nbsp;@TR<<List of Applications>>"

cat <<EOF
<font color="#FF0000">This page is currently in development process. Some features 
may not function. </font> 
<br>
<img src="/images/coming_soon2.jpg" border="0" >

<table width="95%" border="0" cellspacing="1">
  <tr>
    <td width="30%">&nbsp;</td>
    <td width="70%">&nbsp;</td>
  </tr>
  <tr>
    <td>
<IFRAME SRC="applications.sh?page=list" STYLE="width:100%; height:350px; border:1px dotted #888888;" FRAMEBORDER="0" SCROLLING="NO" name="AppList"></IFRAME>

</td>
    <td>
<IFRAME SRC="applications.sh?page=index" STYLE="width:90%; height:350px; border:1px dotted #888888;" FRAMEBORDER="0" SCROLLING="YES" name="AppIndex"></IFRAME>

</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
EOF

footer

fi

?>
<!--
##WEBIF:name:Applications:1:<List>
-->
