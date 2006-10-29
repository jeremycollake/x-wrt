
. /etc/functions.sh
. /etc/functions-net.sh

[ -z "$(nvram get hs_type)$(nvram get hs_mode)" ] && {
    . /etc/hs/defaults 
}

configs=/etc/hs/configs.sh
[ ! -e $configs ] && {
    # All the possible hs_<name> attributes
    HS_CONFIGS="type mode nasid uamhomepage uamserver uamsecret \
radius radius2 radauth radacct radsecret radsecret2 admusr admpwd \
tapif network netmask dynip dynip_mask statip statip_mask \
uamlisten uamformat uamallow macallow macauth web_admin \
uamport provider provider_link wwwdir adminterval gatewayid \
radconf_server radconf_secret radconf_user radconf_pwd \
radconf radconf_authport radconf_acctport \
cframe cframe_url cframe_pos cframe_sz"
    for n in $HS_CONFIGS; do
	N=$(echo $n | tr 'a-z' 'A-Z')
	echo "HS_$N=\$(nvram get hs_$n)" >> $configs
    done
}
. $configs

LAN_IPADDR=${lan_ipaddr:-$(nvram get lan_ipaddr)}
LAN_NETMASK=${lan_netmask:-$(nvram get lan_netmask)}
LAN_IPADDR=$(ip2int $LAN_IPADDR)
LAN_NETMASK=$(ip2int ${LAN_NETMASK:-255.255.255.0})
LAN_NETWORK=$((LAN_IPADDR&LAN_NETMASK))
LAN_CLASSC_MASK=$(ip2int 255.255.255.0)
LAN_CLASSC_NET=$((LAN_IPADDR&LAN_CLASSC_MASK))

HS_TAPIF=${HS_TAPIF:-br0}

# for chilli
HS_UAMPORT=${HS_UAMPORT:-3990}
HS_WWWDIR=${HS_WWWDIR:=/etc/chilli/www}

case ${hs_mode:-$HS_MODE} in
    combined)
	HS_NETWORK=${HS_NETWORK:-$(int2ip $LAN_CLASSC_NET)}
	HS_NETMASK=${HS_NETMASK:-$(int2ip $LAN_NETMASK)}
	HS_UAMLISTEN=${HS_UAMLISTEN:-$(int2ip $LAN_IPADDR)}
	;;
    wireless)
	HS_NETWORK=${HS_NETWORK:-10.1.0.0}
	HS_NETMASK=${HS_NETMASK:-255.255.0.0}
	HS_UAMLISTEN=${HS_UAMLISTEN:-10.1.0.1}
	HS_DYNIP=${HS_DYNIP:-10.1.1.0}
	HS_DYNIP_MASK=${HS_DYNIP_MASK:-255.255.255.0}
	;;
esac

RUN_D=/var/run
CMDSOCK=$RUN_D/chilli.sock
PIDFILE=$RUN_D/chilli.pid

HS_SSID=$(grep current_bss.SSID /proc/net/wl0|awk '{print $2}'|sed s/\"//g)
HS_NASMAC=$(grep perm_etheraddr /proc/net/wl0|awk '{print $2}')
HS_WANIF=$(nvram get wan_ifname)
HS_NASIP=${HS_WANIF:+$(ifconfig $HS_WANIF|grep 'inet addr'|awk -F: '{print $2}'|awk '{print $1}')}
HS_DNS_DOMAIN=${HS_DNS_DOMAIN:-cap.coova.org}
HS_DNS1=${HS_DNS1:-$HS_UAMLISTEN}
HS_DNS2=${HS_DNS2:-$HS_NASIP}
HS_NASID=${HS_NASID:-$HS_NASMAC}

HS_CFRAME_URL=${HS_CFRAME_URL:-http://coova.org/cframe/default/}
HS_CFRAME_SZ=${HS_CFRAME_SZ:-100}
HS_CFRAME_POS=${HS_CFRAME_POS:-top}

