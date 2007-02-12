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

if ! empty "$FORM_package"; then
echo "<html><header></header><body>"
	echo "Installing SWAP packages ...<br><br><pre>"
	echo "Installing kmod-loop package ..."
	install_package "kmod-loop"
	echo "Installing losetup package ..."
	install_package "losetup"
	install_package "swap-utils"
exit
fi

if ! empty "$FORM_remove"; then
	echo "<html><header></header><body><font size=3>Removing Swap packages ...<br><br><pre>"
	remove_package "losetup"
	remove_package "kmod-loop"
	remove_package "swap-utils"
	rm /etc/config/swap
	echo "</pre>Done.</font></body></html>"
exit
fi

if  is_package_installed "kmod-loop" && is_package_installed "losetup" &&  is_package_installed "swap-utils" ; then 

########## Check if first time /etc/config/swap exists

if [ -s "/etc/config/swap" ] ; then
echo ""
else
echo "config swap set
	option path	'/tmp'
	option ram	'2000'" > /etc/config/swap
fi

######## Read config

uci_load "swap"
SET_PATH="$CONFIG_set_path"
SET_RAM="$CONFIG_set_ram"

HEADER="<link rel=stylesheet type=text/css href=/themes/active/webif.css>
<script type="text/javascript" src="/js/balloontip.js">
</script>"

cat <<EOF
<html><head>
$HEADER
</head><body bgcolor="#eceeec"><strong>Status</strong><br><br><hr>
EOF

######## Try to map SWAP
if ! empty "$FORM_swapon"; then

dd if=/dev/zero of=/$SET_PATH/swapfile count=$SET_RAM
losetup /dev/loop/0 /$SET_PATH/swapfile
mkswap /dev/loop/0
swapon /dev/loop/0
echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
echo "<br><br>Changing current RAM ..."
exit
fi

if ! empty "$FORM_swapoff"; then
swapoff /dev/loop/0
fi

######### Save SWAP
if ! empty "$FORM_save_swap"; then
echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
echo "<br>saving ..."

uci_set "swap" "set" "path" "$FORM_swap_path"
uci_set "swap" "set" "ram" "$FORM_swap_ram"
uci_commit "swap"
exit
fi

####### Check if swap is running
#if [ "$(ps ax | grep -c loop0)" = '1' ]; then
if [ $(free |grep "Swap" | sed -e s/'Swap:'//g -e s/' '//g) = "000" ]; then
cat <<EOF
<div class=warning>Swap is not mounted.</div><br><br> 
<form method="post" action='$SCRIPT_NAME'>
<input type="submit" name="swapon" value="Swap RAM">
</form><br>
EOF

else
echo "<form method="post" action='$SCRIPT_NAME'><font color="#33CC00"><br>Swap is succesfully maped in $SET_PATH</font>&nbsp;&nbsp;<input type="submit" name="swapoff" value="UnSwap RAM"></form><br><br>"
fi

cat <<EOF
<strong>Swap Configuration</strong><br>
<br>
<form action='$SCRIPT_NAME' method='post'>
<table width="100%" border="0" cellspacing="1">
<tr>
<td colspan="2" height="1"  bgcolor="#333333"></td></tr>
<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td width="200px">&nbsp;<a href="#" rel="b1">Swap file Location:</a></td>
<td><input name="swap_path" type="text" value=$SET_PATH></td></tr>
<tr><td width="200px">&nbsp;<a href="#" rel="b2">Size (blocks):</a></td>
<td><input name="swap_ram" type="text" value=$SET_RAM></td></tr>
<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>&nbsp;</td>
<td><input type="submit" style='border: 1px solid #000000;' name="save_swap" value="Save"></td>
</tr></table></form>

<div id="b1" class="balloonstyle" style="width: 250px;">
Location where swap file will be stored.<br><br>Example: /mnt
</div>
<div id="b2" class="balloonstyle" style="width: 450px;">
Size in blocks: 1000 blocks = 512 Kbytes | 1 Megabyte = 2000 blocks
</div>
</body></html>
EOF

fi
?>