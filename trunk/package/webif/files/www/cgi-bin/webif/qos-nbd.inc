###################################################################
# Nbd QoS scripts config
#
# Description:
#	Configures nbd's QoS scripts.
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
! empty "$FORM_submit" && {	
	#
	# determine if user was editing a QoS classification entry by checking
	# HTTP_REFERER. May want to change this method.
	#
	current_qos_item=$(echo "$HTTP_REFERER" | grep "qos_edit=" | cut -d'=' -f2)	
	! empty "$current_qos_item" && {				
		# for validation purposes, replace non-numeric stuff in
		# ports list and port range with integer.				
		ports_validate=$(echo "$FORM_current_ports" | sed s/','/'0'/g)
		portrange_validate=$(echo "$FORM_current_portrange" | sed s/'-'/'0'/g)
		validate <<EOF
			int|ports_validate|Port Listing||$ports_validate
			int|portrange_validate|Port Range||$portrange_validate				
EOF
		equal "$?" "0" && {
			SAVED=1				
			uci_set "qos" "cfg$current_qos_item" "target" "$FORM_current_target"
			uci_set "qos" "cfg$current_qos_item" "proto" "$FORM_current_proto"
			uci_set "qos" "cfg$current_qos_item" "ports" "$FORM_current_ports"			
			uci_set "qos" "cfg$current_qos_item" "portrange" "$FORM_current_portrange"
			uci_set "qos" "cfg$current_qos_item" "layer7" "$FORM_current_layer7"			
			uci_set "qos" "cfg$current_qos_item" "ipp2p" "$FORM_current_ipp2p"		
		}						
	}			
	
	validate <<EOF
int|FORM_wan_dowload|WAN Download Speed||$FORM_wan_download
int|FORM_wan_upload|WAN Upload Speed||$FORM_wan_upload
EOF
	equal "$?" "0" && {
		SAVED=1		
		uci_set "qos" "wan" "enabled" "$FORM_wan_enabled"
		! empty "$FORM_wan_download" && {
			uci_set "qos" "wan" "download" "$FORM_wan_download"
		}
		! empty "$FORM_wan_upload" && {
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
		# TODO: This isn't always working when the item is non-empty, possibly because of a problem with 
		#       uci_unset.
		#uci_remove "qos" "cfg$current_qos_item"
		#
		# Until the above works, we'll just clear everything .. not ideal, but..	
		# 
		uci_set "qos" "cfg$current_qos_item" "target" ""
		uci_set "qos" "cfg$current_qos_item" "proto" ""
		uci_set "qos" "cfg$current_qos_item" "ports" ""
		uci_set "qos" "cfg$current_qos_item" "portrange" ""
		uci_set "qos" "cfg$current_qos_item" "layer7" ""
		uci_set "qos" "cfg$current_qos_item" "ipp2p" ""
	}
}
	
uci_load qos
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
helpitem|Maximum Upload
helptext|HelpText Maximum Upload#This should be about 90% of your maximum sustained WAN upload throughput, in kilobits.
helpitem|Maximum Download
helptext|HelpText Maximum Download#This should be about 95% of your maximum sustained WAN download throughput, in kilobits.
field|@TR<<WAN Download Speed>>|field_n_wan_download
text|wan_download|$FORM_wan_download| @TR<<kilobits>>
field|@TR<<Advanced>>|field_n_advanced
helpitem|Advanced
helptext|HelpText Advanced#The rest of the configuration is stored in /etc/config/qos.
string|<a href="./system-editor.sh?path=/etc/config&amp;edit=qos">@TR<<edit_qos_cfg#Edit Config File>></a>
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

#ALT_BACKGROUND_COLOR_1="#e5e7e9"

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
		show_column "$count" "target" ""		
		eval _val="\"\$CONFIG_cfg${count}_ipp2p\""
		if empty "$_val"; then
		 	show_column "$count" "proto" ""
		else
			show_column "$count" "proto" "" "peer-2-peer"
		fi		
		show_column "$count" "layer7" ""
		show_column "$count" "portrange" ""
		show_column "$count" "ports" ""		
		echo "<td bgcolor=\"$cur_color\"><a href=\"$SCRIPT_NAME?qos_edit=$count\">@TR<<edit>></a>&nbsp;"
		echo "<a href=\"$SCRIPT_NAME?qos_remove=$count\">@TR<<clear>></a></td>"
		echo "</tr>"
	}	
done

cat <<EOF
<tr><td><a href="$SCRIPT_NAME?qos_add=1">@TR<<new rule>></a></td></tr>
</tbody></table>
EOF

display_form <<EOF
helpitem|Default QoS
helptext|HelpText default_qos#he QoS package is pre-configured for the majority of users. Peer-2-peer traffic such as bittorrent is marked as 'bulk' and common network services that require responsiveness are marked in higher priorities. Additionally, TCP SYN/ACK packets and DNS queries are given very high priority to ensure speedy networking performance.
end_form
EOF

# 
# handle 'edit' (qos rule)
#
#
! empty "$FORM_qos_edit" && {	
	current_item="$FORM_qos_edit"
	eval _target="\"\$CONFIG_cfg${current_item}_target\""	
	eval _proto="\"\$CONFIG_cfg${current_item}_proto\""
	eval _ports="\"\$CONFIG_cfg${current_item}_ports\""
	eval _portrange="\"\$CONFIG_cfg${current_item}_portrange\""
	eval _layer7="\"\$CONFIG_cfg${current_item}_layer7\""	
	eval _ipp2p="\"\$CONFIG_cfg${current_item}_ipp2p\""
	display_form <<EOF
	start_form|@TR<<QoS Rule Edit>>
	field|@TR<<Classify As>>|current_target
	select|current_target|$_target
	option|Bulk|Bulk
	option|Normal|Normal
	option|Priority|Priority
	option|Express|Express
	field|@TR<<Protocol>>|proto
	select|current_proto|$_proto
	option||Any
	option|tcp|TCP
	option|udp|UDP
	option|tcp,udp|TCP/UDP
	field|@TR<<Ports>>|current_ports
	text|current_ports|$_ports
	field|@TR<<Port Range>>|current_portrange
	text|current_portrange|$_portrange
	field|@TR<<Layer7>>|current_layer7
	text|current_layer7|$_layer7
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

#show_validated_logo
