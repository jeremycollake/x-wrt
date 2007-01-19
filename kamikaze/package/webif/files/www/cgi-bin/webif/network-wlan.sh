#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Wireless configuration
#
# Description:
#	Wireless configuration.
#
# Author(s) [in order of work date]:
#       Original webif authors.
#	Jeremy Collake <jeremy.collake@gmail.com>
#	Travis Kemen	<kemen04@gmail.com>
# Major revisions:
#
# UCI variables referenced:
#
# Configuration files referenced:
#   wireless
#

header "Network" "Wireless" "@TR<<Wireless Configuration>>" 'onload="modechange()"' "$SCRIPT_NAME"
config_cb() {
config_get TYPE "$CONFIG_SECTION" TYPE
case "$TYPE" in
        wifi-device)
                append DEVICES "$CONFIG_SECTION"
        ;;
        wifi-iface)
                config_get device "$CONFIG_SECTION" device
                config_get vifs "$device" vifs
                append vface "$CONFIG_SECTION" "$N"
        ;;
        interface)
	        append network_devices "$CONFIG_SECTION"
        ;;
esac
}
config_load network
NETWORK_DEVICES="none $network_devices"
config_load wireless

#echo "$DEVICES"
#echo "vifs $vface"

local forms save_form js validate

#####################################################################
#setup network device form for vfaces
#
for iface in $NETWORK_DEVICES; do
	network_options="$network_options 
			option|$iface|@TR<<$iface>>"
done

#####################################################################
# generate nas package field
#
if ! empty "$FORM_install_nas"; then
	echo "Installing NAS package ...<pre>"
	install_package "nas"
	echo "</pre>"
fi
nas_installed="0"
ipkg list_installed | grep -q nas
equal "$?" "0" && nas_installed="1"

install_nas_button='field|@TR<<NAS Package>>|install_nas|hidden'
if ! equal "$nas_installed" "1"; then
	install_nas_button="$install_nas_button
		string|<div class=\"warning\">WPA and WPA2 will not work until you install the NAS package. </div>
		submit|install_nas| Install NAS Package |"
else
	install_nas_button="$install_nas_button
		string|@TR<<Installed>>."
fi

#####################################################################
# This is looped for every physical wireless card (wifi-device)
#
for device in $DEVICES; do
        config_get country $device country
        config_get FORM_channel $device channel
        config_get FORM_maxassoc $device maxassoc
        config_get FORM_distance $device distance
        append forms "start_form|@TR<<Wireless Adapter >> $device @TR<< Configuration>>" "$N"
        
        # Initialize channels based on country code
        # (--- hardly a switch here ---)
        case "$country" in
                All|all|ALL) CHANNELS="1 2 3 4 5 6 7 8 9 10 11 12 13 14"; CHANNEL_MAX=14 ;;
                *) CHANNELS="1 2 3 4 5 6 7 8 9 10 11"; CHANNEL_MAX=11 ;;
        esac
        F_CHANNELS="field|@TR<<Channel>>
                select|channel_${device}|$FORM_channel
                option|0|@TR<<Auto>>"
        for ch in $CHANNELS; do
                F_CHANNELS="${F_CHANNELS}
                        option|$ch"
        done

        maxassoc="field|Max Associated Clients (default 128)
                text|maxassoc_${device}|$FORM_maxassoc"

        distance="field|Wireless Distance (In Meters)
                text|distance_${device}|$FORM_distance"

        append forms "$F_CHANNELS" "$N"
        append forms "$maxassoc" "$N"
        append forms "$distance" "$N"
        append forms "helpitem|Wireless Distance" "$N"
        append forms "helptext|Helptext Wireless Distance#You must enter a number that is double the distance of your longest link." "$N"
        append forms "end_form" "$N"
        
        for vcfg in $vface; do
       		config_get FORM_device $vcfg device
       		if [ "$FORM_device" = "$device" ]; then
	        	config_get FORM_network $vcfg network
	        	config_get FORM_mode $vcfg mode
	        	config_get FORM_ssid $vcfg ssid
	        	config_get FORM_encryption $vcfg encryption
	        	config_get FORM_key $vcfg key
	        	config_get FORM_key1 $vcfg key1
	        	config_get FORM_key2 $vcfg key2
	        	config_get FORM_key3 $vcfg key3
	        	config_get FORM_key4 $vcfg key4
	        	config_get FORM_server $vcfg server
	        	config_get FORM_port $vcfg port
	        	config_get FORM_hidden $vcfg hidden
	        	config_get FORM_isolate $vcfg isolate
			append forms "start_form|@TR<<Wireless Virtual Adaptor Configuration for Wireless Card >> $FORM_device" "$N"
			network="field|@TR<<Network>>
	        	        select|network_${vcfg}|$FORM_network
	        	        $network_options"
			append forms "$network" "$N"
			
			mode_fields="field|@TR<<WLAN Mode#Mode>>
			select|mode_$vcfg|$FORM_mode
			option|ap|@TR<<Access Point>>
			option|sta|@TR<<Client>>
			option|adhoc|@TR<<Ad-Hoc>>"
			append forms "$mode_fields" "$N"

			hidden="field|@TR<<ESSID Broadcast>>
				select|broadcast_$vcfg|$FORM_hidden
				option|0|@TR<<Show>>
				option|1|@TR<<Hide>>"
			append forms "$hidden" "$N"
			
			ssid="field|@TR<<ESSID>>
				text|ssid_$vcfg|$FORM_ssid"
			append forms "$ssid" "$N"
			
			encryption_forms="field|@TR<<Encryption Type>>
				select|encryption_$vcfg|$FORM_encryption
				option|none|@TR<<Disabled>>
				option|wep|WEP
				option|psk|WPA (@TR<<PSK>>)
				option|psk2|WPA2 (@TR<<PSK>>)
				option|wpa|WPA (RADIUS)
				option|wpa2|WPA2 (RADIUS)"
			append forms "$encryption_forms" "$N"
			
			! empty "$FORM_generate_wep_128_$vcfg" &&
			{
				FORM_key1=""
				FORM_key2=""
				FORM_key3=""
				FORM_key4=""
				# generate a single 128(104)bit key
				if empty "$FORM_wep_passphrase_$vcfg"; then
					echo "<div class=warning>$EMPTY_passphrase_error</div>"
				else
					textkeys=$(wepkeygen -s "$FORM_wep_passphrase_$vcfg"  |
					 awk 'BEGIN { count=0 };
						{ total[count]=$1, count+=1; }
						END { print total[0] ":" total[1] ":" total[2] ":" total[3]}')
					FORM_key1=$(echo "$textkeys" | cut -d ':' -f 0-13 | sed s/':'//g)
					FORM_key2=""
					FORM_key3=""
					FORM_key4=""
				fi
			}
			
			! empty "$FORM_generate_wep_40_$vcfg" &&
			{
				FORM_key1=""
				FORM_key2=""
				FORM_key3=""
				FORM_key4=""
				# generate a single 128(104)bit key
				if empty "$FORM_wep_passphrase_$vcfg"; then
					echo "<div class=warning>$EMPTY_passphrase_error</div>"
				else
					textkeys=$(wepkeygen "$FORM_wep_passphrase_$vcfg" | sed s/':'//g)
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
			wep="field|@TR<<Passphrase>>|wep_keyphrase_$vcfg|hidden
				text|wep_passphrase_$vcfg|$FORM_wep_passphrase_$vcfg
				string|<br />
				field|&nbsp;|wep_generate_keys_$vcfg|hidden
				submit|generate_wep_40_$vcfg|Generate 40bit Keys
				submit|generate_wep_128_$vcfg|Generate 128bit Key
				string|<br />
				field|@TR<<WEP Key 1>>|wep_key_1_$vcfg|hidden
				radio|key_$vcfg|$FORM_key|1
				text|key1_$vcfg|$FORM_key1|<br />
				field|@TR<<WEP Key 2>>|wep_key_2_$vcfg|hidden
				radio|key_$vcfg|$FORM_key|2
				text|key2_$vcfg|$FORM_key2|<br />
				field|@TR<<WEP Key 3>>|wep_key_3_$vcfg|hidden
				radio|key_$vcfg|$FORM_key|3
				text|key3_$vcfg|$FORM_key3|<br />
				field|@TR<<WEP Key 4>>|wep_key_4_$vcfg|hidden
				radio|key_$vcfg|$FORM_key|4
				text|key4_$vcfg|$FORM_key4|<br />"
			append forms "$wep" "$N"
			
			install_nas_button="field|@TR<<NAS Package>>|install_nas_$vcfg|hidden"
			if ! equal "$nas_installed" "1"; then
				install_nas_button="$install_nas_button
					string|<div class=\"warning\">WPA and WPA2 will not work until you install the NAS package. </div>
					submit|install_nas| Install NAS Package |"
			else
				install_nas_button="$install_nas_button
				string|@TR<<Installed>>."
			fi
			
			wpa="field|WPA @TR<<PSK>>|wpapsk_$vcfg|hidden
				password|wpa_psk_$vcfg|$FORM_key
				field|@TR<<RADIUS IP Address>>|radius_ip_$vcfg|hidden
				text|radius_ipaddr_$vcfg|$FORM_server
				field|@TR<<RADIUS Server Key>>|radiuskey_$vcfg|hidden
				text|radius_key_$vcfg|$FORM_key
				$install_nas_button"
			append forms "$wpa" "$N"
			
			javascript_forms="
				v = isset('encryption_$vcfg','wep');
				set_visible('wep_key_1_$vcfg', v);
				set_visible('wep_key_2_$vcfg', v);
				set_visible('wep_key_3_$vcfg', v);
				set_visible('wep_key_4_$vcfg', v);
				set_visible('wep_generate_keys_$vcfg', v);
				set_visible('wep_keyphrase_$vcfg', v);
				set_visible('wep_keys_$vcfg', v);
				//
				// force encryption listbox to no selection if user tries
				// to set WPA (PSK) with Ad-hoc mode.
				//
				if (isset('mode_$vcfg','adhoc'))
				{
					if (isset('encryption_$vcfg','psk'))
					{
						document.getElementById('encryption_$vcfg').value = 'off';
					}
				}
				//
				// force encryption listbox to no selection if user tries
				// to set WPA (Radius) with anything but AP mode.
				//
				if (!isset('mode_$vcfg','ap'))
				{
					if (isset('encryption_$vcfg','wpa') || isset('encryption_$vcfg','wpa2'))
					{
						document.getElementById('encryption_$vcfg').value = 'off';
					}
				}
				v = (isset('encryption_$vcfg','psk') || isset('encryption_$vcfg','psk2'));
				set_visible('wpapsk_$vcfg', v);
				v = (isset('encryption_$vcfg','psk') || isset('encryption_$vcfg','psk2') || isset('encryption_$vcfg','wpa') || isset('encryption_$vcfg','wpa2'));
				set_visible('install_nas_$vcfg', v);

				v = (isset('encryption_$vcfg','wpa') || isset('encryption_$vcfg','wpa2'));
				set_visible('radiuskey_$vcfg', v);
				set_visible('radius_ip_$vcfg', v);"
			append js "$javascript_forms" "$N"
			
			append forms "helpitem|Encryption Type" "$N"
			append forms "helptext|HelpText Encryption Type#WPA (RADIUS) is only supported in Access Point mode. WPA (PSK) does not work in Ad-Hoc mode." "$N"
			append forms "end_form" "$N"
		fi
	done
        
        
        #fix/finish save forms and add validation
        append save_form "uci_set" "wireless" "$device" "channel" "$FORM_channel_${device}"
        append save_form "uci_set" "wireless" "$device" "maxassoc" "$FORM_maxassoc_${device}"
        append save_form "uci_set" "wireless" "$device" "distance" "$FORM_distance_${device}"

done

#####################################################################
# modechange script
#
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	$js

	hide('save');
	show('save');
}
-->
</script>

EOF


display_form <<EOF
onchange|modechange
$forms
EOF

footer ?>
<!--
##WEBIF:name:Network:300:Wireless
-->







# Old WhiteRussian code, current left for reference. To be deleted when kamikaze port of it is completed.
load_settings "wireless"

header "Network" "Wireless" "@TR<<Wireless Configuration>>" 'onload="modechange()"' "$SCRIPT_NAME"
ShowNotUpdatedWarning

#####################################################################
# constants
EMPTY_passphrase_error="ERROR: Can not generate key(s) from a non-existant passphrase."

#####################################################################
# Initialize channels based on country code
# (--- hardly a switch here ---)
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
# install NAS if asked
if ! empty "$FORM_install_nas"; then
	echo "Installing NAS package ...<pre>"
	install_package "nas"
	echo "</pre>"
fi

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
# TODO: A bug exists in validate where if blank lines preceed a validation entry then it can fail validation
#  without any reported error, only the return value is bad. The old code here used seperate validation 
#  strings, i.e. V_PSK, V_WEP. This would result in blank lines in the validation call, causing this anomaly.
		case "$FORM_encryption" in
			wpa) V_ENCRYPTION="$V_ENCRYPTION
	string|FORM_radius_key|@TR<<RADIUS Server Key>>|min=4 max=63 required|$FORM_radius_key
	ip|FORM_radius_ipaddr|@TR<<RADIUS IP Address>>|required|$FORM_radius_ipaddr";;
			psk) V_ENCRYPTION="$V_ENCRYPTION
				wpapsk|FORM_wpa_psk|@TR<<WPA PSK#WPA Pre-Shared Key>>|required|$FORM_wpa_psk";;
			wep) V_ENCRYPTION="$V_ENCRYPTION
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
$V_ENCRYPTION
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
		echo "<div class=warning>$EMPTY_passphrase_error</div>"
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
		echo "<div class=warning>$EMPTY_passphrase_error</div>"
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


#####################################################################
# generate nas package field
#
nas_installed="0"
ipkg list_installed | grep -q nas
equal "$?" "0" && nas_installed="1"

install_nas_button='field|@TR<<NAS Package>>|install_nas|hidden'
if ! equal "$nas_installed" "1"; then
	install_nas_button="$install_nas_button
		string|<div class=\"warning\">WPA and WPA2 will not work until you install the NAS package. </div>
		submit|install_nas| Install NAS Package |"
else
	install_nas_button="$install_nas_button
		string|@TR<<Installed>>."
fi

#####################################################################
# modechange script
#
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{
	//
	// force encryption listbox to no selection if user tries
	// to set WPA (PSK) with Ad-hoc mode.
	//
	if (isset('mode','adhoc'))
	{
		if (isset('encryption','psk'))
		{
			document.getElementById('encryption').value = 'none';
		}
	}
	//
	// force encryption listbox to no selection if user tries
	// to set WPA (Radius) with anything but AP mode.
	//
	if (!isset('mode','ap'))
	{
		if (isset('encryption','wpa'))
		{
			document.getElementById('encryption').value = 'none';
		}
	}

	var v = isset('encryption','wep');
	set_visible('wep_key_1', v);
	set_visible('wep_key_2', v);
	set_visible('wep_key_3', v);
	set_visible('wep_key_4', v);
	set_visible('wep_generate_keys', v);
	set_visible('wep_keyphrase', v);
	set_visible('wep_keys', v);

	if (isset('gmode','bOnly'))
	{
		document.getElementById('gmode_protection').disabled = true;
	}
	else
	{
		document.getElementById('gmode_protection').disabled = false;
	}

	v = (isset('encryption','wpa') || isset('encryption','psk'));
	set_visible('wpa_support', v);
	set_visible('wpa_crypto', v);

	set_visible('wpapsk', isset('encryption','psk'));
	v = (isset('encryption','psk') || isset('encryption','wpa'));
	set_visible('install_nas', v);

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
field|@TR<<Passphrase>>|wep_keyphrase|hidden
text|wep_passphrase|$FORM_wep_passphrase
string|<br />
field|&nbsp;|wep_generate_keys|hidden
submit|generate_wep_40|Generate 40bit Keys
submit|generate_wep_128|Generate 128bit Key
string|<br />
field|@TR<<WEP Key 1>>|wep_key_1|hidden
radio|key|$FORM_key|1
text|key1|$FORM_key1|<br />
field|@TR<<WEP Key 2>>|wep_key_2|hidden
radio|key|$FORM_key|2
text|key2|$FORM_key2|<br />
field|@TR<<WEP Key 3>>|wep_key_3|hidden
radio|key|$FORM_key|3
text|key3|$FORM_key3|<br />
field|@TR<<WEP Key 4>>|wep_key_4|hidden
radio|key|$FORM_key|4
text|key4|$FORM_key4|<br />
$install_nas_button
end_form
EOF

show_validated_logo

footer ?>
<!--
##WEBIF:name:Network:300:Wireless
-->
