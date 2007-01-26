#!/usr/bin/webif-page
<?
###################################################################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Dmytro Dykhman <dmytro@iroot.ca>
#
# Major revisions:
#
#
# Configuration files referenced:
#   none
#
# TODO:
#   I originally wrote this before I had bothered to learn much about
#   awk, so it uses 'pure' shell scripting. It would be much simpler
#   and probably more efficient to use awk. Maybe recode someday, but
#   why fix what's isn't broken...
#

. "/usr/lib/webif/webif.sh"

header "Status" "Site Survey" "<img src=/images/wscan.jpg align=absmiddle>&nbsp;@TR<<Wireless survey>>"
?>

<?

if is_package_installed "wl" ; then #--->[ -s "/usr/sbin/wl" ] ||

MAX_TRIES=4
MAX_CELLS=100
Wimg=0

tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)
tempscan=$(mktemp /tmp/.survscan.XXXXXX)

##################################################
#
Dopurge ()
{

	sed 1d < $tempfile > $tempfile2
	rm $tempfile
	mv $tempfile2 $tempfile     
}

counter=0

for counter in $(seq 1 $MAX_TRIES); do
       wl scan
       wl scanresults > $tempscan 2> /dev/null
	if equal $(sed '2,$ d' $tempscan | cut -c0-4) "SSID" ; then break ; fi
       sleep 1
done

if [ $counter -gt $MAX_TRIES ]; then
	echo "<tr><td>@TR<<Sorry, no scan results.>></td></tr>"
else

#---------------------------------------------
# We need to add a "break" on the first line!

current_line=$(grep -i '' < $tempscan)
echo "" > $tempfile
echo "$current_line" >> $tempfile
rm $tempscan
#--------------------------------------------
current=1

echo "<br><a href='' onClick='document.location.reload(true)'>@TR<<Re-scan>></a><br><br><table width="98%" border="0" cellspacing="1" bgcolor="#999999" >"
echo "<tr bgcolor="#999999" class="wifiscantitle" >"
echo "<td width='32'>@TR<<Signal>>/</td>"
echo "<td width='32'>@TR<<Noise>></td>"
echo "<td>@TR<<Status>></td>"
echo "<td>@TR<<SSID>></td>"
echo "<td>@TR<<MAC>></td>"
echo "<td width='20'>@TR<<Channel>></td>"
echo "<td>@TR<<Rate>></td>"
echo "<td>&nbsp;</td>"
echo "</tr>"


# Read File
#-------------------------

while read f
do

# DEBUG
#------\/
	#echo $f "<br>"

current_line=$(sed '2,$ d' $tempfile)

#echo "-> '" $current_line "'<br>"

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

#-------------------------
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
RATED=$(sed '2,$ d' $tempfile)

echo "<tr bgcolor="#FFFFFF" class="wifiscanrow">"
if [ $RSSI -lt 60 ]; then 
Wimg=5
elif [ $RSSI -lt 72 ]; then
Wimg=4
elif [ $RSSI -lt 81 ]; then
Wimg=3
elif [ $RSSI -lt 85 ]; then
Wimg=2
elif [ $RSSI -lt 92 ]; then
Wimg=1
else
Wimg=0
fi

echo "<td><center><img src="/images/wifi$Wimg.gif" ALT='-" $RSSI "dBm'></center></td>"

if [ $NOISE -gt 95 ]; then
Wimg=0
elif [ $NOISE -gt 92 ]; then
Wimg=1
elif [ $NOISE -gt 88 ]; then
Wimg=2
elif [ $NOISE -gt 85 ]; then
Wimg=3
elif [ $NOISE -gt 80 ]; then 
Wimg=4
else
Wimg=5
fi

echo "<td><center><img src="/images/wifi$Wimg.gif" ALT='-" $NOISE "dBm'></center></td>"

if  [ "$SEC" == "ESS WEP" ] ; then
Wimg="wep"
else
Wimg="opn"
fi

echo "<td><center><img src="/images/$Wimg.gif" ALT='$SEC'></center></td>"
echo "<td>&nbsp;&nbsp;" $SSID
#echo "$current_line" | cut -c8-20 | cut -d '"' -f1
echo "</td>"
echo "<td><center>" $BSSID "</center></td>"
echo "<td><center>" $CHANNEL "</center></td>"

if  [ "$RATE" == "66" ] ; then
Wimg="54 Mbps"
elif  [ "$RATE" == "75" ] ; then
Wimg="54 Mbps"
elif  [ "$RATE" == "44" ] ; then
Wimg="11 Mbps"
else
#Wimg="("$RATE") $RATED"
Wimg="(?)"
fi

echo "<td><center>$Wimg</center></td>"
echo "<td><center>"
echo "<input type='submit' style='border: 1px solid #000000; font-size:8pt; ' name='joinwifi' value='@TR<<Join>>' disabled>"
echo "</center></td></tr>"

fi
fi

Dopurge

done < $tempfile

rm $tempfile
#rm $tempfile2
echo "</table><br><a href='' onClick='document.location.reload(true)'>@TR<<Re-scan>></a>"
fi
else

if ! empty "$FORM_install_package"; then
	echo "Installing wl package ...<pre>"
	install_package "wl"
	echo "</pre>"
fi

echo "<form enctype='multipart/form-data' action='$SCRIPT_NAME' method='post'>"
install_package_button="string|<div class=warning>Wireless Scanning will not work until you install "wl": </div>
		submit|install_package| Install "wl" Package |"

display_form <<EOF
$install_package_button
EOF
echo "</form>"

fi
	
footer ?>
<!--
##WEBIF:name:Status:980:Site Survey
-->