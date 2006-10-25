#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
load_settings hotspot
. /usr/lib/webif/hs.sh

header "Status" "HotSpot" "HotSpot Status $HS_USING" ''
ShowUntestedWarning

has_required_pkg && {

get_status(){
    PID=
    RUNNING=
    case "$pkg" in
	chillispot)
	    FPID=none
	    [ -e $PIDFILE ] && FPID=$(cat $PIDFILE)
	    PPID=$(ps aux | grep chilli | grep $FPID | awk '{print $1}')
	    equal "$FPID" "$PPID" && { PID=$FPID; RUNNING=1; }
	    ;;
	wifidog)
	    wdctl status 2>/dev/null >/dev/null && RUNNING=1
	    ;;
    esac
}

get_status

echo "<pre>"

equal "$FORM_status" "start" && {
    if [ -z "$RUNNING" ]; then
	echo "<pre>"
	case "$pkg" in
	    chillispot) 
		echo "Starting $pkg..."
		/etc/init.d/S??chilli start 
		;;
	    wifidog) 
		/etc/init.d/S??wifidog start 
		;;
	esac
	echo "</pre>"
	sleep 4
	get_status
    else
	echo "$pkg already running..."
    fi
}

equal "$FORM_status" "stop" && {
    if [ -n "$RUNNING" ]; then
	echo "Stopping $pkg..."
	case "$pkg" in
	    chillispot) 
		/etc/init.d/S??chilli stop 
		;;
	    wifidog) 
		wdctl stop 2>/dev/null
		;;
	esac
	sleep 4
	get_status
    else
	echo "$pkg not running..."
    fi
}

equal "$FORM_action" "reboot" && {
    echo "Rebooting the Linksys..."
    reboot
}

neq "$FORM_release" "" && {
    echo "Releasing MAC address $FORM_release"
    case "$pkg" in
	chillispot) 
	    chilli_query $CMDSOCK dhcp-release $FORM_release 
	    ;;
	wifidog) 
	    wdctl reset $FORM_release 
	    ;;
    esac
}

changeto=start
desc="not running"
pid=""

if [ -n "$RUNNING" ]; then
    changeto=stop
    desc="running"
    if [ -n "$PID" ]; then
	pid=" (pid $PID)"
    fi
fi

echo "</pre>"

cat<<EOF
<div class="settings">
<div class="settings-title"><h3><strong>HotSpot Status</strong></h3></div>
<p>$pkg is <b>$desc</b>$pid 
<a href="$SCRIPT_NAME?status=$changeto">$changeto $pkg</a></td>
</p>
EOF

if [ "$pkg" = "chillispot" ]; then
cat<<EOF
<table style="margin-top: 10px; width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
<tbody>
	<tr>
		<th>@TR<<MAC Address>></th>
		<th>@TR<<IP Address>></th>
		<th>@TR<<Session ID>></th>
		<th>@TR<<Username>></th>
		<th>@TR<<Session Time>></th>
		<th>@TR<<Idle Time>></th>
		<th></th>
	</tr>
EOF

[ -e "$CMDSOCK" ] && chilli_query $CMDSOCK list | awk '
{
	print "<tr>"
	print "<td>" $1 "</td>"
	print "<td>" $2 "</td>"
	print "<td>" $4 "</td>"
	print "<td>" $6 "</td>"
	print "<td>" $7 "</td>"
	print "<td>" $8 "</td>"
	print "<td>" 
        if ($5 == 1) 
          print "<a onclick=\"javascript:return confirm('"'"'Logout user " $6 "?'"'"');\" href=\"?release=" $1 "\">logout</a>"
        else
          print "<a href=\"?release=" $1 "\">release</a>"
        print "</td>"
	print "</tr>"
}
'
cat<<EOF
</tbody>
</table>
EOF

elif [ "$pkg" = "wifidog" ]; then

wdctl status 2>/dev/null | awk '
BEGIN {
  FS="[ ]+"
  clients=0
  intro=0
  hosts=0
  print "<h3>Status</h3>"
}
($0 ~ /.+:.+/ && clients == 0) {
  if (intro == 0) {
    print "<table style=\"margin-top: 10px; width: 90%; text-align: left;\" border=\"0\" cellpadding=\"2\" cellspacing=\"2\" align=\"center\"><tbody>"
  }
  gsub(/:/,"</td><td>",$0)
  print "<tr><td>" $0 "</td></tr>"  
  intro=1
}
($2 ~ /IP:/) {
  ip=$3
  mac=$5
}
($2 ~ /Token:/) {
  token=$3
}
($2 ~ /Downloaded:/) {
  down=$3
}
($2 ~ /Uploaded:/) {
  up=$3
}
($0 ~ /^Client /) {
  clients=1
  if (intro == 1) {
    print "</tbody></table>"
    print "<h3>Current Sessions</h3>"
    print "<table style=\"margin-top: 10px; width: 90%; text-align: left;\" border=\"0\" cellpadding=\"2\" cellspacing=\"2\" align=\"center\"><tbody>"
    print "<tr>" 
    print "<th>@TR<<MAC Address>></th>"
    print "<th>@TR<<IP Address>></th>"
    print "<th>@TR<<Token>></th>"
    print "<th>@TR<<Data Up>></th>"
    print "<th>@TR<<Data Down>></th>"
    print "<th></th>"
    print "</tr>"
    intro=0
  }
}
(clients == 1 && $0 ~ /^$/) {
  print "<tr><td>" mac "</td><td>" ip "</td><td>" token "</td><td>" up "</td><td>" down "</td><td>"
  print "<a onclick=\"javascript:return confirm('"'"'Logout MAC " mac "?'"'"');\" href=\"?release=" mac "\">reset</a>"
  print "</td></tr>"
  clients=0
  mac=""
  ip=""
  token=""
  up=""
  down=""
}
($0 ~ /^Authentication servers/) {
    print "</tbody></table>"
    print "<h3>Authentication Servers</h3>"
}
END {
    print "</tbody></table>"
}
'

cat<<EOF
</tbody>
</table>
EOF

fi

cat<<EOF
</div>
</div>
EOF

}
footer 
?>
<!--
##WEBIF:name:HotSpot:9:Status
##WEBIF:name:Status:6:HotSpot
-->
