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
conntrack_path="/proc/sys/net/ipv4/netfilter"

save_setting_ip_conntrack() {
	local group="conntrack"
	# $1 = name
	# $2 = value
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	oldval=$(cat "$conntrack_path/$1" 2>/dev/null)
	grep "^$1=" /tmp/.webif/config-${group} >&- 2>&- && {
		grep -v "^$1=" /tmp/.webif/config-${group} > /tmp/.webif/config-${group}-new 2>&-
		mv /tmp/.webif/config-${group}-new /tmp/.webif/config-${group} 2>&- >&-
	}
	equal "$oldval" "$2" || echo "$1=\"$2\"" >> /tmp/.webif/config-${group} 2>/dev/null
}

empty "$FORM_submit" && {
	load_settings "conntrack"
	FORM_ip_conntrack_max="${ip_conntrack_max:-$(cat "$conntrack_path/ip_conntrack_max" 2>/dev/null)}"
	FORM_ip_conntrack_generic_timeout="${ip_conntrack_generic_timeout:-$(cat "$conntrack_path/ip_conntrack_generic_timeout" 2>/dev/null)}"
	FORM_ip_conntrack_icmp_timeout="${ip_conntrack_icmp_timeout:-$(cat "$conntrack_path/ip_conntrack_icmp_timeout" 2>/dev/null)}"
	FORM_ip_conntrack_tcp_timeout_established="${ip_conntrack_tcp_timeout_established:-$(cat "$conntrack_path/ip_conntrack_tcp_timeout_established" 2>/dev/null)}"
	FORM_ip_conntrack_udp_timeout="${ip_conntrack_udp_timeout:-$(cat "$conntrack_path/ip_conntrack_udp_timeout" 2>/dev/null)}"
	FORM_ip_conntrack_udp_timeout_stream="${ip_conntrack_udp_timeout_stream:-$(cat "$conntrack_path/ip_conntrack_udp_timeout_stream" 2>/dev/null)}"
} || {
	SAVED=1
	validate <<EOF
int|FORM_ip_conntrack_max|@TR<<Maximum Connections>>|min=512 max=32768|$FORM_ip_conntrack_max
int|FORM_ip_conntrack_generic_timeout|@TR<<Generic Timeout>>|min=1 max=134217728|$FORM_ip_conntrack_generic_timeout
int|FORM_ip_conntrack_icmp_timeout|@TR<<ICMP Timeout>>|min=1 max=134217728|$FORM_ip_conntrack_icmp_timeout
int|FORM_ip_conntrack_tcp_timeout_established|@TR<<TCP Established Timeout>>|min=30 max=134217728|$FORM_ip_conntrack_tcp_timeout_established
int|FORM_ip_conntrack_udp_timeout|@TR<<UDP Timeout>>|min=30 max=134217728|$FORM_ip_conntrack_udp_timeout
int|FORM_ip_conntrack_udp_timeout_stream|@TR<<UDP Stream Timeout>>|min=30 max=134217728|$FORM_ip_conntrack_udp_timeout_stream
EOF
	equal "$?" "0" && {
		save_setting_ip_conntrack ip_conntrack_max "$FORM_ip_conntrack_max"
		save_setting_ip_conntrack ip_conntrack_generic_timeout "$FORM_ip_conntrack_generic_timeout"
		save_setting_ip_conntrack ip_conntrack_icmp_timeout "$FORM_ip_conntrack_icmp_timeout"
		save_setting_ip_conntrack ip_conntrack_tcp_timeout_established "$FORM_ip_conntrack_tcp_timeout_established"
		save_setting_ip_conntrack ip_conntrack_udp_timeout "$FORM_ip_conntrack_udp_timeout"
		save_setting_ip_conntrack ip_conntrack_udp_timeout_stream "$FORM_ip_conntrack_udp_timeout_stream"
	}
}

equal "$FORM_ip_conntrack_tcp_timeout_established" "432000" && {
	tcp_warning_text='<table width="55%"><tbody><tr><td>
<div class="warning">@TR<<big_warning#WARNING>>: @TR<<network_misc_too_big_timeout#Your default TCP established timeout value is very high (5 days). Most peer-2-peer users should lower it. A safe setting is probably 1 day (86400), though some users prefer 1 hour (3600).>></div>
</td></tr></tbody></table>'
}

header "Network" "Tweaks" "@TR<<Networking Tweaks>>" '' "$SCRIPT_NAME"

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

footer ?>
<!--
##WEBIF:name:Network:900:Tweaks
-->
