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
############### CODE DIRECTLY FROM network-wlan.sh (r2620) ###########

# Parse Settings, this function is called when doing a config_load
config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
	        wifi-device)
	                append DEVICES "$cfg_name"
	        ;;
	        wifi-iface)
	                append vface "$cfg_name" "$N"
	        ;;
	        interface)
		        append network_devices "$cfg_name"
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
}
###### Common HTML controls
HTML_option(){
echo "<option value='$1' $3>$2</option>"
}
HTML_label(){
if [ $2 == 0 ] ; then type="hidden" ; else type="text" ; fi
echo "<label>$1<input type='$type' name='$5' class='DEPENDS ON $4 BEING $3'></label>"
}

DisplayTable()
{
	DST1="document.keyform0"
	DST2="document.keyform1"
	DST3="<script type='text/javascript'"
cat <<EOF
$DST3 src="/js/window.js"></script>
$DST3 src="/js/forms.js"></script>
$DST3>
function java1(target,sec) {
$DST1.network.value = sec 
$DST1.wifi.value = target 
$DST2.network.value = sec 
$DST2.wifi.value = target 

if ( sec == "enc" ) {
$DST1.img1.src = "/images/wep.gif"
$DST2.img1.src = "/images/wep.gif"
}else{
$DST1.img1.src = "/images/opn.gif"
$DST2.img1.src = "/images/opn.gif"
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
<tr><td align='right'>@TR<<status_wlan_survey_Mode#Mode:>></td>
<td><label><select name='wlmode' STYLE='width: 150px'>
EOF
HTML_option "client" "@TR<<status_wlan_survey_Client#Client>>"
HTML_option "repeater" "@TR<<status_wlan_survey_Repeater#Repeater>>"
echo "</select></label></td></tr>"

if ! equal "$nas_installed" "1"; then
echo "<tr><td colspan=2><font color=red>@TR<<status_wlan_survey_NAS_required#Repeater mode requires NAS package.>></font><input type='submit' name='install_nas' value='@TR<<Install NAS>>' ></td>"
else echo "<tr><td align='right' height=1><label>SSID:<input type='hidden' class=\"DEPENDS ON wlmode BEING repeater\"></label></td>
<td height=1><label><input type='text' name='new_ssid' class=\"DEPENDS ON wlmode BEING repeater\"></label>
</td></tr>"
fi

echo "<tr><td align='right' height=1><label>@TR<<status_wlan_survey_Interface#Interface:>><input type='hidden' class=\"DEPENDS ON wlmode BEING client\"></label></td><td><label><select name='virtual_wl' STYLE=\"width: 150px\">"
counter=0
        for vcfg in $vface; do
       		config_get FORM_device $vcfg device
       	echo "<option value='$vcfg'>@TR<<status_wlan_survey_Virtual_Adapter#Virtual Adapter>> $counter</option>"
		let "counter+=1"
	done
echo "</select><input type='hidden' class=\"DEPENDS ON wlmode BEING client\"></label></td></tr>"
}
DIVWINDOWFOOTER="<tr><td></td><td><br/><input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join Network>>' /></td></tr></table></form></td></tr></table></div>"

var1=0 ; DIVWINDOW
echo $DIVWINDOWFOOTER

var1=1 ; DIVWINDOW
	echo "<tr><td align='right'>@TR<<status_wlan_survey_Key_Type#Key Type:>></td><td><select name='keytype' STYLE='width: 150px'>"
	HTML_option "wep" "WEP"
	HTML_option "psk" "WPA (PSK)"
	HTML_option "psk2" "WPA2 (PSK)"
	HTML_option "wpa" "WPA (RADIUS)"
	HTML_option "wpa2" "WPA2 (RADIUS)"
	echo "</select><br/></td></tr><tr><td align='right'>"

	HTML_label "@TR<<status_wlan_survey_WEP_Key#WEP Key:>>" 0 "wep" "keytype"
	HTML_label "@TR<<status_wlan_survey_WPA_Key#WPA Key:>>" 0 "psk" "keytype"
	HTML_label "@TR<<status_wlan_survey_WPA2_Key#WPA2 Key:>>" 0 "psk2" "keytype"
	HTML_label "@TR<<status_wlan_survey_RADIUS_IP_Port_Key#RADIUS IP:<br/>Port:<br/>Key:>>" 0 "wpa" "keytype"
	HTML_label "@TR<<status_wlan_survey_RADIUS_IP_Port_Key#RADIUS IP:<br/>Port:<br/>Key:>>" 0 "wpa2" "keytype"
	echo "</td><td>"
	HTML_label "" 1 "wep" "keytype" "wepkey"
	HTML_label "" 1 "psk" "keytype" "pskkey"
	HTML_label "" 1 "psk2" "keytype" "psk2key"

	if ! equal "$nas_installed" "1"; then
		echo "<label><font color=red>@TR<<status_wlan_survey_NAS_required_by_RADIUS#RADIUS requires NAS package.>></font><input type='submit' name='install_nas' value='@TR<<Install NAS>>' class=\"DEPENDS ON keytype BEING wpa\"></label>"
	else	HTML_label "" 1 "wpa" "keytype" "wpaip"
		HTML_label "" 1 "wpa" "keytype" "wpaport"
		HTML_label "" 1 "wpa" "keytype" "wpakey"
	fi

	HTML_label "" 1 "wpa2" "keytype" "wpa2ip"
	HTML_label "" 1 "wpa2" "keytype" "wpa2port"
	HTML_label "" 1 "wpa2" "keytype" "wpa2key"
	echo "</td></tr>"
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

echo "<tr bgcolor='#FFFFFF' class='wifiscanrow$color' align='center'>"

##### Signal Ratio

if [ $RSSI -lt 60 ]; then Wimg=5 ; elif [ $RSSI -lt 72 ]; then Wimg=4 ; elif [ $RSSI -lt 81 ]; then Wimg=3 ; elif [ $RSSI -lt 85 ]; then Wimg=2 ; elif [ $RSSI -lt 92 ]; then Wimg=1 ; else Wimg=0 ; fi
echo "<td><img src="/images/wifi$Wimg.gif" ALT='-" $RSSI "dBm' /></td>"

##### Noise Ratio
if [ $NOISE -gt 95 ]; then Wimg=0 ; elif [ $NOISE -gt 92 ]; then Wimg=1 ; elif [ $NOISE -gt 88 ]; then Wimg=2 ; elif [ $NOISE -gt 85 ]; then Wimg=3 ; elif [ $NOISE -gt 80 ]; then Wimg=4 ; else Wimg=5 ; fi
echo "<td><img src="/images/wifi$Wimg.gif" ALT='-" $NOISE "dBm' /></td>"

##### Security
if  [ "$SEC" = "ESS WEP" ] || [ "$SEC" = "on" ] ; then Wimg="wep" ; else Wimg="opn" ; fi

echo "<td><img src="/images/$Wimg.gif" ALT='$SEC' /></td>"
echo "<td align='left'>&nbsp;&nbsp;" $SSID "</td>"
echo "<td>" $BSSID "</td>"
echo "<td>" $CHANNEL "</td>"

##### Speed (needs improvements!)
if  [ "$RATE" = "66" ] || [ "$RATE" = "75" ]; then Wimg="54 Mbps"; elif  [ "$RATE" = "44" ]; then Wimg="11 Mbps"; else Wimg="(?)"; fi

	echo "<td>$Wimg</td><td>"

	if  [ "$SEC" = "ESS WEP" ] || [ "$SEC" = "on" ] ; then
		echo "<input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join>>' onClick=\"loadwindow(1,'$SCRIPT_NAME/?wep=1&ssid=$SSID',300,260,0,0);java1('$SSID','enc')\" />"
	else	echo "<input type='submit' class='flatbtn' name='joinwifi' value='@TR<<Join>>' onClick=\"loadwindow(0,'$SCRIPT_NAME/?wep=1&ssid=$SSID',300,160,0,0);java1('$SSID','opn')\" />"
	fi
	echo $_JSload"</td></tr>"
}
############# The Scanning Part >
ScanResults="<tr><td>@TR<<Sorry, no scan results.>></td></tr>"

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
WL(){
	Dopurge (){
		sed 1d < $tempfile > $tempfile2
		rm $tempfile 2> /dev/null
		mv $tempfile2 $tempfile     
	}
	

if [ $counter -gt $MAX_TRIES ]; then
	echo $ScanResults
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

if ! equal "$current_line" "" ;then

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
	IWLISTSCAN(){
		counter=0
		for counter in $(seq 1 $MAX_TRIES); do
			iwlist scan > $tempfile 2> /dev/null
			grep -i "Address" < $tempfile >> /dev/null
			equal "$?" "0" && break
			sleep 1
		done
	}
IWLIST(){
found_networks=0
first_hit=1

if [ $counter -gt $MAX_TRIES ]; then
        echo $ScanResults
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
################

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

###########################################
if ! empty "$FORM_install_nas"; then

	echo "@TR<<status_wlan_survey_Installing_NAS#Installing NAS package ...>><pre>"
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
	#######################
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
	echo "<br/><b>@TR<<status_wlan_survey_Successfully_joined#Successfully joined>> \"$FORM_wifi\" @TR<<status_wlan_survey_network#network...>></b><br/><br/>"

	if [ "$FORM_wlmode" = "repeater" ]; then 
	cat <<EOF
	<center><table border="0" cellspacing="1" bgcolor="#000000">
	<tr bgcolor='#FFFF00'><td><img src="/images/wep.gif" alt />@TR<<status_wlan_survey_Set_Security#&nbsp;You can set Security Settings for new SSID:>> "$FORM_new_ssid" @TR<<status_wlan_survey_Network_Wireless#in <b>Network &gt; Wireless</b>&nbsp;>></td></tr>
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

	if is_package_installed "wl" ; then WL
	else	IWLIST ; fi

footer ?>
<!--
##WEBIF:name:Status:980:Site Survey
-->
