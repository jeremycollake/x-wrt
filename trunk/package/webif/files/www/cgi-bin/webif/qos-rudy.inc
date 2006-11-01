#
# Included from network-qos.sh
#
# Rudy's QoS Script Config
#
#
# Author: Travis Kemen <kemen04@gmail.com>
# Version 0.001
##FIXME: edonkey-dl shows up as -dl for Layer 7 rules
##FIXME: L7 Save rules need to be dynamic
##FIXME: L7 checkboxes need to display nicely
##Possible FIXME: Should the save function be changed?
##TODO: Finish Layer 7 Functions
##TODO: Combine some of the functions
##TODO: Figure out a different way to list and remove existing items
##TODO: Proper naming of variables.


. /etc/qos.conf

exists /tmp/.webif/qos  && QOS_FILE=/tmp/.webif/qos || QOS_FILE=/etc/qos.conf
exists $QOS_FILE || touch $QOS_FILE >&- 2>&-

# Number of blank fields to make
ipexprcount=5
ippriocount=5
ipbulkcount=5
tcpexprcount=5
tcppriocount=5
tcpbulkcount=5
udpexprcount=5
udppriocount=5
udpbulkcount=5


###############################################
for config in $(ls /etc/l7-protocols/ -1 |cut -d "." -f 1 2>&-); do
name=${config}
checkbox_string="checkbox|$name|$FORM_used|$name|$name<br>"
FORM_checkbox="$FORM_checkbox
		$checkbox_string"
FORM_ip_string="$FORM_ip_string FORM_$name"		
done
##############################################
for config in $IP_EXPR; do
name=${config}
ipbox_string="field|@TR<<Express IP Address>>
                text|ip_expr$ipexprcount|$name"
ip_expr="$ip_expr
                $ipbox_string"
let "ipexprcount+=1"
done
###############################################
for config in $IP_PRIO; do
name=${config}
ipbox_string="field|@TR<<Priority IP Address>>
                text|ip_prio$ippriocount|$name"
ip_prio="$ip_prio
                $ipbox_string"
let "ippriocount+=1"
done
###############################################
for config in $IP_BULK; do
name=${config}
ipbox_string="field|@TR<<Bulk IP Address>>
                text|ip_bulk$ipbulkcount|$name"
ip_bulk="$ip_bulk
                $ipbox_string"
let "ipbulkcount+=1"
done
###############################################
for config in $TCP_EXPR; do
name=${config}
ipbox_string="field|@TR<<Express TCP Port>>
                text|tcp_expr$tcpexprcount|$name"
tcp_expr="$tcp_expr
                $ipbox_string"
let "tcpexprcount+=1"
done
###############################################
for config in $TCP_PRIO; do
name=${config}
ipbox_string="field|@TR<<Priority TCP Port>>
                text|tcp_prio$tcppriocount|$name"
tcp_prio="$tcp_prio
                $ipbox_string"
let "tcppriocount+=1"
done
###############################################
for config in $TCP_BULK; do
name=${config}
ipbox_string="field|@TR<<Bulk TCP Port>>
                text|tcp_bulk$tcpbulkcount|$name"
tcp_bulk="$tcp_bulk
                $ipbox_string"
let "tcpbulkcount+=1"
done
###############################################
for config in $UDP_EXPR; do
name=${config}
ipbox_string="field|@TR<<Express UDP Port>>
                text|udp_expr$udpexprcount|$name"
udp_expr="$udp_expr
                $ipbox_string"
let "udpexprcount+=1"
done
###############################################
for config in $UDP_PRIO; do
name=${config}
ipbox_string="field|@TR<<Priority UDP Port>>
                text|udp_prio$udppriocount|$name"
udp_prio="$udp_prio
                $ipbox_string"
let "udppriocount+=1"
done
###############################################
for config in $UDP_BULK; do
name=${config}
ipbox_string="field|@TR<<Bulk UDP Port>>
                text|udp_bulk$udpbulkcount|$name"
udp_bulk="$udp_bulk
                $ipbox_string"
let "udpbulkcount+=1"
done


###############################################
#Save Functions				      #
###############################################
if empty "$FORM_submit"; then
        FORM_download_speed=${download_speed:-$DOWNLOAD}
        FORM_upload_speed=${upload_speed:-$UPLOAD}
        FORM_conntrack_max=${conntrack_max:-$(sysctl net.ipv4.ip_conntrack_max |cut -d ' ' -f 3)}
        FORM_conntrack_ip_conntrack_tcp_timeout_established=${conntrack_ip_conntrack_tcp_timeout_established:-$(sysctl net.ipv4.netfilter.ip_conntrack_ip_conntrack_tcp_timeout_established_established |cut -d ' ' -f 3)}
        FORM_conntrack_ip_conntrack_udp_timeout_stream=${conntrack_ip_conntrack_udp_timeout_stream:-$(sysctl net.ipv4.netfilter.ip_conntrack_ip_conntrack_udp_timeout_stream |cut -d ' ' -f 3)}
else 
	SAVED=1
	validate <<EOF
int|FORM_download_speed|@TR<<Download Speed>>|required|$FORM_download_speed
int|FORM_upload_speed|@TR<<Upload Speed>>|required|$FORM_upload_speed
EOF
	equal "$?" 0 && {
        	save_setting conntrack ip_conntrack_max $FORM_conntrack_max
        	save_setting conntrack ip_conntrack_tcp_timeout_established $FORM_conntrack_ip_conntrack_tcp_timeout_established
        	save_setting conntrack ip_conntrack_udp_timeout_stream $FORM_conntrack_ip_conntrack_udp_timeout_stream
        }

###############################################
for count in $(seq 0 $ipexprcount); do
eval "ip_test=\"\${FORM_ip_expr$count}\""
ip_val="$ip_test"
        for ip in $ip_val; do
        ip_expr_save_value="$ip_expr_save_value $ip"
        done
done
###############################################
for count in $(seq 0 $ippriocount); do
eval "ip_prio_val=\"\${FORM_ip_prio$count}\""
val_ip_prio="$ip_prio_val"
        for ip in $val_ip_prio; do
        ip_prio_save_value="$ip_prio_save_value $ip"
        done
done
################################################
for count in $(seq 0 $ipbulkcount); do
eval "ip_bulk_val=\"\${FORM_ip_bulk$count}\""
val_ip_bulk="$ip_bulk_val"
        for ip in $val_ip_bulk; do
        ip_bulk_save_value="$ip_bulk_save_value $ip"
        done
done
################################################
for count in $(seq 0 $tcpexprcount); do
eval "ip_test=\"\${FORM_tcp_expr$count}\""
ip_val="$ip_test"
        for ip in $ip_val; do
        tcp_expr_save_value="$tcp_expr_save_value $ip"
        done
done
###############################################
for count in $(seq 0 $tcppriocount); do
eval "ip_prio_val=\"\${FORM_tcp_prio$count}\""
val_ip_prio="$ip_prio_val"
        for ip in $val_ip_prio; do
        tcp_prio_save_value="$tcp_prio_save_value $ip"
        done
done
################################################
for count in $(seq 0 $tcpbulkcount); do
eval "ip_bulk_val=\"\${FORM_tcp_bulk$count}\""
val_ip_bulk="$ip_bulk_val"
        for ip in $val_ip_bulk; do
        tcp_bulk_save_value="$tcp_bulk_save_value $ip"
        done
done
################################################
for count in $(seq 0 $udpexprcount); do
eval "ip_test=\"\${FORM_udp_expr$count}\""
ip_val="$ip_test"
        for ip in $ip_val; do
        udp_expr_save_value="$udp_expr_save_value $ip"
        done
done
###############################################
for count in $(seq 0 $udppriocount); do
eval "ip_prio_val=\"\${FORM_udp_prio$count}\""
val_ip_prio="$ip_prio_val"
        for ip in $val_ip_prio; do
        udp_prio_save_value="$udp_prio_save_value $ip"
        done
done
################################################
for count in $(seq 0 $udpbulkcount); do
eval "ip_bulk_val=\"\${FORM_udp_bulk$count}\""
val_ip_bulk="$ip_bulk_val"
        for ip in $val_ip_bulk; do
        udp_bulk_save_value="$udp_bulk_save_value $ip"
        done
done

################################################
save_setting qos UPLOAD " $FORM_upload_speed"
save_setting qos DOWNLOAD " $FORM_download_speed"
save_setting qos IP_EXPR "$ip_expr_save_value"
save_setting qos IP_PRIO "$ip_prio_save_value"
save_setting qos IP_BULK "$ip_bulk_save_value"
save_setting qos TCP_EXPR "$tcp_expr_save_value"
save_setting qos TCP_PRIO "$tcp_prio_save_value"
save_setting qos TCP_BULK "$tcp_bulk_save_value"
save_setting qos UDP_EXPR "$udp_expr_save_value"
save_setting qos UDP_PRIO "$udp_prio_save_value"
save_setting qos UDP_BULK "$udp_bulk_save_value"
case "$FORM_priority" in
	expr) save_setting qos L7_EXPR "$FORM_aim $FORM_bittorrent $FORM_edonkey $FORM_fasttrack $FORM_ftp $FORM_gnutella $FORM_http $FORM_ident $FORM_irc $FORM_jabber $FORM_msnmessenger $FORM_ntp $FORM_pop3 $FORM_smtp $FORM_ssl $FORM_vnc";;
	prio) save_setting qos L7_PRIO "$FORM_aim $FORM_bittorrent $FORM_edonkey $FORM_fasttrack $FORM_ftp $FORM_gnutella $FORM_http $FORM_ident $FORM_irc $FORM_jabber $FORM_msnmessenger $FORM_ntp $FORM_pop3 $FORM_smtp $FORM_ssl $FORM_vnc";;
	bulk) save_setting qos L7_BULK "$FORM_aim $FORM_bittorrent $FORM_edonkey $FORM_fasttrack $FORM_ftp $FORM_gnutella $FORM_http $FORM_ident $FORM_irc $FORM_jabber $FORM_msnmessenger $FORM_ntp $FORM_pop3 $FORM_smtp $FORM_ssl $FORM_vnc";;
esac
fi

cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">
<!--
function modechange()
{	

        if (isset('protocol','ip'))
        {
            set_visible('ip_expr_form', isset('priority','expr'));
            set_visible('ip_prio_form', isset('priority','prio'));
            set_visible('ip_bulk_form', isset('priority','bulk'));
            hide('tcp_expr_form');
            hide('tcp_prio_form');
            hide('tcp_bulk_form');
            hide('udp_expr_form');
            hide('udp_prio_form');
            hide('udp_bulk_form');
		hide('l7_form');
        }
        if (isset('protocol','tcp'))
	  {
	      set_visible('tcp_expr_form', isset('priority','expr'));
	      set_visible('tcp_prio_form', isset('priority','prio'));
	      set_visible('tcp_bulk_form', isset('priority','bulk'));
	      hide('ip_expr_form');
		hide('ip_prio_form');
		hide('ip_bulk_form');
		hide('udp_expr_form');
		hide('udp_prio_form');
            hide('udp_bulk_form');
        	hide('l7_form');
	  }
        if (isset('protocol','udp'))
	{
		set_visible('udp_expr_form', isset('priority','expr'));
		set_visible('udp_prio_form', isset('priority','prio'));
		set_visible('udp_bulk_form', isset('priority','bulk'));                
	      hide('ip_expr_form');
		hide('ip_prio_form');
		hide('ip_bulk_form');
		hide('tcp_expr_form');
		hide('tcp_prio_form');
            hide('tcp_bulk_form');
		hide('l7_form');

        }
	if (isset('protocol','layer7'))
	{
		set_visible('l7_form', isset('protocol','layer7'));
	      hide('ip_expr_form');
		hide('ip_prio_form');
		hide('ip_bulk_form');
		hide('tcp_expr_form');
		hide('tcp_prio_form');
            hide('tcp_bulk_form');
            hide('udp_expr_form');
            hide('udp_prio_form');
            hide('udp_bulk_form');
	}
	hide('save');
	show('save');
}
-->
</script>
EOF
#################################################################
#       Upload and Download Speed, and conntrack Forms          #
#################################################################
display_form <<EOF
onchange|modechange
start_form|@TR<<QOS Internet Speed Configuration>>
field|@TR<<Upload Speed>>
helpitem|Up/Down Speeds
helptext|HelpText Up/Down Speeds#Set 5% - 10% lower than *measured* line speed (set to zero to disable)
text|upload_speed|$FORM_upload_speed
field|@TR<<Download Speed>>
text|download_speed|$FORM_download_speed
field|@TR<<Maximum Number Of Connections>>
text|conntrack_max|$FORM_conntrack_max
field|@TR<<TCP Timeout (in seconds)>>
text|conntrack_ip_conntrack_tcp_timeout_established|$FORM_conntrack_ip_conntrack_tcp_timeout_established
field|@TR<<UDP Timeout (in seconds)>>
text|conntrack_ip_conntrack_udp_timeout_stream|$FORM_conntrack_ip_conntrack_udp_timeout_stream
end_form

#################################################################
#               Protocol and Priority Menus                     #
#################################################################
start_form|@TR<<QOS Priority Configuration>>
field|@TR<<Priority>>
select|protocol|$FORM_type
option|ip|@TR<<IP>>
option|tcp|@TR<<TCP>>
option|udp|@TR<<UDP>>
option|layer7|@TR<<Layer 7 Filtering>>
select|priority|$FORM_priority
option|expr|@TR<<Express>>
option|prio|@TR<<Priority>>
option|bulk|@TR<<Bulk>>
end_form

#################################################################
#               Port Forms                                      #
#################################################################
#
# TODO: Port Ranges
#

start_form|@TR<<Express TCP Ports>>|tcp_expr_form|hidden
$tcp_expr
field|@TR<<Express TCP Port>>
text|tcp_expr0|$FORM_tcp_expr0
field|@TR<<Express TCP Port>>
text|tcp_expr1|$FORM_tcp_expr1
field|@TR<<Express TCP Port>>
text|tcp_expr2|$FORM_tcp_expr2
field|@TR<<Express TCP Port>>
text|tcp_expr3|$FORM_tcp_expr3
field|@TR<<Express TCP Port>>
text|tcp_expr4|$FORM_tcp_expr4
end_form

start_form|@TR<<Priority TCP Ports>>|tcp_prio_form|hidden
$tcp_prio
field|@TR<<Priority TCP Port>>
text|tcp_prio0|$FORM_tcp_prio0
field|@TR<<Priority TCP Port>>
text|tcp_prio1|$FORM_tcp_prio1
field|@TR<<Priority TCP Port>>
text|tcp_prio2|$FORM_tcp_prio2
field|@TR<<Priority TCP Port>>
text|tcp_prio3|$FORM_tcp_prio3
field|@TR<<Priority TCP Port>>
text|tcp_prio4|$FORM_tcp_prio4
end_form

start_form|@TR<<Bulk TCP Ports>>|tcp_bulk_form|hidden
$tcp_bulk
field|@TR<<Bulk TCP Port>>
text|tcp_bulk0|$FORM_tcp_bulk0
field|@TR<<Bulk TCP Port>>
text|tcp_bulk1|$FORM_tcp_bulk1
field|@TR<<Bulk TCP Port>>
text|tcp_bulk2|$FORM_tcp_bulk2
field|@TR<<Bulk TCP Port>>
text|tcp_bulk3|$FORM_tcp_bulk3
field|@TR<<Bulk TCP Port>>
text|tcp_bulk4|$FORM_tcp_bulk4
end_form

start_form|@TR<<Express UDP Ports>>|udp_expr_form|hidden
$udp_expr
field|@TR<<Express UDP Port>>
text|udp_expr0|$FORM_udp_expr0
field|@TR<<Express UDP Port>>
text|udp_expr1|$FORM_udp_expr1
field|@TR<<Express UDP Port>>
text|udp_expr2|$FORM_udp_expr2
field|@TR<<Express UDP Port>>
text|udp_expr3|$FORM_udp_expr3
field|@TR<<Express UDP Port>>
text|udp_expr4|$FORM_udp_expr4
end_form

start_form|@TR<<Priority UDP Ports>>|udp_prio_form|hidden
$udp_prio
field|@TR<<Priority UDP Port>>
text|udp_prio0|$FORM_udp_prio0
field|@TR<<Priority UDP Port>>
text|udp_prio1|$FORM_udp_prio1
field|@TR<<Priority UDP Port>>
text|udp_prio2|$FORM_udp_prio2
field|@TR<<Priority UDP Port>>
text|udp_prio3|$FORM_udp_prio3
field|@TR<<Priority UDP Port>>
text|udp_prio4|$FORM_udp_prio4
end_form

start_form|@TR<<Bulk UDP Ports>>|udp_bulk_form|hidden
$udp_bulk
field|@TR<<Bulk UDP Port>>
text|udp_bulk0|$FORM_udp_bulk0
field|@TR<<Bulk UDP Port>>
text|udp_bulk1|$FORM_udp_bulk1
field|@TR<<Bulk UDP Port>>
text|udp_bulk2|$FORM_udp_bulk2
field|@TR<<Bulk UDP Port>>
text|udp_bulk3|$FORM_udp_bulk3
field|@TR<<Bulk UDP Port>>
text|udp_bulk4|$FORM_udp_bulk4
end_form


#################################################################
#               IP Address Forms                                #
#################################################################
start_form|@TR<<QOS Express IP Addresses>>|ip_expr_form
$ip_expr
field|@TR<<Express IP Address>>
text|ip_expr0|$FORM_ip_expr0
field|@TR<<Express IP Address>>
text|ip_expr1|$FORM_ip_expr1
field|@TR<<Express IP Address>>
text|ip_expr2|$FORM_ip_expr2
field|@TR<<Express IP Address>>
text|ip_expr3|$FORM_ip_expr3
field|@TR<<Express IP Address>>
text|ip_expr4|$FORM_ip_expr4
end_form

start_form|@TR<<QOS Priority IP Addresses>>|ip_prio_form|hidden
$ip_prio
field|@TR<<Priority IP Address>>
text|ip_prio0|$FORM_ip_prio0
field|@TR<<Priority IP Address>>
text|ip_prio1|$FORM_ip_prio1
field|@TR<<Priority IP Address>>
text|ip_prio2|$FORM_ip_prio2
field|@TR<<Priority IP Address>>
text|ip_prio3|$FORM_ip_prio3
field|@TR<<Priority IP Address>>
text|ip_prio4|$FORM_ip_prio4
end_form

start_form|@TR<<QOS Bulk IP Addresses>>|ip_bulk_form|hidden
$ip_bulk
field|@TR<<Bulk IP Address>>
text|ip_bulk0|$FORM_ip_bulk0
field|@TR<<Bulk IP Address>>
text|ip_bulk1|$FORM_ip_bulk1
field|@TR<<Bulk IP Address>>
text|ip_bulk2|$FORM_ip_bulk2
field|@TR<<Bulk IP Address>>
text|ip_bulk3|$FORM_ip_bulk3
field|@TR<<Bulk IP Address>>
text|ip_bulk4|$FORM_ip_bulk4
end_form

#################################################################
#               Layer 7 Forms                                   #
#################################################################
start_form|@TR<<QOS Layer & Protocol Filtering>>|l7_form|hidden
field|@TR<<Layer 7 Protocols>>
$FORM_checkbox
end_form

EOF
