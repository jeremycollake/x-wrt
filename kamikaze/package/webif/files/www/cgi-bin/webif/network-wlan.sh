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

local forms js

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
	eval FORM_channel="\$FORM_channel_$device"
	eval FORM_maxassoc="\$FORM_maxassoc_$device"
	eval FORM_distance="\$FORM_distance_$device"
if empty "$FORM_submit"; then
        config_get country $device country
        config_get FORM_channel $device channel
        config_get FORM_maxassoc $device maxassoc
        config_get FORM_distance $device distance
fi
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
			eval FORM_radius_key="\$FORM_radius_key_$vcfg"
			eval FORM_radius_ipaddr="\$FORM_radius_ipaddr_$vcfg"
			eval FORM_wpa_psk="\$FORM_wpa_psk_$vcfg"
			eval FORM_encryption="\$FORM_encryption_$vcfg"
			eval FORM_mode="\$FORM_mode_$vcfg"
			eval FORM_server="\$FORM_server_$vcfg"
			eval FORM_port="\$FORM_port_$vcfg"
			eval FORM_hidden="\$FORM_broadcast_$vcfg"
			eval FORM_isolate="\$FORM_isolate_$vcfg"
			eval FORM_key="\$FORM_key_$vcfg"
			eval FORM_key1="\$FORM_key1_$vcfg"
			eval FORM_key2="\$FORM_key2_$vcfg"
			eval FORM_key3="\$FORM_key3_$vcfg"
			eval FORM_key4="\$FORM_key4_$vcfg"
			eval FORM_broadcast="\$FORM_broadcast_$vcfg"
			eval FORM_ssid="\$FORM_ssid_$vcfg"
			eval FORM_network="\$FORM_network_$vcfg"
			
			
       		if empty "$FORM_submit"; then
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
		fi
			append forms "start_form|@TR<<Wireless Virtual Adaptor Configuration for Wireless Card >> $FORM_device" "$N"
			network="field|@TR<<Network>>
	        	        select|network_${vcfg}|$FORM_network
	        	        $network_options"
			append forms "$network" "$N"
			
			mode_fields="field|@TR<<WLAN Mode#Mode>>
			select|mode_$vcfg|$FORM_mode
			option|ap|@TR<<Access Point>>
			option|wds|@TR<<WDS>>
			option|sta|@TR<<Client>>
			option|adhoc|@TR<<Ad-Hoc>>"
			append forms "$mode_fields" "$N"

			hidden="field|@TR<<ESSID Broadcast>>|broadcast_$vcfg|hidden
				select|broadcast_$vcfg|$FORM_hidden
				option|0|@TR<<Show>>
				option|1|@TR<<Hide>>"
			append forms "$hidden" "$N"
			
			ssid="field|@TR<<ESSID>>|ssid_$vcfg|hidden
				text|ssid_$vcfg|$FORM_ssid"
			append forms "$ssid" "$N"
			
			bssid="field|@TR<<BSSID>>|bssid_$vcfg|hidden
				text|bssid_$vcfg|$FORM_bssid"
			append forms "$bssid" "$N"
			
			eval FORM_wep_passphrase="\$FORM_wep_passphrase_$vcfg"
			eval FORM_generate_wep_128="\$FORM_generate_wep_128_$vcfg"
			eval FORM_generate_wep_40="\$FORM_generate_wep_40_$vcfg"
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
					FORM_encryption="wep"
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
					FORM_encryption="wep"
				fi
			
			}

			encryption_forms="field|@TR<<Encryption Type>>
				select|encryption_$vcfg|$FORM_encryption
				option|none|@TR<<Disabled>>
				option|wep|WEP
				option|psk|WPA (@TR<<PSK>>)
				option|psk2|WPA2 (@TR<<PSK>>)
				option|wpa|WPA (RADIUS)
				option|wpa2|WPA2 (RADIUS)"
			append forms "$encryption_forms" "$N"

			wep="field|@TR<<Passphrase>>|wep_keyphrase_$vcfg|hidden
				text|wep_passphrase_$vcfg|$FORM_wep_passphrase
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
				v = (!isset('mode_$vcfg','wds'));
				set_visible('ssid_$vcfg', v);
				set_visible('broadcast_$vcfg', v);
				v = (isset('mode_$vcfg','wds'));
				set_visible('bssid_$vcfg', v);
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
done
if ! empty "$FORM_submit"; then
	empty "$FORM_generate_wep_128" && empty "$FORM_generate_wep_40" &&
	{
		SAVED=1
		validate <<EOF
for device in $DEVICES; do
for vcfg in $vface; do
config_get FORM_device $vcfg device
if [ "$FORM_device" = "$device" ]; then
# TODO: A bug exists in validate where if blank lines preceed a validation entry then it can fail validation
#  without any reported error,
string|FORM_radius_key_$vcfg|@TR<<RADIUS Server Key>>|min=4 max=63 required|$FORM_radius_key" "$N"
ip|FORM_radius_ipaddr|@TR<<RADIUS IP Address>>|required|$FORM_radius_ipaddr" "$N"
wpapsk|FORM_wpa_psk|@TR<<WPA PSK#WPA Pre-Shared Key>>|required|$FORM_wpa_psk" "$N"
int|FORM_key|@TR<<Selected WEP Key>>|min=1 max=4|$FORM_key
wep|FORM_key1_$vcfg|@TR<<WEP Key>> 1||$FORM_key1
wep|FORM_key2_$vcfg|@TR<<WEP Key>> 2||$FORM_key2
wep|FORM_key3_$vcfg|@TR<<WEP Key>> 3||$FORM_key3
wep|FORM_key4_$vcfg|@TR<<WEP Key>> 4||$FORM_key4
int|FORM_broadcast|wl0_closed|required min=0 max=1|$FORM_broadcast
string|FORM_ssid|@TR<<ESSID>>|required|$FORM_ssid" "$N"
int|FORM_channel|@TR<<Channel>>|required min=0 max=$CHANNEL_MAX|$FORM_channel
fi
done
done
EOF
		#equal "$?" 0 && {
			for device in $DEVICES; do
				eval FORM_channel="\$FORM_channel_$device"
				eval FORM_maxassoc="\$FORM_maxassoc_$device"
				eval FORM_distance="\$FORM_distance_$device"
				uci_set "wireless" "$device" "channel" "$FORM_channel"
				uci_set "wireless" "$device" "maxassoc" "$FORM_maxassoc"
				uci_set "wireless" "$device" "distance" "$FORM_distance"
				
				for vcfg in $vface; do
     		  			config_get FORM_device $vcfg device
     		  			if [ "$FORM_device" = "$device" ]; then
						eval FORM_radius_key="\$FORM_radius_key_$vcfg"
						eval FORM_radius_ipaddr="\$FORM_radius_ipaddr_$vcfg"
						eval FORM_wpa_psk="\$FORM_wpa_psk_$vcfg"
						eval FORM_encryption="\$FORM_encryption_$vcfg"
						eval FORM_mode="\$FORM_mode_$vcfg"
						eval FORM_server="\$FORM_server_$vcfg"
						eval FORM_port="\$FORM_port_$vcfg"
						eval FORM_hidden="\$FORM_broadcast_$vcfg"
						eval FORM_isolate="\$FORM_isolate_$vcfg"
						eval FORM_key="\$FORM_key_$vcfg"
						eval FORM_key1="\$FORM_key1_$vcfg"
						eval FORM_key2="\$FORM_key2_$vcfg"
						eval FORM_key3="\$FORM_key3_$vcfg"
						eval FORM_key4="\$FORM_key4_$vcfg"
						eval FORM_broadcast="\$FORM_broadcast_$vcfg"
						eval FORM_ssid="\$FORM_ssid_$vcfg"
						eval FORM_bssid="\$FORM_bssid_$vcfg"
						eval FORM_network="\$FORM_network_$vcfg"

						uci_set "wireless" "$vcfg" "network" "$FORM_network"
						uci_set "wireless" "$vcfg" "ssid" "$FORM_ssid"
						uci_set "wireless" "$vcfg" "bssid" "$FORM_bssid"
						uci_set "wireless" "$vcfg" "mode" "$FORM_mode"
						uci_set "wireless" "$vcfg" "encryption" "$FORM_encryption"
						uci_set "wireless" "$vcfg" "server" "$FORM_server"
						uci_set "wireless" "$vcfg" "port" "$FORM_port"
						uci_set "wireless" "$vcfg" "hidden" "$FORM_hidden"
						uci_set "wireless" "$vcfg" "isolate" "$FORM_isolate"
						uci_set "wireless" "$vcfg" "key" "$FORM_key"
						uci_set "wireless" "$vcfg" "key1" "$FORM_key1"
						uci_set "wireless" "$vcfg" "key2" "$FORM_key2"
						uci_set "wireless" "$vcfg" "key3" "$FORM_key3"
						uci_set "wireless" "$vcfg" "key4" "$FORM_key4"
					fi
				done
			done
		#}
	}
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