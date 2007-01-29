#!/usr/bin/webif-page
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!
. "/usr/lib/webif/functions.sh"
. /lib/config/uci.sh

if ! empty "$FORM_package"; then
echo "<html><header></header><body>"

	echo "<font size=2>Installing Samba packages ...<br><br><pre>"
echo "Installing kmod-cifs package ..."
	install_package "http://downloads.openwrt.org/whiterussian/rc6/packages/kmod-cifs_2.4.30-brcm-4_mipsel.ipk"
echo "Installing cifsmount package ..."
       install_package "http://downloads.openwrt.org/whiterussian/rc6/packages/cifsmount_1.5-2_mipsel.ipk"
	echo "</pre></font>"
echo "</body></html>"
exit
fi

if  is_package_installed "kmod-cifs"  &&  is_package_installed "cifsmount"  ; then 


########## Check if first time /etc/config/cifs exists

if [ -s "/etc/config/cifs" ] ; then
echo ""
else
echo "config samba net
	option ip	''
	option pc	''
	option grp	'workgroup'

config samba login
	option usr	'guest'
	option pwd	''

config samba mount
	option share	'smb'
	option mnt	'/mnt'" > /etc/config/cifs
fi

######## Read config

uci_load "cifs"
NET_IP="$CONFIG_net_ip"
NET_PC="$CONFIG_net_pc"
NET_GRP="$CONFIG_net_grp"

LOGIN_USR="$CONFIG_login_usr"
LOGIN_PWD="$CONFIG_login_pwd"

MOUNT_SHARE="$CONFIG_mount_share"
MOUNT_MNT="$CONFIG_mount_mnt"



HEADER="<link rel=stylesheet type=text/css href=/themes/active/webif.css><link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css">
<script type="text/javascript" src="/js/balloontip.js">
</script>"

cat <<EOF
<html>
<head>
$HEADER
</head>

<body bgcolor="#eceeec">
<strong>Status</strong><br><br>
<hr>

EOF

######## Try to map CIFS
if ! empty "$FORM_mapcifs"; then

mount -t cifs //$NET_IP/$MOUNT_SHARE //$MOUNT_MNT -o unc=\\\\$NET_PC\\$MOUNT_SHARE,ip=$NET_IP,user=$LOGIN_USR,pass=$LOGIN_PWD,dom=$NET_GRP

fi

######### Save CIFS
if ! empty "$FORM_save_cifs"; then
echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
echo "<br>saving...."

uci_set "cifs" "net" "ip" "$FORM_smb_ip"
uci_set "cifs" "net" "pc" "$FORM_smb_pc"
uci_set "cifs" "net" "grp" "$FORM_smb_wrkgrp"
uci_set "cifs" "login" "usr" "$FORM_smb_usr"
uci_set "cifs" "login" "pwd" "$FORM_smb_pwd"
uci_set "cifs" "mount" "share" "$FORM_smb_dir"
uci_set "cifs" "mount" "mnt" "$FORM_smb_mnt"
uci_commit "cifs"

exit
fi


####### Check if cifsd is running
if [ "$(ps ax | grep -c cifsd)" = '1' ]; then

cat <<EOF
<div class=warning>Network drive is not mounted.</div><br><br> 
<form method="post" action='$SCRIPT_NAME'>
  <input type="submit" name="mapcifs" value="Map Network Drive">
</form>
<br>
EOF

else
echo "<font color="#33CC00">Network drive is succesfully maped in $MOUNT_MNT</font><br><br>"
fi

cat <<EOF
<strong>Samba Configuration</strong><br>
<br>
<form action='$SCRIPT_NAME' method='post'>
<table width="100%" border="0" cellspacing="1">
  <tr>
  <td colspan="2" height="1"  bgcolor="#333333"></td>
  </tr>
  <tr> 
    <td width="100px"><a href="" rel="b1">IP Address</a></td>
    <td > <input name="smb_ip" type="text" value=$NET_IP></td>
  </tr>
  <tr> 
    <td><a href="" rel="b2">PC name</a></td>
    <td><input name="smb_pc" type="text" value=$NET_PC></td>
  </tr>
  <tr> 
    <td><a href="" rel="b3">Workgroup</a></td>
    <td><input name="smb_wrkgrp" type="text" value=$NET_GRP></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2" height="1"  bgcolor="#333333"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b6">Username</a></td>
    <td><input name="smb_usr" type="text" value=$LOGIN_USR></td>
  </tr>
  <tr> 
    <td><a href="" rel="b7">Password</a></td>
    <td><input name="smb_pwd" type="password" value=$LOGIN_PWD></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr > 
    <td colspan="2" height="1" bgcolor="#333333"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b4">Shared Folder</a></td>
    <td><input name="smb_dir" type="text" value=$MOUNT_SHARE></td>
  </tr>
  <tr> 
    <td><a href="" rel="b5">Mount Path</a></td>
    <td><input name="smb_mnt" type="text" value=$MOUNT_MNT></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><input type="submit" style='border: 1px solid #000000;' name="save_cifs" value="Save"></td>
  </tr>
</table>
</form>

<div id="b1" class="balloonstyle" style="width: 450px;">
An IP address (Internet Protocol address) is a unique address that devices use in order to identify and communicate with each other on a network.<br><br>Example: 192.168.1.5
</div>
<div id="b2" class="balloonstyle" style="width: 450px;">
A Computer Name is a unique name assigned to each computer on a network.<br><br>Example: Tux
</div>
<div id="b3" class="balloonstyle" style="width: 450px;">
Workgroup is a group of computers participating on a network.<br><br>Example: Workgroup
</div>
<div id="b4" class="balloonstyle" style="width: 450px;">
Shared Folder is a directory which can be viewd by any person connected to that client at that time.<br><br>Example: documents/todays
</div>
<div id="b5" class="balloonstyle" style="width: 450px;">
Location on the router to create virtual directory from shared folder<br><br>Example: /mnt
</div>
<div id="b6" class="balloonstyle" style="width: 450px;">
A user in computing context is one who uses a computer system.<br><br>Example: joesmith
</div>
<div id="b7" class="balloonstyle" style="width: 450px;">
A password is a form of secret authentication data that is used to control access to a resource.<br><br>Example: hBjGX56
</div>
</body></html>
EOF

fi
?>