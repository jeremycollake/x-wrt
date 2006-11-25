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
	SAVED=1
	validate <<EOF
int|FORM_wan_dowload|WAN Download Speed||$FORM_wan_download
int|FORM_wan_upload|WAN Upload Speed||$FORM_wan_upload
EOF
	equal "$?" "0" && {
		uci_set "qos" "wan" "enabled" "$FORM_wan_enabled"
		! empty "$FORM_wan_download" && {
			uci_set "qos" "wan" "download" "$FORM_wan_download"
		}
		! empty "$FORM_wan_upload" && {
			uci_set "qos" "wan" "upload" "$FORM_wan_upload"
		}
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
helptext|HelpText Advanced#The rest of the configuration is stored in /etc/config/qos. Its default state suffices for most users.
string|<a href="./system-editor.sh?path=/etc/config&amp;edit=qos">@TR<<edit_qos_cfg#Edit Config File>></a>
end_form
EOF


# show the current ruleset in a table
cat <<EOF
<div class="settings">
<div class="settings-title"><h3>@TR<<Current QoS Configuration>></h3></div>
</div>
<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="0" align="center"><tbody>
<tr><th>Group</th><th>Protocol</th><th>L7 Filters</th><th>Port range</th><th>Ports</th></tr>
EOF

# outputs variable to a column
show_column() 
{
	# cfg number
	# option name
	# bgcolor (optional)
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

ALT_BACKGROUND_COLOR_1="#e5e7e9"

count=2 # wan interface config is the first
while [ 1 ]; do
	eval _type="\"\$CONFIG_cfg${count}_TYPE\""
	empty "$_type" && break
	equal "$_type" "classify" && {
		if equal "$cur_color" "$ALT_BACKGROUND_COLOR_1"; then
			cur_color=""
		else
			cur_color="$ALT_BACKGROUND_COLOR_1"
		fi
		echo "<tr>"
		show_column "$count" "target" "$cur_color"		
		eval _val="\"\$CONFIG_cfg${count}_ipp2p\""
		if empty "$_val"; then
		 	show_column "$count" "proto" "$cur_color"
		else
			show_column "$count" "proto" "$cur_color" "peer-2-peer"
		fi		
		show_column "$count" "layer7" "$cur_color"
		show_column "$count" "portrange" "$cur_color"
		show_column "$count" "ports" "$cur_color"
		echo "</tr>"
	}
	let count+=1
done

cat <<EOF
</tbody></table>
EOF

show_validated_logo
