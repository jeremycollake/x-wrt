#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# DHCP configuration
#
# Description:
#	DHCP configuration.
#
# Author(s) [in order of work date]:
#	Travis Kemen	<thepeople@users.berlios.de>
# Major revisions:
#
# UCI variables referenced:
#
# Configuration files referenced:
#   dhcp, network
#

header "Network" "DHCP" "@TR<<DHCP Configuration>>" 'onload="modechange()"' "$SCRIPT_NAME"

###################################################################
# Parse Settings, this function is called when doing a config_load
config_cb() {
config_get TYPE "$CONFIG_SECTION" TYPE
case "$TYPE" in
	interface)
		if [ "$CONFIG_SECTION" != "loopback" ]; then
			append networks "$CONFIG_SECTION" "$N"
		fi
	;;
	dhcp)
		append dhcp_cfgs "$CONFIG_SECTION" "$N"
	;;
esac
}
uci_load network
uci_load dhcp
dhcp_cfgs=$(echo "$dhcp_cfgs" |uniq)

#add dhcp network
if [ "$FORM_add_dhcp" != "" ]; then
	vcfg_number=$(echo "$dhcp_cfgs" |wc -l)
	let "vcfg_number+=1"
	uci_add "dhcp" "dhcp" ""
	uci_set "dhcp" "cfg$vcfg_number" "interface" "$FORM_network_add"
	dhcp_cfgs=""
	uci_load dhcp
	dhcp_cfgs=$(echo "$dhcp_cfgs" |uniq)
fi

for config in $dhcp_cfgs; do
	if [ "$FORM_submit" = "" ]; then
		config_get interface $config interface
		config_get start $config start
		config_get limit $config limit
		config_get leasetime $config leasetime
		config_get_bool ignore $config ignore 0
	else
		config_get interface $config interface
		eval start="\$FORM_start_$config"
		eval limit="\$FORM_limit_$config"
		eval leasetime="\$FORM_leasetime_$config"
		eval ignore="\$FORM_ignore_$config"
	fi
	
	#Save networks with a dhcp interface.
	append dhcp_networks "$interface" "$N"

	#convert leasetime to minutes
	lease_int=$(echo "$leasetime" | tr -d [a-z][A-Z])			
	time_units=$(echo "$leasetime" | tr -d [0-9])
	time_units=${time_units:-m}
	case "$time_units" in
		"h" | "H" ) let "leasetime=$lease_int*60";;
		"d" | "D" ) let "leasetime=$lease_int*24*60";;
		"s" | "S" ) let "leasetime=$lease_int/60";;
		"w" | "W" ) let "leasetime=$lease_int*7*24*60";;
		"m" | "M" ) leasetime="$lease_int";;  # minutes 			
		*) leasetime="$lease_int"; echo "<br />WARNING: Unknown suffix found on dhcp lease time: $leasetime";;
	esac

	form_dhcp="start_form|$interface DHCP
		field|@TR<<DHCP>>
		radio|ignore_$config|$ignore|0|@TR<<On>>
		radio|ignore_$config|$ignore|1|@TR<<Off>>
		field|@TR<<Start>>
		text|start_$config|$start
		field|@TR<<Limit>>
		text|limit_$config|$limit
		field|@TR<<Lease Time (in minutes)>>
		text|leasetime_$config|$leasetime
		end_form"
	append forms "$form_dhcp" "$N"

	append validate_forms "int|start_$config|@TR<<DHCP Start>>||$start" "$N"
	append validate_forms "int|limit_$config|@TR<<DHCP Limit>>||$limit" "$N"
	append validate_forms "int|leasetime_$config|@TR<<DHCP Lease Time>>|min=1 max=2147483647|$leasetime" "$N"
done

for network in $networks; do
	echo "$dhcp_networks" | grep -q "$network"
	if [ "$?" != "0" ]; then
		append network_options "option|$network" "$N"
	fi
done
if [ "$network_options" != "" ]; then
	field_dhcp_add="start_form
		select|network_add
		$network_options
		submit|add_dhcp|@TR<<Add DHCP>>
		end_form"
	append forms "$field_dhcp_add" "$N"
fi

if ! empty "$FORM_submit"; then
	SAVED=1
	validate <<EOF
$validate_forms
EOF
	equal "$?" 0 && {
		for config in $dhcp_cfgs; do
			eval start="\$FORM_start_$config"
			eval limit="\$FORM_limit_$config"
			eval leasetime="\$FORM_leasetime_$config"
			eval ignore="\$FORM_ignore_$config"
			
			if [ "$leasetime" != "" ]; then
				leasetime="${leasetime}m"
			fi
			
			uci_set "dhcp" "$config" "start" "$start"
			uci_set "dhcp" "$config" "limit" "$limit"
			uci_set "dhcp" "$config" "leasetime" "$leasetime"
			uci_set "dhcp" "$config" "ignore" "$ignore"
		done
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
$validate_error
$forms
EOF

footer ?>
<!--
##WEBIF:name:Network:425:DHCP
-->
