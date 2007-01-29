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
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced:
#   /etc/sysctl.conf
#

header "Network" "Tweaks" "@TR<<Networking Tweaks>>" '' "$SCRIPT_NAME"

! empty "$FORM_submit" && {
	validate <<EOF
int|FORM_ip_conntrack_max|Maximum Connections|min=512 max=32768|$FORM_ip_conntrack_max
int|FORM_ip_conntrack_udp_timeout_stream|UDP Stream Timeout|min=30 max=134217728|$FORM_ip_conntrack_udp_timeout_stream
int|FORM_ip_conntrack_udp_timeout|UDP Timeout|min=30 max=134217728|$FORM_ip_conntrack_udp_timeout
int|FORM_ip_conntrack_tcp_timeout_established|TCP Established Timeout|min=30 max=134217728|$FORM_ip_conntrack_tcp_timeout_established
int|FORM_ip_conntrack_generic_timeout|Generic Timeout|min=1 max=134217728|$FORM_ip_conntrack_generic_timeout
int|FORM_ip_conntrack_icmp_timeout|ICMP Timeout|min=1 max=134217728|$FORM_ip_conntrack_icmp_timeout
EOF
	equal "$?" "0" && {
		save_setting conntrack ip_conntrack_udp_timeout_stream "$FORM_ip_conntrack_udp_timeout_stream"
		save_setting conntrack ip_conntrack_udp_timeout "$FORM_ip_conntrack_udp_timeout"
		save_setting conntrack ip_conntrack_tcp_timeout_established "$FORM_ip_conntrack_tcp_timeout_established"
		save_setting conntrack ip_conntrack_max "$FORM_ip_conntrack_max"
		save_setting conntrack ip_conntrack_generic_timeout "$FORM_ip_conntrack_generic_timeout"
		save_setting conntrack ip_conntrack_icmp_timeout "$FORM_ip_conntrack_icmp_timeout"
	}
}

load_settings "conntrack"

FORM_ip_conntrack_max="${ip_conntrack_max:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_max)}"
FORM_ip_conntrack_generic_timeout="${ip_conntrack_generic_timeout:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_generic_timeout)}"
FORM_ip_conntrack_icmp_timeout="${ip_conntrack_icmp_timeout:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_icmp_timeout)}"
FORM_ip_conntrack_tcp_timeout_established="${ip_conntrack_tcp_timeout_established:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established)}"
FORM_ip_conntrack_udp_timeout_stream="${ip_conntrack_udp_timeout_stream:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout_stream)}"
FORM_ip_conntrack_udp_timeout="${ip_conntrack_udp_timeout:-$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout)}"

equal "$FORM_ip_conntrack_tcp_timeout_established" "432000" && {
	tcp_warning_text='<table width="55%"><tbody><tr><td>
	<div class="warning">WARNING: Your default TCP established timeout value is very high (5 days). Most peer-2-peer users should lower it. A safe setting is probably 1 day (86400), though some users prefer 1 hour (3600).</div>
	</td></tr></tbody></table>'
}

display_form <<EOF
start_form|@TR<<Conntrack Settings>>
field|@TR<<Maximum Connections>>|field_ip_conntrack_max
text|ip_conntrack_max|$FORM_ip_conntrack_max
helpitem|Maximum Connections
helptext|HelpText maximum_connections#This is the maximum number of simultaneous connections your router can track. A larger number means more RAM use and higher CPU utilization if that many connections actually end up used. It is usually best to leave this at its default value.
field|@TR<<Generic Timeout>>|field_ip_conntrack_generic_timeout
text|ip_conntrack_generic_timeout|$FORM_ip_conntrack_generic_timeout
field|@TR<<ICMP Timeout>>|field_ip_conntrack_icmp_timeout
text|ip_conntrack_icmp_timeout|$FORM_ip_conntrack_icmp_timeout
field|@TR<<TCP Established Timeout>>|field_ip_conntrack_tcp_timeout_established
text|ip_conntrack_tcp_timeout_established|$FORM_ip_conntrack_tcp_timeout_established
helpitem|TCP Established Timeout
helptext|HelpText tcp_established_timeout#This is the number of seconds that a established connection can be idle before it is forcibly closed. Sometimes connections are not properly closed and can fill up your conntrack table if these values are too high. If they are too low, then connections can be disconnected simply because they are idle.
field|@TR<<UDP Timeout>>|field_ip_conntrack_udp_timeout
text|ip_conntrack_udp_timeout|$FORM_ip_conntrack_udp_timeout
field|@TR<<UDP Stream Timeout>>|field_ip_conntrack_udp_timeout_stream
text|ip_conntrack_udp_timeout_stream|$FORM_ip_conntrack_udp_timeout_stream
#field|@TR<<Reset to Defaults>>
#submit|reset_defaults|&nbsp;Reset&nbsp;
end_form
EOF

echo "$tcp_warning_text"
show_validated_logo

footer ?>
<!--
##WEBIF:name:Network:900:Tweaks
-->
