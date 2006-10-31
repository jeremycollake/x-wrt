#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
###################################################################
# Misc. Network Configuration
#
# Description:
#	Misc. Network configuration
#
# Author(s) [in order of work date]: 
# 	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced: 
#   /etc/sysctl.conf
#

header "Network" "Miscellaneous" "@TR<<Miscellaneous Configuration>>" 'onload="modechange()"' "$SCRIPT_NAME"

! empty "$FORM_submit" && {
	validate <<EOF
int|FORM_udp_est_timeout|UDP Established Timeout|min=30 max=134217728|$FORM_udp_est_timeout
int|FORM_tcp_est_timeout|TCP Established Timeout|min=30 max=134217728|$FORM_tcp_est_timeout
EOF
	equal "$?" "0" && {
		save_setting conntrack udp_est_timeout "$FORM_udp_est_timeout"
		save_setting conntrack tcp_est_timeout "$FORM_tcp_est_timeout"
	}	
}

load_settings "conntrack"

# defaults used in WR RC6
#net.ipv4.ip_conntrack_tcp_timeouts="300 43200 120 60 120 120 10 60 30 120"
#net.ipv4.ip_conntrack_udp_timeouts="60 180"
sysctl_contents=$(cat /etc/sysctl.conf)
all_tcp_timeouts=$(echo "$sysctl_contents" | grep "net.ipv4.ip_conntrack_tcp_timeouts" | cut -d'=' -f2)
all_udp_timeouts=$(echo "$sysctl_contents" | grep "net.ipv4.ip_conntrack_udp_timeouts" | cut -d'=' -f2)

# if we have a full string of timeouts, extract applicable ones
! empty "$all_tcp_timeouts" && {
	current_tcp_est_timeout=$(echo "$all_tcp_timeouts" | cut -d' ' -f2)	
}
! empty "$all_udp_timeouts" && {
	current_udp_est_timeout=$(echo "$all_udp_timeouts" | cut -d' ' -f2)
}

# if we have specific timeouts, extract applicable ones
echo "$sysctl_contents" | grep -q "ip_conntrack_tcp_timeout_established"
equal "$?" "0" && {
	current_tcp_est_timeout=$(echo "$sysctl_contents" | grep "ip_conntrack_tcp_timeout_established" | cut -d'=' -f2)
}
echo "$sysctl_contents" | grep -q "ip_conntrack_udp_timeout_established"
equal "$?" "0" && {
	current_udp_est_timeout=$(echo "$sysctl_contents" | grep "ip_conntrack_udp_timeout_established" | cut -d'=' -f2)
}

FORM_tcp_est_timeout="${tcp_est_timeout:-$current_tcp_est_timeout}"
FORM_tcp_est_timeout="${FORM_tcp_est_timeout:-432000}"
# todo: what is the default udp timeout?
FORM_udp_est_timeout="${udp_est_timeout:-$current_udp_est_timeout}"
FORM_udp_est_timeout="${FORM_udp_est_timeout:-432000}"

display_form <<EOF
start_form|@TR<<Conntrack Configuration>>
field|@TR<<UDP Established Timeout>>|udp_est_timeout
text|udp_est_timeout|$FORM_udp_est_timeout
field|@TR<<TCP Established Timeout>>|tcp_est_timeout
text|tcp_est_timeout|$FORM_tcp_est_timeout
end_form
EOF

#show_validated_logo

footer ?>
<!--
##WEBIF:name:Network:900:Miscellaneous
-->
