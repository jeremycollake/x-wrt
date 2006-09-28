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
	print "string|<tr><td><br /></td></tr>"	
	print "string|<tr><td><dl><dt><strong>"$6"</strong><div class=mount-target>@"$1"</div><dd>Usage: "$3 "<div class=kb>KB</div> of " $2 "<div class=kb>KB</div></dt></dd></dt></dl></tr>"	
	print "progressbar|mount_" mcount "||40%|" $5 "|" filled_caption "|"; mcount+=1}'
	)
		

display_form <<EOF
start_form|Basic Statistics
string|<tr><td><h3>Load Average</h3></td></tr>
string|<tr><td><font size=+1 color="red">$_loadavg</font><tr><td>
string|<tr><td><br /></td></tr>
helpitem|Load Average
helptext|Helptext Load Average#The load average represents the average number of active processes during the past 1, 5, and 15 minutes. Generally speaking, >=3 is extremely high, >=2 is high, >=1 is moderate, and >=0 is low.
string|<tr><td><h3>RAM Utilization</h3><tr><td>
string|<tr><td>Total: $TOTAL_MEM KB</td></tr>
string|<tr><td>Used: $USED_MEM KB ($MEM_PERCENT_USED%)</tr></td>
progressbar|ramuse||200|$MEM_PERCENT_USED|$MEM_PERCENT_USED%||
string|<tr><td><br /></td></tr>
string|<tr><td><h3>Tracked Connections</h3></td></tr>
string|<tr><td>Maximum: $MAX_CONNECTIONS</td></tr>
string|<tr><td>Used: $ACTIVE_CONNECTIONS ($USED_CONNECTIONS_PERCENT%)</td></tr>
progressbar|conntrackuse||200|$USED_CONNECTIONS_PERCENT|$USED_CONNECTIONS_PERCENT%||
string|<tr><td><br /></td></tr>
string|<tr><td><h3>Mounts</h3></td></tr
$mounts_form
string|<tr><td><br /></td></tr>
end_form|
EOF
?>

<? footer ?>
<!--
##WEBIF:name:Status:1:Status
-->
