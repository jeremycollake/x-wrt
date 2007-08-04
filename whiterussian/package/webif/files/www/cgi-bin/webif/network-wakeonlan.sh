#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# network-wakeonlan.sh
#
# Description:
#  Sends magic WOL packets.
#
# Author(s) [in order of work date]:
#  unknown
#  Lubos Stanek <lubek@users.berlios.de>
#
# Major revisions:
#

HOSTS_FILE="/etc/hosts"
ETHERS_FILE="/etc/ethers"

header_inject_head=$(cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function targetwindow(url) {
	var wasOpen  = false;
	var win = window.open(url);    
	return (typeof(win)=='object')?true:false;
}
function modechange()
{
	var v;
	v = isset('wake_app', 'wol')
	set_visible('field_wake_wol_target', v);
	set_visible('field_wake_wol_port', v);
	set_visible('field_wake_wol_wait', v);
	set_visible('field_wake_wol_password', v);
	set_visible('help_wol', v);
	v = isset('wake_app', 'ether-wake')
	set_visible('field_wake_ether_broadcast', v);
	set_visible('field_wake_ether_iface', v);
	set_visible('field_wake_ether_password', v);
	set_visible('help_ether', v);
	v = (isset('wake_app', 'ether-wake') || isset('wake_app', 'wol'))
	set_visible('field_wake_verbose', v);
	set_visible('help_either', v);
	hide('save');
	show('save');
}
-->
</script>

EOF
)

if empty "$FORM_submit"; then
	FORM_wake_mac="${FORM_wake_mac:-"00:00:00:00:00:00"}"
else
	validate_text=$(
	if [ "$FORM_wakeup" = "custom" ]; then
		if [ "$FORM_wake_mac" = "00:00:00:00:00:00" ]; then
			echo "mac|FORM_wake_mac|@TR<<network_wol_Custom_MAC_Address#Custom MAC Address>>|required|"
		else
			echo "mac|FORM_wake_mac|@TR<<network_wol_Custom_MAC_Address#Custom MAC Address>>|required|$FORM_wake_mac"
		fi
	else
		echo "mac|FORM_wakeup|@TR<<network_wol_MAC_Address#MAC Address>>|required|$FORM_wakeup"
	fi
	case "$FORM_wake_app" in
		wol)
			WOLAPPBIN=$(which wol 2>/dev/null)
			echo "string|WOLAPPBIN|@TR<<network_wol_missing_app#The application is not available>>|required|$WOLAPPBIN"
			[ -n "$FORM_wake_wol_target" ] && echo "ip|FORM_wake_wol_target|@TR<<network_wol_Target_Host#Target Host>>|required|$FORM_wake_wol_target"
			[ -n "$FORM_wake_wol_port" ] && echo "port|FORM_wake_wol_port|@TR<<network_wol_Port#Port>>|required|$FORM_wake_wol_port"
			[ -n "$FORM_wake_wol_wait" ] && echo "int|FORM_wake_wol_wait|@TR<<network_wol_Wait#Wait>>|required min=1 max=3000|$FORM_wake_wol_wait"
			[ -n "$FORM_wake_wol_password" ] && echo "mac|FORM_wake_wol_password|@TR<<network_wol_Password#Password>>|required|$FORM_wake_wol_password"
		;;
		ether-wake)
			WOLAPPBIN=$(which ether-wake 2>/dev/null)
			[ -z "$WOLAPPBIN" ] && WOLAPPBIN=$(which ether_wake 2>/dev/null)
			[ -z "$WOLAPPBIN" ] && WOLAPPBIN=$(which etherwake 2>/dev/null)
			echo "string|WOLAPPBIN|@TR<<network_wol_missing_app#The application is not available>>|required|$WOLAPPBIN"
			[ -n "$FORM_wake_ether_broadcast" ] && echo "int|FORM_wake_ether_broadcast|@TR<<network_wol_etherwake_Broadcast_packet#Broadcast Packet>>||$FORM_wake_ether_broadcast"
			[ -n "$FORM_wake_ether_password" ] && {
				if [ "$FORM_wake_ether_password" = "${FORM_wake_ether_password%%.*}" ]; then
					echo "mac|FORM_wake_ether_password|@TR<<network_wol_etherwake_Password#Password>>|required|$FORM_wake_ether_password"
				else
					echo "ip|FORM_wake_ether_password|@TR<<network_wol_etherwake_Password#Password>>|required|$FORM_wake_ether_password"
				fi
			}
		;;
		*)
			echo "string|FORM_wake_app|@TR<<network_wol_Application#Application>>|required|"
		;;
	esac
	[ -n "$FORM_wake_verbose" ] && echo "int|FORM_wake_verbose|@TR<<network_wol_Verbose_Output#Verbose Output>>||$FORM_wake_verbose"
	)
	validate "$validate_text"
	unset validate_text
fi

header "Network" "WoL" "@TR<<Wake-On-LAN>>"

! empty "$FORM_install_wol$FORM_install_etherwake" && {
	echo "@TR<<network_wol_installing_package#Installing the package>> ...<pre>"
	if [ -n "$FORM_install_wol" ]; then
		install_package "wol"
	fi
	if [ -n "$FORM_install_etherwake" ]; then
		install_package "ether-wake"
	fi
	echo "</pre>"
	unset FORM_submit
}

! empty "$FORM_submit" && empty "$ERROR" && {
	case "$FORM_wake_app" in
		wol)
			[ -n "$FORM_wake_wol_target" ] && WOLOPTIONS="$WOLOPTIONS -h $FORM_wake_wol_target"
			[ -n "$FORM_wake_wol_port" ] && WOLOPTIONS="$WOLOPTIONS -p $FORM_wake_wol_port"
			[ -n "$FORM_wake_wol_wait" ] && WOLOPTIONS="$WOLOPTIONS -w $FORM_wake_wol_wait"
			[ -n "$FORM_wake_wol_password" ] && WOLOPTIONS="$WOLOPTIONS --passwd=$FORM_wake_wol_password"
			[ "$FORM_wake_verbose" = "1" ] && WOLOPTIONS="$WOLOPTIONS -v"
		;;
		ether-wake)
			[ "$FORM_wake_ether_broadcast" = "1" ] && WOLOPTIONS="$WOLOPTIONS -b"
			iface="$FORM_wake_ether_iface"
			[ -z "$iface" ] && iface=$(nvram get lan_ifname | sed 's/[[:space:]]//g')
			[ -n "$FORM_wake_ether_iface" ] && WOLOPTIONS="$WOLOPTIONS -i $iface"
			[ -n "$FORM_wake_ether_password" ] && WOLOPTIONS="$WOLOPTIONS -p $FORM_wake_ether_password"
			[ "$FORM_wake_verbose" = "1" ] && WOLOPTIONS="$WOLOPTIONS -D"
		;;
	esac
	echo "<br />"
	echo "<p>@TR<<network_wol_Sending#Sending the magic packet...>></p>"
	if [ "$FORM_wakeup" = "custom" ]; then
		WOLOPTIONS="$WOLOPTIONS $FORM_wake_mac"
	else
		WOLOPTIONS="$WOLOPTIONS $FORM_wakeup"
	fi
	[ "$FORM_wake_verbose" = "1" ] && {
		echo "<pre class=\"smalltext\">"
		$WOLAPPBIN $WOLOPTIONS
		echo "</pre>"
	} || {
		$WOLAPPBIN $WOLOPTIONS > /dev/null 2>&1
	}
	echo "<p>@TR<<network_wol_Done#Done.>></p>"
	echo "<br />"
}

is_package_installed "ether-wake"; have_etherwake=$((!$?))
is_package_installed "wol"; have_wol=$((!$?))
[ "$have_wol" -eq 1 ] && form_app_options="$form_app_options
option|wol|@TR<<network_option_wol#wol>>"
[ "$have_etherwake" -eq 1 ] && form_app_options="$form_app_options
option|ether-wake|@TR<<network_wol_option_ether-wake#ether-wake>>"

[ "$have_wol" -eq 1 -o "$have_etherwake" -eq 1 ] && {
	for ifname in lan wifi wan $(nvram get ifnames); do
		iface=$(nvram get ${ifname}_ifname | sed 's/[[:space:]]//g')
		[ -n "$iface" ] && {
			form_interface_options="$form_interface_options
option|$iface|$ifname"
		}
	done

	cat <<EOF
<blockquote style="text-align: right">
<p>@TR<<network_wol_moreinfo#See the <a href="#wollegend">help</a> for more information about Wake-On-LAN.>></p>
</blockquote>
<form enctype="multipart/form-data" name="wakeup" method="post" action="$SCRIPT_NAME">
<input type="hidden" name="submit" value="1" />
EOF
	display_form <<EOF
onchange|modechange
start_form|@TR<<network_wol_Shared_options#Shared options>>
field|@TR<<network_wol_Application#Application>>
select|wake_app|$FORM_wake_app
$form_app_options
field|@TR<<network_wol_etherwake_Broadcast_packet#Broadcast Packet>>|field_wake_ether_broadcast|hidden
checkbox|wake_ether_broadcast|$FORM_wake_ether_broadcast|1|
field|@TR<<network_wol_Interface#Interface>>|field_wake_ether_iface|hidden
select|wake_ether_iface|$FORM_wake_ether_iface
$form_interface_options
field|@TR<<network_wol_etherwake_Password#Password>>|field_wake_ether_password|hidden
password|wake_ether_password|$FORM_wake_ether_password
field|@TR<<network_wol_Target_Host#Target Host>>|field_wake_wol_target|hidden
text|wake_wol_target|$FORM_wake_wol_target
field|@TR<<network_wol_Port#Port>>|field_wake_wol_port|hidden
text|wake_wol_port|$FORM_wake_wol_port
field|@TR<<network_wol_Wait#Wait>>|field_wake_wol_wait|hidden
text|wake_wol_wait|$FORM_wake_wol_wait
field|@TR<<network_wol_Password#Password>>|field_wake_wol_password|hidden
password|wake_wol_password|$FORM_wake_wol_password
field|@TR<<network_wol_Verbose_Output#Verbose Output>>|field_wake_verbose|hidden
checkbox|wake_verbose|$FORM_wake_verbose|1|
EOF
	# the display_form data text is not terminated
	# due to the hack to enable hidden helptexts
	cat <<EOF
</tr>
</table>
</div>
<blockquote class="settings-help" id="help_ether" style="display: none">
	<h3><strong>@TR<<Short help>>:</strong></h3>
	<h4>@TR<<network_wol_etherwake_Broadcast_Packet#Broadcast Packet>>:</h4>
	<p>@TR<<network_wol_etherwake_Broadcast_Packet_helptext#Send the wake-up packet to the broadcast address.>></p>
	<h4>@TR<<network_wol_etherwake_Password#Password>>:</h4>
	<p>@TR<<network_wol_etherwake_Password_helptext#A password may be specified in Ethernet six byte hex format (00:22:44:66:88:aa) or four byte dotted decimal (192.168.1.1) format.>></p>
</blockquote>
<blockquote class="settings-help" id="help_wol" style="display: none">
	<h4>@TR<<network_wol_Target_Host#Target Host>>:</h4>
	<p>@TR<<network_wol_Target_Host_helptext#Broadcast packet to this IP address, if you want to send only to one subnet (default is 255.255.255.255).>></p>
	<h4>@TR<<network_wol_Port#Port>>:</h4>
	<p>@TR<<network_wol_Port_helptext#Use different destination port (default is 40000).>></p>
	<h4>@TR<<network_wol_Wait#Wait>>:</h4>
	<p>@TR<<network_wol_Wait_helptext#Waits entered milliseconds between Magic Packets.>></p>
	<h4>@TR<<network_wol_Password#Password>>:</h4>
	<p>@TR<<network_wol_Password_helptext#A SecureON password may be specified in Ethernet six byte hex format (00:22:44:66:88:aa).>></p>
</blockquote>
<blockquote class="settings-help" id="help_either" style="display: none">
	<h4>@TR<<network_wol_Verbose_Output#Verbose Output>>:</h4>
	<p>@TR<<network_wol_Verbose_Output_helptext#Increase the Debug Level or turn on verbose output.>></p>
</blockquote>
<div class="clearfix">&nbsp;</div></div>
<script type="text/javascript">
<!--
modechange()
 -->
</script>
EOF

	display_form <<EOF
start_form|@TR<<network_wol_Wake_up#Wake up!>>
EOF
	cat <<EOF
<tr>
	<th>@TR<<network_wol_Host_Name#Host Name>></th>
	<th>@TR<<network_wol_IP_Address#IP Address>></th>
	<th>@TR<<network_wol_MAC_Address#MAC Address>></th>
	<th>@TR<<network_wol_Action#Action>></th>
	</tr>
<tr>
	<td colspan="2">@TR<<network_wol_Custom_MAC_Address#Custom MAC Address>></td>
	<td><input type="text" name="wake_mac" value="$FORM_wake_mac" /></td>
	<td><button name="wakeup" type="submit" value="custom">@TR<<network_wol_Wake_up#Wake up!>></button></td>
</tr>
EOF
	[ -s "$ETHERS_FILE" ] && {
		cat "$HOSTS_FILE" "$ETHERS_FILE" 2>/dev/null | awk '
BEGIN {
	odd = 0
}
{
	if ($1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}/) {
		for (i = 2; i <= NF; i++) {
			hostnames[$1 "_" (i-1)] = $(i)
		}
		hostnames[$1] = NF - 1
	}
	if ($1 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}/) {
		if (odd == 1) {
			tab_row = "<tr>"
			odd--
		} else {
			tab_row = "<tr class=\"odd\">"
			odd++
		}
		if (hostnames[$2] > 0) {
			rowspan = ((hostnames[$2] > 1) ? " rowspan=\"" hostnames[$2] "\"" : "")
			for (i = 1; i <= hostnames[$2]; i++) {
				printf tab_row
				printf "<td>" hostnames[$2 "_" i] "</td>"
				if (i == 1) {
					printf "<td" rowspan ">" $2 "</td>"
					printf "<td" rowspan ">" $1 "</td>"
					printf "<td" rowspan "><button name=\"wakeup\" type=\"submit\" value=\"" $1 "\">@TR<<network_wol_Wake_up#Wake up!>></button></td>"
				}
				print "</tr>"
			}
		} else {
			printf tab_row
			printf "<td>&nbsp;</td>"
			printf "<td>" $2 "</td>"
			printf "<td>" $1 "</td>"
			printf "<td><button name=\"wakeup\" type=\"submit\" value=\"" $1 "\">@TR<<network_wol_Wake_up#Wake up!>></button></td>"
			print "</tr>"
		}
	}
}'
	}

	display_form <<EOF
helpitem|network_wol_Wake_up#Wake up!
helptext|network_wol_Wake_up_helptext#Enter any of the shared options in the form above and press the button to wake up the particular computer.<br />If you want the particular computer to be listed here, you must add it to the static addresses list in the <a href="network-hosts.sh">/etc/ethers</a> file.
end_form
EOF


	echo "</form>"
}

cat <<EOF
<div class="settings">
<a name="wollegend"></a>
<h3>@TR<<network_wol_Wake-On-LAN#Wake-On-LAN>></h3>
<p>@TR<<wol_help#Here you can send a Wake-On-LAN packet to automatically boot up a computer that is turned off. The computer must support WOL, and the feature needs to be turned on in the BIOS for this to work. Unfortunately, there is no explicit response from that machine, so you do not know whether the waking was successful and the machine is really booting up.>></p>
<p>@TR<<wol_help2#For even more information, see the <a href="http://en.wikipedia.org/wiki/Wake-on-LAN" onclick="return !targetwindow(this.href);">Wake-on-LAN description</a>.>></p>
<p>@TR<<network_wol_Application_helptext#There are two two applications available that generate and transmit a magic packet; the <strong>ether-wake</strong> application uses a special Ethernet frame and the <strong>wol</strong> application uses an UDP packet.>></p>
EOF
[ "$have_wol" -eq 0 -o "$have_etherwake" -eq 0 ] && {
	echo "<form enctype=\"multipart/form-data\" name=\"install\" method=\"post\" action=\"$SCRIPT_NAME\">"
	[ "$have_wol" -eq 0 ] && {
		cat <<EOF
<p>@TR<<network_wol_requires_wol#Install the wol package if you want to wake up a computer via a routable UDP packet>>:
<input type="submit" name="install_wol" value=" @TR<<network_wol_Install_wol#Install wol>> " /></p>
EOF
	}
	[ "$have_etherwake" -eq 0 ] && {
		cat <<EOF
<p>@TR<<network_wol_requires_ether-wake#Install the ether-wake package, if you want to wake up a computer via a nonroutable Ethernet frame>>:
<input type="submit" name="install_etherwake" value=" @TR<<network_wol_Install_ether-wake#Install ether-wake>> " /></p>
EOF
	}
	echo "</form>"
}
echo "<div class=\"clearfix\">&nbsp;</div></div>"

footer ?>
<!--
##WEBIF:name:Network:699:WoL
-->
