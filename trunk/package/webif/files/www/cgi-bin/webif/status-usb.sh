#!/usr/bin/webif-page
<?
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
#
. /usr/lib/webif/webif.sh
header "Status" "USB" "USB Devices"
?>
<table style="width: 90%; " border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>

	<tr><th><b>All connected devices (excluding system hubs)</b></th></tr>
	<tr><td><table cellpadding="10" cellspacing="10" align="left" border="0">
	<col style=\"text-align:center;\"><col align=center><col><col><col align=center><col align=center>
	<tr><th>Bus</th><th>Device</th><th>Product</th><th>Manufacturer</th><th>VendorID:ProdID</th><th>USB version</th></tr>
	<?
	[ -f /proc/bus/usb/devices ] && grep -e "^[TDPS]:" /proc/bus/usb/devices | sed 's/[[:space:]]*=[[:space:]]*/=/g' | sed 's/[[:space:]]\([^ |=]*\)=/|\1=/g' | sed 's/^/|/' | awk '
	BEGIN { i=0; RS="|"; FS="=";}
	$1 ~ /^T: / { i++; }
	$1 ~ /^Bus/ { bus[i]=$2; }
	$1 ~ /^Dev#/ { device[i]=$2; }
	$1 ~ /^Ver/ { usbversion[i]=$2; }
	$1 ~ /^Vendor/ { vendorID[i]=$2; }
	$1 ~ /^ProdID/ { productID[i]=$2; }
	$1 ~ /^Manufacturer/ { manufacturer[i]=$2; }
	$1 ~ /^Product/ { product[i]=$2; }
	END {
		for ( j=1; j<=i; ++j ) {
			vpID=vendorID[j]":"productID[j];
			if ( length(product[j])<1 && vpID != "0000:0000" ) {
				"[ -n \"`which lsusb`\" ] && lsusb -d "vpID" | sed \"s/^.*"vpID" //\"" | getline product[j];
			}
			if ( length(manufacturer[j])<1 && productID[j]!="0000" ) {
				pid=vendorID[j];
				"[ -f /usr/share/usb.ids ] && grep -e \"^"pid"\" /usr/share/usb.ids | sed \"s/^"pid" *//\"" | getline manufacturer[j];
			}
			if ( vpID != "0000:0000" ) {
				print "<tr><td>" bus[j] "</td><td>" device[j] "</td><td>" product[j] "</td><td>" manufacturer[j] "</td><td>" vpID "</td><td>" usbversion[j] "</td></tr>";
			}
		}
	}
	'
?></table></td>
	</tr>
	<tr><td><br /><br /></td></tr>

	<tr>
		<th><b>Mounted USB / SCSI devices</b></th>
	</tr>
	<tr>
		<td><pre><? mount | grep /dev/scsi/  ?></pre></td>
	</tr>

	<tr><td><br /><br /></td></tr>
	<tr>

	<tr>
		<th><b>Loaded USB drivers</b></th>
	</tr>
	<tr>
		<td><pre><? [ -f /proc/bus/usb/drivers ] && cat /proc/bus/usb/drivers ?></pre></td>
	</tr>

	<tr><td><br /><br /></td></tr>

</tbody>
</table>

<? footer ?>
<!--
##WEBIF:name:Status:454:USB
-->

