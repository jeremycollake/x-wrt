#!/usr/bin/webif-page
<?
# Adopted from vpn-openvpn.sh
# July 2007 - Authored by Liran Tal <liran@enginx.com>

. /usr/lib/webif/webif.sh

config_cb() {
        config_get TYPE "$CONFIG_SECTION" TYPE
        case "$TYPE" in
                server)
                        server_cfg="$CONFIG_SECTION"
                ;;
        esac
}

uci_load "l2tpns"

header "VPN" "L2TPns" "@TR<<L2TPns>>" ' onload="modechange()" ' "$SCRIPT_NAME"

if ! empty "$FORM_install_package"; then
        echo "@TR<<vpn_l2tpns_Installing_package#Installing l2tpns package ...>><pre>"
        install_package "l2tpns"
        echo "</pre>"
fi

install_package_button=""
! is_package_installed "l2tpns" &&
        install_package_button="string|<div class=warning>@TR<<vpn_l2tpns_warn#VPN will not work until you install L2TPns:>> </div>
                submit|install_package| @TR<<vpn_l2tpns_install_package#Install L2TPns Package>> |"

if empty "$FORM_submit"; then
        eval "FORM_l2tpns_cfg1_mode=\"\$CONFIG_${server_cfg}_mode\""
        eval "FORM_l2tpns_cfg1_serverip=\"\$CONFIG_${server_cfg}_serverip\""
        eval "FORM_l2tpns_cfg1_dns1=\"\$CONFIG_${server_cfg}_dns1\""
        eval "FORM_l2tpns_cfg1_dns2=\"\$CONFIG_${server_cfg}_dns2\""
        eval "FORM_l2tpns_cfg1_debug=\"\$CONFIG_${server_cfg}_debug\""
        eval "FORM_l2tpns_cfg1_radiusacctmode=\"\$CONFIG_${server_cfg}_radiusacctmode\""
        eval "FORM_l2tpns_cfg1_pidfile=\"\$CONFIG_${server_cfg}_pidfile\"" 
        eval "FORM_l2tpns_cfg1_logfile=\"\$CONFIG_${server_cfg}_logfile\""
        eval "FORM_l2tpns_cfg1_radius1=\"\$CONFIG_${server_cfg}_radius1\"" 
        eval "FORM_l2tpns_cfg1_radius2=\"\$CONFIG_${server_cfg}_radius2\"" 
        eval "FORM_l2tpns_cfg1_radiusauthport=\"\$CONFIG_${server_cfg}_radiusauthport\"" 
        eval "FORM_l2tpns_cfg1_radiussecret=\"\$CONFIG_${server_cfg}_radiussecret\"" 

else
        [ "$server_cfg" = "" ] && {
                uci_add "l2tpns" "server"
                server_cfg="cfg1"
        }
        uci_set "l2tpns" "$server_cfg" "mode" "$FORM_l2tpns_cfg1_mode"
        uci_set "l2tpns" "$server_cfg" "serverip" "$FORM_l2tpns_cfg1_serverip"
        uci_set "l2tpns" "$server_cfg" "dns1" "$FORM_l2tpns_cfg1_dns1"
        uci_set "l2tpns" "$server_cfg" "dns2" "$FORM_l2tpns_cfg1_dns2"
        uci_set "l2tpns" "$server_cfg" "radius1" "$FORM_l2tpns_cfg1_radius1"
        uci_set "l2tpns" "$server_cfg" "radius2" "$FORM_l2tpns_cfg1_radius2"
        uci_set "l2tpns" "$server_cfg" "radiussecret" "$FORM_l2tpns_cfg1_radiussecret"
        uci_set "l2tpns" "$server_cfg" "radiusauthport" "$FORM_l2tpns_cfg1_radiusauthport"
        uci_set "l2tpns" "$server_cfg" "radiusacctmode" "$FORM_l2tpns_cfg1_radiusacctmode"
        uci_set "l2tpns" "$server_cfg" "debug" "$FORM_l2tpns_cfg1_debug"
        uci_set "l2tpns" "$server_cfg" "pidfile" "$FORM_l2tpns_cfg1_pidfile"
        uci_set "l2tpns" "$server_cfg" "logfile" "$FORM_l2tpns_cfg1_logfile"

fi

cat <<EOF
<script type="text/javascript" src="/webif.js "></script>
<script type="text/javascript">
<!--
function modechange()
{
        var v;
        v = isset('l2tpns_cfg1_mode', 'enabled');
        set_visible('connection_settings', v);

        hide('save');
        show('save');
}
-->
</script>
EOF


display_form <<EOF
onchange|modechange
$install_package_button
start_form|@TR<<L2TPns>>
field|@TR<<Start L2TPns Connection>>
select|l2tpns_cfg1_mode|$FORM_l2tpns_cfg1_mode
option|disabled|@TR<<Disabled>>
option|enabled|@TR<<Enabled>>
end_form

start_form|@TR<<Connection Settings>>|connection_settings|hidden
field|@TR<<Server Address>>
text|l2tpns_cfg1_serverip|$FORM_l2tpns_cfg1_serverip
helpitem|l2tpns_cfg1_serverip#Server Address
helptext|l2tpns_cfg1_serverip_text#The IP Address on which the L2TPns server will be listening on

field|@TR<<Primary DNS>>
text|l2tpns_cfg1_dns1|$FORM_l2tpns_cfg1_dns1
field|@TR<<Secondary DNS>>
text|l2tpns_cfg1_dns2|$FORM_l2tpns_cfg1_dns2
helpitem|l2tpns_cfg1_dns#DNS Addresses
helptext|l2tpns_cfg1_dns_text#DNS Servers upon which clients will be provided with

field|@TR<<Primary RADIUS>>
text|l2tpns_cfg1_radius1|$FORM_l2tpns_cfg1_radius1
field|@TR<<Secondary RADIUS>>
text|l2tpns_cfg1_radius2|$FORM_l2tpns_cfg1_radius2
helpitem|l2tpns_cfg1_radius#RADIUS Servers
helptext|l2tpns_cfg1_radius_text#RADIUS Servers IP Addresses

field|@TR<<RADIUS Secret>>
text|l2tpns_cfg1_radiussecret|$FORM_l2tpns_cfg1_radiussecret
field|@TR<<RADIUS Port>>
text|l2tpns_cfg1_radiusauthport|$FORM_l2tpns_cfg1_radiusauthport
helpitem|l2tpns_cfg1_radiussecret#RADIUS Secret
helptext|l2tpns_cfg1_radiussecret_text#RADIUS Servers shared secret key

field|@TR<<RADIUS Accounting>>
helpitem|l2tpns_cfg1_radiusauthport#RADIUS Port
helptext|l2tpns_cfg1_radiusauthport_text#RADIUS Servers Port for authentication (the same is used for both primary and secondary radiu
s servers)

select|l2tpns_cfg1_radiusacctmode|$FORM_l2tpns_cfg1_radiusacctmode
option|yes|@TR<<Yes>>
option|no|@TR<<No>>

field|@TR<<Debug>>
select|l2tpns_cfg1_debug|$FORM_l2tpns_cfg1_debug
option|1|1
option|2|2
option|3|3

field|@TR<<Log file>>
text|l2tpns_cfg1_logfile|$FORM_l2tpns_cfg1_logfile

field|@TR<<Pid file>>
text|l2tpns_cfg1_pidfile|$FORM_l2tpns_cfg1_pidfile

end_form

EOF

footer
?>
<!--
##WEBIF:name:VPN:3:L2TPns
-->
