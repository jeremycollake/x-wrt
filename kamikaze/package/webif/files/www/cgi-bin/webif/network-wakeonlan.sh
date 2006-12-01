#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

HOSTS_FILE=/etc/hosts
ETHERS_FILE=/etc/ethers

header "Network" "WoL" "@TR<<Wake-On-LAN>>" ''
ShowNotUpdatedWarning

# check to make sure busybox's etherwake isn't included
! exists "/bin/etherwake" && {
	has_pkgs ether-wake
}
?>
<br />

<?
wokeup=""
empty "$FORM_wakecustom" || {
	validate <<EOF
mac|FORM_mac|Hardware (MAC) address||$FORM_mac
EOF
	mac=$FORM_mac;
}
empty "$FORM_wake" || mac=$FORM_wake;
empty "$ERROR" && [ -n "$mac" ] && {
	if [ -n "$FORM_wolapp" ]; then
		echo "<p>&nbsp;</p><p style=\"background:#ffffc0; color:#c00000; font-weight: bold;\">$FORM_wolapp: ";
		res=`$FORM_wolapp $mac 2>&1`;
		if [ -n "$res" ]; then echo "$res"; else echo "Waking up $mac..."; fi
		echo "</p><p>&nbsp;</p>";
	else
		echo "<p>&nbsp;</p><p  style=\"background:#ffffc0; color:#c00000; font-weight: bold;\">ERROR: No WOL application given! Please make sure you have installed either wol or ether-wake, and you have selected one of them in the form below.</p><p>&nbsp;</p>";
	fi
}
empty $ERROR || { echo "<h3 class=Error>$ERROR</h3>"; }

?>

<form>
<table><tr><th>WOL application:</th><td><select name="wolapp">
<?
	for i in ether-wake wol; do
		[ -n `which $i` ] && {
			echo "<option value=\"$i\" ";
			[ "$i" = "$FORM_wolapp" ] && echo "SELECTED";
			echo ">$i";
		}
	done
?>
</select></td></tr></table>
<table border=1>
<tr><th>Machine</th><th>IP Address</th><th>MAC Address</th><th></th></tr>
<tr><td></td><td></td><td><input type="text" name="mac" value=<?
if [ -n "$FORM_mac" ]; then echo "\"$FORM_mac\""; else echo "\"00:00:00:00:00:00\""; fi ?>
></td><td><button name="wakecustom" type="submit" value="wakecustom">Wake up</button></td></tr>
<?

name_for_ip() {
	grep -e "^[\t ]*$1[\t ]+.*" $HOSTS_FILE | sed 's/^[\t ]*'$1'[\t ]*//'
}

if [ -e /etc/ethers ]; then
	cat $ETHERS_FILE | awk -F ' ' '
	{
		"grep -e "$2" /etc/hosts | sed \"s/^"$2"\w*//\"" | getline hostname;
		print "<tr><td>" hostname "</td><td>" $2 "</td><td>" $1 "</td><td><button name=\"wake\" type=\"submit\" value=\"" $1 "\">Wake up</button></td></tr>";
	}'
fi

?>
</table>
</form>
<br /><br />
<div class="tip">@TR<<wol_help#Here you can send a Wake-On-LAN packet to automatically boot up a computer that is turned off. The computer must support WOL, and the feature needs to be turned on in the BIOS for this to work. Unfortunately, there is no explicit response from that machine, so you do not know whether the waking was successful and the machine is really booting up.>></div>

<? footer ?>
<!--
##WEBIF:name:Network:699:WoL
-->

