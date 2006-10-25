#!/usr/bin/webif-page
<? 
	. "/usr/lib/webif/webif.sh"
	mini_header "Status" "Status" "@TR<<Device Status>>" ''

	MEMINFO=$(cat "/proc/meminfo")
	nI="0"
	for CUR_VAR in $MEMINFO; do
		case "$nI" in
		  18) TOTAL_MEM=$CUR_VAR;;
		  21) FREE_MEM=$CUR_VAR;;	  
		  23) break;;	   
		esac		
		let "nI+=1"		
	done

    	_firmware_name="$(nvram get firmware_name)"
	_version="$(nvram get firmware_version)"	
	_uptime="$(uptime)"
	_loadavg="${_uptime#*load average: }"
	_uptime="${_uptime#*up }"
	_uptime="${_uptime%%,*}"
	_hostname=$(cat /proc/sys/kernel/hostname)		

	USED_MEM=$(expr $TOTAL_MEM - $FREE_MEM)
	MEM_PERCENT_FREE=$(expr $FREE_MEM "*" 100 / $TOTAL_MEM)
	MEM_PERCENT_USED=$(expr 100 - $MEM_PERCENT_FREE)

?>
<meta http-equiv="refresh" content="15">

<body ><div id="short-status">
	<ul>
		<li><strong> <? echo -n $_firmware_name ?> <? echo -n $_version ?>  </strong>
		<li><strong>- Host:</strong> <? echo -n $_hostname ?> 
		<li><strong>- Uptime:</strong> <? echo -n $_uptime ?>
		<li><strong>- Load:</strong> <? echo -n $_loadavg ?>
		<li><strong>- Mem:</strong> <? echo -n $FREE_MEM ?> KB free - <? echo -n $MEM_PERCENT_USED  ?>% used 
	</ul>
	</div>
</body>
</html>
