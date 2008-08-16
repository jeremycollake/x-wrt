#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Firewall configuration
#
# Description:
#	Firewall configuration.
#
# Author(s) [in order of work date]:
#	Original webif authors.
#	Travis Kemen	<kemen04@gmail.com>
# Major revisions:
#
# UCI variables referenced:
#
# Configuration files referenced:
#	firewall
#

#remove rule
if ! empty "$FORM_remove_vcfg"; then
	uci_remove "firewall" "$FORM_remove_vcfg"
fi

#Add new rule
if [ -n "$FORM_port_rule" ]; then
	uci_add "firewall" "rule" "$FORM_name"; add_rule_cfg="$CONFIG_SECTION"
	uci_set "firewall" "$add_rule_cfg" "src" "wan"
	uci_set "firewall" "$add_rule_cfg" "proto" "$FORM_protocol_rule"
	uci_set "firewall" "$add_rule_cfg" "src_ip" "$FORM_src_ip_rule"
	uci_set "firewall" "$add_rule_cfg" "dest_ip" "$FORM_dest_ip_rule"
	uci_set "firewall" "$add_rule_cfg" "dest_port" "$FORM_port_rule"
	uci_set "firewall" "$add_rule_cfg" "target" "ACCEPT"
fi
#Add new rule
if [ -n "$FORM_dest_port_redirect" ]; then
	uci_add "firewall" "redirect" "$FORM_name_redirect"; add_redirect_cfg="$CONFIG_SECTION"
	uci_set "firewall" "$add_redirect_cfg" "src" "wan"
	uci_set "firewall" "$add_redirect_cfg" "proto" "$FORM_protocol_redirect"
	uci_set "firewall" "$add_redirect_cfg" "src_ip" "$FORM_src_ip_redirect"
	uci_set "firewall" "$add_redirect_cfg" "src_dport" "$FORM_src_dport_redirect"
	uci_set "firewall" "$add_redirect_cfg" "dest_ip" "$FORM_dest_ip_redirect"
	uci_set "firewall" "$add_redirect_cfg" "dest_port" "$FORM_dest_port_redirect"
fi

config_cb() {
	local cfg_type="$1"
	local cfg_name="$2"

	case "$cfg_type" in
		forwarding)
			append forwarding_cfgs "$cfg_name"
		;;
		zone)
			append zone_cfgs "$cfg_name" "$N"
		;;
		rule)
			append rule_cfgs "$cfg_name" "$N"
		;;
		redirect)
			append redirect_cfgs "$cfg_name" "$N"
		;;
		interface)
			append network_devices "$cfg_name"
		;;
	esac
}
cur_color="odd"
get_tr() {
	if equal "$cur_color" "odd"; then
		cur_color="even"
		tr="string|<tr>"
	else
		cur_color="odd"
		tr="string|<tr class=\"odd\">"
	fi
}

uci_load firewall

get_tr
form="string|<div class=\"settings\">
	string|<h3><strong>@TR<<Incoming>></strong></h3>
	string|<table style=\"width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"3\" cellspacing=\"2\" summary=\"@TR<<Incomimg>>\">
	$tr
	string|<th>@TR<<Name>></th>
	string|<th>@TR<<Protocol>></th>
	string|<th>@TR<<Source IP>></th>
	string|<th>@TR<<Destination IP>></th>
	string|<th>@TR<<Port>></th>
	string|</tr>"
append forms "$form" "$N"
for rule in $rule_cfgs; do
	if [ "$FORM_submit" = "" -o "$add_rule_cfg" = "$rule" ]; then
		config_get FORM_protocol $rule proto
		config_get FORM_src_ip $rule src_ip
		config_get FORM_dest_ip $rule dest_ip
		config_get FORM_port $rule dest_port
	else
		eval FORM_protocol="\$FORM_protocol_$rule"
		eval FORM_src_ip="\$FORM_src_ip_$rule"
		eval FORM_dest_ip="\$FORM_dest_ip_$rule"
		eval FORM_port="\$FORM_port_$rule"
		uci_set firewall "$rule" "proto" "$FORM_protocol"
		uci_set firewall "$rule" "src_ip" "$FORM_src_ip"
		uci_set firewall "$rule" "dest_ip" "$FORM_dest_ip"
		uci_set firewall "$rule" "dest_port" "$FORM_port"
	fi

	echo "$rule" |grep -q "cfg*****" && name="" || name="$rule"
	get_tr
	form="$tr
		string|<td>$name</td>
		string|<td>
		select|protocol_$rule|$FORM_protocol
		option|tcp|TCP
		option|udp|UDP
		string|</td>
		string|<td>
		text|src_ip_$rule|$FORM_src_ip
		string|</td>
		string|<td>
		text|dest_ip_$rule|$FORM_dest_ip
		string|</td>
		string|<td>
		text|port_$rule|$FORM_port
		string|</td>
		string|<td>
		string|<a href=\"$SCRIPT_NAME?remove_vcfg=$rule\">@TR<<Remove Rule>></a>
		string|</td>
		string|</tr>"
	append forms "$form" "$N"
done
get_tr
form="$tr
	string|<td>
	text|name|
	string|</td>
	string|<td>
	select|protocol_rule
	option|tcp|TCP
	option|udp|UDP
	string|</td>
	string|<td>
	text|src_ip_rule
	string|</td>
	string|<td>
	text|dest_ip_rule
	string|</td>
	string|<td>
	text|port_rule|
	string|</td>
	string|<td>
	string|&nbsp;
	string|</td>
	string|</tr>
	string|</table></div>"
append forms "$form" "$N"

#PORT Forwarding
cur_color="odd"
get_tr
form="string|<div class=\"settings\">
	string|<h3><strong>@TR<<Port Forwarding>></strong></h3>
	string|<table style=\"width: 90%; margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"3\" cellspacing=\"2\" summary=\"@TR<<Port Forwarding>>\">
	$tr
	string|<th>@TR<<Name>></th>
	string|<th>@TR<<Protocol>></th>
	string|<th>@TR<<Source IP>></th>
	string|<th>@TR<<Destination Port>></th>
	string|<th>@TR<<To IP Address>></th>
	string|<th>@TR<<To Port>></th>
	string|</tr>"
append forms "$form" "$N"

for rule in $redirect_cfgs; do
	if [ "$FORM_submit" = "" -o "$add_redirect_cfg" = "$rule" ]; then
		config_get FORM_protocol $rule proto
		config_get FORM_src_ip $rule src_ip
		config_get FORM_dest_ip $rule dest_ip
		config_get FORM_src_dport $rule src_dport
		config_get FORM_dest_port $rule dest_port
	else
		eval FORM_protocol="\$FORM_protocol_$rule"
		eval FORM_src_ip="\$FORM_src_ip_$rule"
		eval FORM_dest_ip="\$FORM_dest_ip_$rule"
		eval FORM_dest_port="\$FORM_dest_port_$rule"
		eval FORM_src_dport="\$FORM_src_dport_$rule"
		uci_set firewall "$rule" "proto" "$FORM_protocol"
		uci_set firewall "$rule" "src_ip" "$FORM_src_ip"
		uci_set firewall "$rule" "dest_ip" "$FORM_dest_ip"
		uci_set firewall "$rule" "src_dport" "$FORM_src_dport"
		uci_set firewall "$rule" "dest_port" "$FORM_dest_port"
	fi

	echo "$rule" |grep -q "cfg*****" && name="" || name="$rule"
	get_tr
	form="$tr
		string|<td>$name</td>
		string|<td>
		select|protocol_$rule|$FORM_protocol
		option|tcp|TCP
		option|udp|UDP
		string|</td>
		string|<td>
		text|src_ip_$rule|$FORM_src_ip
		string|</td>
		string|<td>
		text|src_dport_$rule|$FORM_src_dport
		string|</td>
		string|<td>
		text|dest_ip_$rule|$FORM_dest_ip
		string|</td>
		string|<td>
		text|dest_port_$rule|$FORM_dest_port
		string|</td>
		string|<td>
		string|<a href=\"$SCRIPT_NAME?remove_vcfg=$rule\">@TR<<Remove Rule>></a>
		string|</td>
		string|</tr>"
	append forms "$form" "$N"
done
get_tr
form="$tr
	string|<td>
	text|name_redirect|
	string|</td>
	string|<td>
	select|protocol_redirect
	option|tcp|TCP
	option|udp|UDP
	string|</td>
	string|<td>
	text|src_ip_redirect
	string|</td>
	string|<td>
	text|src_dport_redirect
	string|</td>
	string|<td>
	text|dest_ip_redirect
	string|</td>
	string|<td>
	text|dest_port_redirect
	string|</td>
	string|<td>
	string|&nbsp;
	string|</td>
	string|</tr>
	string|</table></div>"
append forms "$form" "$N"



header "Network" "Firewall" "@TR<<Firewall>>" 'onload="modechange()"' "$SCRIPT_NAME"
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
##WEBIF:name:Network:415:Firewall
-->
