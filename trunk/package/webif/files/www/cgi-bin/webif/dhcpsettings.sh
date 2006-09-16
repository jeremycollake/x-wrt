#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
. /etc/functions.sh
load_settings network

if empty "$FORM_submit"; then
        FORM_dhcp_cache_size=${dhcp_cache_size:-$(nvram get dhcp_cache_size)}
        FORM_dhcp_no_hosts=${dhcp_no_hosts:-$(nvram get dhcp_no_hosts)}
        FORM_dhcp_no_regcache=${dhcp_no_regcache:-$(nvram get dhcp_no_regcache)}
        FORM_dhcp_strict_order=${dhcp_strict_order:-$(nvram get dhcp_strict_order)}
        FORM_dhcp_port=${dhcp_port:-$(nvram get dhcp_port)}
        FORM_dhcp_log_queries=${dhcp_log_queries:-$(nvram get dhcp_log_queries)}
        FORM_dhcp_no_resolv=${dhcp_no_resolv:-$(nvram get dhcp_no_resolv)}
        FORM_dhcp_domain=${dhcp_domain:-$(nvram get dhcp_domain)}
        FORM_dhcp_lease_max=${dhcp_lease_max:-$(nvram get dhcp_lease_max)}
        FORM_dhcp_read_ethers=${dhcp_read_ethers:-$(nvram get dhcp_read_ethers)}
else 
    SAVED=1
    validate <<EOF
int|FORM_dhcp_cache_size|DHCP cache size||$FORM_dhcp_cache_size
int|FORM_dhcp_no_hosts|DHCP no hosts||$FORM_dhcp_no_hosts
int|FORM_dhcp_no_regcache|DHCP no regcache||$FORM_dhcp_no_regcache
int|FORM_dhcp_strict_order|DHCP strict order||$FORM_dhcp_strict_order
int|FORM_dhcp_port|DHCP port||$FORM_dhcp_port
int|FORM_dhcp_log_queries|DHCP log queries||$FORM_dhcp_log_queries
int|FORM_dhcp_no_resolv|DHCP no resolv||$FORM_dhcp_no_resolv
string|FORM_dhcp_domain|DHCP domain||$FORM_dhcp_domain
int|FORM_dhcp_lease_max|DHCP dhcp||$FORM_dhcp_lease_max
int|FORM_dhcp_read_ethers|DHCP read ethers||$FORM_dhcp_read_ethers
EOF
    equal "$?" 0 && {
        save_setting network dhcp_cache_size $FORM_dhcp_cache_size
        save_setting network dhcp_no_hosts $FORM_dhcp_no_hosts
        save_setting network dhcp_no_regcache $FORM_dhcp_no_regcache
        save_setting network dhcp_strict_order $FORM_dhcp_strict_order
        save_setting network dhcp_port $FORM_dhcp_port
        save_setting network dhcp_log_queries $FORM_dhcp_log_queries
        save_setting network dhcp_no_resolv $FORM_dhcp_no_resolv
        save_setting network dhcp_domain $FORM_dhcp_domain
        save_setting network dhcp_lease_max $FORM_dhcp_lease_max
        save_setting network dhcp_read_ethers $FORM_dhcp_read_ethers
    }
fi

header "Network" "DHCPSettings" "@TR<<DHCP Configuration>>" '' "$SCRIPT_NAME"

display_form <<EOF
start_form|@TR<<DHCP Configuration>> $FORM_iface
field|@TR<<Cache Size>>|dhcp_cache_size
text|dhcp_cache_size|$FORM_dhcp_cache_size
field|@TR<<No Hosts>>|dhcp_no_hosts
checkbox|dhcp_no_hosts|$FORM_dhcp_no_hosts|1
field|@TR<<No Reg Cache>>|dhcp_no_regcache
checkbox|dhcp_no_regcache|$FORM_dhcp_no_regcache|1
field|@TR<<Strict Order>>|dhcp_strict_order
checkbox|dhcp_strict_order|$FORM_dhcp_strict_order|1
field|@TR<<Log Queries>>|dhcp_log_queries
checkbox|dhcp_log_queries|$FORM_dhcp_log_queries|1
field|@TR<<No Resolv>>|dhcp_no_resolv
checkbox|dhcp_no_resolv|$FORM_dhcp_no_resolv|1
field|@TR<<Port>>|_dhcp_port
text|dhcp_port|$FORM_dhcp_port
field|@TR<<Domain>>|dhcp_domain
text|dhcp_domain|$FORM_dhcp_domain
field|@TR<<Lease Max>>|dhcp_lease_max
text|dhcp_lease_max|$FORM_dhcp_lease_max
field|@TR<<Read Ethers>>|dhcp_read_ethers
checkbox|dhcp_read_ethers|$FORM_dhcp_read_ethers|1
end_form
EOF

footer ?>
<!--
##WEBIF:name:Network:450:Dnsmasq
-->