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
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
		interface)
			if [ "$cfg_name" != "loopback" ]; then
				append networks "$cfg_name" "$N"
			fi
		;;
		dhcp)
			append dhcp_cfgs "$cfg_name" "$N"
		;;
		dnsmasq)
			append dnsmasq_cfgs "$cfg_name" "$N"
		;;
	esac
}
uci_load network
uci_load dhcp
# create dnsmasq's section when missing
[ -z "$dnsmasq_cfgs" ] && {
	uci_add dhcp dnsmasq
	unset dhcp_cfgs dnsmasq_cfgs
	uci_load dhcp
}

vcfg_number=$(echo "$dhcp_cfgs" "$dnsmasq_cfgs" |wc -l)
let "vcfg_number+=1"

#add dhcp network
if [ "$FORM_add_dhcp" != "" ]; then
	uci_add "dhcp" "dhcp" ""
	uci_set "dhcp" "cfg$vcfg_number" "interface" "$FORM_network_add"
	dhcp_cfgs=""
	dnsmasq_cfgs=""
	uci_load dhcp
	let "vcfg_number+=1"
fi

dnsmasq_cfgs=$(echo "$dnsmasq_cfgs" |uniq)
dhcp_cfgs=$(echo "$dhcp_cfgs" |uniq)

for config in $dnsmasq_cfgs; do
	if [ "$FORM_submit" = "" ]; then
		config_get authoritative $config authoritative
		config_get domain $config domain
		config_get boguspriv $config boguspriv
		config_get filterwin2k $config filterwin2k
		config_get localise_queries $config localise_queries
		config_get expandhosts $config expandhosts
		config_get nonegcache $config nonegcache
		config_get readethers $config readethers
		config_get leasefile $config leasefile
	else
		eval authoritative="\$FORM_authoritative_$config"
		eval domain="\$FORM_domain_$config"
		eval boguspriv="\$FORM_boguspriv_$config"
		eval filterwin2k="\$FORM_filterwin2k_$config"
		eval localise_queries="\$FORM_localise_queries_$config"
		eval expandhosts="\$FORM_expandhosts_$config"
		eval nonegcache="\$FORM_nonegcache_$config"
		eval readethers="\$FORM_readethers_$config"
		eval leasefile="\$FORM_leasefile_$config"
	fi
	
	form_dnsmasq="start_form|DHCP Settings
		field|@TR<<Authoritative>>
		radio|authoritative_$config|$authoritative|1|@TR<<Enabled>>
		radio|authoritative_$config|$authoritative|0|@TR<<Disabled>>
		helpitem|Authoritative
		helptext|HelpText Authoritative#Should be set when dnsmasq is the only DHCP server on a network.
		field|@TR<<Domain>>
		text|domain_$config|$domain
		helpitem|Domain
		helptext|HelpText Domain#Specifies the domain for the DHCP server.
		field|@TR<<Bogus Private Reverse Lookups>>
		radio|boguspriv_$config|$boguspriv|1|@TR<<Enabled>>
		radio|boguspriv_$config|$boguspriv|0|@TR<<Disabled>>
		field|@TR<<filterwin2k>>
		radio|filterwin2k_$config|$filterwin2k|1|@TR<<Enabled>>
		radio|filterwin2k_$config|$filterwin2k|0|@TR<<Disabled>>
		field|@TR<<Localise Queries>>
		radio|localise_queries_$config|$localise_queries|1|@TR<<Enabled>>
		radio|localise_queries_$config|$localise_queries|0|@TR<<Disabled>>
		field|@TR<<Expand Hosts>>
		radio|expandhosts_$config|$expandhosts|1|@TR<<Enabled>>
		radio|expandhosts_$config|$expandhosts|0|@TR<<Disabled>>
		field|@TR<<Negative Caching>>
		radio|nonegcache_$config|$nonegcache|1|@TR<<Enabled>>
		radio|nonegcache_$config|$nonegcache|0|@TR<<Disabled>>
		field|@TR<<Read Ethers>>
		radio|readethers_$config|$readethers|1|@TR<<Enabled>>
		radio|readethers_$config|$readethers|0|@TR<<Disabled>>
		field|@TR<<Lease File>>
		text|leasefile_$config|$leasefile
		helpitem|Lease File
		helptext|HelpText Lease File#Use the specified file to store DHCP lease information. This should remain on /tmp unless you have a external hard drive because it writes out infomation for every lease.
		helpitem|More Information
		helplink|http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
		end_form"
	append forms "$form_dnsmasq" "$N"
done

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
		for config in $dnsmasq_cfgs; do
			eval authoritative="\$FORM_authoritative_$config"
			eval domain="\$FORM_domain_$config"
			eval boguspriv="\$FORM_boguspriv_$config"
			eval filterwin2k="\$FORM_filterwin2k_$config"
			eval localise_queries="\$FORM_localise_queries_$config"
			eval expandhosts="\$FORM_expandhosts_$config"
			eval nonegcache="\$FORM_nonegcache_$config"
			eval readethers="\$FORM_readethers_$config"
			eval leasefile="\$FORM_leasefile_$config"
			
			uci_set "dhcp" "$config" "authoritative" "$authoritative"
			uci_set "dhcp" "$config" "domain" "$domain"
			uci_set "dhcp" "$config" "local" "/$domain/"
			uci_set "dhcp" "$config" "boguspriv" "$boguspriv"
			uci_set "dhcp" "$config" "filterwin2k" "$filterwin2k"
			uci_set "dhcp" "$config" "localise_queries" "$localise_queries"
			uci_set "dhcp" "$config" "expandhosts" "$expandhosts"
			uci_set "dhcp" "$config" "nonegcache" "$nonegcache"
			uci_set "dhcp" "$config" "readethers" "$readethers"
			uci_set "dhcp" "$config" "leasefile" "$leasefile"
		done
			
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
