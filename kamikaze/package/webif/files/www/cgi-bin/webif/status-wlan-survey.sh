#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
############ KAMIKAZE ONLY #####################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Dmytro Dykhman <dmytro@iroot.ca>
#
# TODO:
#   I originally wrote this before I had bothered to learn much about
#   awk, so it uses 'pure' shell scripting. It would be much simpler
#   and probably more efficient to use awk. Maybe recode someday, but
#   why fix what's isn't broken...
#

##### Variables

MAX_TRIES=4
MAX_CELLS=100
Wimg=0
var1=0
color=0
counter=0
current=1
tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)
tempscan=$(mktemp /tmp/.survscan.XXXXXX)

LoadSettings()
{
################ CODE DIRECTLY FROM network-wlan.sh (r2620) ###########

# Parse Settings, this function is called when doing a config_load
config_cb() {
config_get TYPE "$CONFIG_SECTION" TYPE
case "$TYPE" in
        wifi-device)
                append DEVICES "$CONFIG_SECTION"
        ;;
        wifi-iface)
                append vface "$CONFIG_SECTION" "$N"
        ;;
        interface)
	        append network_devices "$CONFIG_SECTION"
        ;;
esac
}
uci_load network
NETWORK_DEVICES="none $network_devices"
uci_load wireless

#FIXME: uci_load bug
#uci_load will pass the same config twice when there is a section to be added by using uci_add before a uci_commit happens
#we will use uniq so we don't try to parse the same config section twice.
vface=$(echo "$vface" |uniq)

vcfg_number=$(echo "$DEVICES $N $vface" |wc -l)
let "vcfg_number+=1"
#####################################################################
}

if ! empty "$FORM_install_nas"; then

	echo "Installing NAS package ...<pre>"
	install_package "nas"
	echo "</pre>"
	echo "<META http-equiv="refresh" content='5;URL=$SCRIPT_NAME'>"
exit
fi
######## Join WIFI ########

if [ "$FORM_joinwifi" != "" ]; then

	for vcfg in $vface; do
	let "counter+=1"
	done

	if [ "$FORM_wepkey" != "" ] ; then wkey=$FORM_wepkey; elif [ "$FORM_pskkey" != "" ] ; then wkey=$FORM_pskkey; elif [ "$FORM_psk2key" != "" ] ; then wkey=$FORM_psk2key; elif [ "$FORM_wpakey" != "" ] ; then wkey=$FORM_wpakey; elif [ "$FORM_wpa2key" != "" ] ; then wkey=$FORM_wpa2key; fi
	if [ "$FORM_wpaip" != "" ] ; then wip=$FORM_wpaip; elif [ "$FORM_wpa2ip" != "" ] ; then wip=$FORM_wpa2ip; fi
	if [ "$FORM_wpaport" != "" ] ; then wprt=$FORM_wpaport; elif [ "$FORM_wpa2port" != "" ] ; then wprt=$FORM_wpa2port; fi


if [ "$FORM_wlmode" = "repeater" ]; then
	if [ $counter = "1" ] ; then
	##################################
	# Add Virtual Interface
	uci_add "wireless" "wifi-iface" ""
	fi

	LoadSettings

	for vcfg in $vface; do
		config_get FORM_device $vcfg device

		if [ "$vcfg" = "cfg2" ]; then
			uci_set "wireless" "$vcfg" "mode" "sta"
			uci_set "wireless" "$vcfg" "ssid" "$FORM_wifi"
			uci_set "wireless" "$vcfg" "network" "lan"
				if [ "$wkey" != "" ]; then
					uci_set "wireless" "$vcfg" "encryption" "$FORM_keytype"
					uci_set "wireless" "$vcfg" "server" "$wip"
					uci_set "wireless" "$vcfg" "port" "$wprt"
					uci_set "wireless" "$vcfg" "key" "$wkey"
				else
					uci_set "wireless" "$vcfg" "encryption" "none"
					uci_set "wireless" "$vcfg" "server" ""
					uci_set "wireless" "$vcfg" "port" ""
					uci_set "wireless" "$vcfg" "key" ""
				fi
		fi

		if [ "$vcfg" = "cfg3" ]; then # - set second virtual adapter as AP
			uci_set "wireless" "$vcfg" "device" "$( echo $DEVICES | awk '{ print $1  }')"
			uci_set "wireless" "$vcfg" "mode" "ap"
			uci_set "wireless" "$vcfg" "ssid" "$FORM_new_ssid"
			uci_set "wireless" "$vcfg" "hidden" "0"
			uci_set "wireless" "$vcfg" "network" "lan"
		fi
	done
else
	for vcfg in $vface; do
		config_get FORM_device $vcfg device

		if [ "$FORM_virtual_wl" = "$vcfg" ]; then # - do it for selected virtual adapter
			uci_set "wireless" "$vcfg" "mode" "sta"
			uci_set "wireless" "$vcfg" "ssid" "$FORM_wifi"
			uci_set "wireless" "$vcfg" "network" "lan"
				if [ "$wkey" != "" ]; then
					uci_set "wireless" "$vcfg" "encryption" "$FORM_keytype"
					uci_set "wireless" "$vcfg" "server" "$wip"
					uci_set "wireless" "$vcfg" "port" "$wprt"
					uci_set "wireless" "$vcfg" "key" "$wkey"
				else
					uci_set "wireless" "$vcfg" "encryption" "none"
					uci_set "wireless" "$vcfg" "server" ""
					uci_set "wireless" "$vcfg" "port" ""
					uci_set "wireless" "$vcfg" "key" ""
				fi
		fi
	done
	
	#iwconfig wl0 mode "repeater"
	iwconfig wl0 essid "$FORM_wifi"
fi

uci_commit "wireless"
	echo "<br/><b>Successfully joined \"$FORM_wifi\" network...</b><br/><br/>"

	if [ "$FORM_wlmode" = "repeater" ]; then 
	cat <<EOF
	<center><table border="0" cellspacing="1" bgcolor="#000000">
	<tr bgcolor='#FFFF00'><td><img src="/images/wep.gif" alt />&nbsp;You can set Security Settings for new SSID: "$FORM_new_ssid" in <b>Network > Wireless</b></td></tr>
	</table></center>
EOF
	fi
	footer
	sleep 6
	killall nas >&- 2>&- && sleep 2
	(
		/sbin/wifi
		[ -f /etc/init.d/S41wpa ] && /etc/init.d/S41wpa
	) >&- 2>&- <&-

	exit
fi #<- end if Join WIFI

DisplayTable()
{
cat <<EOF
<script type="text/javascript" src="/js/window.js"></script>
<script type="text/javascript" src="/js/forms.js"></script>

<script type="text/javascript">
function java1(target,sec) {
document.keyform0.network.value = sec 
document.keyform0.wifi.value = target 
document.keyform1.network.value = sec 
document.keyform1.wifi.value = target 

if ( sec == "enc" ) {
document.keyform0.img1.src = "/images/wep.gif"
document.keyform1.img1.src = "/images/wep.gif"
}else{
document.keyform0.img1.src = "/images/opn.gif"
document.keyform1.img1.src = "/images/opn.gif"
}
}
window.onload = function() {
setupDependencies('keyform0','keyform1');
}
</script>
EOF

##### Check if NAS installed
nas_installed="0"
ipkg list_installed | grep -q nas
equal "$?" "0" && nas_installed="1"

##### DIV window common header
DIVWINDOW()
{
cat <<EOF
<div id="dwindow$var1" style="position:absolute;background-color:#EBEBEB;cursor:hand;left:0px;top:0px;display:none;border: 1px solid black" onMousedown="initializedrag(event)" onMouseup="stopdrag()" >
<table width='100%' border='0' ><tr bgcolor=navy><td><div align='right'><img src="/images/close.gif" onClick="closeit()" alt /></div></td>
</tr></table>
<table style="height: 100%; width: 100%" border='0'>
<tr><td valign='top'>
<form action='$SCRIPT_NAME' method='post' name='keyform$var1'>
<input type='hidden' name='wifi' value="" />
<input type='hidden' name='network' value="" />
<table width='100%' border='0' >
<tr><td width=120><img src="" name="img1" alt /></td><td></td></tr>
<tr><td align='right'>Mode:</td>
<td><label><select name='wlmode' STYLE='width: 150px'>
<option value='client' selected>Client</option>
<option value='repeater'>Repeater</option>
</select></label></td></tr>
EOF

if ! equal "$nas_installed" "1"; then
echo "<tr><td colspan=2><font color=red>Repeater mode requires NAS package.</font><input type='submit' name='install_nas' value='@TR<<Install NAS>>' ></td>"
else echo "<tr><td align='right' height=1><label>SSID:<input type='hidden' class=\"DEPENDS ON wlmode BEING repeater\"></label></td>
<td height=1><label><input type='text' name='new_ssid' class=\"DEPENDS ON wlmode BEING repeater\"></label>
</td></tr>"
fi

echo "<tr><td align='right' height=1><label>Interface:<input type='hidden' class=\"DEPENDS ON wlmode BEING client\"></label></td><td><label><select name='virtual_wl' STYLE=\"width: 150px\">"
counter=0
        for vcfg in $vface; do
       		config_get FORM_device $vcfg device
       	echo "<option value='$vcfg'>Virtual Adapter $counter</option>"
		let "counter+=1"
	done
echo "</select><input type='hidden' class=\"DEPENDS ON wlmode BEING client\"></label></td></tr>"
}
DIVWINDOWFOOTER="<tr><td></td><td><br/><input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join Network>>' /></td></tr></table></form></td></tr></table></div>"

var1=0 ; DIVWINDOW
echo $DIVWINDOWFOOTER

var1=1 ; DIVWINDOW
cat <<EOF
<tr><td align="right">Key Type:</td>
<td><select name="keytype" STYLE="width: 150px">
<option value="wep" selected>WEP</option>
<option value="psk">WPA (PSK)</option>
<option value="psk2">WPA2 (PSK)</option>
<option value="wpa">WPA (RADIUS)</option>
<option value="wpa2">WPA2 (RADIUS)</option>
</select><br/></td></tr>

<tr><td align="right">
<label>WEP Key:<input type="hidden" class="DEPENDS ON keytype BEING wep"></label>
<label>WPA Key:<input type="hidden" class="DEPENDS ON keytype BEING psk"></label>
<label>WPA2 Key:<input type="hidden" class="DEPENDS ON keytype BEING psk2"></label>
<label>RADIUS IP:<br/>Port:<br/>Key:<input type="hidden" class="DEPENDS ON keytype BEING wpa"></label>
<label>RADIUS IP:<br/>Port:<br/>Key:<input type="hidden" class="DEPENDS ON keytype BEING wpa2"></label></td>
<td><label><input type="text" name="wepkey" class="DEPENDS ON keytype BEING wep"></label>
<label><input type="text" name="pskkey" class="DEPENDS ON keytype BEING psk"></label>
<label><input type="text" name="psk2key" class="DEPENDS ON keytype BEING psk2"></label>
EOF

	if ! equal "$nas_installed" "1"; then
		echo "<label><font color=red>RADIUS requires NAS package.</font><input type='submit' name='install_nas' value='@TR<<Install NAS>>' class=\"DEPENDS ON keytype BEING wpa\"></label>"
	else
cat <<EOF
<label><input type="text" name="wpaip" class="DEPENDS ON keytype BEING wpa"></label>
<label><input type="text" name="wpaport" class="DEPENDS ON keytype BEING wpa"></label>
<label><input type="text" name="wpakey" class="DEPENDS ON keytype BEING wpa"></label>
EOF
	fi

cat <<EOF
<label><input type="text" name="wpa2ip" class="DEPENDS ON keytype BEING wpa2"></label>
<label><input type="text" name="wpa2port" class="DEPENDS ON keytype BEING wpa2"></label>
<label><input type="text" name="wpa2key" class="DEPENDS ON keytype BEING wpa2"></label>
</td></tr>
EOF

echo $DIVWINDOWFOOTER

cat <<EOF
<br/><a href='$SCRIPT_NAME'>@TR<<Re-scan>></a><br/><br/><table width="98%" border="0" cellspacing="1" bgcolor="#999999" >
<tr class="wifiscantitle" >
<td width='32'>@TR<<Signal>>/</td>
<td width='32'>@TR<<Noise>></td>
<td>@TR<<Status>></td>
<td>@TR<<SSID>></td>
<td>@TR<<MAC>></td>
<td width='20'>@TR<<Channel>></td>
<td>@TR<<Rate>></td>
<td>&nbsp;</td></tr>
EOF
}

DisplayTR()
{
if [ "$color" = "1" ] ; then color="2" ; else color="1" ; fi

echo "<tr bgcolor="#FFFFFF" class="wifiscanrow$color">"

##### Signal Ratio

if [ $RSSI -lt 60 ]; then Wimg=5 ; elif [ $RSSI -lt 72 ]; then Wimg=4 ; elif [ $RSSI -lt 81 ]; then Wimg=3 ; elif [ $RSSI -lt 85 ]; then Wimg=2 ; elif [ $RSSI -lt 92 ]; then Wimg=1 ; else Wimg=0 ; fi
echo "<td><center><img src="/images/wifi$Wimg.gif" ALT='-" $RSSI "dBm' /></center></td>"

##### Noise Ratio
if [ $NOISE -gt 95 ]; then Wimg=0 ; elif [ $NOISE -gt 92 ]; then Wimg=1 ; elif [ $NOISE -gt 88 ]; then Wimg=2 ; elif [ $NOISE -gt 85 ]; then Wimg=3 ; elif [ $NOISE -gt 80 ]; then Wimg=4 ; else Wimg=5 ; fi
echo "<td><center><img src="/images/wifi$Wimg.gif" ALT='-" $NOISE "dBm' /></center></td>"

##### Security
if  [ "$SEC" = "ESS WEP" ] || [ "$SEC" = "on" ] ; then Wimg="wep" ; else Wimg="opn" ; fi

echo "<td><center><img src="/images/$Wimg.gif" ALT='$SEC' /></center></td>"
echo "<td>&nbsp;&nbsp;" $SSID
#echo "$current_line" | cut -c8-20 | cut -d '"' -f1
echo "</td>"
echo "<td><center>" $BSSID "</center></td>"
echo "<td><center>" $CHANNEL "</center></td>"

##### Speed (needs improvements!)
if  [ "$RATE" = "66" ] ; then Wimg="54 Mbps" ; elif  [ "$RATE" = "75" ] ; then Wimg="54 Mbps" ; elif  [ "$RATE" = "44" ] ; then Wimg="11 Mbps" ; else Wimg="(?)" ; fi

echo "<td><center>$Wimg</center></td>"
echo "<td><center>"

	if  [ "$SEC" = "ESS WEP" ] || [ "$SEC" = "on" ] ; then
		echo "<input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join>>' onClick=\"loadwindow(1,'$SCRIPT_NAME/?wep=1&ssid=$SSID',300,260,0,0);java1('$SSID','enc')\" />"
	else
		echo "<input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join>>' onClick=\"loadwindow(0,'$SCRIPT_NAME/?wep=1&ssid=$SSID',300,160,0,0);java1('$SSID','opn')\" />"
	fi
echo "</center>$_JSload</td></tr>"
}

######################### The Scanning Part >

##### wl scanning #######
	WLSCAN(){
	counter=0
		for counter in $(seq 1 $MAX_TRIES); do
			wl scan 2> /dev/null
			wl scanresults > $tempscan 2> /dev/null
			if equal $(sed '2,$ d' $tempscan | cut -c0-4) "SSID" ; then break ; fi
			sleep 1
		done
		#-------------------------
		# We need to add a "break" on the first line!

		current_line=$(grep -i '' < $tempscan)
		echo "" > $tempfile
		echo "$current_line" >> $tempfile
		rm $tempscan 2> /dev/null
		#------------------------
	}
WL()
{
	Dopurge ()
	{
		sed 1d < $tempfile > $tempfile2
		rm $tempfile 2> /dev/null
		mv $tempfile2 $tempfile     
	}
	

if [ $counter -gt $MAX_TRIES ]; then
	echo "<tr><td>@TR<<Sorry, no scan results.>></td></tr>"
else
	DisplayTable

# Read File
#------------------------

while read f
do

# DEBUG
#------\/
#echo $f "<br/>"

current_line=$(sed '2,$ d' $tempfile)

#echo "-> '" $current_line "'<br/>"

if equal "$current_line" "" ; then
	let "current=1"
	#echo "->" $current
else
	let "current=0"		
fi

if equal "$current" "1" ;then

Dopurge

current_line=$(sed '2,$ d' $tempfile)

if equal "$current_line" "" ;then
echo ""
else

##### Set Variables
#current_line=$(sed '2,$ d' $tempfile)
SSID=$(sed '2,$ d' $tempfile | sed -e s/'SSID: '//g -e s/'"'//g)
Dopurge
RSSI=$(sed '2,$ d' $tempfile | cut -c22-23)
NOISE=$(sed '2,$ d' $tempfile | cut -c37-38)
CHANNEL=$(sed '2,$ d' $tempfile  | cut -c53-55 )
Dopurge
BSSID=$(sed '2,$ d' $tempfile  | cut -c7-24 )
SEC=$(sed '2,$ d' $tempfile  | cut -c38-44 )
Dopurge
RATE=$(sed '2,$ d' $tempfile  | wc -c)
#RATED=$(sed '2,$ d' $tempfile)

DisplayTR

fi
fi

Dopurge

done < $tempfile

rm $tempfile 2> /dev/null
rm $tempfile2 2> /dev/null
echo "</table><br/><a href='$SCRIPT_NAME'>@TR<<Re-scan>></a><br/>"
fi
}

######### iwlist scanning #######
	IWLISTSCAN()
	{
		counter=0
		for counter in $(seq 1 $MAX_TRIES); do
			iwlist scan > $tempfile 2> /dev/null
			grep -i "Address" < $tempfile >> /dev/null
			equal "$?" "0" && break
			sleep 1
		done
	}
IWLIST()
{
found_networks=0
first_hit=1

if [ $counter -gt $MAX_TRIES ]; then
        echo "<tr><td>@TR<<Sorry, no scan results.>></td></tr>"
else
	DisplayTable

        current=0
        counter=0

        for counter in $(seq 1 $MAX_CELLS); do

                current_line=$(sed '2,$ d' < $tempfile)
                empty "$current_line" && break
                # line must contain both "Cell" and "Address" to be considered
                #  start of a new cell..
                echo "$current_line" | grep "Cell" >> /dev/null
                result_one=$?
                echo "$current_line" | grep "Address" >> /dev/null
                result_two=$?
                if equal "$result_one" "0" && equal "$result_two" "0" ; then
                        if equal "$first_hit" "0" ; then
                                let "current+=1"
                        fi
                        first_hit=0
                fi
                if equal "$first_hit" "0" ; then
                        echo "$current_line" >> "$tempfile"_"${current}"
                fi

                sed 1d < $tempfile > $tempfile2
                rm $tempfile 2> /dev/null
                mv $tempfile2 $tempfile
        done

        current=0
        counter=0
        for counter in $(seq 1 $MAX_CELLS); do
                ! exists "$tempfile"_"${current}" && break
                ####################################################
                # parse out MAC
                address_pre=$(sed '2,$ d' < "$tempfile"_"${current}" | sed -e s/'Cell'//g -e s/'Address'//g -e s/'-'//g)
                count=0
                for i in $address_pre; do
                        case $count in
                                0) CELL_ID=$i;;
                                2) BSSID=$i;;
                                3) break;;
                        esac
                        let "count+=1"
                done
################################

SSID=$(grep -i "ESSID" < "$tempfile"_"${current}" | sed -e s/'ESSID:'//g  -e s/'"'//g | awk '{ print $1 }' )

CHANNEL=$(grep -i "Channel:" < "$tempfile"_"${current}" | sed -e s/'Channel:'//g -e s/' '//g)
if equal $CHANNEL "" ; then CHANNEL=$(grep -i "Frequency:" < "$tempfile"_"${current}" | awk '{ print $4  }' | sed -e s/')'//g ) ; fi
	
	quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality'//g -e s/'Signal level'//g  -e s/'dBm'//g -e s/'Noise level'//g -e s/'-'//g -e s/'='//g -e s/':'//g)
                count=0
	for i in $quality_pre; do
		case $count in
			0) QUALITY=$i;;
			1) RSSI=$i;;
			2) NOISE=$i
			break;;
		esac
			let "count+=1"
	done

SEC=$(grep -i "Encryption key" < "$tempfile"_"${current}" | sed -e s/'Encryption key:'//g | awk '{ print $1 }')
RATE=1

DisplayTR

rm -f "$tempfile"_"${current}"
let "found_networks+=1"
let "current+=1"
done

echo "</table><br/><a href='$SCRIPT_NAME'>@TR<<Re-scan>></a><br/>"

fi #<- end if were scan results

rm $tempfile 2> /dev/null
rm $tempfile2 2> /dev/null

}
	if is_package_installed "wl" ; then #<- for Broadcom units where iwlist is broken
		WLSCAN
	else	IWLISTSCAN
	fi

	pagesize=$(grep -i -c "dbm" < $tempfile)
	LoadSettings
	header "Status" "Site Survey" "<img src='/images/wscan.jpg' alt />&nbsp;@TR<<Wireless survey>>" '' '' "$pagesize"

	if is_package_installed "wl" ; then WL
	else	IWLIST ; fi

footer ?>
<!--
##WEBIF:name:Status:980:Site Survey
-->