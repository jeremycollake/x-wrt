#!/usr/bin/webif-page
<?
###################################################################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]: 
# 	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	wl0_ifname
# 	wl0_mode
#	wl0_infra  (unnecessary to be 1? -- seems so in tests so far)
#
# Configuration files referenced: 
#   none
#

. "/usr/lib/webif/webif.sh"
header "Status" "Survey" "@TR<<Wireless survey>>"
?>

<?
MAX_TRIES=5
MAX_CELLS=100
WL0_IFNAME=$(nvram get wl0_ifname)
##################################################
# Handle switch to sta mode at user request
# 
if empty "$FORM_clientswitch"; then	  	
	CLIENT_SWITCH_BUTTON="<form enctype=\"multipart/form-data\" method=\"post\"><input type=\"submit\" value=\" Scan \" name=\"clientswitch\" /></form>"	
else	
	ORIGINAL_WL_MODE=$(nvram get wl0_mode)
	nvram set wl0_mode="sta"
	# tests show scan works in infra or ad-hoc mode, but we'll do this to be safe
	ORIGINAL_INFRA=$(nvram get wl0_infra)	
	nvram set wl0_infra="1"		
	# todo: wifi up here and below causes the page to stay in a wait state.. tried several ways
	wifi up 2>/dev/null >/dev/null </dev/null
fi
WL_MODE=$(nvram get wl0_mode)					
?>
<table style="width: 90%; text-align: center;" border="0" cellpadding="2" cellspacing="2">
<tbody>
<?
##################################################
#
if equal $WL_MODE "ap" ; then
	echo "<table><tbody><tr><td>Your wireless adaptor is not in client mode. " \
	"To do a scan it must be put into client mode for a few seconds." \
	"Your WLAN traffic will be interrupted during this brief period." \
	"<tr><td><br /></td></tr><tr><td>$CLIENT_SWITCH_BUTTON</td></tr></tbody></table>"
else 		
	
tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)

echo " Please wait while scan is performed ... <br /><br />"
counter=0
for counter in $(seq 1 $MAX_TRIES); do
	#echo "." 	 
	iwlist scan > $tempfile 2> /dev/null	
	grep -i "Address" < $tempfile >> /dev/null
	equal "$?" "0" && break				
	sleep 1
done
echo "Done."

first_hit=1
if [ $counter -gt $MAX_TRIES ]; then
	echo "<tr><td>Sorry, no scan results.</td></tr>"	
else	
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
		equal "$result_one" "0" && equal "$result_two" "0" && {
			equal "$first_hit" "0" && {
				let "current+=1"									
			}
			first_hit=0
		}
		equal "$first_hit" "0" && {
			echo "$current_line" >> "$tempfile"_"${current}"
		}
		
		sed 1d < $tempfile > $tempfile2
		rm $tempfile
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
				2) MAC_ID=$i;;	
				3) break;;	
			esac	
			let "count+=1"
		done

		####################################################
		# parse out essid
		ESSID=$(grep -i "ESSID" < "$tempfile"_"${current}" | sed -e s/'ESSID:'//g -e s/'"'//g)
	
		####################################################
		# parse out channel
		CHANNEL_ID=$(grep -i "Channel" < "$tempfile"_"${current}" | sed -e s/'Channel:'//g -e s/' '//g)

		####################################################
		# parse out signal
		quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality:'//g -e s/'Signal level:'//g  -e s/'dBm'//g -e s/'Noise level:'//g)
		count=0
		for i in $quality_pre; do
			case $count in
				0) QUALITY=$i;;
				1) SIGNAL_DBM=$i;;		
				2) NOISE_DBM=$i;;
				3) break;;		
			esac	
			let "count+=1"
		done
	
		#
		# only show quality if it's not 0/0
		#
		if ! equal "$QUALITY" "0/0"; then
			QUALITY_STRING="string|<tr><td>Quality $QUALITY</tr></td>"
		fi
			
		NOISE_BASE=-99
		NOISE_DELTA=$(expr $NOISE_BASE - $NOISE_DBM)
	
		SIGNAL_INTEGRITY=$(expr $SIGNAL_DBM + $NOISE_DELTA)
		MAC_DASHES=$(echo "$MAC_ID" | sed s/':'/'-'/g)
		MAC_FIRST_THREE=$(echo "$MAC_DASHES" | cut -c1-8)
		SNR_PERCENT=$(expr 100 + $SIGNAL_INTEGRITY)
			
		FORM_cells="$FORM_cells 
			string|<tr><td><strong>Cell</strong> $CELL_ID</tr></td>
			string|<tr><td><strong>SSID</strong> $ESSID (<div class=mac-address><a href=\"http://standards.ieee.org/cgi-bin/ouisearch?$MAC_FIRST_THREE\" target=\"_new\">$MAC_DASHES</a></div>)</tr></td>					
			string|<tr><td><strong>Channel</strong> $CHANNEL_ID</tr></td>
			$QUALITY_STRING
			string|<tr><td><strong>Signal</strong> $SIGNAL_DBM dBm <strong>Noise</strong> $NOISE_DBM dBm</tr></td>
			string|<tr><td><strong>SNR</strong> $SIGNAL_INTEGRITY dBm</td></tr>
			progressbar|SNR||200|$SNR_PERCENT|$SIGNAL_INTEGRITY dBm
			string|<tr><td><br /></td></tr>"
		
		rm -f "$tempfile"_"${current}"
	
		let "current+=1"
	done	
fi # end if were scan results

rm -f "$tempfile"
rm -f "$tempfile2"

if ! empty "$FORM_clientswitch"; then	  	
	#echo "<tr><td>Restoring settings...</tr></td>"
	# restore radio to its original state
	nvram set wl0_mode=$ORIGINAL_WL_MODE				
	nvram set wl0_infra=$ORIGINAL_INFRA			
	wifi up 2>/dev/null >/dev/null </dev/null	
fi 

fi # end if is in 'allowed to scan' mode

 2>/dev/null >/dev/null </dev/null
?>
<br /></tbody></table>

<?
if ! empty "$FORM_clientswitch"; then	  
display_form <<EOF
start_form|@TR<<Survey Results>>
$FORM_cells
end_form|
EOF
fi
?>

<? footer ?>
<!--
##WEBIF:name:Status:800:Survey
-->
