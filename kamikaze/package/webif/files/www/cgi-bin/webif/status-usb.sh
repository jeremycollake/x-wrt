#!/usr/bin/webif-page
<?
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
#
. /usr/lib/webif/webif.sh
header "Status" "USB" "@TR<<USB Devices>>"

display_form <<EOF
start_form|@TR<<All connected devices (excluding system hubs)>>
EOF
?>
<table>
<tbody>	
	<tr><td><table cellpadding="10" cellspacing="10" align="left" border="0">	
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
?>
</tbody>
</table>

<?
display_form <<EOF
end_form
start_form|@TR<<Mounted USB / SCSI devices>>
EOF
?>

<table>
<tbody>
	<tr>
		<td><pre><? mount | grep /dev/scsi/  ?></pre></td>
	</tr>

</tbody>
</table>

<?
display_form <<EOF
end_form
start_form|@TR<<Loaded USB drivers>>
EOF
?>

<table>
<tbody>
	<tr>
		<td><pre><? [ -f /proc/bus/usb/drivers ] && cat /proc/bus/usb/drivers ?></pre></td>
	</tr>

	<tr><td><br /><br /></td></tr>
</tbody>
</table>

<?
display_form <<EOF
end_form
EOF

footer ?>
<!--
##WEBIF:name:Status:454:USB
-->

