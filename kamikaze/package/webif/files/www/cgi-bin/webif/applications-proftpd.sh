#!/usr/bin/webif-page
<?
#########################################
# About page
#
# Author(s) [in order of work date]:
#        Dmytro Dykhman <dmytro@iroot.ca.
#

. /usr/lib/webif/functions.sh
. /lib/config/uci.sh

cat <<EOF
HTTP/1.0 200 OK
Content-type: text/html

EOF

ipkg_LIB()
{

uci_load "app.ipkg"
loc="$CONFIG_int_location"

echo "#!/bin/sh" > /tmp/.D43S.tmp
echo "START=98" > /tmp/.D43S.tmp
echo "find $loc/usr/lib/ |grep \".so\" |cut -d / -f 5 | awk '{print \" if [ ! -f /usr/lib/\"\$1\" ] \\n then \\n ln -s $loc/usr/lib/\"\$1\" /usr/lib/\"\$1\" \\n fi\"}' > /tmp/lib1.tmp" >> /tmp/.D43S.tmp
echo "find $loc/opt/lib/ |grep \".so\" |cut -d / -f 5 | awk '{print \" if [ ! -f /usr/lib/\"\$1\" ] \\n then \\n ln -s $loc/opt/lib/\"\$1\" /usr/lib/\"\$1\" \\n fi\"}' > /tmp/lib2.tmp" >> /tmp/.D43S.tmp
echo "sh /tmp/lib1.tmp ; rm /tmp/lib1.tmp" >> /tmp/.D43S.tmp
echo "sh /tmp/lib2.tmp ; rm /tmp/lib2.tmp" >> /tmp/.D43S.tmp

# EXPERIMENTAL!!!
#cp /tmp/.D43S.tmp /etc/init.d/mountlibs
#chmod 755 /etc/init.d/mountlibs
#ln -s /etc/init.d/mountlibs /etc/rc.d/S98mountlibs
}

url1="http://ftp.osuosl.org/pub/nslu2/feeds/unslung/wl500g/"
#url1="http://192.168.0.8/"

loc=""

if ! empty "$FORM_package"; then
if ! empty "$FORM_ipkg"; then loc="-d "$FORM_ipkg ; fi

echo "<html><header></header><body>Installing FTP Server packages ...<br><br><pre>"
echo "Installing openssl package ..."

ipkg $loc install $url1"openssl_0.9.7l-3_mipsel.ipk" -force-overwrite -force-defaults 

echo "Installing proftpd package ..."

ipkg $loc install $url1"proftpd_1.2.10-5_mipsel.ipk" -force-overwrite -force-defaults
#ipkg $loc install $url1"proftpd_1.3.0a-1_mipsel.ipk" -force-overwrite -force-defaults

echo "</pre></body></html>"

#### Make sure installation completed sucessfully
if  is_package_installed "openssl"  &&  is_package_installed "proftpd"  ; then 
	
	#### Load libraries that we just installed

	ipkg_LIB
	sh /tmp/.D43S.tmp ; rm /tmp/.D43S.tmp

	#### Small patches to get it working with webif^2
	#cp $loc/opt/etc/proftpd.conf /etc/proftpd.conf

echo "ServerName			\"ProFTPD Webif^2 Installation\"
ServerType			standalone
DefaultServer			on
WtmpLog			off
Port				21
Umask				022
MaxInstances			10
PassivePorts			49873 49873

MaxClients                    3 \"550 Too Many Users (Limit=%m)\"
MaxClientsPerHost             1 \"551 One connection per IP\"

DirFakeUser on ~
DirFakeGroup on ~

<Global>
  RootLogin On
  RequireValidShell off
  #AuthUserFile /etc/passwd
  AuthUserFile		/etc/passwd
 
  AllowStoreRestart on
</Global>

DefaultRoot	/www/

<Directory /www>
    <Limit ALL>
      AllowAll
    </Limit>
</Directory>

User				root
Group				root

AllowOverwrite		on" > /etc/proftpd.conf

#if equal $(grep "nobody:" < /etc/group) "" ; then echo "nobody:x:65535:" >> /etc/group ; fi
	mkdir /opt
	mkdir /opt/var
	mkdir /opt/var/proftpd
	ln -s $loc/opt/sbin/proftpd /usr/sbin/proftpd

	#### Check if first time /etc/config exists

	if [ -s "/etc/config/app.proftpd" ] ; then
	echo ""
	else
	echo "config proftpd net
	option port	'21'" > /etc/config/app.proftpd
	fi
fi
exit
fi

if ! empty "$FORM_remove"; then
	echo "<html><header></header><body><font size=3>Removing FTP Server packages ...<br><br><pre>"
	remove_package "proftpd"
	remove_package "openssl"
	rm /etc/config/app.proftpd
	rm /etc/proftpd.conf
	echo "</pre>Done.</font></body></html>"
exit
fi

if  is_package_installed "openssl"  &&  is_package_installed "proftpd"  ; then 


######## Read config

uci_load "app.proftpd"
NET_PORT="$CONFIG_net_port"


HEADER="<link rel=stylesheet type=text/css href=/themes/active/webif.css>
<script type="text/javascript" src="/js/balloontip.js">
</script>"

cat <<EOF
<html><head><title></title>
$HEADER
</head><body bgcolor="#eceeec">
<strong>Status</strong><br><br><hr>
EOF

######## Try start Proftpd
if ! empty "$FORM_startftp"; then
echo "<META http-equiv="refresh" content='4;URL=$SCRIPT_NAME'>"
echo "<br>Starting FTP Server ...<br/>"
proftpd -c /etc/proftpd.conf &
exit
fi

######### Save Proftpd
if ! empty "$FORM_save_proftpd"; then
echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
echo "<br>saving...."

uci_set "app.proftpd" "net" "port" "$FORM_ftp_port"
uci_commit "app.proftpd"

exit
fi 

if ! empty "$FORM_stopftp"; then
echo "<META http-equiv="refresh" content='4;URL=$SCRIPT_NAME'>"
echo "<br>Stopping FTP Server ..."
killall -q proftpd
exit
fi

####### Check if proftpd is running
#echo "'"$(ps ax | grep -c proftpd)"'"
if [ $(ps ax | grep -c proftpd) = "1" ] ; then

cat <<EOF
<form method="post" action='$SCRIPT_NAME'>
<div class=warning>FTP Server is not running</div>&nbsp;&nbsp;<input type="submit" name="startftp" value="Start"><br/>
</form>
<br>
EOF

else

echo "<form method="post" action='$SCRIPT_NAME'><font color="#33CC00">FTP Server is succesfully started</font>&nbsp;&nbsp;<input type="submit" name="stopftp" value='Stop'></form><br><br>"
fi

cat <<EOF
<strong>FTP Server Configuration</strong><br>
<br>
<form action='$SCRIPT_NAME' method='post'>
<table width="100%" border="0" cellspacing="1">
<tr><td colspan="2" height="1"  bgcolor="#333333"></td></tr>
<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr> 
<td width="100"><a href="#" rel="b1">Port</a></td>
<td><input name="ftp_port" type="text" value=$NET_PORT></td>
</tr>
<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>&nbsp;</td>
<td><input type="submit" style='border: 1px solid #000000;' name="save_proftpd" value="Save"></td>
</tr>
</table>
</form>

<div id="b1" class="balloonstyle" style="width: 450px;">
Port number<br><br>Default: 21
</div>
</body></html>
EOF

fi
?>