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

if is_package_installed "qos-scripts"; then
! empty "$FORM_submit" && empty "$FORM_install_nbd" && {	
	current_qos_item="$FORM_current_rule_index"	
	! equal "$current_qos_item" "0" && {		
		# for validation purposes, replace non-numeric stuff in
		# ports list and port range with integer.				
		ports_validate=$(echo "$FORM_current_ports" | sed s/','/'0'/g)
		portrange_validate=$(echo "$FORM_current_portrange" | sed s/'-'/'0'/g)
		echo "validating..."
validate <<EOF
int|ports_validate|@TR<<Port Listing>>||$ports_validate
int|portrange_validate|@TR<<Port Range>>||$portrange_validate
ip|FORM_current_srchost|@TR<<Source IP>>||$FORM_current_srchost
ip|FORM_current_dsthost|@TR<<Dest IP>>||$FORM_current_dsthost
EOF
		if ! equal "$?" "0"; then
			echo "FAILED"
			echo "<div class=\"warning\">Validation of one or more fields failed! Not saving.</div>"
		else
			SAVED=1
			uci_set "qos" "cfg$current_qos_item" "target" "$FORM_current_target"
			if ! empty "$FORM_current_srchost"; then			
				uci_set "qos" "cfg$current_qos_item" "srchost" "$FORM_current_srchost"
			else
				uci_remove "qos" "cfg$current_qos_item" "srchost" "$FORM_current_srchost"
			fi
			if ! empty "$FORM_current_dsthost"; then			
				uci_set "qos" "cfg$current_qos_item" "dsthost" "$FORM_current_dsthost"
			else
				uci_remove "qos" "cfg$current_qos_item" "dsthost" "$FORM_current_dsthost"
			fi
			if ! empty "$FORM_current_proto"; then
				uci_set "qos" "cfg$current_qos_item" "proto" "$FORM_current_proto"
			else
				uci_remove "qos" "cfg$current_qos_item" "proto"
			fi
			if ! empty "$FORM_current_ports"; then			
				uci_set "qos" "cfg$current_qos_item" "ports" "$FORM_current_ports"
			else
				uci_remove "qos" "cfg$current_qos_item" "ports" "$FORM_current_ports"
			fi
			if ! empty "$FORM_current_portrange"; then
				uci_set "qos" "cfg$current_qos_item" "portrange" "$FORM_current_portrange"
			else
				uci_remove "qos" "cfg$current_qos_item" "portrange" "$FORM_current_portrange"
			fi
			if ! empty "$FORM_current_layer7"; then			
				uci_set "qos" "cfg$current_qos_item" "layer7" "$FORM_current_layer7"
			else
				uci_remove "qos" "cfg$current_qos_item" "layer7" "$FORM_current_layer7"
			fi
			if ! empty "$FORM_current_ipp2p"; then
				uci_set "qos" "cfg$current_qos_item" "ipp2p" "$FORM_current_ipp2p"
			else
				uci_remove "qos" "cfg$current_qos_item" "ipp2p" "$FORM_current_ipp2p"
			fi
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
		uci_set "qos" "cfg$current_qos_item" "srchost" ""
		uci_set "qos" "cfg$current_qos_item" "dsthost" ""
		uci_set "qos" "cfg$current_qos_item" "proto" ""
		uci_set "qos" "cfg$current_qos_item" "layer7" ""
		uci_set "qos" "cfg$current_qos_item" "ipp2p" ""
		uci_set "qos" "cfg$current_qos_item" "ports" ""
		uci_set "qos" "cfg$current_qos_item" "portrange" ""
		# show 'deleted' as target to indicate pending delete
		uci_set "qos" "cfg$current_qos_item" "target" "deleted"
		uci_remove "qos" "cfg$current_qos_item"
	}
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
EOF

cat <<EOF
<table style="width: 100%; text-align: left; font-size: 0.8em;" border="0" cellpadding="2" cellspacing="1"><tbody>
<tr>
<th>@TR<<Group>></th>
<th>@TR<<Source IP>></th>
<th>@TR<<Dest IP>></th>
<th>@TR<<Protocol>></th>
<th>@TR<<Layer7>></th>
<th>@TR<<Port range>></th>
<th>@TR<<Ports>></th>
<th></th>
</tr>
EOF

# outputs variable to a column
show_column()
{
	# cfg number
	# option name
	# cell bgcolor (optional)
	# over-ride text (if config option is empty)
	local _val
	eval _val="\"\$CONFIG_cfg${1}_${2}\""		
	td_start="<td>"
	! empty "$3" && td_start="<td bgcolor=\"$3\">"
	echo "$td_start"	
	if empty "$_val" && ! empty "$4"; then	
		echo "$4"
	else
		echo "$_val"
	fi	
	echo "</td>"			
}

# TODO:
#
# We can't just break out when we think we're at the end
# because new classification rules get added to the very bottom.
# Possible solutions:
#
#       * uci_insert function (best)
#       * variable that contains count of UCI config groups loaded
#         (so we at least know the real end).
#
for count in $(seq 2 100); do 	# !! see note above for static limit rationale !!
	eval _type="\"\$CONFIG_cfg${count}_TYPE\""	
	equal "$_type" "classify" && {
		if equal "$cur_color" "even"; then
			cur_color="odd"
		else
			cur_color="even"
		fi
		echo "<tr class=\"$cur_color\">"
		show_column "$count" "target" "" "..."
		show_column "$count" "srchost" ""
		show_column "$count" "dsthost" ""
		eval _val="\"\$CONFIG_cfg${count}_ipp2p\""
		if empty "$_val"; then
		 	show_column "$count" "proto" ""
		else
			equal "$_val" "all" && _val="peer-2-peer"
			show_column "$count" "proto" "" "$_val"
		fi		
		show_column "$count" "layer7" ""
		show_column "$count" "portrange" ""
		show_column "$count" "ports" ""
		echo "<td bgcolor=\"$cur_color\"><a href=\"$SCRIPT_NAME?qos_edit=$count\">@TR<<edit>></a>&nbsp;"
		echo "<a href=\"$SCRIPT_NAME?qos_remove=$count\">@TR<<remove>></a></td>"
		echo "</tr>"
		# if we are adding, always keep last index in FORM_qos_edit
		! empty "$FORM_qos_add" && FORM_qos_edit="$count"
	}
done

cat <<EOF
<tr><td><a href="$SCRIPT_NAME?qos_add=1">@TR<<new rule>></a></td></tr>
</tbody></table>
EOF

display_form <<EOF
helpitem|Default QoS
helptext|HelpText default_qos#The QoS package is pre-configured for the majority of users. Peer-2-peer traffic such as bittorrent is marked as 'bulk' and common network services that require responsiveness are marked in higher priorities. Additionally, TCP SYN/ACK packets and DNS queries are given very high priority to ensure speedy networking performance.
end_form
EOF

# 
# handle 'edit' (qos rule)
#
#
! empty "$FORM_qos_edit" && {	
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
	eval _target="\"\$CONFIG_cfg${current_item}_target\""	
	eval _srchost="\"\$CONFIG_cfg${current_item}_srchost\""
	eval _dsthost="\"\$CONFIG_cfg${current_item}_dsthost\""		
	eval _proto="\"\$CONFIG_cfg${current_item}_proto\""
	eval _ports="\"\$CONFIG_cfg${current_item}_ports\""
	eval _portrange="\"\$CONFIG_cfg${current_item}_portrange\""
	eval _layer7="\"\$CONFIG_cfg${current_item}_layer7\""	
	eval _ipp2p="\"\$CONFIG_cfg${current_item}_ipp2p\""
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
