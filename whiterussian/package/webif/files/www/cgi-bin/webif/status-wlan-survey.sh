#!/usr/bin/webif-page
<?
###################################################################
# Wireless survey page
#
# Description:
#	Perform a wireless survey and display pretty results.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	wl0_ifname
#	wl0_mode
#	wl0_infra  (unnecessary to be 1? -- seems so in tests so far)
#
# Configuration files referenced:
#   none
#
# TODO:
#   I originally wrote this before I had bothered to learn much about
#   awk, so it uses 'pure' shell scripting. It would be much simpler
#   and probably more efficient to use awk. Maybe recode someday, but
#   why fix what's isn't broken...
#
#
#

. /usr/lib/webif/webif.sh

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
#clienttable table {
	text-align: left;
	font-size: 0.9em;
	border-style: none;
	border-spacing: 0;
}
#clienttable td, th {
	padding-left: 0.2em;
	padding-right: 0.2em;
}
#clienttable .tdnumber {
	text-align: right;
}
#clienttable .tdcenter {
	text-align: center;
}
-->
</style>

EOF

)


header "Status" "Wireless" "@TR<<Wireless>>"

! empty "$FORM_submit" && equal "$FORM_action" "installwl" && {
	echo "@TR<<status_wlan_survey_Installing_wl_package#Installing wl package>> ...<pre>"
	install_package wl
	echo "</pre><br />"
}

MAX_TRIES=4
MAX_CELLS=100
WL0_IFNAME=$(nvram get wl0_ifname)
##################################################
# Handle switch to sta mode at user request
#
if ! empty "$FORM_clientswitch"; then
	ORIGINAL_WL_MODE=$(nvram get wl0_mode)
	nvram set wl0_mode="sta"
	# tests show scan works in infra or ad-hoc mode, but we'll do this to be safe
	ORIGINAL_INFRA=$(nvram get wl0_infra)
	nvram set wl0_infra="1"
	wifi up 2>/dev/null >/dev/null </dev/null
fi
WL_MODE=$(nvram get wl0_mode)

##################################################
#
if equal $WL_MODE "ap" ; then
	cat <<EOF
<div class="settings">
<form enctype="multipart/form-data" method="post" action="$SCRIPT_NAME">
<h3><strong>@TR<<Survey Results>></strong></h3>
<p>@TR<<HelpText WLAN Survey#Your wireless adaptor is not in client mode. To do a scan it must be put into client mode for a few seconds. Your WLAN traffic will be interrupted during this brief period.>></p>
<input type="submit" value=" @TR<<Scan>> " name="clientswitch" />
</form>
<div class="clearfix">&nbsp;</div></div>
EOF

	wlcmd=$(which wl)
	[ -n "$wlcmd" ] && {
			cat <<EOF
<div class="settings">
<h3><strong>@TR<<status_wlan_survey_Connected_clients#Connected clients>></strong></h3>
<div id="clienttable">
<table>
<tbody>
<tr>
	<th colspan="2" class="tdcenter">@TR<<status_wlan_survey_Addresses#Addresses>></th>
	<th colspan="2" class="tdcenter">@TR<<status_wlan_survey_Names#Names>></th>
	<th colspan="2" class="tdcenter">@TR<<status_wlan_survey_Times#Times>></th>
	<th colspan="5">&nbsp;</th>
</tr>
<tr>
	<th>@TR<<status_wlan_survey_MAC#MAC>></th>
	<th>@TR<<status_wlan_survey_IP#IP>></th>
	<th>@TR<<status_wlan_survey_DHCP#DHCP>></th>
	<th>@TR<<status_wlan_survey_Hosts#Hosts>></th>
	<th>@TR<<status_wlan_survey_Idle#Idle>></th>
	<th>@TR<<status_wlan_survey_Connected#Connected>></th>
	<th>@TR<<status_wlan_survey_RSSI#RSSI>></th>
	<th>@TR<<status_wlan_survey_Authenticated#Authenticated>></th>
	<th>@TR<<status_wlan_survey_Associated#Associated>></th>
	<th>@TR<<status_wlan_survey_Authorized#Authorized>></th>
	<th>@TR<<status_wlan_survey_Features#Features>></th>
</tr>
EOF
		assoclist=$(wl assoclist 2>/dev/null | sed 's/assoclist//'; wl wds 2>/dev/null | sed 's/wds//')
		! empty "$assoclist" && {
			# it is just a shortcut :-)
			(
			killall -ALRM dnsmasq >/dev/null 2>&1
			for ass in $assoclist; do
				wl sta_info $ass 2>/dev/null | sed '/ERROR/d'
				wl rssi $ass 2>/dev/null
			done
			) | awk '
BEGIN {
	num = 0
	SUBSEP = "_"
	ind = 0
	while (("cat /proc/net/arp 2>/dev/null" | getline) > 0) {
		if ($1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/) {
			arp[toupper($4)] = $1
		}
	}
	while (("cat /var/dhcp.leases 2>/dev/null" | getline) > 0) {
		if ($1 ~ /^[[:digit:]]{10}$/) {
			$2 = toupper($2)
			leases[$2 SUBSEP "ip"] = $3
			leases[$2 SUBSEP "name"] = $4
		}
	}
	while (("cat /etc/ethers 2>/dev/null" | getline) > 0) {
		if ($1 ~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/) {
			ethers[toupper($1)] = $2
		}
	}
	while (("cat /etc/hosts 2>/dev/null" | getline) > 0) {
		if ($1 ~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/) {
			hosts[$1] = $2
			for (i = 3; i <= NF; i++) hosts[$1] = hosts[$1] = ", " $i
		}
	}
}
function indent_level(level) {
	if (level > 0) {
		for (i = 1; i <= level; i++) printf "\t"
	}
}
function fmtime(seconds, secs, fstring, y, d, h, m ,s) {
	if (seconds >= 0) {
		secs = seconds
		y = int(secs / (60 * 60 * 24 * 365))
		if (y > 0) {
			fstring = sprintf("%d@TR<<status_wlan_survey_y#y>> ", y)
			secs = secs % (60 * 60 * 24 * 365)
		}
		d = int(secs / 60 / 60 / 24)
		if (d > 0) {
			fstring = sprintf("%d@TR<<status_wlan_survey_d#d>> ", d) fstring
			secs = secs % (60 * 60 * 24)
		}
		h = int(secs / 60 / 60)
		m = int(secs / 60 % 60)
		s = int(secs % 60)
		fstring = fstring "%02d:%02d:%02d"
		return sprintf(fstring, h, m, s)
	} else return "&nbsp;"
}
function showclient() {
	if (_cl["mac"] != "") {
		num++
		indent_level(ind)
		if (num % 2 > 0) print "<tr>"
		else print "<tr class=\"odd\">"

		_cl["ip"] = arp[_cl["mac"]]
		if (_cl["ip"] == "") _cl["ip"] = leases[_cl["mac"] SUBSEP "ip"]
		if (_cl["ip"] == "") _cl["ip"] = ethers[_cl["mac"]]
		if (_cl["ip"] == "") _cl["ip"] = "&nbsp;"
		_cl["dhcpname"] = leases[_cl["mac"] SUBSEP "name"]
		if (_cl["dhcpname"] == "") _cl["dhcpname"] = "&nbsp;"
		_cl["hostname"] = (hosts[_cl["ip"]] == "" ? "&nbsp;" : hosts[_cl["ip"]])

		indent_level(ind + 1)
		printf "<td>" _cl["mac"] "</td>"
		printf "<td>" _cl["ip"] "</td>"
		printf "<td>" _cl["dhcpname"] "</td>"
		printf "<td>" _cl["hostname"] "</td>"
		printf "<td class=\"tdnumber\">" fmtime(_cl["idle"]) "</td>"
		printf "<td class=\"tdnumber\">" fmtime(_cl["in"]) "</td>"
		printf "<td class=\"tdnumber\">" _cl["rssi"] "</td>"
		printf "<td class=\"tdcenter\">" (_cl["AUTHENTICATED"] ? "@TR<<status_wlan_survey_yes#yes>>" : "@TR<<status_wlan_survey_no#no>>") "</td>"
		printf "<td class=\"tdcenter\">" (_cl["ASSOCIATED"] ? "@TR<<status_wlan_survey_yes#yes>>" : "@TR<<status_wlan_survey_no#no>>") "</td>"
		printf "<td class=\"tdcenter\">" (_cl["AUTHORIZED"] ? "@TR<<status_wlan_survey_yes#yes>>" : "@TR<<status_wlan_survey_no#no>>") "</td>"

		_cl["features"] = (_cl["WME"] ? "@TR<<status_wlan_survey_WME#WME>>" : "")
		_cl["features"] = _cl["features"] ", " (_cl["BRCM"] ? "@TR<<status_wlan_survey_Broadcom#Broadcom>>" : "")
		_cl["features"] = _cl["features"] ", " (_cl["ABCAP"] ? "@TR<<status_wlan_survey_Afterburner#Afterburner>>" : "")
		gsub(/, , /, ", ", _cl["features"])
		gsub(/, $/, "", _cl["features"])
		gsub(/^, /, "", _cl["features"])

		if (_cl["features"] == "") _cl["features"] = "@TR<<status_wlan_survey_none#none>>"
		printf "<td class=\"tdcenter\">" _cl["features"] "</td>"
		print "</tr>"
	}
	delete _cl
}
{
	if ($1 == "STA") {
		showclient()
		_cl["mac"] = toupper($2)
		sub(":$", "", _cl["mac"])
	} else if ($1 == "idle") {
		_cl["idle"] = $2
	} else if ($1 == "in") {
		_cl["in"] = $3
	} else if ($1 == "state") {
		for (i = 3; i <= NF; i++) _cl[$i] = 1
	} else if ($1 == "flags") {
		for (i = 3; i <= NF; i++) _cl[$i] = 1
	} else if ($1 == "rssi") {
		_cl["rssi"] = $3
	}
}
END {
	if (_cl["mac"] != "") showclient()
	if (num == 0) {
		indent_level(ind)
		print "<tr><td colspan=\"11\">@TR<<status_wlan_survey_No_connected_clients#No connected clients found.>></td></tr>"
	}
}
'
		} || {
			echo "<tr><td colspan=\"11\">@TR<<status_wlan_survey_No_connected_clients#No connected clients found.>></td></tr>"
		}
		cat <<EOF
</tbody>
</table>
</div>
<div class="clearfix">&nbsp;</div></div>
EOF
	} || {
		echo "<form method=\"post\" name=\"installwl\" action=\"$SCRIPT_NAME\" enctype=\"multipart/form-data\">"
		display_form <<EOF
start_form|@TR<<status_wlan_survey_Connected_clients#Connected clients>>
field|@TR<<status_wlan_survey_Wireless_driver_utility#Wireless driver utility>>
string|<input type="hidden" name="action" value="installwl" />
submit|submit|@TR<<status_wlan_survey_Install_wl#Install wl>>
helpitem|status_wlan_survey_Wireless_driver_utility#Wireless driver utility
helptext|status_wlan_survey_Wireless_driver_utility_helptext#This function requires you to install the proprietary Broadcom utility for setting and reading wireless driver parameters.
end_form
EOF
		echo "</form>"
	}
else

tempfile=$(mktemp /tmp/.survtemp.XXXXXX)
tempfile2=$(mktemp /tmp/.survtemp.XXXXXX)

#echo " Please wait while scan is performed ... <br /><br />"
found_networks=0
counter=0
for counter in $(seq 1 $MAX_TRIES); do
	#echo "."
	iwlist scan > $tempfile 2> /dev/null
	grep -i "Address" < $tempfile >> /dev/null
	equal "$?" "0" && break
	sleep 1
done

first_hit=1
if [ $counter -gt $MAX_TRIES ]; then
	echo "<tr><td>@TR<<Sorry, no scan results.>></td></tr>"
else
	current=0
	counter=0
	for counter in $(seq 1 $MAX_CELLS); do
		current_line=$(sed '2,$ d' < $tempfile)
		empty "$current_line" && break
		# line must contain both "Cell" and "Address" to be considered
		#  start of a new cell..
		echo "$current_line" | grep "Cell" >> /dev/null
		result_one=$?
		echo "$current_line" | grep "Address" >> /dev/null
		result_two=$?
		equal "$result_one" "0" && equal "$result_two" "0" && {
			equal "$first_hit" "0" && {
				let "current+=1"
			}
			first_hit=0
		}
		equal "$first_hit" "0" && {
			echo "$current_line" >> "$tempfile"_"${current}"
		}

		sed 1d < $tempfile > $tempfile2
		rm $tempfile
		mv $tempfile2 $tempfile
	done

	current=0
	counter=0
	for counter in $(seq 1 $MAX_CELLS); do
		! exists "$tempfile"_"${current}" && break
		####################################################
		# parse out MAC
		address_pre=$(sed '2,$ d' < "$tempfile"_"${current}" | sed -e s/'Cell'//g -e s/'Address'//g -e s/'-'//g)
		count=0
		for i in $address_pre; do
			case $count in
				0) CELL_ID=$i;;
				2) MAC_ID=$i;;
				3) break;;
			esac
			let "count+=1"
		done

		####################################################
		# parse out essid
		ESSID=$(grep -i "ESSID" < "$tempfile"_"${current}" | sed -e s/'ESSID:'//g -e s/'"'//g)

		####################################################
		# parse out channel
		CHANNEL_ID=$(grep -i "Channel" < "$tempfile"_"${current}" | sed -e s/'Channel:'//g -e s/' '//g)

		####################################################
		# parse out signal
		quality_pre=$(grep -i "Quality" < "$tempfile"_"${current}" | sed -e s/'Quality:'//g -e s/'Signal level:'//g  -e s/'dBm'//g -e s/'Noise level:'//g)
		count=0
		for i in $quality_pre; do
			case $count in
				0) QUALITY=$i;;
				1) SIGNAL_DBM=$i;;
				2) NOISE_DBM=$i
					break;;
			esac
			let "count+=1"
		done

		#
		# only show quality if it's not 0/0
		#
		if ! equal "$QUALITY" "0/0"; then
			QUALITY_STRING="string|<tr><td>@TR<<Quality>> $QUALITY</tr></td>"
		fi

		NOISE_BASE=-99
		NOISE_DELTA=$(expr $NOISE_BASE - $NOISE_DBM)

		SIGNAL_INTEGRITY=$(expr $SIGNAL_DBM + $NOISE_DELTA)
		MAC_DASHES=$(echo "$MAC_ID" | sed s/':'/'-'/g)
		MAC_FIRST_THREE=$(echo "$MAC_DASHES" | cut -c1-8)
		SNR_PERCENT=$(expr 100 + $SIGNAL_INTEGRITY)

		FORM_cells="$FORM_cells
			string|<tr><td><strong>@TR<<Cell>></strong> $CELL_ID</td></tr>
			string|<tr><td><strong>@TR<<SSID>></strong> $ESSID (<a href=\"http://standards.ieee.org/cgi-bin/ouisearch?$MAC_FIRST_THREE\" target=\"_blank\">$MAC_DASHES</a>)</td></tr>
			string|<tr><td><strong>@TR<<Channel>></strong> $CHANNEL_ID</td></tr>
			$QUALITY_STRING
			string|<tr><td><strong>@TR<<Signal>></strong> $SIGNAL_DBM dBm / <strong>@TR<<Noise>></strong> $NOISE_DBM dBm</td></tr><tr><td>
			progressbar|SNR|<strong>@TR<<SNR>></strong> $SIGNAL_INTEGRITY dBm|200|$SNR_PERCENT|$SIGNAL_INTEGRITY dBm
			string|</td></tr><tr><td>&nbsp;</td></tr>"

		rm -f "$tempfile"_"${current}"
		let "found_networks+=1"
		let "current+=1"
	done
fi # end if were scan results

rm -f "$tempfile"
rm -f "$tempfile2"

if ! empty "$FORM_clientswitch"; then
	#echo "<tr><td>Restoring settings...</tr></td>"
	# restore radio to its original state
	nvram set wl0_mode=$ORIGINAL_WL_MODE
	nvram set wl0_infra=$ORIGINAL_INFRA
	wifi up 2>/dev/null >/dev/null </dev/null
fi
fi # end if is in 'allowed to scan' mode

if ! equal $WL_MODE "ap" ; then
	if equal "$found_networks" "0"; then
		echo "@TR<<No wireless networks were found>>."
	else
		display_form <<EOF
		start_form|@TR<<Survey Results>>
		$FORM_cells
		end_form|
EOF
	fi
fi

footer ?>
<!--
##WEBIF:name:Status:980:Wireless
-->
