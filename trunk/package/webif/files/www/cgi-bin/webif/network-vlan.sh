#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"
###################################################################
# VLAN configuration page
#
# Description:
#	Configures any number of VLANs.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	vlan#ports
#	vlan#hwname
#
# Configuration files referenced:
#   none
#
load_settings network

header "Network" "VLAN" "@TR<<Virtual LANs>>" '' "$SCRIPT_NAME"

###################################################################
# toggles and default settings
#
ALLOW_VLAN_NUMBERING_GAPS=0 # toggle alowance of gaps, i.e. vlan0, vlan1, vlan5 are defined
				# note: allowing gaps makes for a much slower loading page since
				#  we have to search through MAX_VLANS instead of stopping at first
				#  unset vlan variable.
PORT_BASE=0		# base number of the ports
PORT_COUNT=6		# number of ports (todo: should determine dynamically)
MAX_PORT=5		# maximum port number (todo: should determine dynamically)
MAX_VLANS=16		# limit the switch can handle on the bcm947xx (todo: dynamically determine)
MAX_VLANS_INDEX=15	# like MAX_VLANS, except starts at 0 instead of 1
#for later use
HELP_TEXT=

###################################################################
# CountNumberOfVLANsThatContainPortX ( ### )
#
# used to test if a port is in another vlan, so we know if we should
# tag it or not. Returns count in RETURN_VAR.
#
# stops when it encounters more than 1...
#
CountNumberOfVLANsThatContainPortX ( )
{
	local lcount
	lcount="0"
	for count2 in $(seq "0" "$MAX_VLANS_INDEX"); do
		if [ -z $(nvram get vlan"$count2"hwname) ]; then
			break
		fi
		eval value="\"\$FORM_vlan_${count2}_port_${1}\""
		equal "$value" "1" &&
		{
			let "lcount+=1"
			equal "$lcount" "2" && break
		}
	done
	equal "$lcount" "1" && return 0
	return "1"
}

###################################################################
# save settings or handle input
#
if ! empty "$FORM_submit"; then
	SAVED=1

	#
	# handle add or remove
	#
	for count in $(seq 0 $MAX_VLANS_INDEX); do
		current_vlan_hw_nvram_name=vlan"$count"hwname
		if [ -z $(nvram get $current_vlan_hw_nvram_name) ]; then
			let "count-=1"
			break
		fi
	done

	#
	# now add or remove if appropriate.. we use vlanXhwname variable
	#  as indication of the existance of the vlan, to allow for
	#  empty vlans.
	#
	! empty "$FORM_add_vlan" &&
	{
		let "count+=1"
		nvram set vlan"$count"hwname=et0
	}
	! empty "$FORM_remove_vlan" &&
	{
		# todo: will not work if vlan0 doesn't exist..
		# nvram unset vlan"$count"hwname
		# better set it empty to force the user to save changes
		# where is the 'unset_setting' function?
		save_setting network "vlan${count}hwname" ""
		save_setting network "vlan${count}ports" ""
		let "count-=1"
	}
	highest_vlan=$count

	#
	# save VLAN configuration (also do add or remove)
	#
	for count in $(seq 0 $highest_vlan); do
		current_vlan_nvram_name=vlan"$count"ports
		current_vlan_hw_nvram_name=vlan"$count"hwname
		current_vlan_ports=""
		for port_counter in $(seq $PORT_BASE $MAX_PORT); do

			eval value="\"\$FORM_vlan_${count}_port_${port_counter}\""
			if [ "$value" = "1" ]; then
				if empty "$current_vlan_ports" ; then
					current_vlan_ports="$port_counter"
				else
					current_vlan_ports="$current_vlan_ports $port_counter"
				fi

				#
				# does port exist in alternate VLANs?
				#				
				! equal "$port_counter" "5" && {
					CountNumberOfVLANsThatContainPortX "$port_counter" || {
						# add 't' to indicate 'tagged'
						current_vlan_ports="${current_vlan_ports}t"
					}
				}
				#
				# if port 5 of vlan 0, add '*'
				# 
				equal "$count" "0" && equal "$port_counter" "5" && {
					current_vlan_ports="${current_vlan_ports}*"
				}
			fi
		done
		save_setting network "$current_vlan_hw_nvram_name" "et0"
		save_setting network "$current_vlan_nvram_name" "$current_vlan_ports"
	done

	load_settings network
fi

####################################################################
# add headers for the port numbers
#
uci_load "webif"

if echo "$CONFIG_general_device_name" | grep -iq "WRT54G"; then
	wan_port="4"
elif echo "$CONFIG_general_device_name" | grep -iq "WL-500g"; then
	wan_port="0"
elif echo "$CONFIG_general_device_name" | grep -iq "WHR-G54"; then
	wan_port="0"
elif echo "$CONFIG_general_device_name" | grep -iq "WHR-HP-G54"; then
	wan_port="0"
else
	wan_port="-1"
fi

FORM_port_headers="string|<tr><th></th>"
for current_port in $(seq $PORT_BASE $MAX_PORT); do
	current_hdr=""
	case $current_port in 
		"$wan_port") current_hdr="WAN";;
		"0" ) current_hdr="eNet0";;
		"1" ) current_hdr="eNet1";;
		"2" ) current_hdr="eNet2";;
		"3" ) current_hdr="eNet3";;
		"4" ) current_hdr="eNet4";;
		"5" ) current_hdr="Internal";;		
	esac
	FORM_port_headers="${FORM_port_headers}<th>$current_hdr</th>"
done
FORM_port_headers="${FORM_port_headers}</tr>"

####################################################################
# now create the vlan rows, one for each set vlan variable, even
#  if empty.
#
FORM_all_vlans="$FORM_port_headers"		# holds VLAN webif form we build
for count in $(seq "0" "$MAX_VLANS_INDEX"); do
	vlanport="vlan${count}ports"
	FORM_current_vlan="string|<tr><th>VLAN $count&nbsp;&nbsp;</th>"
	#
	# for each port, create a checkbox and mark if
	#  port for in vlan
	#
	FORM_log_ipaddr=${log_ipaddr:-$(nvram get log_ipaddr)}
	defaultval=$(nvram get "$vlanport")
	eval ports="\${vlan${count}ports:-\"$defaultval\"}"
	if [ -z "$ports" ]; then
		# make sure it really is unset and not just empty
		if [ -z $(nvram get vlan"$count"hwname) ]; then
			if [ $ALLOW_VLAN_NUMBERING_GAPS = 1 ]; then
				continue		# to allow vlan # gaps
			else
				break			# to disallow vlan # gaps
			fi
		fi
	fi
	for current_port in $(seq $PORT_BASE $MAX_PORT); do
		# if port in vlan, mark checkbox
		port_included=0
		# see if saved but uncommitted/applied or already set in form
		eval value="\"\$FORM_vlan_${count}_port_${current_port}\""
		eval value2="\"\$vlan_${count}_port_${current_port}\""
		# set if committed
		echo "$ports" | grep "$current_port" >> "/dev/null"  2>&1
		if equal "$?" "0" || equal "$value" "1" || equal "$value2" "1" ; then
			port_included=1
		fi
		variable_name="vlan_${count}_port_${current_port}"
		checkbox_string="checkbox|$variable_name|$port_included|1|&nbsp;"
		FORM_current_vlan="$FORM_current_vlan
			string|<td>
			$checkbox_string
			string|</td>"
	done
	FORM_all_vlans="$FORM_all_vlans
		$FORM_current_vlan
		string|</tr>"
done


###################################################################
# show form
#
display_form <<EOF
onchange|modechange
start_form|@TR<<VLAN Configuration>>
helpitem|VLAN
helptext|Helptext VLAN#A virtual LAN is a set of ports that are bridged to create what appears to be a LAN. Ports 0 through 4 are the 5 ports on the back of the router. Depending on the router, port 0 or port 4 is the WAN port and the others are the LAN ports. Port 5 is an internal port that connects the on-chip device to the switch itself.
helplink|http://wiki.openwrt.org/OpenWrtDocs/Configuration?highlight=%28wl0_mode%29#head-1f582c0ad21a03a769e00c345743d6cf85ba878f
$FORM_all_vlans
end_form
start_form|
string|<tr><td>
submit|add_vlan|@TR<<Add New VLAN>>
submit|remove_vlan|@TR<<Remove Last VLAN>>
string|</td></tr>
end_form
EOF

 footer ?>
<!--
##WEBIF:name:Network:250:VLAN
-->
