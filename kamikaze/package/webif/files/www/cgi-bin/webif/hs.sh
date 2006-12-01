#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

hswebif_msg=$(has_pkgs hswebif)
if ! empty "$hswebif_msg"; then

header "HotSpot" "Configuration" "HotSpot Config $HS_USING" ' onLoad="modechange()" ' "$SCRIPT_NAME"
ShowNotUpdatedWarning
has_pkgs hswebif

else
load_settings hotspot
. /usr/lib/webif/hs.sh

if empty "$FORM_submit"; then 
    FORM_hs_type=${hs_type:-$HS_TYPE}
    FORM_hs_mode=${hs_mode:-$HS_MODE}
    FORM_hs_nasid=${hs_nasid:-$HS_NASID}
    FORM_hs_uamserver=${hs_uamserver:-$HS_UAMSERVER}
    FORM_hs_uamsecret=${hs_uamsecret:-$HS_UAMSECRET}
    FORM_hs_gatewayid=${hs_gatewayid:-$HS_GATEWAYID}
    FORM_hs_radconf=${hs_radconf:-$HS_RADCONF}
    FORM_hs_radconf_server=${hs_radconf_server:-$HS_RADCONF_SERVER}
    FORM_hs_radconf_secret=${hs_radconf_secret:-$HS_RADCONF_SECRET}
    FORM_hs_radconf_authport=${hs_radconf_authport:-$HS_RADCONF_AUTHPORT}
    FORM_hs_radconf_user=${hs_radconf_user:-$HS_RADCONF_USER}
    FORM_hs_radconf_pwd=${hs_radconf_pwd:-$HS_RADCONF_PWD}
else 
    SAVED=1
    save_setting hotspot hs_type "$FORM_hs_type"
    save_setting hotspot hs_mode "$FORM_hs_mode"
    case "$FORM_hs_type" in

	chillispot)

	    save_setting hotspot hs_radconf "$FORM_hs_radconf"

	    case "$FORM_hs_radconf" in
		on)
		    validate <<EOF
hostname|FORM_hs_radconf_server|RADIUS Server|required|$FORM_hs_radconf_server
string|FORM_hs_radconf_secret|Shared Secret|required|$FORM_hs_radconf_secret
string|FORM_hs_radconf_user|Config Username|required|$FORM_hs_radconf_user
string|FORM_hs_radconf_pwd|Config Password|required|$FORM_hs_radconf_pwd
int|FORM_hs_radconf_authport|RADIUS Auth Port|required|$FORM_hs_radconf_authport
EOF
		    equal "$?" 0 && {
			save_setting hotspot hs_radconf_server "$FORM_hs_radconf_server"
			save_setting hotspot hs_radconf_secret "$FORM_hs_radconf_secret"
			save_setting hotspot hs_radconf_authport "$FORM_hs_radconf_authport"
			save_setting hotspot hs_radconf_user "$FORM_hs_radconf_user"
			save_setting hotspot hs_radconf_pwd "$FORM_hs_radconf_pwd"
		    }
		    ;;
		*)
		    validate <<EOF
hostname|FORM_hs_uamserver|$HS_PROVIDER UAM Hostname|required|$FORM_hs_uamserver
string|FORM_hs_uamsecret|UAM Secret|required|$FORM_hs_uamsecret
string|FORM_hs_nasid|NAS Identifier|required|$FORM_hs_nasid
EOF
		    equal "$?" 0 && {
			save_setting hotspot hs_nasid "$FORM_hs_nasid"
			save_setting hotspot hs_uamserver "$FORM_hs_uamserver"
			save_setting hotspot hs_uamsecret "$FORM_hs_uamsecret"
		    }
		    ;;
	    esac
	    ;;

	wifidog)
	    validate <<EOF
string|FORM_hs_gatewayid|Gateway ID|required|$FORM_hs_gatewayid
EOF
	    equal "$?" 0 && {
		save_setting hotspot hs_gatewayid "$FORM_hs_gatewayid"
	    }
	    ;;

    esac
fi

authserv() {
    mkdir /etc/wifidog 2>&-
    touch /etc/wifidog/auth-servers
    case "$1" in
	add)
	    validate <<EOF
hostname|FORM_host|Auth Server Hostname|required|$FORM_host
port|FORM_port|Auth Server Port|required|$FORM_port
string|FORM_proto|Auth Server Protocol|required|$FORM_proto
string|FORM_path|Auth Server Path|required|$FORM_path
EOF
	    equal "$?" 0 && {
		cat /etc/wifidog/auth-servers > /tmp/servers.tmp
		echo "$FORM_host	$FORM_proto	$FORM_port	$FORM_path" >> /tmp/servers.tmp
		mv /tmp/servers.tmp  /etc/wifidog/auth-servers
	    }
	    ;;
	del)
	    validate <<EOF
int|FORM_line|Auth Server Entry|required|$FORM_line
EOF
	    equal "$?" 0 && {
		awk -v "line=$FORM_line" '(NR != line) { print }' /etc/wifidog/auth-servers > /tmp/servers.tmp
		mv /tmp/servers.tmp  /etc/wifidog/auth-servers
	    }
	    ;;	
    esac
}

empty "$FORM_add_host" || authserv add 
empty "$FORM_del_host" || authserv del 

header "HotSpot" "Configuration" "HotSpot Config $HS_USING" ' onLoad="modechange()" ' "$SCRIPT_NAME"
ShowUntestedWarning

has_pkgs chillispot wifidog

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
	var v;
	v = isset('hs_type', 'chillispot');
	set_visible('chilli_config', v);

	v = isset('hs_radconf', 'on');
	set_visible('radconf_server', v);
	set_visible('radconf_authport', v);
	set_visible('radconf_secret', v);
	set_visible('radconf_user', v);
	set_visible('radconf_pwd', v);

        v = !v;
	set_visible('uam_hostname', v);
	set_visible('uam_secret', v);
	set_visible('uam_nasid', v);

	v = isset('hs_type', 'wifidog');
	set_visible('wifidog_config', v);
	set_visible('auth-servers', v);

	hide('save');
	show('save');
}
function setconfig(type, user, pwd) { 
        set_value('hs_type',type); 
        set_value('hs_radconf','on'); 
        modechange();
        set_value('hs_radconf_server','rad01.coova.org');
        set_value('hs_radconf_secret','coova-anonymous');
        set_value('hs_radconf_authport','1812');
        set_value('hs_radconf_user',user);
        set_value('hs_radconf_pwd',pwd);
}
-->
</script>
EOF

display_form <<EOF
start_form|HotSpot Configurations
field|HotSpot Type
onchange|modechange
select|hs_type|$FORM_hs_type
option||Disabled
option|chillispot|ChilliSpot UAM
option|wifidog|WiFiDog UAM
field|HotSpot Mode
select|hs_mode|$FORM_hs_mode
option|wireless|Wireless Only
option|combined|LAN & Wireless
helpitem|Want a demo?
helptext|Here are some options: <ul><li><a href="javascript:setconfig('chillispot','coova-ap-tos','coovachilli');">Coova Simple ToS</a></li><li><a href="javascript:setconfig('chillispot','picopoint-demo','coovachilli');">PicoPoint Gatekeeper Demo</a></li></ul>
end_form
EOF

chilli_msg=$(has_pkgs chillispot)
if empty "$chilli_msg"; then
    display_form <<EOF
start_form|ChilliSpot Configurations|chilli_config|hidden
field|Auto Configuration
onchange|modechange
select|hs_radconf|$FORM_hs_radconf
option|on|Enabled
option|off|Disabled
field|RADIUS Server|radconf_server|hidden
text|hs_radconf_server|$FORM_hs_radconf_server
field|RADIUS Auth Port|radconf_authport|hidden
text|hs_radconf_authport|$FORM_hs_radconf_authport
field|Shared Secret|radconf_secret|hidden
text|hs_radconf_secret|$FORM_hs_radconf_secret
field|Config Name (username)|radconf_user|hidden
text|hs_radconf_user|$FORM_hs_radconf_user
field|Config Password|radconf_pwd|hidden
text|hs_radconf_pwd|$FORM_hs_radconf_pwd
field|UAM Hostname|uam_hostname|hidden
text|hs_uamserver|$FORM_hs_uamserver
field|UAM Secret|uam_secret|hidden
text|hs_uamsecret|$FORM_hs_uamsecret
field|NAS Identifier|uam_nasid|hidden
text|hs_nasid|$FORM_hs_nasid
helpitem|Auto Config
helptext|When using <b>Auto Config</b>, your settings are set by RADIUS. Otherwise, configure basic settings here, and then configure <a href="hs-radius.sh">RADIUS</a>, and <a href="hs-advanced.sh">Advanced</a> settings. (be sure to <b>Save Changes</b> on each page and then <b>Apply Changes</b> at the end)
end_form
EOF
else
    display_form <<EOF
start_form|ChilliSpot Configurations|chilli_config|hidden
message|$chilli_msg
end_form
EOF
fi

display_form <<EOF
start_form|WiFiDog Configurations|wifidog_config|hidden
EOF

wifidog_msg=$(has_pkgs wifidog)
if empty "$wifidog_msg"; then
    display_form <<EOF
field|Gateway ID
text|hs_gatewayid|$FORM_hs_gatewayid
end_form
EOF

if [ ! -e /etc/wifidog/auth-servers ]; then
mkdir /etc/wifidog >/dev/null
touch /etc/wifidog/auth-servers
fi

awk     -v "url=$SCRIPT_NAME" \
	-v "host=$FORM_host" \
	-v "proto=$FORM_proto" \
        -v "port=$FORM_port" \
        -v "path=$FORM_path" \
        -f /usr/lib/webif/common.awk -f - /etc/wifidog/auth-servers <<EOF
BEGIN {
	FS="[ \\t]"
        line=1
	print "<form enctype=\\"multipart/form-data\\" method=\\"post\\">"
	start_form("@TR<<Auth Servers>>"," style=\"display:none;\" id=\"auth-servers\"")
	print "<table width=\\"70%\\" summary=\\"Settings\\">"
	print "<tr><th>@TR<<Hostname>></th><th>@TR<<Proto>></th><th>Port</th><th>Path</th><th></th></tr>"
}

{
	print "<tr><td>" \$1 "</td><td>" \$2 "</td><td>" \$3 "</td><td>" \$4 "</td><td align=\\"right\\" width=\\"10%\\"><a href=\\"" url "?del_host=1&line=" line "\\">@TR<<Remove>></a></td></tr>"
        line = line  1
}

END {
	print "<tr><td>" textinput("host", host) "</td><td><select name=\"proto\">" sel_option("http", "http", proto) sel_option("https", "https", proto) "</select></td><td><input type=\"text\" name=\"port\" value=\"" port "\" size=5 maxlength=5 /></td><td>" textinput("path", path) "</td><td style=\\"width: 10em\\">" button("add_host", "Add") "</td></tr>"
	print "</table>"
	print "</form>"
	end_form();
}
EOF


else
display_form <<EOF
message|$wifidog_msg
end_form
EOF
fi

fi

footer ?>
<!--
##WEBIF:name:HotSpot:1:Configuration
-->
