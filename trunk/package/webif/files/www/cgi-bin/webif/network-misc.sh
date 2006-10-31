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
int|FORM_max_conntrack|Maximum Connections|min=512 max=16384|$FORM_max_conntrack
int|FORM_udp_stream_timeout|UDP Stream Timeout|min=30 max=134217728|$FORM_udp_stream_timeout
#int|FORM_udp_timeout|UDP Timeout|min=30 max=134217728|$FORM_udp_timeout
int|FORM_tcp_est_timeout|TCP Established Timeout|min=30 max=134217728|$FORM_tcp_est_timeout
EOF
	equal "$?" "0" && {
		save_setting conntrack udp_stream_timeout "$FORM_udp_stream_timeout"
		save_setting conntrack udp_timeout "$FORM_udp_timeout"
		save_setting conntrack tcp_est_timeout "$FORM_tcp_est_timeout"
		save_setting conntrack max_conntrack "$FORM_max_conntrack"
	}	
}

load_settings "conntrack"

# defaults used in WR RC6
#net.ipv4.ip_conntrack_tcp_timeouts="300 43200 120 60 120 120 10 60 30 120"
#net.ipv4.ip_conntrack_udp_timeouts="60 180"
current_max_conntrack=$(cat /proc/sys/net/ipv4/ip_conntrack_max)
current_tcp_est_timeout=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established)
current_udp_stream_timeout=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout_stream)
#current_udp_timeout=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout)

FORM_max_conntrack="${max_conntrack:-$current_max_conntrack}"
FORM_tcp_est_timeout="${tcp_est_timeout:-$current_tcp_est_timeout}"
FORM_udp_stream_timeout="${udp_stream_timeout:-$current_udp_stream_timeout}"
#FORM_udp_timeout="${udp_timeout:-$current_udp_timeout}"

display_form <<EOF
start_form|@TR<<Conntrack Configuration>>
field|@TR<<Maximum Connections>>|max_conntrack
text|max_conntrack|$FORM_max_conntrack
helpitem|Maximum Connections
helptext|HelpText maximum_connections#This is the maximum number of simultaneous connections your router can track. A larger number means more RAM use and higher CPU utilization if that many connections actually end up used. It is usually best to leave this at its default value.
field|@TR<<TCP Established Timeout>>|tcp_est_timeout
text|tcp_est_timeout|$FORM_tcp_est_timeout
helpitem|TCP Established Timeout
helptext|HelpText tcp_established_timeout#This is the number of seconds that a established connection can be idle before it is forcibly closed. Sometime connections are not properly closed and can fill up your conntrack table if these values are too high. If they are too low, then connections can be disconnected simple because they are idle.
#field|@TR<<UDP Timeout>>|udp_timeout
#text|udp_timeout|$FORM_udp_timeout
field|@TR<<UDP Stream Timeout>>|udp_stream_timeout
text|udp_stream_timeout|$FORM_udp_stream_timeout
end_form
EOF

#show_validated_logo

footer ?>
<!--
##WEBIF:name:Network:900:Miscellaneous
-->
