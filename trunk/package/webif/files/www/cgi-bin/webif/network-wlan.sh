#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
###################################################################
# Wireless configuration
#
# Description:
#	Basic wireless configuration.
#
# Author(s) [in order of work date]: 
#       Original webif authors.
# 	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced: 
#   none
#

load_settings "wireless"

header "Network" "Wireless" "@TR<<Wireless Configuration>>" 'onLoad="modechange()"' "$SCRIPT_NAME"

#####################################################################
# defaults - ONLY used in the rare case these nvram variables are unset
#DEFAULT_INFRA=1

#####################################################################
# constants
EMPTY_passphrase_error="<div class=warning>ERROR: Can not generate key(s) from a non-existant passphrase.</div>"

#####################################################################
# Initialize channels based on country code
CC=${wl0_country_code:-$(nvram get wl0_country_code)}
case "$CC" in
	All|all|ALL) CHANNELS="1 2 3 4 5 6 7 8 9 10 11 12 13 14"; CHANNEL_MAX=14 ;;
	*) CHANNELS="1 2 3 4 5 6 7 8 9 10 11"; CHANNEL_MAX=11 ;;
esac
F_CHANNELS="option|0|@TR<<Auto>>"
for ch in $CHANNELS; do
	F_CHANNELS="${F_CHANNELS}
option|$ch"
done

#####################################################################	
# initialize forms
if empty "$FORM_submit"; then	
	FORM_gmode=${wl0_gmode:-$(nvram get wl0_gmode)}
  	case "$FORM_gmode" in
    		0) FORM_gmode=bOnly;;
    		1) FORM_gmode=b+g;;
    		2) FORM_gmode=g;;
    		3) FORM_gmode=bDeferred;;
    		4) FORM_gmode=gPerformance;;
    		5) FORM_gmode=gLRS;;
    		6) FORM_gmode=gAfterburner;;
    		*) FORM_gmode=Unknown;;    
  	esac
  
  	FORM_gmode_protection=${wl0_gmode_protection:-$(nvram get wl0_gmode_protection)}
  
	FORM_mode=${wl0_mode:-$(nvram get wl0_mode)}
	infra=${wl0_infra:-$(nvram get wl0_infra)}
	case "$infra" in
		0|off|disabled) FORM_mode=adhoc;;
	esac
	FORM_radio=${wl0_radio:-$(nvram get wl0_radio)}
	case "$FORM_radio" in
		0|off|diabled) FORM_radio=0;;
		*) FORM_radio=1;;
	esac
			
	FORM_ssid=${wl0_ssid:-$(nvram get wl0_ssid)}
	FORM_broadcast=${wl0_closed:-$(nvram get wl0_closed)}
	case "$FORM_broadcast" in
		1|off|disabled) FORM_broadcast=1;;
		*) FORM_broadcast=0;;
	esac
	FORM_channel=${wl0_channel:-$(nvram get wl0_channel)}
	FORM_encryption=off
	akm=${wl0_akm:-$(nvram get wl0_akm)}
	case "$akm" in
		psk)
			FORM_encryption=psk
			FORM_wpa1=wpa1
			;;
		psk2)
			FORM_encryption=psk
			FORM_wpa2=wpa2
			;;
		'psk psk2')
			FORM_encryption=psk
			FORM_wpa1=wpa1
			FORM_wpa2=wpa2
			;;
		wpa)
			FORM_encryption=wpa
			FORM_wpa1=wpa1
			;;
		wpa2)
			FORM_encryption=wpa
			FORM_wpa2=wpa2
			;;
		'wpa wpa2')
			FORM_encryption=wpa
			FORM_wpa1=wpa1
			FORM_wpa2=wpa2
			;;
		*)
			FORM_wpa1=wpa1
			;;
	esac
	FORM_wpa_psk=${wl0_wpa_psk:-$(nvram get wl0_wpa_psk)}
	FORM_radius_key=${wl0_radius_key:-$(nvram get wl0_radius_key)}
	FORM_radius_ipaddr=${wl0_radius_ipaddr:-$(nvram get wl0_radius_ipaddr)}
	crypto=${wl0_crypto:-$(nvram get wl0_crypto)}
	case "$crypto" in
		tkip)
			FORM_tkip=tkip
			;;
		aes)
			FORM_aes=aes
			;;
		'tkip+aes'|'aes+tkip')
			FORM_aes=aes
			FORM_tkip=tkip
			;;
		*)
			FORM_tkip=tkip
			;;
	esac
	equal "$FORM_encryption" "off" && {
		wep=${wl0_wep:-$(nvram get wl0_wep)}
		case "$wep" in
			1|enabled|on) FORM_encryption=wep;;
			*) FORM_encryption=off;;
		esac
	}
	FORM_key1=${wl0_key1:-$(nvram get wl0_key1)}
	FORM_key2=${wl0_key2:-$(nvram get wl0_key2)}
	FORM_key3=${wl0_key3:-$(nvram get wl0_key3)}
	FORM_key4=${wl0_key4:-$(nvram get wl0_key4)}
	key=${wl0_key:-$(nvram get wl0_key)}
	FORM_key=${key:-1}
#####################################################################	
# save forms
else 
	 empty "$FORM_generate_wep_128" && empty "$FORM_generate_wep_40" &&
	 {	
		SAVED=1					  	
		case "$FORM_encryption" in
			wpa) V_RADIUS="
	string|FORM_radius_key|@TR<<RADIUS Server Key>>|min=4 max=63 required|$FORM_radius_key
	ip|FORM_radius_ipaddr|@TR<<RADIUS IP Address>>|required|$FORM_radius_ipaddr";;
			psk) V_PSK="wpapsk|FORM_wpa_psk|@TR<<WPA PSK#WPA Pre-Shared Key>>|required|$FORM_wpa_psk";;
			wep) V_WEP="
int|FORM_key|@TR<<Selected WEP Key>>|min=1 max=4|$FORM_key
wep|FORM_key1|@TR<<WEP Key>> 1||$FORM_key1
wep|FORM_key2|@TR<<WEP Key>> 2||$FORM_key2
wep|FORM_key3|@TR<<WEP Key>> 3||$FORM_key3
wep|FORM_key4|@TR<<WEP Key>> 4||$FORM_key4";;
		esac

		validate <<EOF
int|FORM_radio|wl0_radio|required min=0 max=1|$FORM_radio
int|FORM_broadcast|wl0_closed|required min=0 max=1|$FORM_broadcast
string|FORM_ssid|@TR<<ESSID>>|required|$FORM_ssid
int|FORM_channel|@TR<<Channel>>|required min=0 max=$CHANNEL_MAX|$FORM_channel
$V_WEP
$V_RADIUS
$V_PSK
EOF
		equal "$?" 0 && {	
			NUM_gmode="1"	
			case "$FORM_gmode" in
	  			bOnly) NUM_gmode=0;;
	  			b+g) NUM_gmode=1;;
	  			g) NUM_gmode=2;;
	  			bDeferred) NUM_gmode=3;;
	  			gPerformance) NUM_gmode=4;;
	  			gLRS) NUM_gmode=5;;
	  			gAfterburner) NUM_gmode=6;;  
			esac  	

			save_setting wireless wl0_gmode "$NUM_gmode"  
  			save_setting wireless wl0_gmode_protection "$FORM_gmode_protection"  		
			save_setting wireless wl0_radio "$FORM_radio"

			if equal "$FORM_mode" adhoc; then
				FORM_mode=sta
				infra="0"
			fi
			save_setting wireless wl0_mode "$FORM_mode"
			save_setting wireless wl0_infra ${infra:-1}
			
			save_setting wireless wl0_ssid "$FORM_ssid"
			save_setting wireless wl0_closed "$FORM_broadcast"
			save_setting wireless wl0_channel "$FORM_channel"
	
			crypto=""
			equal "$FORM_aes" aes && crypto="aes"
			equal "$FORM_tkip" tkip && crypto="tkip${crypto:++$crypto}"
			save_setting wireless wl0_crypto "$crypto"

			case "$FORM_encryption" in
			psk)
				case "${FORM_wpa1}${FORM_wpa2}" in
					wpa1) save_setting wireless wl0_akm "psk";;
					wpa2) save_setting wireless wl0_akm "psk2";;
					wpa1wpa2) save_setting wireless wl0_akm "psk psk2";;
				esac
				save_setting wireless wl0_wpa_psk "$FORM_wpa_psk"
				save_setting wireless wl0_wep "disabled"
				;;
			wpa)
				case "${FORM_wpa1}${FORM_wpa2}" in
					wpa1) save_setting wireless wl0_akm "wpa";;
					wpa2) save_setting wireless wl0_akm "wpa2";;
					wpa1wpa2) save_setting wireless wl0_akm "wpa wpa2";;
				esac
				save_setting wireless wl0_radius_ipaddr "$FORM_radius_ipaddr"
				save_setting wireless wl0_radius_key "$FORM_radius_key"
				save_setting wireless wl0_wep "disabled"
				;;
			wep)				
				save_setting wireless wl0_wep enabled
				save_setting wireless wl0_akm "none"
				save_setting wireless wl0_key1 "$FORM_key1"
				save_setting wireless wl0_key2 "$FORM_key2"
				save_setting wireless wl0_key3 "$FORM_key3"
				save_setting wireless wl0_key4 "$FORM_key4"
				save_setting wireless wl0_key "$FORM_key"
				;;
			off)
				save_setting wireless wl0_akm "none"
				save_setting wireless wl0_wep disabled
				;;
			esac
		}			
	}
fi

! empty "$FORM_generate_wep_128" && 
{
	FORM_key1=""
	FORM_key2=""
	FORM_key3=""
	FORM_key4=""
	# generate a single 128(104)bit key	
	if empty "$FORM_wep_passphrase"; then
		echo "$EMPTY_passphrase_error"
	else
		textkeys=$(wepkeygen -s "$FORM_wep_passphrase"  |
		 awk 'BEGIN { count=0 }; 
		 	{ total[count]=$1, count+=1; } 
		 	END { print total[0] ":" total[1] ":" total[2] ":" total[3]}')		
		FORM_key1=$(echo "$textkeys" | cut -d ':' -f 0-13 | sed s/':'//g)	
		FORM_key2=""
		FORM_key3=""
		FORM_key4=""
	fi
}

! empty "$FORM_generate_wep_40" && 
{
	FORM_key1=""
	FORM_key2=""
	FORM_key3=""
	FORM_key4=""
	# generate a single 128(104)bit key	
	if empty "$FORM_wep_passphrase"; then
		echo "$EMPTY_passphrase_error"
	else
		textkeys=$(wepkeygen "$FORM_wep_passphrase" | sed s/':'//g)		
		keycount=1
		for curkey in $textkeys; do
		case $keycount in
			1) FORM_key1=$curkey;;
			2) FORM_key2=$curkey;;
			3) FORM_key3=$curkey;;
			4) FORM_key4=$curkey
				break;;
		esac
		let "keycount+=1"
		done
	fi
	
}
	
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{
/* TODO: the following code from the original webif is fucked up
	- and encryption_psk/encryption_wpa don't exist..
	- wpa/psk should be ok in any mode
	
	if (isset('mode','adhoc')) 
	{
		document.getElementById('encryption_psk').disabled = true;
		if (isset('encryption','psk')) 
		{
				document.getElementById('encryption').value = 'off';
		}
	} 
	else 
	{
		document.getElementById('encryption_psk').disabled = false;
	}
	
	if (!isset('mode','ap')) 
	{
		document.getElementById('encryption_wpa').disabled = true;
		if (value('encryption') == 'wpa') 
		{
				document.getElementById('encryption').value = 'off';
		}
	} 
	else 
	{
		document.getElementById('encryption_wpa').disabled = false;
	}
*/	
	if (isset('gmode','bOnly')) 
	{
		document.getElementById('gmode_protection').disabled = true;
	} 
	else 
	{
		document.getElementById('gmode_protection').disabled = false;
	}

	var v = (isset('encryption','wpa') || isset('encryption','psk'));
	set_visible('wpa_support', v);
	set_visible('wpa_crypto', v);
	
	set_visible('wpapsk', isset('encryption','psk'));
	set_visible('wep_keys', isset('encryption','wep'));

	v = isset('encryption','wpa');
	set_visible('radiuskey', v);
	set_visible('radius_ip', v);

	hide('save');
	show('save');
}
-->
</script>

EOF

display_form <<EOF
onchange|modechange
start_form|@TR<<Wireless Configuration>>
field|@TR<<Wireless Interface>>
select|radio|$FORM_radio
option|1|@TR<<Enabled>>
option|0|@TR<<Disabled>>
field|@TR<<ESSID Broadcast>>
select|broadcast|$FORM_broadcast
option|0|@TR<<Show>>
option|1|@TR<<Hide>>
field|@TR<<ESSID>>
text|ssid|$FORM_ssid
field|@TR<<Channel>>
select|channel|$FORM_channel
$F_CHANNELS
field|@TR<<WLAN Mode#Mode>>
select|mode|$FORM_mode
option|ap|@TR<<Access Point>>
option|sta|@TR<<Client>>
option|wet|@TR<<Client>> (@TR<<Bridge>>)
option|adhoc|@TR<<Ad-Hoc>>
helpitem|WLAN Mode
helptext|HelpText WLAN Mode#This sets the operation mode of your wireless network. Selecting 'Client (Bridge)' will not change your network interface settings. It will only set some parameters in the wireless driver that allow for limited bridging of the interface.
helplink|http://wiki.openwrt.org/OpenWrtDocs/Configuration#head-7126c5958e237d603674b3a9739c9d23bdfdb293

field|@TR<<Wireless Mode#Wireless Mode>>
select|gmode|$FORM_gmode
option|bOnly|@TR<<802.11b>>
option|b+g|@TR<<802.11b + 802.11g>>
option|g|@TR<<802.11g>>
option|bDeferred|@TR<<802.11g with 802.11b deferred>>
option|gPerformance|@TR<<802.11g (performance)>>
option|gLRS|@TR<<802.11g (range - LRS)>>
option|gAfterburner|@TR<<802.11g (afterburner)>>

field|@TR<<G-mode Protection#G-mode Protection>>
select|gmode_protection|$FORM_gmode_protection
option|1|@TR<<Enabled>>
option|0|@TR<<Disabled>>
helpitem|G-mode Protection
helptext|HelpText G-mode Protection#Set this in a mixed network when some stations can not hear.
end_form
start_form|@TR<<Encryption Settings>>
field|@TR<<Encryption Type>>
select|encryption|$FORM_encryption
option|off|@TR<<Disabled>>
option|wep|WEP
option|psk|WPA (@TR<<PSK>>)
option|wpa|WPA (RADIUS)
helpitem|Encryption Type
helptext|HelpText Encryption Type#WPA (RADIUS) is only supported in Access Point mode. WPA (PSK) does not work in Ad-Hoc mode.
field|@TR<<WPA Mode>>|wpa_support|hidden
checkbox|wpa1|$FORM_wpa1|wpa1|WPA1
checkbox|wpa2|$FORM_wpa2|wpa2|WPA2
field|@TR<<WPA Algorithms>>|wpa_crypto|hidden
checkbox|tkip|$FORM_tkip|tkip|RC4 (TKIP)
checkbox|aes|$FORM_aes|aes|AES
field|WPA @TR<<PSK>>|wpapsk|hidden
password|wpa_psk|$FORM_wpa_psk
field|@TR<<RADIUS IP Address>>|radius_ip|hidden
text|radius_ipaddr|$FORM_radius_ipaddr
field|@TR<<RADIUS Server Key>>|radiuskey|hidden
text|radius_key|$FORM_radius_key
field|@TR<<WEP Keys>>|wep_keys|hidden
string|@TR<<Passphrase>>
text|wep_passphrase|$FORM_wep_passphrase
string|<br />
submit|generate_wep_128|Generate 128bit Key
submit|generate_wep_40|Generate 40bit Keys
string|<br />
radio|key|$FORM_key|1
text|key1|$FORM_key1|<br />
radio|key|$FORM_key|2
text|key2|$FORM_key2|<br />
radio|key|$FORM_key|3
text|key3|$FORM_key3|<br />
radio|key|$FORM_key|4
text|key4|$FORM_key4|<br />
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:300:Wireless
-->
