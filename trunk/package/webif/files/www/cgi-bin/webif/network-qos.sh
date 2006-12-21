#!/usr/bin/webif-page
<?
###################################################################
# qos-scripts configuration page
#
# This page is synchronized between kamikaze and WR branches. Changes to it *must* 
# be followed by running the webif-sync.sh script.
#
# Description:
#	Configures the qos-scripts package.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#   /etc/config/qos
#
#
. /usr/lib/webif/webif.sh

G_SHOW_ADVANCED_RULES="1"	# if set, 'default' and 'reclassify' rules shown too

header "Network" "QoS" "@TR<<QOS Configuration>>" ' onload="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_nbd"; then
	echo "Installing Nbd's QoS scripts ...<pre>"
	! install_package "qos-scripts" && {
		install_package "http://ftp.berlios.de/pub/xwrt/packages/qos-scripts_0.9.1-1_mipsel.ipk"
	}
	echo "</pre>"
fi

is_package_installed "qos-re" && {
	echo "<div class=\"warning\">Rudy's QoS scripts are found installed. Be sure to uninstall Rudy's scripts before using the new qos-scripts package.</div>"
}

# TODO: move this to shared functions somewhere
# set an option, or remove it if the value is empty
uci_set_value_remove_if_empty() {
	local _package="$1"
	local _config="$2"	
	local _option="$3"
	local _value="$4"
	if ! empty "$_value"; then
		uci_set "$_package" "$_config" "$_option" "$_value"
	else
		uci_remove "$_package" "$_config" "$_option"
	fi
}

if is_package_installed "qos-scripts"; then
! empty "$FORM_submit" && empty "$FORM_install_nbd" && {	
	current_qos_item="$FORM_current_rule_index"	
	! equal "$current_qos_item" "0" && {		
		# for validation purposes, replace non-numeric stuff in
		# ports list and port range with integer.				
		ports_validate=$(echo "$FORM_current_ports" | sed s/','/'0'/g)
		portrange_validate=$(echo "$FORM_current_portrange" | sed s/'-'/'0'/g)		
validate <<EOF
int|ports_validate|@TR<<Port Listing>>||$ports_validate
int|portrange_validate|@TR<<Port Range>>||$portrange_validate
ip|FORM_current_srchost|@TR<<Source IP>>||$FORM_current_srchost
ip|FORM_current_dsthost|@TR<<Dest IP>>||$FORM_current_dsthost
EOF
		if ! equal "$?" "0"; then			
			echo "<div class=\"warning\">Validation of one or more fields failed! Not saving.</div>"
		else
			SAVED=1
			uci_set "qos" "$current_qos_item" "target" "$FORM_current_target"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "srchost" "$FORM_current_srchost"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "dsthost" "$FORM_current_dsthost"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "proto" "$FORM_current_proto"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "ports" "$FORM_current_ports"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "portrange" "$FORM_current_portrange"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "layer7" "$FORM_current_layer7"
			uci_set_value_remove_if_empty "qos" "$current_qos_item" "ipp2p" "$FORM_current_ipp2p"
		fi
	}
	
	validate <<EOF
int|FORM_wan_dowload|WAN Download Speed||$FORM_wan_download
int|FORM_wan_upload|WAN Upload Speed||$FORM_wan_upload
EOF
	equal "$?" "0" && {
		SAVED=1
		uci_load qos # to check existing variables
		! equal "$FORM_wan_enabled" "$CONFIG_wan_enabled" && {
		 	uci_set "qos" "wan" "enabled" "$FORM_wan_enabled"
		}
		! empty "$FORM_wan_download" && ! equal "$FORM_wan_download" "$CONFIG_wan_download" && {
			uci_set "qos" "wan" "download" "$FORM_wan_download"
		}
		! empty "$FORM_wan_upload" && ! equal "$FORM_wan_upload" "$CONFIG_wan_upload" && {
			uci_set "qos" "wan" "upload" "$FORM_wan_upload"
		}
	}
}

#
# handle 'add new rule'
#
! empty "$FORM_qos_add" && {	
	# todo: this add needs to be in the save area, causes instant save here	of
	#       an empty rule here. However, requires more work than a simple move ;).
	uci_add "qos" "classify" ""
}
	
#
# handle 'remove' (qos rule)
#
! empty "$FORM_qos_remove" && {
	current_qos_item=$(echo "$QUERY_STRING" | grep "qos_remove=" | cut -d'=' -f2)	
	! empty "$current_qos_item" && {		
		# also manually clear the other options so they are immediately empty		
		uci_set "qos" "$current_qos_item" "srchost" ""
		uci_set "qos" "$current_qos_item" "dsthost" ""
		uci_set "qos" "$current_qos_item" "proto" ""
		uci_set "qos" "$current_qos_item" "layer7" ""
		uci_set "qos" "$current_qos_item" "ipp2p" ""
		uci_set "qos" "$current_qos_item" "ports" ""
		uci_set "qos" "$current_qos_item" "portrange" ""
		# show 'deleted' as target to indicate pending delete
		uci_set "qos" "$current_qos_item" "target" "deleted"
		uci_remove "qos" "$current_qos_item"
	}
}

# copy a rule to another - used by swap_rule()
copy_rule()
{
	local rule1_index=$1
	local rule2_index=$2
	eval _target="\"\$CONFIG_${rule2_index}_target\""	
	eval _srchost="\"\$CONFIG_${rule2_index}_srchost\""
	eval _dsthost="\"\$CONFIG_${rule2_index}_dsthost\""		
	eval _proto="\"\$CONFIG_${rule2_index}_proto\""
	eval _ports="\"\$CONFIG_${rule2_index}_ports\""
	eval _portrange="\"\$CONFIG_${rule2_index}_portrange\""
	eval _layer7="\"\$CONFIG_${rule2_index}_layer7\""	
	eval _ipp2p="\"\$CONFIG_${rule2_index}_ipp2p\""
	uci_set_value_remove_if_empty "qos" "$rule1_index" "target" "$_target"	
	uci_set_value_remove_if_empty "qos" "$rule1_index" "srchost" "$_srchost"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "dsthost" "$_dsthost"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "proto" "$_proto"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "layer7" "$_layer7"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "ipp2p" "$_ipp2p"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "ports" "$_ports"
	uci_set_value_remove_if_empty "qos" "$rule1_index" "portrange" "$_portrange"
}

# swap a rule with another - for up/down
swap_rule()
{
	local rule1_index=$1
	local rule2_index=$2
	copy_rule "$1" "$2"
	copy_rule "$2" "$1"
	# now a uci_load will reload swapped rules
}

#
# handle 'up' or 'down' (qos rule)
#
! empty "$FORM_qos_swap_dest" && ! empty "$FORM_qos_swap_src" && {
	uci_load "qos"
	swap_rule "$FORM_qos_swap_dest" "$FORM_qos_swap_src"
}	
	
uci_load "qos"
FORM_wan_enabled="$CONFIG_wan_enabled"
FORM_wan_download="$CONFIG_wan_download"
FORM_wan_upload="$CONFIG_wan_upload"

######################################################################
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

function modechange()
{		
	if(isset('wan_enabled','1'))
	{
		document.getElementById('wan_upload').disabled = false;
		document.getElementById('wan_download').disabled = false;
	}
	else
	{
		document.getElementById('wan_upload').disabled = true;
		document.getElementById('wan_download').disabled = true;		
	}
}
</script>
EOF
######################################################################

display_form <<EOF
onchange|modechange
start_form|@TR<<QoS Options>>
field|@TR<<QoS Service>>|field_n_enabled
select|wan_enabled|$FORM_wan_enabled
option|1|Enabled
option|0|Disabled
field|@TR<<WAN Upload Speed>>|field_n_wan_upload
text|wan_upload|$FORM_wan_upload| @TR<<kilobits>>
helpitem|Maximum Upload/Download
helptext|HelpText Maximum Upload#Your maximum sustained upload and download speeds, in kilobits.
field|@TR<<WAN Download Speed>>|field_n_wan_download
text|wan_download|$FORM_wan_download| @TR<<kilobits>>
helpitem|Advanced
helptext|HelpText Advanced#Normally users just use the form below to configure QoS. Some people may need access to the more advanced settings. Most people do NOT and should NOT. <a href="./system-editor.sh?path=/etc/config&amp;edit=qos">Manually edit config</a>
end_form
EOF

# show the current ruleset in a table
display_form <<EOF
start_form|@TR<<QoS Traffic Classification Rules>>
end_form
EOF

cat <<EOF
<table style="width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;" border="0" cellpadding="3" cellspacing="2"><tbody>
<tr>
<th>@TR<<Group>></th>
<th>@TR<<Source IP>></th>
<th>@TR<<Dest. IP>></th>
<th>@TR<<Protocol>></th>
<th>@TR<<Layer-7>></th>
<th>@TR<<Port range>></th>
<th>@TR<<Ports>></th>
EOF
equal "$G_SHOW_ADVANCED_RULES" "1" && {
	cat <<EOF
	<th>@TR<<Type>></th>
	<th>@TR<<Flags>></th>
	<th>@TR<<PktSize>></th>
	<th>@TR<<Mark>></th>
EOF
}
cat <<EOF
<th></th>
</tr>
EOF

# outputs variable to a column
show_column()
{
	# section name
	# option name
	# cell bgcolor (optional)
	# over-ride text (if config option is empty)
	local _val
	config_get _val "$1" "$2"
	td_start="<td>"
	! empty "$3" && td_start="<td bgcolor=\"$3\">"
	echo "$td_start"
	echo "${_val:-$4}"
	echo "</td>"
}

#
# callback for sections
#
local last_shown_rule="-1"
callback_foreach_rule() {
	local count=$1
	config_get _type "$count" "TYPE"
	case $_type in
		"classify") ;;
		"reclassify") equal "$G_SHOW_ADVANCED_RULES" "0" && return;;
		"default") equal "$G_SHOW_ADVANCED_RULES" "0" && return;;
		*) return;;
	esac
	equal "$_type" "classify" && {	
		## finishing previous table entry
		# for 'down' since we didn't know index of next classify item.
		# if there is a last shown rule, show 'up' option for PREVIOUS rule
		! equal "$last_shown_rule" "-1" && {
		 	echo "<a href=\"$SCRIPT_NAME?qos_swap_dest=$count&amp;qos_swap_src=$last_shown_rule\">@TR<<down>></a>"
			echo "</td></tr>"
		}	
		## end finishing last iteration

		if equal "$cur_color" "even"; then
			cur_color="odd"
		else
			cur_color="even"
		fi
		echo "<tr class=\"$cur_color\">"		
		show_column "$count" "target" "" "..."
		show_column "$count" "srchost" ""
		show_column "$count" "dsthost" ""
		eval _val="\"\$CONFIG_${count}_ipp2p\""
		if empty "$_val"; then
		 	show_column "$count" "proto" ""
		else
			equal "$_val" "all" && _val="peer-2-peer"
			show_column "$count" "proto" "" "$_val"
		fi		
		show_column "$count" "layer7" ""
		show_column "$count" "portrange" ""
		show_column "$count" "ports" ""
		equal "$G_SHOW_ADVANCED_RULES" "1" && show_column "$count" "TYPE" "" ""		
		equal "$G_SHOW_ADVANCED_RULES" "1" && show_column "$count" "tcpflags" "" ""
		equal "$G_SHOW_ADVANCED_RULES" "1" && show_column "$count" "pktsize" "" ""
		equal "$G_SHOW_ADVANCED_RULES" "1" && show_column "$count" "mark" "" ""
		echo "<td bgcolor=\"$cur_color\"><a href=\"$SCRIPT_NAME?qos_edit=$count\">@TR<<edit>></a>&nbsp;"
		echo "<a href=\"$SCRIPT_NAME?qos_remove=$count\">@TR<<delete>></a>&nbsp;"
		# if there is a last shown rule, show 'up' option
		! equal "$last_shown_rule" "-1" && {
		 	echo "<a href=\"$SCRIPT_NAME?qos_swap_src=$count&amp;qos_swap_dest=$last_shown_rule\">@TR<<up>></a>&nbsp;"
		}
		# if we are adding, always keep last index in FORM_qos_edit
		! empty "$FORM_qos_add" && FORM_qos_edit="$count"
		last_shown_rule="$count"
	}
}

config_foreach callback_foreach_rule

# if we showed any rules, finish table row
! equal "$last_shown_rule" "-1" && {
	echo "</td></tr>"
}

cat <<EOF
<tr><td><a href="$SCRIPT_NAME?qos_add=1">@TR<<new rule>></a></td></tr>
</tbody></table>
EOF

# 
# handle 'edit' (qos rule)
#
#
! empty "$FORM_qos_edit" && {	
	# for padding as if the qos table was encpasulated in std form
	display_form <<EOF
	start_form
	end_form
EOF
	#
	# build list of available L7-protocols
	#	
	l7_protocols="option||None"
	for curfile in /etc/l7-protocols/*; do
		_l7basename=$(basename "$curfile" | sed s/'.pat'//g)
		l7_protocols="$l7_protocols
			option|$_l7basename|$_l7basename"
	done
	
	current_item="$FORM_qos_edit"
	config_get _target "${current_item}" "target"
	config_get _srchost "${current_item}" "srchost"
	config_get _dsthost "${current_item}" "dsthost"
	config_get _proto "${current_item}" "proto"
	config_get _ports "${current_item}" "ports"
	config_get _portrange "${current_item}" "portrange"
	config_get _layer7 "${current_item}" "layer7"
	equal "$G_SHOW_ADVANCED_RULES" "1" && {
		config_get _ipp2p "${current_item}" "ipp2p"
		config_get _mark "${current_item}" "mark"
		config_get _tcpflags "${current_item}" "tcpflags"
		config_get _pktsize "${current_item}" "pktsize"
	}
	display_form <<EOF
	start_form|@TR<<QoS Rule Edit>>
	field|@TR<<Rules Index>>|rule_number|hidden
	text|current_rule_index|$current_item|hidden
	field|@TR<<Classify As>>|current_target
	select|current_target|$_target
	option|Bulk|Bulk
	option|Normal|Normal
	option|Priority|Priority
	option|Express|Express
	field|@TR<<Source IP>>|current_srchost
	text|current_srchost|$_srchost
	field|@TR<<Dest IP>>|current_dsthost
	text|current_dsthost|$_dsthost
	field|@TR<<Protocol>>|proto
	select|current_proto|$_proto
	option||Any
	option|tcp|TCP
	option|udp|UDP	
	field|@TR<<Ports>>|current_ports
	text|current_ports|$_ports
	field|@TR<<Port Range>>|current_portrange
	text|current_portrange|$_portrange
	field|@TR<<Layer7>>|current_layer7
	select|current_layer7|$_layer7
	$l7_protocols
	field|@TR<<Peer-2-Peer>>|ipp2p
	select|current_ipp2p|$_ipp2p
	option||None
	option|all|All
	option|bit|bitTorrent
	option|dc|DirectConnect
	option|edk|eDonkey
	option|gnu|Gnutella
	option|kazaa|Kazaa
	helpitem|QoS Rule Edit
	helptext|HelPText qos_rule_edit_help#You need only set fields you wish to match traffic on. Leave the others blank.
	helpitem|Layer-7
	helptext|HelpText layer7_help#Layer-7 filters are used to identify types of traffic based on content inspection. Numerous layer-7 filters are available on the web, though not all are efficient and accurate. To install more filters, download them and put them in /etc/l7-protocols.
	helpitem|Peer-2-Peer
	helptext|HelpText p2p_help#The difference between the Peer-2-Peer field and layer-7 filters is simply that the Peer-2-Peer option uses a special tool, ipp2p, to match traffic of common p2p protocols. It is typically more efficient than layer-7 filters.
	end_form
EOF
}
else
	echo "<div class=\"warning\">A compatible QOS package was not found to be installed.</div>"

display_form <<EOF
onchange|modechange
start_form|@TR<<QoS Packages>>
field|Nbd's QoS Scripts (recommended)|nbd_qos
submit|install_nbd|Install
end_form
EOF
fi

#show_validated_logo

footer ?>
<!--
##WEBIF:name:Network:600:QoS
-->
