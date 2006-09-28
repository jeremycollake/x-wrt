#!/usr/bin/webif-page
<? 
. "/usr/lib/webif/webif.sh"
header "Status" "Status" "@TR<<Device Status>>" 
?>

<meta http-equiv="refresh" content="20">

<?

MEMINFO=$(free | sed 1,3d)
nI="0"
for CUR_VAR in $MEMINFO; do
	case "$nI" in
	  1) TOTAL_MEM=$CUR_VAR;;
	  3) FREE_MEM=$CUR_VAR
	  	break;;	  	
	esac		
	let "nI+=1"		
done

# todo: in progress crap
#CPU_UTIL=$(cpu -a | sed s/'CPU:'// | sed s/'average'// | sed s/'%'//)
#CPU_AVG_USE=$(expr substr "$CPU_UTIL" 0 2)
#echo $CPU_AVG_USE

USED_MEM=$(expr $TOTAL_MEM - $FREE_MEM)
MEM_PERCENT_FREE=$(expr $FREE_MEM "*" 100 / $TOTAL_MEM)
MEM_PERCENT_USED=$(expr 100 - $MEM_PERCENT_FREE)

#todo: if we're not going to use 'free' vars, remove from calculatin
ACTIVE_CONNECTIONS=$(cat "/proc/net/ip_conntrack" | wc -l)
MAX_CONNECTIONS=$(cat "/proc/sys/net/ipv4/netfilter/ip_conntrack_max")
FREE_CONNECTIONS=$(expr $MAX_CONNECTIONS - $ACTIVE_CONNECTIONS)
FREE_CONNECTIONS_PERCENT=$(expr $FREE_CONNECTIONS "*" 100 / $MAX_CONNECTIONS)
USED_CONNECTIONS_PERCENT=$(expr 100 - $FREE_CONNECTIONS_PERCENT)

# _loadavg should be set by the header code..
empty "$_loadavg" && {
	_loadavg="${_uptime#*load average: }"
	_uptime="${_uptime#*up }"
}

mounts_form=$(
df | awk 'BEGIN { mcount=0 }; 
	/\// {
	filled_caption=$5;				
	print "string|<tr><td><strong>"$6"</strong></td><td>"$1"</td></tr>"		
	print "progressbar|mount_" mcount "|&nbsp;&nbsp;" $3 "<div class=kb>KB</div> of " $2 "<div class=kb>KB</div>|200|" $5 "|" filled_caption "|"; mcount+=1
	print "string|<tr><td><br /></td></tr>"
	}'
	)
		

display_form <<EOF
start_form|Load Average
string|<tr><td><font size=+1 color="red">$_loadavg</font><tr><td>
end_form|
helpitem|Load Average
helptext|Helptext Load Average#The load average represents the average number of active processes during the past 1, 5, and 15 minutes. Generally speaking, >=3 is extremely high, >=2 is high, >=1 is moderate, and >=0 is low.
start_form|RAM Usage
string|<tr><td>Total: $TOTAL_MEM KB</td></tr>
progressbar|ramuse|Used: $USED_MEM KB ($MEM_PERCENT_USED%)|200|$MEM_PERCENT_USED|$MEM_PERCENT_USED%||
end_form|
start_form|Tracked Connections
string|<tr><td>Maximum: $MAX_CONNECTIONS</td></tr>
progressbar|conntrackuse|Used: $ACTIVE_CONNECTIONS ($USED_CONNECTIONS_PERCENT%)|200|$USED_CONNECTIONS_PERCENT|$USED_CONNECTIONS_PERCENT%||
end_form|
start_form|Mount Usage
$mounts_form
string|<tr><td><br /></td></tr>
end_form|
EOF
?>

<? footer ?>
<!--
##WEBIF:name:Status:1:Status
-->
