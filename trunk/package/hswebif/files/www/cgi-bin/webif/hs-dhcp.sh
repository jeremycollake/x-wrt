#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings network
load_settings hotspot
. /usr/lib/webif/hs.sh

if empty "$FORM_submit"; then 
    FORM_hs_uamlisten=${hs_uamlisten:-$HS_UAMLISTEN}
    FORM_hs_network=${hs_network:-$HS_NETWORK}
    FORM_hs_netmask=${hs_netmask:-$HS_NETMASK}
    FORM_hs_dynip=${hs_dynip:-$HS_DYNIP}
    FORM_hs_dynip_mask=${hs_dynip_mask:-$HS_DYNIP_MASK}
    FORM_hs_statip=${hs_statip:-$HS_STATIP}
    FORM_hs_statip_mask=${hs_statip_mask:-$HS_STATIP_MASK}
else 
    SAVED=1
    case ${hs_mode:-$HS_MODE} in
	combined)
	    FORM_hs_uamlisten=${hs_uamlisten:-$HS_UAMLISTEN}
	    FORM_hs_network=${hs_network:-$HS_NETWORK}
	    FORM_hs_netmask=${hs_netmask:-$HS_NETMASK}
	    ;;
	wireless)
	    validate <<EOF
ip|FORM_hs_uamlisten|HotSpot Internal IP|required|$FORM_hs_uamlisten
network|FORM_hs_network|HotSpot DHCP Network|required|$FORM_hs_network
netmask|FORM_hs_netmask|HotSpot DHCP Netmask|required|$FORM_hs_netmask
EOF
	    equal "$?" 0 && {
		[ "$FORM_hs_network" = "$HS_NETWORK" ] || \
		    save_setting hotspot hs_network "$FORM_hs_network"
		[ "$FORM_hs_netmask" = "$HS_NETMASK" ] || \
		    save_setting hotspot hs_netmask "$FORM_hs_netmask"
		[ "$FORM_hs_uamlisten" = "$HS_UAMLISTEN" ] || \
		    save_setting hotspot hs_uamlisten "$FORM_hs_uamlisten"
	    }
	    ;;
    esac
    validate <<EOF
ip|FORM_hs_dynip|Dynamic DHCP IP Pool||$FORM_hs_dynip
netmask|FORM_hs_dynip_mask|Dynamic DHCP IP Pool Netmask||$FORM_hs_dynip_mask
ip|FORM_hs_statip|Static DHCP IP Pool||$FORM_hs_statip
netmask|FORM_hs_statip_mask|Static DHCP IP Pool Netmask||$FORM_hs_statip_mask
EOF
    equal "$?" 0 && {
    	[ "$FORM_hs_dynip" = "$HS_DYNIP" ] || \
		save_setting hotspot hs_dynip "$FORM_hs_dynip"
    	[ "$FORM_hs_dynip_mask" = "$HS_DYNIP_MASK" ] || \
		save_setting hotspot hs_dynip_mask "$FORM_hs_dynip_mask"
    	save_setting hotspot hs_statip "$FORM_hs_statip"
    	save_setting hotspot hs_statip_mask "$FORM_hs_statip_mask"
    }
fi

header "HotSpot" "DHCP" "HotSpot DHCP Configs $HS_USING" '' "$SCRIPT_NAME"
ShowUntestedWarning


has_required_pkg && {

if equal "$pkg" "wifidog"; then
    echo "<p>No DHCP settings for WiFiDog access controller.</p>"
else

[ "${hs_mode:-$HS_MODE}" = "combined" ] && {
    note1='helpitem|Note
helptext|Using <a href="lan.sh">LAN</a> Settings when running HotSpot services on both wired and wireless interfaces'
    script1='<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
  document.getElementById("hs_uamlisten").disabled = true;
  document.getElementById("hs_network").disabled = true;
  document.getElementById("hs_netmask").disabled = true;
</script>'
}

display_form <<EOF
start_form|HotSpot DHCP Configurations
$note1
field|HotSpot Internal IP Address
text|hs_uamlisten|$FORM_hs_uamlisten
field|HotSpot DHCP Network
text|hs_network|$FORM_hs_network
field|HotSpot DHCP Netmask
text|hs_netmask|$FORM_hs_netmask
end_form
start_form|Optional Advanced Settings
helpitem|Dynamic IP Pool
helptext|Explicitly set the Dynamic IP Pool network and netmask (ex: 10.1.1.0, 255.255.255.0) which must be a subnet of the DHCP Network
field|Dynamic IP Pool Network
text|hs_dynip|$FORM_hs_dynip
field|Dynamic IP Pool Netmask
text|hs_dynip_mask|$FORM_hs_dynip_mask
helpitem|Static IP Pool
helptext|Static IP Pool used for RADIUS IP allocation network and netmask (ex: 10.1.2.0, netmask 255.255.255.0) which must be a subnet of the DHCP Network
field|Static IP Pool Network
text|hs_statip|$FORM_hs_statip
field|Static IP Pool Netmask
text|hs_statip_mask|$FORM_hs_statip_mask
end_form
EOF

echo $script1

fi

}

footer ?>
<!--
##WEBIF:name:HotSpot:3:DHCP
-->
