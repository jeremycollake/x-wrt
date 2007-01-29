#!/usr/bin/webif-page
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!
. "/usr/lib/webif/functions.sh"


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



HEADER="<link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css">
<script type="text/javascript" src="/js/balloontip.js">
</script>"

cat <<EOF
<html>
<head>
$HEADER
</head>

<body bgcolor="#eceeec">
<strong>Samba Configuration</strong><br><hr><br>
EOF

if [ "$(ps ax | grep -c cifsd)" = '1' ]; then
echo "no"
else
echo "yes"
fi

cat <<EOF
<table width="100%" border="0" cellspacing="1">
  <tr> 
    <td width="100px"><a href="" rel="b1">IP Address</a></td>
    <td > <input type="text" name="textfield"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b2">PC name</a></td>
    <td><input type="text" name="textfield2"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b3">Workgroup</a></td>
    <td><input type="text" name="textfield3"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b4">Shared Folder</a></td>
    <td><input type="text" name="textfield4"></td>
  </tr>
  <tr> 
    <td><a href="" rel="b5">Mount Path</a></td>
    <td><input type="text" name="textfield5"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><input type="submit" style='border: 1px solid #000000;' name="Submit" value="Save"></td>
  </tr>
</table>

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
</body></html>
EOF

fi
?>